classdef odeprogress < handle
    properties
        mode
        timelimit
    end
    
    properties(SetAccess=protected)
        OutputFcn = @(src,event) false;
    end

    properties(Access=protected)
        tlim

        tspan
        tlast

        last_warn

        % For Time keeper
        start_time
        ToBeContinue = true;

        % For mode = "dialog" or "predict"
        dialog

    end

    methods

        function obj = odeprogress(mode,timelimit)
            arguments
                mode        = 'disp';
                timelimit   = inf;
            end
            obj.mode = mode;
            obj.timelimit = duration(0,0,timelimit);
        end

        function opt = getoption(obj)
            opt = odeset('OutputFcn',obj.OutputFcn,'Events',@obj.Events);
        end

        function set.mode(obj,val)
            switch val
                case 'none'
                    obj.OutputFcn = @obj.time_keeper;   %#ok
                case 'disp'
                    obj.OutputFcn = @obj.dispFcn;       %#ok
                case 'dialog'
                    obj.OutputFcn = @obj.dialogFcn;     %#ok
            end
            obj.mode = val;
        end


        function f = dialogFcn(obj,t,x,flag)
            [f,flag] = obj.time_keeper(t,x,flag);

            switch char(flag)
                case 'init'
                    obj.tlim  = t;
                    obj.tspan = t(end)-t(1);
                    obj.tlast = t(1);
                    obj.dialog = waitbar(0,' ','Name','Simulation in progress...');
                    return
                case 'done'
                    delete(obj.dialog)
                case 'timeout'
                    delete(obj.dialog)
                    disp('The simulation is terminated because the time limit has been exceeded.')
                otherwise
                    if ~isgraphics(obj.dialog)
                        obj.dialogFcn(obj.tlim,[],'init');
                    end
                    per = (t-obj.tlast)/obj.tspan;
                    if per>= 0.01
                        waitbar(t/obj.tspan,obj.dialog,sprintf('Time: %0.2f(s) / %0.2f(s)',t,obj.tlim(end)))
                        obj.tlast = floor(per*100)/100 * obj.tspan + obj.tlast;
                    end
            end
        end

        function f = dispFcn(obj,t,x,flag)
            [f,flag] = obj.time_keeper(t,x,flag);

            switch char(flag)
                case 'init'
                    disp(' ')
                    t0 = [num2str( t(1)  ),'s'];
                    te = [num2str( t(end)),'s'];
                    disp([t0,repmat(' ',[1,101-numel([t0,te])]),te])
                    disp([  '|        10%       20%       30%       40%       50%       60%       70%       80%       90%        |',newline,...
                            '|---------o---------o---------o---------o---------o---------o---------o---------o---------o---------|'])
                    fprintf('|')

                    obj.tlim  = t;
                    obj.tspan = t(end)-t(1);
                    obj.tlast = t(1);
                    return
                case 'done'
                    disp('|')
                case 'timeout'
                    disp('|')
                    disp('The simulation is terminated because the time limit has been exceeded.')
                otherwise
                    wid = lastwarn;
                    if ~strcmp(obj.last_warn,wid)
                        obj.dispFcn(obj.tlim,[],'init');
                    end
                    per = (t-obj.tlast)/obj.tspan;
                    if per>= 0.01
                        roundper = floor(per*100);
                        fprintf(repmat('>',1,roundper))
                        obj.tlast = roundper/100 * obj.tspan + obj.tlast;
                    end
            end
        end


        function [f,flag] = time_keeper(obj,~,~,flag)
            f = false;
            if isinf(obj.timelimit)
                return; 
            end

            switch char(flag)
                case 'init'
                    obj.ToBeContinue = true;
                    obj.start_time = datetime;
                case 'done'
                    return
                otherwise
                    if (datetime - obj.start_time) > obj.timelimit
                        obj.ToBeContinue = false;
                        flag = 'timeout';
                    end
            end
        end


        function [value,isterminal,direction] = Events(obj,~,~)
            value = obj.ToBeContinue;
            isterminal = 1;
            direction  = 0;
        end
    end
end