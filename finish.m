function finish()
    set = SystemFunc.config('finish');
    DATE = char(datetime('now','Format','uuuu/MM/dd HH:mm:ss'));

% Launch Bookmark management application at startup
    if set.saveWorkspace
        dataname = ['AutoSave',DATE];
        WorkspaceStash.add(dataname)
    end

% Send LINE when matlab shutdown
    if set.sendLINE
        MessageManager.send_LINE(['(',DATE,')',newline,' >> shutdown'])
    end

end