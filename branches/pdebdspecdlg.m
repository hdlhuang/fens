function varargout = pdebdspecdlg(varargin)
% PDEBDSPECDLG M-file for pdebdspecdlg.fig
%      PDEBDSPECDLG, by itself, creates a new PDEBDSPECDLG or raises the existing
%      singleton*.
%
%      H = PDEBDSPECDLG returns the handle to a new PDEBDSPECDLG or the handle to
%      the existing singleton*.
%
%      PDEBDSPECDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PDEBDSPECDLG.M with the given input arguments.
%
%      PDEBDSPECDLG('Property','Value',...) creates a new PDEBDSPECDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pdebdspecdlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pdebdspecdlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pdebdspecdlg

% Last Modified by GUIDE v2.5 12-Mar-2004 22:22:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pdebdspecdlg_OpeningFcn, ...
                   'gui_OutputFcn',  @pdebdspecdlg_OutputFcn, ...
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


% --- Executes just before pdebdspecdlg is made visible.
function pdebdspecdlg_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for pdebdspecdlg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pdebdspecdlg wait for user response (see UIRESUME)
% uiwait(handles.pdebdspecdlg);
setappdata(handles.pdebdspecdlg,'filename','PDESBD.mat');
global gd
try
  set(handles.pdelist,'String',gd.PDES.PDEVLIST,'Value',1);
  set(handles.bclist,'String',gd.ARGIN.NBDC.BDC,'UserData',gd.ARGIN.NBDC.BDT);
catch
end
  
% --- Outputs from this function are returned to the command line.
function varargout = pdebdspecdlg_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

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


function setdbc_Callback(handles,val)
if val, val=1; end
set(handles.dbc,'Value',val);
set(handles.nbc,'Value',1-val);

% --- Executes on button press in dbc.
function dbc_Callback(hObject, eventdata, handles)
setdbc_Callback(handles,1);
% --- Executes on button press in nbc.
function nbc_Callback(hObject, eventdata, handles)
setdbc_Callback(handles,0);

% --- Executes during object creation, after setting all properties.
function bcstr_CreateFcn(hObject, eventdata, handles)
Object_CreateFcn(hObject)

function bcstr_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function bclist_CreateFcn(hObject, eventdata, handles)
Object_CreateFcn(hObject)

% --- Executes on selection change in bclist.
function bclist_Callback(hObject, eventdata, handles)
bclist = get(handles.bclist,'String');
line = get(handles.bclist,'Value');
set(handles.pdelist,'Value',line);
bcstr = bclist{line};
set(handles.bcstr,'String',bcstr);
ud = get(handles.bclist,'UserData');
setdbc_Callback(handles,ud(line));

function ListSelChanged(handles)
bclist_Callback(handles.bclist, [], handles)

% --- Executes on button press in addb.
function addb_Callback(hObject, eventdata, handles)
bcstr = get(handles.bcstr,'String');
bclist = get(handles.bclist,'String');
line = get(handles.pdelist,'Value');
bclist{line} = bcstr;
ud = get(handles.bclist,'UserData');
ud(line) = get(handles.dbc,'Value');
set(handles.bclist,'String',bclist,'Value',line,'UserData',ud);

% --- Executes on button press in delb.
function delb_Callback(hObject, eventdata, handles)
line = get(handles.bclist,'Value');
bclist = get(handles.bclist,'String');
bclist{line}='';
set(handles.bclist,'String',bclist);

% --- Executes on button press in okbtn.
function okbtn_Callback(hObject, eventdata, handles)
global gd
gd.ARGIN.NBDC.BDC = get(handles.bclist,'String');
gd.ARGIN.NBDC.BDT = get(handles.bclist,'UserData');
gd.PDES.BDCLIST(:,gd.ARGIN.COLUMN) = gd.ARGIN.NBDC.BDC;
gd.PDES.BDTLIST(:,gd.ARGIN.COLUMN) = gd.ARGIN.NBDC.BDT;
gd.PDES.UPDATEJAC = 1;
close(handles.pdebdspecdlg);

% --- Executes on button press in cancelbtn.
function cancelbtn_Callback(hObject, eventdata, handles)
close(handles.pdebdspecdlg);

function filename = lgetfilename(handles,bload)
[filename, pathname] = GetFilename(bload);
if any(filename)
  filename = [pathname filename];
  set(handles.pdebdspecdlg,'Name',['pdebdspecdlg - ' filename]);
  setappdata(handles.pdebdspecdlg,'filename',filename);
end

% --- Executes on button press in reloadbtn.
function reloadbtn_Callback(hObject, eventdata, handles)
filename = getappdata(handles.pdebdspecdlg,'filename');
warning off
s = load(filename,'bclist','userdata');
warning on
if ~isfield(s,'bclist')
  MsgBox('不是该程序保存的文件,','格式错误');
  return;
end
set(handles.bclist,'String',s.bclist,'Value',1,'UserData',s.userdata);
ListSelChanged(handles);

% --- Executes on button press in loadbtn.
function loadbtn_Callback(hObject, eventdata, handles)
filename = lgetfilename(handles,1);
if ~any(filename),return;end
reloadbtn_Callback(hObject, eventdata, handles);

% --- Executes on button press in savebtn.
function savebtn_Callback(hObject, eventdata, handles)
bclist = get(handles.bclist,'String');
userdata = get(handles.bclist,'UserData');
filename = getappdata(handles.pdebdspecdlg,'filename');
save(filename,'bclist','userdata');

% --- Executes on button press in saveasbtn.
function saveasbtn_Callback(hObject, eventdata, handles)
filename = lgetfilename(handles,0);
if ~any(filename),return;end
savebtn_Callback(hObject, eventdata, handles);

% --- Executes on button press in clearbtn.
function clearbtn_Callback(hObject, eventdata, handles)
set(handles.bclist,'String',{});
set(handles.bcstr,'String','');

% --- Executes during object creation, after setting all properties.
function pdelist_CreateFcn(hObject, eventdata, handles)
Object_CreateFcn(hObject)

% --- Executes on selection change in pdelist.
function pdelist_Callback(hObject, eventdata, handles)
line = get(handles.pdelist,'Value');
str = get(handles.bclist,'String');
if size(str(:),1) < line
  str{line}='';
  set(handles.bclist,'String',str);
end
set(handles.bclist,'Value',line);