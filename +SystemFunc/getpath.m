function val = getpath(varargin)
    
    fpath = fileparts(mfilename('fullpath'));
    dpath = fpath(1:find(fpath==filesep,1,'last')-1);
    val   = fullfile(dpath,varargin{:});

end