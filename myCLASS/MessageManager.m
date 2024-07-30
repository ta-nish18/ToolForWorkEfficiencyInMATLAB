classdef MessageManager < handle
% Class for sending notifications
%
% <properties>
%       >> obj.isLINE = true   % Flag if send notification to LINE when executing "obj.send" method.
%       >> obj.isRing = false  % Flag if sound notification when executing "obj.send" method.
%
% <usage>
%       >> m = Messagemanager;      % Create an instance of the message manager class.
%       >> m.log('log message')     % Log messages can also be saved. (The message and time are saved as a set.)
%       >> m.send                   % Send notifications with stored log messages.
%
% <static method>
%       >> Messagemaneger.sendLINE(msg)     % send LINE notification
%       >> Messagemaneger.soundNotify(msg)  % play sound
%

    properties
        isLINE = true;
        isRing = false;
    end

    properties(Access=private)
        MessageHolder = [];
    end

    methods

        function obj = MessageManager(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            addParameter(p, 'isLINE' , true );
            addParameter(p, 'isRing' , false);
            parse(p, varargin{:});
            opt = p.Results;

            obj.isLINE = opt.isLINE;
            obj.isRing = opt.isRing;
        end

        function send(obj)
            msg = obj.MessageHolder;
            if obj.isLINE; obj.send_LINE(msg);   end
            if obj.isRing; obj.soundNotify(msg); end
            obj.MessageHolder = [];
        end

        function log(obj,msg)
            t = datetime('now','Format','(yyyy/MM/dd HH:mm:ss) ');
            obj.MessageHolder = [obj.MessageHolder,newline,char(t),newline,char(msg),newline];
        end

    end

    methods(Static)
        
        %%%%%% FUNCTION TO SEND LINE %%%%%%
        function send_LINE(msg)
            arguments
                msg =' ';
            end

            % Check Internet Connection
            if ~SystemFunc.checkInternetConnection
                disp("Can't send LINE because PC is offline.")
                return
            end

            % Check for LINE Token registration
            data = SystemFunc.config("MessageManager");
            key  = data.LINE_Token;
            if key=="" || key=="__Replaced by own Token__" || isempty(key)
                msg = ['Register your LINE token in the "LINE_Token" section of the config.json file.',newline,...
                       'LINE: How to get token? >> https://firestorage.jp/business/line-notify/'];
                warning(msg);
            end
            
            % send LINE
            cmd =  'curl -X POST -H ';
            key = ['"Authorization: Bearer ',char(key),'" -F '];
            msg = ['"','message=',['From MATLAB',newline,msg],'"'];
            url =  ' https://notify-api.line.me/api/notify';
            [~,out] = system([cmd,key,msg,url]);

            % Verify LINE Token is enabled.
            out = jsondecode(out);
            if out.status~=200
                error(out.message)
            end
            
        end
        
        %%%%%% FUNCTION TO Notify with sound %%%%%%
        function soundNotify(msg,file)
            arguments
                msg  = [];
                file = 'train';
            end
            data = load([file,'.mat']);
            sound( data.y, data.Fs);
            disp(msg)
        end

    end
    
end


