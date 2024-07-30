function startup()
    List = {'myCLASS','myFUNCTION','myGUI'};
    cellfun(@(DIR) addpath(SystemFunc.getpath(DIR)), List)

    set = SystemFunc.config('startup');

% Launch Bookmark management application at startup
    if set.Bookmark
        Bookmark; 
    end

% Launch Workspace Stash management application at startup
    if set.WorkspaceStash
        WorkspaceStash;
    end

% Launch Caputuring Figure application at startup
    if set.figCapture
        figCapture;
    end

% Send LINE when matlab launched
    if set.sendLINE
        msg = char(datetime('now','Format','uuuu/MM/dd HH:mm:ss'));
        MessageManager.send_LINE(['(',msg,')',newline,' >> startup!!'])
    end
    
end