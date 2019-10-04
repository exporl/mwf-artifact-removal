function varargout = Compute_options(varargin)
% COMPUTE_OPTIONS MATLAB code for Compute_options.fig
%      COMPUTE_OPTIONS, by itself, creates a new COMPUTE_OPTIONS or raises the existing
%      singleton*.
%
%      H = COMPUTE_OPTIONS returns the handle to a new COMPUTE_OPTIONS or the handle to
%      the existing singleton*.
%
%      COMPUTE_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPUTE_OPTIONS.M with the given input arguments.
%
%      COMPUTE_OPTIONS('Property','Value',...) creates a new COMPUTE_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Compute_options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Compute_options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Compute_options

% Last Modified by GUIDE v2.5 07-Mar-2019 14:24:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Compute_options_OpeningFcn, ...
                   'gui_OutputFcn',  @Compute_options_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Compute_options is made visible.
function Compute_options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Compute_options (see VARARGIN)

set(handles.Compute_Options_GUI,'Units','Pixels','Position',get(0,'ScreenSize').*[1 1 0.4 0.4])


%Copy settings from main GUI
gcf = getappdata(0,'Main_GUI');
compute_options = getappdata(gcf,'compute_options');

handles.delay = compute_options{1};
handles.rank = compute_options{2};
handles.rankopt = compute_options{3};

% Choose default command line output for Compute_options
handles.output = hObject;

%Initialize boxes
%Delay box
set(handles.Delay_Inputbox,'String',num2str(handles.delay));
%Rank box
h = findobj('Tag','Rank_PopupBox');
contents = cellstr(get(h,'String'));
index = find(strcmp(contents,translate_mwf_strings(handles.rank)));
set(handles.Rank_PopupBox,'Value',index);

%Rank options box
if(strcmp(handles.rank,'pct') || strcmp(handles.rank,'first'))
    set(handles.RankOptions_Inputbox,'Visible','on');
else
    set(handles.RankOptions_Inputbox,'Visible','off');
end
set(handles.RankOptions_Inputbox,'String',num2str(handles.rankopt));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Compute_options wait for user response (see UIRESUME)
%uiwait(handles.Compute_Options_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = Compute_options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
%varargout{1} = handles.delay;
%varargout{2} = handles.rank;
%varargout{3} = handles.rankopt;

%delete(handles.Compute_Options_GUI)



function Delay_Inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to Delay_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Delay_Inputbox as text
%        str2double(get(hObject,'String')) returns contents of Delay_Inputbox as a double

%Update delay value
input = str2double(get(hObject,'String'));
if(isnan(input) || input<0)
    waitfor(msgbox('Invalid delay input','Error','error'))
else
    handles.delay = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function Delay_Inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Delay_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Rank_PopupBox.
function Rank_PopupBox_Callback(hObject, eventdata, handles)
% hObject    handle to Rank_PopupBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Rank_PopupBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Rank_PopupBox
contents = cellstr(get(hObject,'String'));
handles.rank = reverse_translate_mwf_strings(contents{get(hObject,'Value')});
if(strcmp(handles.rank,'pct') || strcmp(handles.rank,'first'))
    set(handles.RankOptions_Inputbox,'Visible','on');
else
    set(handles.RankOptions_Inputbox,'Visible','off');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Rank_PopupBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rank_PopupBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RankOptions_Inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to RankOptions_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RankOptions_Inputbox as text
%        str2double(get(hObject,'String')) returns contents of RankOptions_Inputbox as a double
input = str2double(get(hObject,'String'));
if(handles.rank == 'pct')
    if(isnan(input) || input > 100 || input < 0)
        waitfor(msgbox('Invalid percentage input','Error','error'));
    else
        handles.rankopt = input;
        guidata(hObject, handles);
    end
elseif(handles.rank == 'first')
    if(isnan(input))
        waitfor(msgbox('Invalid amount of kept eigenvalues input','Error','error'))
    else
        handles.rankopt = input;
        guidata(hObject, handles);
    end
end



% --- Executes during object creation, after setting all properties.
function RankOptions_Inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RankOptions_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close Compute_Options_GUI.
function Compute_Options_GUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Compute_Options_GUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in OK_button.
function OK_button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

compute_options = {handles.delay, handles.rank, handles.rankopt};

gcf = getappdata(0, 'Main_GUI');
setappdata(gcf, 'compute_options', compute_options);
delete(handles.Compute_Options_GUI);

% --- Executes on button press in Reset_button.
function Reset_button_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gcf = getappdata(0, 'Main_GUI');
compute_options = getappdata(gcf,'compute_options');

delay = compute_options{1};
rank = compute_options{2};
rankopt = compute_options{3};

%Delay box
set(handles.Delay_Inputbox,'String',num2str(delay));
handles.delay = delay;
Delay_Inputbox_Callback(handles.Delay_Inputbox,eventdata,handles);
%Rank box
h = findobj('Tag','Rank_PopupBox');
contents = cellstr(get(h,'String'));
index = find(strcmp(contents,translate_mwf_strings(rank)));
set(handles.Rank_PopupBox,'Value',index);
handles.rank = rank;
Rank_PopupBox_Callback(handles.Rank_PopupBox,eventdata,handles);
%Rank options box
set(handles.RankOptions_Inputbox,'String',num2str(rankopt));
handles.rankopt = rankopt;
RankOptions_Inputbox_Callback(handles.RankOptions_Inputbox,eventdata,handles);

guidata(hObject,handles);



% --- Executes on button press in Default_button.
function Default_button_Callback(hObject, eventdata, handles)
% hObject    handle to Default_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DEFAULT_DELAY = 5;
DEFAULT_RANK = 'poseig';
DEFAULT_RANKOPT = 10;

%Delay box
set(handles.Delay_Inputbox,'String',num2str(DEFAULT_DELAY));
handles.delay = DEFAULT_DELAY;
%Rank box
h = findobj('Tag','Rank_PopupBox');
contents = cellstr(get(h,'String'));
index = find(strcmp(contents,translate_mwf_strings(DEFAULT_RANK)));
set(handles.Rank_PopupBox,'Value',index);
handles.rank = DEFAULT_RANK;
%Rank options box
set(handles.RankOptions_Inputbox,'String',num2str(DEFAULT_RANKOPT));
handles.rankopt = DEFAULT_RANKOPT;

set(handles.RankOptions_Inputbox,'Visible','off');

guidata(hObject,handles);

%Translate option names of mwf_params function to names of popup box
function out = translate_mwf_strings(in)
switch in
    case 'full'
        out = 'Full';
    case 'poseig'
        out = 'Positive eigenvalues';
    case 'pct'
        out = 'Percentage';
    case 'first'
        out = 'First';
end

function out = reverse_translate_mwf_strings(in)
switch in
    case 'Full'
        out = 'full';
    case 'Positive eigenvalues'
        out = 'poseig';
    case 'Percentage'
        out = 'pct';
    case 'First'
        out = 'first';
end
