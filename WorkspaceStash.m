classdef WorkspaceStash < InternalFunc.UItemplate
    
    %%%%%%%%%%% Properties %%%%%%%%%%%
    properties(SetAccess=protected)
        stashdata
    end

    properties(Access=protected)
        ConfigPath = InternalFunc.getpath('+InternalConfig','ListWorkspaceStash.mat')
    end

    %%%%%%%%%%% Constructor %%%%%%%%%%%
    methods
        function obj = WorkspaceStash()
            val = load(obj.ConfigPath);
            obj.stashdata = val.data;
        end
    end

    %%%%%%%%%%% Get/Set methods %%%%%%%%%%%
    methods
        function set.stashdata(obj,data)
            if isempty(data)
                 obj.uilist.Items = {};
            else
                obj.uilist.Items = arrayfun(@(i) string(data(i).name), 1:numel(data));
            end
            obj.stashdata = data;
            save(obj.ConfigPath,'data');%#ok
        end
    end

    %%%%%%%%%%%%%%%%% Callback %%%%%%%%%%%%%%%%%
    methods(Access=protected)

         % Function to add a folder to the bookmarks
         function PushAddButton(obj, ~, ~)
            name = inputdlg("Input Stash Name");
            
                %%% save variables %%%
                datename = ['Data',char(datetime('now','Format','yyyyMMddHHmmss')),'.mat'];
                filename = InternalFunc.getpath('+InternalConfig','stash',datename);
                vars = evalin('base', 'who');
                idx = cellfun(@(c) evalin('base',['isa(',c,',''',class(obj),''')']), vars);
                vars(idx) = [];
                evalin('base', ['save(''' filename ''', ''' strjoin(vars, ''', ''') ''')']);
                %%%%%%%%%%%%%%%%%%%%%%

            data = struct('path',pwd,'name',name,'StashFile',filename);
            if isempty(obj.stashdata)
                obj.stashdata = data;
            else
                obj.stashdata(end+1) = data;
            end
         end

        % Function to remove a folder from the bookmarks
        function PushRemoveButton(obj, ~, ~)
            idx = obj.uilist.ValueIndex;
            if ~isempty(idx)
                delete(obj.stashdata(idx).StashFile);
                obj.stashdata(idx) = [];
            end
        end

        % Function to chage directory
        function PushListBox(obj, ~, ~)
            data = obj.stashdata(obj.uilist.ValueIndex);
            tempVars = load(data.StashFile);
            varNames = fieldnames(tempVars);
            cellfun(@(n) assignin('base', n, tempVars.(n)), varNames);
            cd(data.path)
        end
    end
end
