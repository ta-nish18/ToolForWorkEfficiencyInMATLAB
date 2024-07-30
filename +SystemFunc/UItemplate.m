classdef UItemplate < handle
    properties
        Position
    end

    properties(Dependent)
        Data
    end

    properties(Access=protected)
        uifig
        uilist
    end

    properties(Abstract,Access=protected)
        ConfigFieldName
    end

    methods
        function obj = UItemplate()
            obj.CreateComponent
            obj.refresh
        end

    end

    %%%%%%%%%%%%%%%%% Callback Requirements %%%%%%%%%%%%%%%%%
    methods(Abstract, Access=protected)
        % Processing when an item is double-clicked
        PushListBox(obj, src, event)
    end

    methods
        % Function to add a folder to the bookmarks
        function PushAddButton(obj, src, event)%#ok
             obj.add
             obj.refresh
         end

        % Function to remove a folder from the bookmarks
        function PushRemoveButton(obj, src, event)%#ok
            idx = obj.uilist.ValueIndex;
            if ~isempty(idx)
                obj.remove(idx);
                obj.refresh
            end
        end

        % Function to refresh item list
        function refresh(obj)
            data = obj.Data;
            if isempty(data)
                 obj.uilist.Items = {};
            else
                obj.uilist.Items = arrayfun(@(i) string(data(i).name), 1:numel(data));
            end
        end
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
            obj.uilist.ValueChangedFcn  = @(src, event) obj.refresh;

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

        function val = get.Data(obj)
            val = SystemFunc.config(obj.ConfigFieldName);
        end
    end

end

% dammy Coallback Function
    function nofunc(src,event)%#ok
    end