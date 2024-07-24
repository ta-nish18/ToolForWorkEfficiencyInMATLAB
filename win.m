function win(type)

    if nargin < 1
        type = input('b/w : ','s');
    end
    p = fileparts(mfilename('fullpath'));
    p = [fullfile(p,'+schemer','schemes'),filesep];
    switch type
        case {'white','w'}
            schemer.schemer_import([p,'white.prf'])
        case {'black','k'}
            schemer.schemer_import([p,'black.prf'])
        case {'blue','b'}
            schemer.schemer_import([p,'cobalt.prf'])
        case {'yellow','y'}
            schemer.schemer_import([p,'solarized-light.prf'])
        case {'green','g'}
            schemer.schemer_import([p,'green.prf'])
    end

end