% Type   : Function
% README : Close currently open uifigures at once function
% USAGE  : >> uiclose          --- Close all uifigure
%          >> uiclose  figname --- Close only uifigure which name is "figname"


function uiclose(figname)
    if nargin==1
        close(findall(0, 'type', 'figure', 'Name', figname));
    else
        close(findall(0, 'type', 'figure'));
    end

end