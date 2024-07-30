classdef odeprogress
    properties
        mode % {'disp','dialog','TimeForecast'}
        alla
    end
    
    properties
        OutputFcn = @(src,event) false;
    end

    methods

        function obj = odeprogress(mode)
            if nargin==0
                mode = 'disp';
            end
            obj.mode = mode;
        end

        function set.mode(obj,val)
            switch val
                case 'none'
                case 'disp'
                case 'dialog'
                case 'Time'
            end

        end

    end
end