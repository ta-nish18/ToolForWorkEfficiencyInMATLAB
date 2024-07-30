classdef figCamera < handle
% Class for saving a figure as an image file. ( including GUI support).
%
% <usage>
%       >> figCamera;    % Launch GUI to manage Bookmarks
%
% <static method>
%       >> figCamera.capture(filename)  % Add bookmark data with the name specified in "name"
%       >> figCamera.setExtension(ext)  % Update list of extensions to save.(Without argument, GUI is launched)
%       >> figCamera.setPath(folder)    % Update save path. (Without argument, GUI is launched)
%

    properties(Dependent)
        FileName
        Extension
        SavePath
        Position
    end

    properties(Access=protected)
        uifig
        uigrid
        uiCapture

        uiTextFolder
        uiFolderIcon

        uiExtensionIcon
        uiTextExtension
        uiFileName
    end

    methods
        function obj = figCamera()
            obj.createComponent;
            obj.refresh
        end

        %%%%%%%% Function to refresh Item in uifigure %%%%%%%%
        function refresh(obj)
            data = SystemFunc.config('figCamera');
            
            if strcmp(data.SavePath,'pwd')
                Path = pwd;
            elseif isfolder(data.SavePath)
                Path = data.SavePath;
            else
                error(data.SavePath+" : Not a valid path")
            end
            
            ext = data.Extension;
            txt = [ext(:)' ; [repmat(", ",1,numel(ext)-1),""]];

            obj.uiTextFolder.Text        = Path;
            obj.uiTextExtension.UserData = ext;
            obj.uiTextExtension.Text     = horzcat(txt{:});
        end
        
        %%% Set/Get Method %%%
        function val = get.Position(obj);  val = obj.uifig.Position;           end
        function val = get.FileName(obj);  val = obj.uiFileName.Value;         end
        function val = get.SavePath(obj);  val = obj.uiTextFolder.Text;        end
        function val = get.Extension(obj); val = obj.uiTextExtension.UserData; end
        function set.Position(obj,val);    obj.uifig.Position = val;           end
    end

    %%%%%%%%%%%%%%%%%%%%%%% build component %%%%%%%%%%%%%%%%%%%%%%%
    methods(Access=protected)
        function createComponent(obj)

            %%% create
            obj.uifig  = uifigure('Name','Figure Capture','Position',[500,500,215,200]);
            obj.uigrid = uigridlayout(obj.uifig,[4 3]);

            impath = SystemFunc.getpath('+SystemConfig','image');
            obj.uiCapture = uibutton(obj.uigrid, ...
                              'Text'    ,'capture',...
                              'FontSize',18,...
                              'Icon'    ,fullfile(impath,'camera.png'),...
                              'IconAlignment','top',...
                              'BackgroundColor',[0.8,0.8,0.8],...
                              "ButtonPushedFcn", @(src,event) obj.capture(obj.uiFileName.Value)...
                               );
            
            obj.uiFolderIcon  = uibutton(obj.uigrid, ...
                              'Text','',...
                              'Icon'    ,fullfile(impath,'folder.png'),...
                              'IconAlignment','center',...
                              'BackgroundColor',[0.9,0.9,0.9],...
                              "ButtonPushedFcn", @(src,event) obj.setPath...
                               );
            
            obj.uiExtensionIcon = uibutton(obj.uigrid, ...
                              'Text','',...
                              'Icon'    ,fullfile(impath,'setting.png'),...
                              'IconAlignment','center',...
                              'BackgroundColor',[0.9,0.9,0.9],...
                              "ButtonPushedFcn", @(src,event) obj.setExtension([],obj)...
                               );

            obj.uiFileName     = uitextarea(obj.uigrid);
            obj.uiTextFolder   = uilabel(obj.uigrid,'FontSize',8);
            obj.uiTextExtension= uilabel(obj.uigrid,'FontSize',8);
            
            obj.uiFileName.Value = ['Fig',char(datetime("now","Format","yyMMddHHmmss"))];

            tag_file = uilabel(obj.uigrid,'Text','Name','FontSize',6);
            tag_dir  = uilabel(obj.uigrid,'Text','Path','FontSize',6);
            tag_ext  = uilabel(obj.uigrid,'Text','Ext' ,'FontSize',6);

            %%%% UI LAYOUT
            obj.uigrid.RowHeight   = {80,'1x','1x','1x'};
            obj.uigrid.ColumnWidth = {28,'1x',20};

                                         % Caputure Botton
                                         obj.uiCapture.Layout.Row      = 1;
                                         obj.uiCapture.Layout.Column   = [1,3];

            % Tag "Name"                 % textarea >> file name
            tag_file.Layout.Row   = 2;   obj.uiFileName.Layout.Row     = 2;
            tag_file.Layout.Column= 1;   obj.uiFileName.Layout.Column  = 2;

            % Tag "Path"                 % textarea >> save path                % Folder Icon
            tag_dir.Layout.Row    = 3;   obj.uiTextFolder.Layout.Row   = 3;     obj.uiFolderIcon.Layout.Row   = 3;
            tag_dir.Layout.Column = 1;   obj.uiTextFolder.Layout.Column= 2;     obj.uiFolderIcon.Layout.Column= 3;

            % Tag ".ext"                 % choice >> extension
            tag_ext.Layout.Row    = 4;   obj.uiTextExtension.Layout.Row   = 4;  obj.uiExtensionIcon.Layout.Row   = 4;
            tag_ext.Layout.Column = 1;   obj.uiTextExtension.Layout.Column= 2;  obj.uiExtensionIcon.Layout.Column= 3;
        end
    end



    methods(Static)

        function setPath(val)
            if nargin==0 || isempty(val)
                val = uigetdir;
                if ~val; error('Select Save Folder'); end
            elseif ~isfolder(val)
                error('It is not Folder')
            end
            SystemFunc.setconfig(val,'figCamera','SavePath')
        end

        function setExtension(ext,cls)
            arguments
                ext = [];
                cls = struct('refresh',[]); % Dammy class which has "refresh" method.
            end

            if isempty(ext)
                selectUI_forExtension(@Callback)
            else
                Callback(ext)
            end

            % Define Callback Function
            function Callback(ext)

                if isstring(ext)
                    ext = cellfun(@(c) c, ext, 'UniformOutput',false);
                elseif ischar(ext)
                    ext = {ext};
                elseif ~iscell(ext)
                    error('Format is wrong')
                end

                idx = ismember(ext, {'jpeg','png','tiff','tiffn','meta','pdf','eps','epsc','eps2','epsc2','meta','svg','fig'});
                cellfun(@(c) disp(['  >> removed:',c]), ext(~idx));
                ext = ext(idx);
                
                if sum(ismember(ext,{'tiff','tiffn'}))>1
                    warning('Both "tiff" and "tiffn" are saved with a .tif extension.')
                end

                idx = ismember(ext,{'eps','epsc','eps2','epsc2'});
                if sum(idx)>1
                    exts = cellfun(@(c) ['"',c,'" '],ext(idx),'UniformOutput',false);
                    warning([horzcat(exts{:}),'are all saved with .eps extension.'])
                end

                SystemFunc.setconfig(string(ext),'figCamera','Extension');
                cls.refresh;
            end
        end


        function capture(filename)
            arguments
                filename = 'date'
            end
            disp('Saving...')
            data = SystemFunc.config('figCamera');
            
            % Format filename
            switch string(filename)
                case "date";    filename = ['Fig',char(datetime("now","Format","yyMMddHHmmss"))];
                case "cmd";     filename = input('File Name : ','s');
                case "dlg";     filename = inputdlg("Input file name");
            end

            % Check for overlapping file names in the selected folder
            if strcmp(data.SavePath,'pwd'); data.SavePath = pwd; end
            Tab  = struct2table(dir(data.SavePath));
            [~,ExistFile(:),~] = cellfun(@(n) fileparts(n), Tab.name(~Tab.isdir), 'UniformOutput',false);
            cnt = 1;
            tempname = filename;
            while ismember(tempname,ExistFile)
                tempname = filename{1}+"("+cnt+")";
                cnt = cnt+1;
            end

            % Save figure
            f = gcf;
            filepath = fullfile(char(data.SavePath),char(tempname));
            cellfun(@(e) saveas(f,filepath,e), data.Extension)

            disp("Save Figure at "+filepath)
        end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UI APP for set extension %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function selectUI_forExtension(Callback)
    data = SystemFunc.config('figCamera');

    % build uifigure
    fig = uifigure('Name','Extension Setting');
    fig.Position([3,4]) = [500,350];
    grd = uigridlayout(fig,[2 2]);

    % load Exttension Table
        extTab = readtable(SystemFunc.getpath('+SystemConfig','FigExtension.csv'));
        if ~isempty(data.Extension)
            extTab.set = ismember(extTab.val,data.Extension);
        else  
            extTab.set = logical(extTab.set);
        end

    % uitableの設定
        tab = uitable(grd,"Data",extTab,'ColumnWidth',{'fit',40,55,'1x'});
        tab.ColumnEditable = [true,false,false,false];

    % ui buttonの設定
        bot = uibutton(grd,'Text','Save','BackgroundColor',[0.8,0.8,0.8],...
                          "ButtonPushedFcn", @(src,enent) SaveFcn(src));

    grd.RowHeight   = {'1x',35};
    grd.ColumnWidth = {'1x',100};

    tab.Layout.Row      = 1;
    tab.Layout.Column   = [1,2];

    bot.Layout.Row      = 2;
    bot.Layout.Column   = 2;

    function SaveFcn(src)
        Tab = src.Parent.Children(1).Data;
        Callback(Tab.val(Tab.set));
        delete(src.Parent.Parent)
    end
end


