classdef figCapture < handle
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
        function obj = figCapture()
            obj.createComponent;
            
            obj.FileName = [];
            obj.SavePath = pwd;
            obj.Extension = {'png','eps','fig'};
        end

        %%%%%%%%%%%%%%%%%%
        %%% Set Method %%%
        %%%%%%%%%%%%%%%%%%
        function set.SavePath(obj,val)
            if isempty(val)
                val = uigetdir;
                if ~val; error('Select Save Folder'); end
            elseif ~isfolder(val)
                error('It is not Folder')
            end
            obj.uiTextFolder.Text = val;
        end

        function set.FileName(obj,val)
            if isempty(val)
                val = "Fig"+string(datetime('today','Format','yyMMdd'));
            end
            obj.uiFileName.Value = val;
        end

        function set.Position(obj,val)
            obj.uifig.Position = val;
        end

        function set.Extension(obj,val)
            if isempty(val)
                obj.setterExtension();
                return
            elseif isstring(val)
                val = arrayfun(@(i) {char(val(i))}, 1:numel(val),'UniformOutput',false);
            elseif ischar(val)
                val = {val};
            elseif iscell(val)
                val = cellfun(@(c) char(c), val, 'UniformOutput',false);
            else
                error('Format is wrong')
            end
            idx = ismember(val, {'jpeg','png','tiff','tiffn','meta','pdf','eps','epsc','eps2','epsc2','meta','svg','fig'});
            cellfun(@(c) disp(['  >> removed:',c]), val(~idx));
            val = val(idx);
            if sum(ismember(val,{'tiff','tiffn'}))>1
                warning('"tiff"と"tiffn"はどちらも.tif拡張子で保存されるため、いずれか１つを選択してください。')
            end
            if sum(ismember(val,{'eps','epsc','eps2','epsc2'}))>1
                warning('"eps","epsc","eps2","epsc2"はいずれも.eps拡張子で保存されるため、いずれか１つを選択してください。')
            end
            text = cell(2,numel(val));
            text(1,:) = val;
            text(2,:) = {', '};
            text(end) = {''};
            obj.uiTextExtension.Text = horzcat(text{:});
            obj.uiTextExtension.UserData  = val;
        end
        
        %%%%%%%%%%%%%%%%%%
        %%% Get Method %%%
        %%%%%%%%%%%%%%%%%%
        function val = get.Position(obj);  val = obj.uifig.Position;           end
        function val = get.FileName(obj);  val = obj.uiFileName.Value;         end
        function val = get.SavePath(obj);  val = obj.uiTextFolder.Text;        end
        function val = get.Extension(obj); val = obj.uiTextExtension.UserData; end
    end

    %%%%%%%%%%%%%%%%%%%%%%% build component %%%%%%%%%%%%%%%%%%%%%%%
    methods(Access=protected)
        function createComponent(obj)

            %%% create
            obj.uifig  = uifigure('Name','Figure Capture','Position',[500,500,215,200]);
            obj.uigrid = uigridlayout(obj.uifig,[4 3]);

            impath = InternalFunc.getpath('+InternalConfig','image');
            obj.uiCapture = uibutton(obj.uigrid, ...
                              'Text'    ,'capture',...
                              'FontSize',18,...
                              'Icon'    ,fullfile(impath,'camera.png'),...
                              'IconAlignment','top',...
                              'BackgroundColor',[0.8,0.8,0.8],...
                              "ButtonPushedFcn", @(src,event) obj.capture...
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
                              "ButtonPushedFcn", @(src,event) obj.setExtenstion...
                               );

            obj.uiFileName     = uitextarea(obj.uigrid);
            obj.uiTextFolder   = uilabel(obj.uigrid,'FontSize',8);
            obj.uiTextExtension= uilabel(obj.uigrid,'FontSize',8);
            
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

    %%%%%%%%%%%%%%%% Callback Function %%%%%%%%%%%%%%%%
    methods(Access=protected)

        function capture(obj)
            disp('Saving...')
            Tab = struct2table(dir(obj.SavePath));
            [~,ExistFile(:),~] = cellfun(@(n) fileparts(n), Tab.name(~Tab.isdir), 'UniformOutput',false);
            cnt = 1;
            tempname = obj.FileName{1};
            while ismember(tempname,ExistFile)
                tempname = obj.FileName{1}+"("+cnt+")";
                cnt = cnt+1;
            end
            f = gcf;
            filepath = fullfile(obj.SavePath,tempname);
            cellfun(@(e) saveas(f,filepath,e), obj.Extension)
            disp("Save Figure at "+filepath)
        end

        function setPath(obj)
            obj.SavePath = [];
        end

        function setExtenstion(obj)
            obj.Extension = [];
        end
    end


    methods(Access=protected)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UI APP for set extension %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setterExtension(obj)
            fig = uifigure('Name','Extension Setting','Position',[obj.uifig.Position(1:2),500,350]);
            grd = uigridlayout(fig,[2 2]);

            % tableの読み込み
                tabpath = fileparts(mfilename('fullpath'));
                tabpath = tabpath(1:find(tabpath==filesep,1,'last')-1);
                data = readtable(fullfile(tabpath,'+InternalConfig','FigExtension.csv'));
                if ~isempty(obj.Extension)
                    data.set = ismember(data.val,obj.Extension);
                else  
                    data.set = logical(data.set);
                end

            % uitableの設定
                tab = uitable(grd,"Data",data,'ColumnWidth',{'fit',40,55,'1x'});
                tab.ColumnEditable = [true,false,false,false];

            % ui buttonの設定
                bot = uibutton(grd,'Text','Save','BackgroundColor',[0.8,0.8,0.8],...
                                  "ButtonPushedFcn", @(src,event) SaveFcn(fig,tab,obj));

            grd.RowHeight   = {'1x',35};
            grd.ColumnWidth = {'1x',100};

            tab.Layout.Row      = 1;
            tab.Layout.Column   = [1,2];

            bot.Layout.Row      = 2;
            bot.Layout.Column   = 2;

            function SaveFcn(fig,tab,cls)
                cls.Extension = tab.Data.val(tab.Data.set);
                delete(fig)
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end
end

