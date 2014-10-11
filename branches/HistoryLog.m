function HistoryLog(str)
%disp(str)

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
log=findobj(get(pde_fig,'Children'),'flat','Tag','PDELog');
logstr = get(log,'String');
lines = size(logstr,1);
if lines
    logstr = {logstr{:},str};
else
    logstr = {str};
end

set(log,'String',logstr);
%set(log,'Value',lines+1);
%if lines > 20
%    set(log,'ListboxTop',lines-20);
%end