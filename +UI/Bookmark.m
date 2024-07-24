classdef Bookmark < handle
    properties
        Position
    end
    
    properties(SetAccess=protected)
        bookmarks
    end

    properties(Access=protected)
        pathdata

        uifig
        uilist
    end

    methods
        function obj = Bookmark()
            obj.CreateComponent

            val = load(getConfigPath());
            obj.bookmarks = val.pathdata;
        end
        
        function set.bookmarks(obj,pathdata)
            if isempty(pathdata)
                Items = {};
            else
                Items = arrayfun(@(i) string(pathdata(i).name), 1:numel(pathdata));
            end
            obj.uilist.Items = Items; %#ok
            obj.bookmarks = pathdata;
            save(getConfigPath,'pathdata');
        end

        function set.Position(obj,val)
            obj.uifig.Position = val; %#ok
        end

        function val = get.Position(obj)
            val = obj.uifig.Position;
        end

    end


    %%%%%%%%%%%%%%%%% Callback %%%%%%%%%%%%%%%%%
    methods(Access=protected)

         % Function to add a folder to the bookmarks
         function PushAddButton(obj, ~, ~)
            path = uigetdir;
            name = inputdlg("Input Bookmark Name");
            data = struct('path',path,'name',name);
            if isempty(obj.bookmarks)
                obj.bookmarks = data;
            else
                obj.bookmarks(end+1) = data;
            end
         end

        % Function to remove a folder from the bookmarks
        function PushRemoveButton(obj, ~, ~)
            if ~isempty(obj.uilist.ValueIndex)
                word = ["Remove Bookmark?"," >> "+string(obj.uilist.Value)];
                flag = questdlg( word,"Confirm Remove", 'Yes','No','Yes');
                if strcmp(flag,'Yes')
                    obj.bookmarks(obj.uilist.ValueIndex) = [];
                end
            end
        end

        % Function to chage directory
        function PushListBox(obj, ~, ~)
            idx = obj.uilist.ValueIndex;
            cd(obj.bookmarks(idx).path)
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%% build component %%%%%%%%%%%%%%%%%%%%%%%
    methods(Access=protected)
        function CreateComponent(obj)
            % Create UI figure
            obj.uifig = uifigure('Name', 'Bookmark Manager', 'Position', [100 100 215 350]);
            uigrid = uigridlayout(obj.uifig,[2,2]);
            uigrid.RowHeight   = {'1x',20};
            uigrid.ColumnWidth = {'1x','1x'};

            % Create ListBox to display bookmarks
            obj.uilist = uilistbox(uigrid);
            obj.uilist.Layout.Row    = 1;
            obj.uilist.Layout.Column = [1,2];
            obj.uilist.DoubleClickedFcn = @(src, event) obj.PushListBox(src, event);

            % Create Add buttons
            btnAdd = uibutton(uigrid, 'push', 'Text', 'Add');
            btnAdd.Layout.Row = 2; 
            btnAdd.Layout.Column = 1;
            btnAdd.ButtonPushedFcn    = @(src, event) obj.PushAddButton(src, event);
            
            % Create Remove buttons
            btnRemove = uibutton(uigrid, 'push', 'Text', 'Remove');
            btnRemove.Layout.Row = 2;
            btnRemove.Layout.Column = 2;
            btnRemove.ButtonPushedFcn = @(src, event) obj.PushRemoveButton(src, event);
        end
    end
end


function val = getConfigPath()
    fpath = fileparts(mfilename('fullpath'));
    dpath = fpath(1:find(fpath==filesep,1,'last')-1);
    val = fullfile(dpath,'config','BookmarkList.mat');
    if ~isfile(val)
        pathdata = [];
        save(val,'pathdata')
    end
end