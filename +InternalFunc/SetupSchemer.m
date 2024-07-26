function SetupSchemer
    [file,location] = uigetfile('*.zip');
    if file
        path = InternalFunc.getpath('+schemer');
        unzip([location,file],path)
    end
end