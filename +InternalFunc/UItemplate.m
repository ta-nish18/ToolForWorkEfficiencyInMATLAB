classdef UItemplate < handle
    properties
        Position
    end

    properties(Access=protected)
        uifig
        uilist
    end

    properties(Abstract, Access=protected)
        ConfigPath
    end

    methods
        function obj = UItemplate()
            obj.CreateComponent

            % Completion in the case of missing config file
            if ~isfile(obj.ConfigPath)
                data = [];
                save(obj.ConfigPath,'data')
            end
        end

    end

    %%%%%%%%%%%%%%%%% Callback Requirements %%%%%%%%%%%%%%%%%
    methods(Abstract, Access=protected)
        % Function to add a folder to the bookmarks
        PushAddButton(obj, src, event)
        % Function to remove a folder from the bookmarks
        PushRemoveButton(obj, src, event)
        % Function to chage directory
        PushListBox(obj, src, event)
    end


    %%%%%%%%%%%%%%%%%%%%%%% build component %%%%%%%%%%%%%%%%%%%%%%%
    methods(Access=protected)
        function CreateComponent(obj)
            uiclose(class(obj))

            % Create UI figure
            obj.uifig = uifigure('Name', class(obj), 'Position', [100 100 215 350]);
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


    %%%%%%%%%%%%%% Set/Get method %%%%%%%%%%%%%%
    methods
        function set.Position(obj,val)
            obj.uifig.Position = val; %#ok
        end

        function val = get.Position(obj)
            val = obj.uifig.Position;
        end
    end

end

% dammy Coallback Function
    function nofunc(src,event)%#ok
    end