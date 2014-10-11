function pdesolver( action, mihndl )
%PDESOLVER Summary of this function goes here
%  Detailed explanation goes here
global gd
if nargin < 1
    action = 'init';
end

if strcmp(action,'init')
    init_figure;
    create_menu;
    create_btns    
    return;
end
[solver_fig ax] = get_fig_ax;
set(solver_fig,'CurrentAxes',ax);

if strcmp(action,'Initialize Mesh ')
    gd.MESH = CreateMesh(2,3);
    myplot(gd.MESH.p, gd.MESH.e, gd.MESH.t,...
        'intool','on','shownodelbl','on','showtrilbl','on');
elseif strcmp(action,'Refine Mesh ')
    [gd.MESH.p,gd.MESH.e,gd.MESH.t] = refinemesh(gd.MESH.dl,gd.MESH.p,gd.MESH.e,gd.MESH.t); 
    myplot(gd.MESH.p, gd.MESH.e, gd.MESH.t,...
        'intool','on','shownodelbl','on','showtrilbl','on');
elseif strcmp(action,'mousemove')
    mouse_move;
elseif strcmp(action,'Snap')
    snaphndl = findobj(allchild(solver_fig),'Tag','PDESolverSnap');
    if umtoggle(snaphndl),
        flag = 'on';
    else
        flag = 'off';
    end
    set(snaphndl,'Checked',flag);
elseif strcmp(action,'Axes Limits...')
    if nargin < 2
        xmax=get(ax,'XLim');
        xmin=xmax(1); xmax=xmax(2);
        ymax=get(ax,'YLim');
        ymin=ymax(1); ymax=ymax(2);
        
        PromptString = str2mat('X-axis range:','Y-axis range:');
        OptFlags=[1, 0; 1, 0];
        DefLim = [xmin xmax; ymin ymax];
        figh=axlimdlg('Axes Limits',OptFlags,PromptString,[ax NaN ax],['x'; 'y'],...
            DefLim,'pdesolver(''Axes Limits...'',1); ');
        set(figh,'Tag','SolverAxLimDlg')
    else
        hndls=get(gcf,'UserData');
        hndls=hndls(:,2);                     % EditField handles is 2nd column
        xlim=get(hndls(1),'UserData');
        ylim=get(hndls(2),'UserData');
        
        set(ax,'XLim',xlim, 'YLim',ylim,...
            'DataAspectRatio',[1 1.5*diff(ylim)/diff(xlim) 1]);
        
        set(get(ax,'ZLabel'),'UserData',[]);
        
        h = findobj(allchild(solver_fig),'Tag','PDESolverAxes Equal');
        set(h,'Checked','off')
    end
elseif strcmp(action,'Grid')
    gridhndl = findobj(allchild(solver_fig),'Tag','PDESolverGrid');
    if umtoggle(gridhndl),
        flag = 'on';
    else
        flag = 'off';
    end
    set(ax,'XGrid',flag,'YGrid',flag);
    set(gridhndl,'Checked',flag);

      ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax);

elseif strcmp(action,'Axes Equal')
    h = findobj(allchild(solver_fig),'Tag','PDESolverAxes Equal');
    if umtoggle(h)
        % Axis equal
        axis equal
    else
        % Axis normal
        set(ax,...
            'DataAspectRatioMode','auto',...
            'PlotBoxAspectRatioMode','auto',...
            'CameraViewAngleMode','auto')
    end
    set(get(ax,'ZLabel'),'UserData',[]);

elseif strcmp(action,'Rectangle/square')
    
else
    disp(action);
end



function [fig,ax]= get_fig_ax
fig = findobj(allchild(0),'flat','Tag','PDESolver');
ax  = findobj(allchild(fig),'flat','Tag','SolverAxes');

function init_figure
[solver_fig ax] = get_fig_ax;
if ~isempty(solver_fig),
    set(0,'CurrentFigure',solver_fig);
    Figpos = get(solver_fig,'Position');
    set(solver_fig,'Colormap',gray(20),'HandleVisibility','on')
    delete(allchild(solver_fig))
    refresh(solver_fig)
else
    ScreenUnits = get(0,'Units');
    set(0,'Unit','pixels');
    ScreenPos = get(0,'ScreenSize');
    set(0,'Unit',ScreenUnits);
    Figpos=[.15 .15 .8 .75].*ScreenPos+[0.1*ScreenPos(3:4) 0 0];
    solver_fig=figure(...
        'Color','w',...
        'Tag','PDESolver',...
        'Colormap',gray(20),...
        'Position',Figpos,...
        'NumberTitle','off',...
        'Name','PDE Solver - [Untitled]',...
        'IntegerHandle','off',...
        'Renderer','painters',...
        'Interruptible','on',...
        'Resize','on',...
        'MenuBar','none',...
        'Visible','on',...
        'KeyPressFcn','pdesolver keycall',...
        'Units','pixels',...
        'WindowButtonMotionFcn','pdesolver mousemove',...
        'WindowButtonDownFcn','pdesolver select',...
        'Pointer','arrow',...
        'HandleVisibility','callback');
