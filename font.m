% Type   : Function
% README : Functions to change font size and formatting
% USAGE  : 
%          >> font val
%
%          If "val" is double (e.g. 10), change font size to that value
%          If "val" is string (e.g. Symbol), change the format to match the input
%
%          ex) 
%          >> font 10
%          >> font Symbol
%
% You can also set up shortcut keys.
% Shortcut file is save at "./+InternalConfig/font.csv"


function font(value)
    path = fileparts(mfilename('fullpath'));
    tab = readtable(fullfile(path,'+InternalConfig','font.csv'));
    if nargin<1
        disp(repmat('-',1,50))
        disp('<<Shortcut list>>')
        disp(tab)
        disp(repmat('-',1,50))
        value = input('input value : ','s');
    end
    
    
    % Identification of font information
    flag = ismember(tab.shortcutKey, value);
    if any(flag)
        s = tab.size(flag);
        f = tab.font{flag};

    elseif ~isnan(str2double(value))
        s = str2double(value);
        f = nan;

    elseif ismember(value,fontinfo)
        s = nan;
        f = value;

    else
        error('Input value could not be identified.')
    end
    
    % Font Setting
    sys = settings;
    if ~isnan(s)
        disp(['  size >> ',num2str(s)])
        sys.matlab.fonts.codefont.Size.TemporaryValue = s;
    end

    if ~isnan(f)
        disp(['  font >> ',f])
        sys.matlab.fonts.codefont.Name.TemporaryValue = f;
    end
    disp(' ')
end
