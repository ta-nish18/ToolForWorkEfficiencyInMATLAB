classdef figProcessor < handle
    properties
        figure
        SavePath  = 0;

        defaultFigFileName = "Fig"+string(datetime("now","Format","yyMMDD"));
        defaultGifFileName = "Gif"+string(datetime("now","Format","yyMMDD"));
        defaultFigExtension = {'fig','eps','png'};
    end

    properties(Access=protected)
        GifName   = [];
        GifFlag   = 'done'; % {'init',[],'done'}
    end

    methods
        function obj = figProcessor(varargin)

            disp('Choose Save Folder')
            path = uigetdir;
            if path
                obj.SavePath = path;
            end

            if ~obj.SavePath
                error('Path is not selected')
            end

            if nargin>0 && isa(varargin{1},'matlab.ui.Figure')
                obj.figure = varargin{1};
            else
                obj.figure   = figure( varargin{:} );
            end

        end

        %%%%%%%%%%%%%%% save figure as GIF %%%%%%%%%%%%%%%

        function getframe(obj,flag,filename)
            arguments
                obj
                flag {mustBeMember(flag,["init","done","progress",[]])} = 'progress'
                filename {mustBeText} = obj.defaultGifFileName
            end
            
            switch flag
                case 'init'     % gifのの１枚目作成の場合はimwriteへのoptionはなし
                    name = obj.GenerateFilename('gif','FileName',filename);                    
                    obj.GifName = name{1};
                    obj.GifFlag = flag;
                    return
                case 'done'     % GifFlagが"終了(done)"になっている場合はrecordGifを実行する
                    obj.GifFlag = flag;
                    return
                case 'progress' % gifのの２枚目以降の場合はimwriteのoptionとして'append'を指定
                    switch obj.GifFlag
                        case 'done'
                            obj.getframe('init',filename)
                            return
                        case 'init'
                            opt = {};
                            obj.GifFlag = 'progress';
                        case 'progress'
                            opt = {'WriteMode','append'};
                    end
            end
            drawnow
            pause(0.001)
            F = getframe(obj.figure);
            [X,map] = rgb2ind(F.cdata,256);
            imwrite(X,map,obj.GifName,opt{:});
        end


        %%%%%%%%%%%%%%% save figure as picture %%%%%%%%%%%%%%%
        function save(obj, varargin)
            filepath = obj.GenerateFilename('fig',varargin{:});
            cellfun(@(name) saveas(obj.figure, name), filepath);
        end



        %%%%%%%%%%%%%%%%% Set Method %%%%%%%%%%%%%%%%%
        function set.SavePath(obj,path)
            obj.SavePath = check_SavePath(path);
        end
        function set.defaultFigExtension(obj,ext)
            obj.defaultFigExtension = check_extension(ext);
        end
        function set.defaultFigFileName(obj,name)
            obj.defaultFigFileName = check_FileName(name);
        end
        function set.defaultGifFileName(obj,name)
            obj.defaultGifFileName = check_FileName(name);
        end
    end


    methods(Access=protected)
        function filepath = GenerateFilename(obj,mode,varargin)
        % default parameter
            p = inputParser;
            p.CaseSensitive = false;
            addParameter(p, 'SavePath' , obj.SavePath );
            switch mode
                case 'fig'
                    addParameter(p, 'FileName' , obj.defaultFigFileName );
                    addParameter(p, 'extension', obj.defaultFigExtension);
                case 'gif'
                    addParameter(p, 'FileName' , obj.defaultGifFileName );
                    addParameter(p, 'extension', {'gif'} );
            end
            parse(p, varargin{:});
            opt = p.Results;

        % Check Parameter
            if nargin>2
                opt.extension = check_extension( opt.extension );
                opt.SavePath  = check_SavePath(  opt.SavePath  );
            end

        % Check for duplicate file names

            Tab = struct2table(dir(opt.SavePath));
            [~,ExistFile(:),~] = cellfun(@(n) fileparts(n), Tab.name(~Tab.isdir), 'UniformOutput',false);

            cnt = 1;
            tempname = opt.FileName;

            while ismember(tempname,ExistFile)
                tempname = opt.FileName+"("+cnt+")";
                cnt = cnt+1;
            end

        % export filepath
            filename = fullfile(opt.SavePath,tempname);
            filepath = cellfun(@(ext) filename+"."+ext, opt.extension, 'UniformOutput',false);
        end
    end
end



function ext = check_extension(ext)
    format_list = {'fig','m','jpg','png','eps','pdf','tif','gif'};
    if ( isstring(ext) || ischar(ext) ) && ismember(ext,format_list)
        ext = {string(ext)};
    elseif iscell(ext)
        idx = ismember(ext,format_list);
        cellfun(@(c) disp(['  >> 除外されました：',char(c)]), ext(~idx))
        ext = ext(idx);
    end
end

function path = check_SavePath(path)
    if isempty(path)
        path = uigetdir;
    end
    
    if ~isfolder(path)
        error('It is not folder.')
    end
end