end
axwidth = 0.8*Figpos(3);
axheight= axwidth/1.5/Figpos(4);
axstdpos = [0.1 0.12 0.8 axheight];
ax=axes(...
    'Parent',solver_fig,...
    'Position',axstdpos,...
    'XColor','k',...
    'Box','on',...
    'YColor','k',...
    'Color','w',...
    'DrawMode','fast',...
    'Tag','SolverAxes',...
    'XLimMode','manual',...
    'YLimMode','manual',...
    'XLim',[-1.5 1.5],...
    'YLim',[-1 1],...
    'XGrid','off',...
    'YGrid','off',...
    'ZGrid','off',...
    'XTickMode','auto',...
    'YTickMode','auto',...
    'Units','normalized',...
    'DataAspectRatio',[1 1 1]);

% Save axes position:
setappdata(ax,'axstdpos',axstdpos)

function create_menu
items = {  
    % File menu:
    '&File',
    '>',
    '&New ^n',
    '&Open... ^o',
    '&Save ^s',
    'Save &As...',
    '&Print...',
    '-',
    'E&xit ^w',
    '<',
    % Edit menu:
    '&Edit',
    '>',
    '&Undo ^z',
    'Cu&t ^x',
    '&Copy ^c',
    '&Paste... ^v',
    'Clea&r ^r',
    'Select &All ^a',
    '<',
    % Options menu:
    '&Options',
    '>',
    '&Grid',
    'Gr&id Spacing...',
    '&Snap',
    '&Axes Limits...',
    'Axes &Equal',
    '&Zoom',
    '&Refresh',
    '<',
    % Draw menu:
    'D&raw',
    '>',
    '&Draw Mode',
    '&Rectangle/square',
    'Rectangle/&square (centered)',
    '&Ellipse/circle',
    'Ellipse/&circle (centered)',
    '&Polygon',
    'R&otate...',
    '<',
    % Boundary menu:
    '&Boundary',
    '>',
    '&Boundary Mode ^b',
    '&Specify Boundary Conditions...',
    'Show &Edge Labels',
    'Show S&ubdomain Labels',
    '-',
    '&Remove Subdomain Border',
    'Re&move All Subdomain Borders',
    '<',
    % PDE menu:
    'P&DE',
    '>',
    '&PDE Mode',
    'P&DE Specification...',
    '<',
    % Mesh menu:
    '&Mesh',
    '>',
    '&Mesh Mode',
    '&Initialize Mesh ^i',
    '&Refine Mesh ^m',
    '&Jiggle Mesh',
    '&Display Triangle Quality',
    'Show &Node Labels',
    'Show &Triangle Labels',
    '<',
    % Solve menu:
    '&Solve',
    '>',
    '&Solve PDE ^e',
    '<',
    % Plot menu:
    '&Plot',
    '>',
    '&Plot Solution ^p'
};
[solver_fig ax] = get_fig_ax;
CreateMenu(items,solver_fig,'PDESolver');

function create_btns
[solver_fig ax] = get_fig_ax;
% X and Y positions:
uicontrol(solver_fig,'Style','frame','Units','normalized',...
    'Position',[0.76 0.96 .24 .04]);
xh=uicontrol(solver_fig,'Style','text','Units','normalized',...
    'HorizontalAlignment','left','Tag','SolverXField',...
    'Position',[.77 .965 .075 .03],'String','X:0.0');
yh=uicontrol(solver_fig,'Style','text','Units','normalized',...
    'HorizontalAlignment','left','Tag','SolverYField',...
    'Position',[.89 .965 .075 .03],'String','Y:0.0');
set(solver_fig,'UserData',[xh yh 0 0]);

function mouse_move
[solver_fig ax] = get_fig_ax;
pv=get(ax,'CurrentPoint');
snaphndl = findobj(allchild(solver_fig),'Tag','PDESolverSnap');
flag = get(snaphndl,'Checked');
[xcurr,ycurr]=pdesnap(ax,pv,strcmp(flag,'on'));
hndls = get(solver_fig,'UserData');
set(hndls(1),'String',sprintf('X:%.4g',xcurr))
set(hndls(2),'String',sprintf('Y:%.4g',ycurr))

function solve
global gd
gd.FE = FECreate(2,3);
gd.PDES = PDECreate;
calcjacob;
assem(0);
%nonlinearsolver;

