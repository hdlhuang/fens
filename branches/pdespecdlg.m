function varargout = pdespecdlg(varargin)
% PDESPECDLG M-file for pdespecdlg.fig
%      PDESPECDLG, by itself, creates a new PDESPECDLG or raises the existing
%      singleton*.
%
%      H = PDESPECDLG returns the handle to a new PDESPECDLG or the handle to
%      the existing singleton*.
%
%      PDESPECDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PDESPECDLG.M with the given input arguments.
%
%      PDESPECDLG('Property','Value',...) creates a new PDESPECDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pdespecdlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pdespecdlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pdespecdlg

% Last Modified by GUIDE v2.5 09-Mar-2004 19:20:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pdespecdlg_OpeningFcn, ...
                   'gui_OutputFcn',  @pdespecdlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pdespecdlg is made visible.
function pdespecdlg_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for pdespecdlg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pdespecdlg wait for user response (see UIRESUME)
% uiwait(handles.pdespecdlg);
setappdata(handles.pdespecdlg,'filename','PDES.mat');
global gd
try
  vlist = gd.PDES.VLIST;
  clist = gd.PDES.CLIST;
  ii = ones(size(vlist));
  jj = zeros(size(clist));
  set(handles.varlist,'String',{vlist{:} clist{:}},'UserData',[ii jj],'Value',1);
  set(handles.pdelist,'String',gd.PDES.PDEVLIST,'Value',1);
catch
end

% --- Outputs from this function are returned to the command line.
function varargout = pdespecdlg_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function varname_CreateFcn(hObject, eventdata, handles)
Object_CreateFcn(hObject);

function varname_Callback(hObject, eventdata, handles)

function Object_CreateFcn(hObject)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function Edit_Changed(hObject,defaultvalue,minvalue,maxvalue)
value = str2num(get(hObject,'String'));
if isnan(value)
    value = defaultvalue;
elseif size(value,1) < 1 || (value < minvalue) || (value > maxvalue)
    value = defaultvalue;
end
set(hObject,'String',num2str(value));


% --- Executes during object creation, after setting all properties.
function varlist_CreateFcn(hObject, eventdata, handles)
Object_CreateFcn(hObject);

% --- Executes on selection change in varlist.
function varlist_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
if line
  ud = get(hObject,'UserData');
  str= get(hObject,'String');
  setsysvar_Callback(handles,ud(line));
  set(handles.varname,'String',str{line});
end

function valid = checkvarname(handles)
varname = get(handles.varname,'String');
bsysvar = get(handles.sysvar,'Value');
i = strfind(varname,'=');
i = size(i(:),1);
valid = 0;
if bsysvar
  if i > 0,    msgbox('变量不能有等号','格式不对');
  else,    valid = 1;  end
else
  if i < 1,    msgbox('系数不能没有等号','格式不对');
  else,    valid = 1;  end
end

% --- Executes on button press in addvar.
function addvar_Callback(hObject, eventdata, handles)
if checkvarname(handles),
  varname = get(handles.varname,'String');
  line = lb_additem(handles.varlist,varname);
  ud = get(handles.varlist,'UserData');
  ud = [ud(1:line-1) get(handles.sysvar,'Value') ud(line:end)];
  set(handles.varlist,'UserData',ud);
end

% --- Executes on button press in delvar.
function delvar_Callback(hObject, eventdata, handles)
line = get(handles.varlist,'Value');
ud = get(handles.varlist,'UserData');
varlist = get(handles.varlist,'String');
ud = array_delsel(ud,line);
varlist = array_delsel(varlist,line);
set(handles.varlist,'UserData',ud,'String',varlist);

% --- Executes on button press in changevar.
function changevar_Callback(hObject, eventdata, handles)
if checkvarname(handles)
  line = get(handles.varlist,'Value');
  varlist = get(handles.varlist,'String');
  varstr = get(handles.varname,'String');
  varlist{line} = varstr;
  set(handles.varlist,'String',varlist);
end

% --- Executes on button press in addeq.
function addeq_Callback(hObject, eventdata, handles)
pdestr = get(handles.pdestr,'String');
lb_additem(handles.pdelist,pdestr);

% --- Executes on button press in deleq.
function deleq_Callback(hObject, eventdata, handles)
line = get(handles.pdelist,'Value');
pdelist = get(handles.pdelist,'String');
pdelist = array_delsel(pdelist,line);
set(handles.pdelist,'String',pdelist,'Value',1);

% --- Executes on button press in changeeq.
function changeeq_Callback(hObject, eventdata, handles)
line = get(handles.pdelist,'Value');
pdelist = get(handles.pdelist,'String');
pdestr = get(handles.pdestr,'String');
pdelist{line} = pdestr;
set(handles.pdelist,'String',pdelist);

function setsysvar_Callback(handles,val)
if val, val=1; end
set(handles.sysvar,'Value',val);
set(handles.coeffvar,'Value',1-val);

% --- Executes on button press in sysvar.
function sysvar_Callback(hObject, eventdata, handles)
setsysvar_Callback(handles,1);
% --- Executes on button press in coeffvar.
function coeffvar_Callback(hObject, eventdata, handles)
setsysvar_Callback(handles,0);


