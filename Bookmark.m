classdef Bookmark < InternalFunc.UItemplate
    
    %%%%%%%%%%% Properties %%%%%%%%%%%
    properties(SetAccess=protected)
        bookmarks
    end

    properties(Access=protected)
        ConfigPath = InternalFunc.getpath('+InternalConfig','ListBookmark.mat')
    end

    %%%%%%%%%%% Constructor %%%%%%%%%%%
    methods
        function obj = Bookmark()
            val = load(obj.ConfigPath);
            obj.bookmarks = val.data;
        end
    end

    %%%%%%%%%%% Get/Set methods %%%%%%%%%%%
    methods
        function set.bookmarks(obj,data)
            if isempty(data)
                 obj.uilist.Items = {};
            else
                obj.uilist.Items = arrayfun(@(i) string(data(i).name), 1:numel(data));
            end
            obj.bookmarks = data;
            save(obj.ConfigPath,'data');%#ok
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
                obj.bookmarks(obj.uilist.ValueIndex) = [];
            end
        end

        % Function to chage directory
        function PushListBox(obj, ~, ~)
            idx = obj.uilist.ValueIndex;
            cd(obj.bookmarks(idx).path)
        end
    end
end