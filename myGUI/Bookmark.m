classdef Bookmark < SystemFunc.UItemplate
% Class to manage Bookmark ( including GUI support).
%
% <usage>
%       >> Bookmark;    % Launch GUI to manage Bookmarks
%
% <static method>
%       >> Bookmark.add(name,path)  % Add bookmark data with the name specified in "name"
%       >> Bookmark.remove(idx)     % Delete idx-th bookmark data
%
    
    %%%%%%%%%%% Properties %%%%%%%%%%%
    properties(Access=protected)
        ConfigFieldName = 'Bookmark';
    end

    %%%%%%%%%%%%%%%%% Callback %%%%%%%%%%%%%%%%%
    methods(Access=protected)

        % Function to chage directory
        function PushListBox(obj, ~, ~)
            idx = obj.uilist.ValueIndex;
            cd(obj.Data(idx).path)
        end
    end


    %%%%%%%%%%%% Add/Remove bookmark %%%%%%%%%%%%
    methods(Static)
        function add(name,path)
            arguments
                name = inputdlg("Input Bookmark Name");
                path = uigetdir;
            end

            % Update bookmark list
            new = struct('name',name,'path',path);
            data = SystemFunc.config('Bookmark');
            if isempty(data); data = new;
            else; data = [data(:);new];
            end
            SystemFunc.setconfig(data,'Bookmark');
        end

        function remove(idx)
            data = SystemFunc.config('Bookmark');
            data(idx) = [];
            SystemFunc.setconfig(data,'Bookmark');
        end
    end

end