% --- Executes during object creation, after setting all properties.
function pdestr_CreateFcn(hObject, eventdata, handles)
Object_CreateFcn(hObject)


function pdestr_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pdelist_CreateFcn(hObject, eventdata, handles)
Object_CreateFcn(hObject)

% --- Executes on selection change in pdelist.
function pdelist_Callback(hObject, eventdata, handles)
line = get(hObject,'Value');
if line
  str= get(hObject,'String');
  set(handles.pdestr,'String',str{line});
end

function ListSelChanged(handles)
pdelist_Callback(handles.pdelist, [], handles)
varlist_Callback(handles.varlist, [], handles)

function line = lb_additem(hObject,item)
listitems = get(hObject,'String');
x = strmatch(item,listitems,'exact');
if ~isempty(x), return; end
line = get(hObject,'Value');
lines = size(listitems,1);
if lines
    listitems = {listitems{1:line-1},item,listitems{line:end}};
else
    listitems = {item};
    line = 1;
end
set(hObject,'String',listitems,'Value',line+1);

% --- Executes on button press in okbtn.
function okbtn_Callback(hObject, eventdata, handles)
global gd
gd.PDES = UpdateFields(gd.PDES,GetPDES(handles));
gd.PDES.UPDATEJAC = 1;
close(handles.pdespecdlg);

% --- Executes on button press in cancelbtn.
function cancelbtn_Callback(hObject, eventdata, handles)
close(handles.pdespecdlg);

function PDES = GetPDES(handles)
vlist = get(handles.varlist,'String');
ud = get(handles.varlist,'UserData');
nvar = size(vlist,1);
ud = ud(1:nvar);
ii = find(ud == 1);
PDES.VLIST = {vlist{ii}};
jj = find(ud == 0);
PDES.CLIST = {vlist{jj}};

PDES.PDEVLIST = get(handles.pdelist,'String');

PDES.NV = size(PDES.VLIST(:),1);
PDES.NC = size(PDES.CLIST(:),1);
PDES.NPDE = PDES.NV;

% variable symbols seperated by space
PDES.VSTR = list2str(PDES.VLIST,' ');
% coeffecient symbols seperated by space
for ic = 1:PDES.NC
  [name,val,desc] = GetPartsStr(PDES.CLIST{ic});
  PDES.CNAME{ic} = name;
  PDES.CVLIST{ic} = val;
  PDES.CDESC{ic} = desc;
end  
PDES.CSTR = list2str(PDES.CNAME,' ');

function [name,val,desc] = GetPartsStr(str)
str = [str '%'];
i = findstr(str,'=');
if isempty(i),  i = 0; end
name = str(1:i(1)-1);
j = findstr(str,'%');
val = str(i(1)+1:j(1)-1);
desc = str(j(1)+1:end);


function filename = getfilename(handles,bload)
if bload
  func = @uigetfile;  promptstr = '打开文件';
else
  func = @uiputfile;  promptstr = '保存文件';
end
[filename, pathname] = feval(func,...
{   '*.mat','MAT-files (*.mat)'; ...
    '*.*',  'All Files (*.*)'}, ...
    promptstr);
if any(filename)
  filename = [pathname filename];
  set(handles.pdespecdlg,'Name',['pdespecdlg - ' filename]);
  setappdata(handles.pdespecdlg,'filename',filename);
end

% --- Executes on button press in reloadbtn.
function reloadbtn_Callback(hObject, eventdata, handles)
filename = getappdata(handles.pdespecdlg,'filename');
warning off
s = load(filename,'varlist','vartype','pdelist');
warning on
if ~isfield(s,'varlist')
  MsgBox('不是该程序保存的文件,','格式错误');
  return;
end
set(handles.varlist,'String',s.varlist,'Value',1);
set(handles.varlist,'UserData',s.vartype);
set(handles.pdelist,'String',s.pdelist,'Value',1);
ListSelChanged(handles);

% --- Executes on button press in loadbtn.
function loadbtn_Callback(hObject, eventdata, handles)
filename = getfilename(handles,1);
if ~any(filename),return;end
reloadbtn_Callback(hObject, eventdata, handles);

% --- Executes on button press in savebtn.
function savebtn_Callback(hObject, eventdata, handles)
varlist = get(handles.varlist,'String');
vartype = get(handles.varlist,'UserData');
pdelist = get(handles.pdelist,'String');
filename = getappdata(handles.pdespecdlg,'filename');
save(filename,'varlist','vartype','pdelist');

% --- Executes on button press in saveasbtn.
function saveasbtn_Callback(hObject, eventdata, handles)
filename = getfilename(handles,0);
if ~any(filename),return;end
savebtn_Callback(hObject, eventdata, handles);

% --- Executes on button press in clearbtn.
function clearbtn_Callback(hObject, eventdata, handles)
set(handles.varlist,'String',{});
set(handles.pdelist,'String',{});
set(handles.varname,'String','');
set(handles.pdestr,'String','');
