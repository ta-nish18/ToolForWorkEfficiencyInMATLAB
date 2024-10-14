classdef WorkspaceStash < SystemFunc.UItemplate
% Class to manage workspace data ( including GUI support).
%
% <usage>
%       >> WorkspaceStash;      % Launch GUI to manage workspace stash.
%
% <static method>
%       >> WorkspaceStash.add(name)     % Add stash data with the name specified in "name"
%       >> WorkspaceStash.remove(idx)   % Delete idx-th stash data
%
    

    %%%%%%%%%%% Properties %%%%%%%%%%%
    properties(Access=protected)
        ConfigFieldName = 'WorkspaceStash';
    end

    %%%%%%%%%%%%%%%%% Callback %%%%%%%%%%%%%%%%%
    methods(Access=protected)

        % Function to chage directory
        function PushListBox(obj, ~, ~)
            data = obj.Data(obj.uilist.ValueIndex);
            cd(data.path)
            if ~isempty(data.prj)
                prj = fullfile(char(data.prj.RootFolder), [char(data.prj.Name),'.prj']);
                openProject(prj); 
            end
            tempVars = load(data.file);
            varNames = fieldnames(tempVars);
            cellfun(@(n) assignin('base', n, tempVars.(n)), varNames);
        end
    end

    %%%%%%%%%%%%%%% Add/Remove stash data %%%%%%%%%%%%%%%
    methods(Static)
        function add(name)
            if nargin==0
                name = inputdlg("Input Stash Name");
            end
        
            % save variables
            datename = ['Data',char(datetime('now','Format','yyyyMMddHHmmss')),'.mat'];
            filename = SystemFunc.getpath('+SystemConfig','stash',datename);
            vars = evalin('base', 'who');
            idx = cellfun(@(c) evalin('base',['isa(',c,',"WorkspaceStash")']), vars);
            vars(idx) = [];
            evalin('base', ['save(''' filename ''', ''' strjoin(vars, ''', ''') ''')']);
            

            % Update stash data
            try 
                prj = currentProject;
            catch
                prj = [];
            end
            new = struct('name',name,'path',pwd,'file',filename,'prj',prj);
            data = SystemFunc.config('WorkspaceStash');
            if isempty(data); data = new;
            else; data = [data,new];
            end
            SystemFunc.setconfig(data,'WorkspaceStash');
        end

        function remove(idx)
            data = SystemFunc.config('WorkspaceStash');
            delete(data(idx).file);
            data(idx) = [];
            SystemFunc.setconfig(data,'WorkspaceStash');
        end
    end

end
