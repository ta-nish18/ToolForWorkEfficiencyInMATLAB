function font(value)
% Functions to change font size and formatting
%
% <usage>
%       >> font val
%
%       If "val" is double (e.g. 10), change font size to that value
%       If "val" is string (e.g. Symbol), change the format to match the input
%
%       ex) 
%       >> font 10
%       >> font Symbol
%
% Shortcut keys can also be used. A list of shortcut keys can be viewed by executing the font function without arguments.
% You can also set up shortcut keys at "./+SystemConfig/config.json"
%

    data = SystemFunc.config('font');
    tab  = struct2table( data );
    if nargin<1
        disp(repmat('-',1,50))
        disp('<<Shortcut list>>')
        disp(tab)
        disp(repmat('-',1,50))
        % value = input('input value : ','s');
        return
    end
    
    
    % Identification of font information

    if isnumeric(value)
        s = value;
        f = nan;
    else
        flag = ismember(tab.shortcutKey, value);
        if any(flag)
            idx = find(flag,1,"first");
            s = tab.size(idx);
            f = tab.font{idx};
    
        elseif ~isnan(str2double(value))
            s = str2double(value);
            f = nan;
    
        elseif ismember(value,fontinfo)
            s = nan;
            f = value;
    
        else
            error('Input value could not be identified.')
        end
    end

    % Font Setting
    sys = settings;
    if ~isnan(s) && s
        disp(['  size >> ',num2str(s)])
        sys.matlab.fonts.codefont.Size.TemporaryValue = s;
    end

    if ~isnan(f)
        disp(['  font >> ',f])
        sys.matlab.fonts.codefont.Name.TemporaryValue = f;
    end
    disp(' ')
end
