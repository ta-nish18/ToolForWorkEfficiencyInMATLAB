function win(prf)
% Functions to change UI theme
%
% <usage>
%       >> win k  --- change to dark mode
%       >> win w  --- change to light mode
%
% <Requirement> 
%       External sources must be downloaded.
%
%       Step1. Download zip from the following page.
%              https://jp.mathworks.com/matlabcentral/fileexchange/53862-matlab-schemer
%
%       Step2. Run as follows and select the zip file you downloaded
%              >> SystemFunc.SetupSchemer
%

    data = SystemFunc.config('win');
    tab  = struct2table( data );
    if nargin<1
        disp(repmat('-',1,50))
        disp('<<Shortcut list>>')
        disp(tab)
        disp(repmat('-',1,50))
        return
    end
    
    path = SystemFunc.getpath('+SystemConfig','schemes');


    % Identification of font information
    flag = ismember(tab.shortcutKey, prf);
    if any(flag)
        idx = find(flag,1,"first");
        prf = tab.prf_file(idx);

        pathprf = checkPRF(path,prf,...
            ['The file name registered in the shortcut key was not recognized. ' ...
            'Please check if the file name registered as a set of shortcut keys is in "+SystemConfig/schemes/".']);

    else
        pathprf = checkPRF(path,prf,'Input value could not be identified.');
    end

    try
        schemer.schemer_import(pathprf)
    catch
        warning('An external source to change the schemer is required. Please follow the Requirement in the help below to set it up.')
        disp([repmat('=',1,40),' help ',repmat('=',1,40)])
        help win
        disp(repmat('=',1,86))
    end
end


function pathprf = checkPRF(path,file,msg)
    pathprf = char(fullfile(path,file));

    if ~strcmp(pathprf(end-3:end),'.prf')
        pathprf = [pathprf,'.prf'];
    end

    if ~isfile( pathprf )
        error(msg)
    end
end