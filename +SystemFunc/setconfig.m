function setconfig(data,varargin)
    old = SystemFunc.config();
    new = setfield(old,varargin{:},data);

    text = jsonencode(new, PrettyPrint=true);
    path = fullfile(SystemFunc.getpath(),'config.json');

    writelines(text,path)
end