function SetupSchemer
    [file,location] = uigetfile('*.zip');
    if file
        path = SystemFunc.getpath('+schemer');
        unzip([location,file],path)
    end
end