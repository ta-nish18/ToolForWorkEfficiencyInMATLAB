% Type   : Function
% README : Functions to change UI theme
% USAGE  : >> win k  --- change to dark mode
%          >> win w  --- change to light mode
%
% Requirement : External sources must be downloaded.
%
%       Step1. Download zip from the following page.
%              https://jp.mathworks.com/matlabcentral/fileexchange/53862-matlab-schemer
%
%       Step2. Run as follows and select the zip file you downloaded
%              >> InternalFunc.SetupSchemer



function win(type)

    switch type
        % case 'edit'
        %     InternalFunc.edit_win;
        case {'white','w'}
            prf = 'white.prf';
        case {'black','k'}
            prf = 'black.prf';
        otherwise
            error('Could not identify.')
    end

    path = [InternalFunc.getpath('+InternalConfig','schemes'), prf];
    try
        schemer.schemer_import(path)
    catch
        warning('An external source to change the schemer is required. Please follow the Requirement in the help below to set it up.')
        disp([repmat('=',1,40),' help ',repmat('=',1,40)])
        help win
        disp(repmat('=',1,86))
    end
end

