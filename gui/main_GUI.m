function varargout = main_GUI(varargin)
% main_GUI MATLAB code for main_GUI.fig
%      main_GUI, by itself, creates a new main_GUI or raises the existing
%      singleton*.
%
%      H = main_GUI returns the handle to a new main_GUI or the handle to
%      the existing singleton*.
%
%      main_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in main_GUI.M with the given input arguments.
%
%      main_GUI('Property','Value',...) creates a new main_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_GUI

% Last Modified by GUIDE v2.5 22-Aug-2019 17:22:49

if verLessThan('matlab', '9.5')
    error('MWF GUI requires MATLAB version R2018b or later')
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @main_GUI_OutputFcn, ...
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

% --- Executes just before main_GUI is made visible.
function main_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_GUI (see VARARGIN)

%Set default GUI size, relative to the screen size
set(handles.Main_GUI,'Units','Pixels','Position',get(0,'ScreenSize').*[1 1 0.8 0.8]);

%Make topoplot figure square regardless of screensize
screensize = get(0,'ScreenSize');
current_position = get(handles.Topo_Figure,'Position');
set(handles.Topo_Figure,'Position',current_position.*[1 1 screensize(4)/screensize(3) 1]);

%Constants
%Plot range in seconds
PLOT_RANGE = 5;
%Amount of delay samples for MWF (see mwf_params.m documentation)
DELAY_SAMPLES = 5;
%Rank option for covariance matrix
%'full','poseig','pct' or 'first' (see mwf_params.m documentation)
RANK = 'poseig';
%Further rank options when rank = 'pct' or 'first' (see mwf_params.m documentation)
RANK_OPT = 10;
%Initial scale for different channels
INIT_SCALE_RATIO = 1/8;

%Load data
L = load('gui_demo_data.mat');
y = L.EEG_data;        % Raw EEG data, contains eye blink artifacts
fs = L.samplerate;     % EEG sample rate
t = 1/fs : 1/fs : length(y)/fs; %time vector
channels = (1:size(y,1))';
%Load initial marker positions: Nx2 matrix
try
    L = load('gui_demo_marks.mat');
    handles.marker_positions = L.marker_positions;
catch
    handles.marker_positions = [0 0];
end

%Load channel labels
try
    channel_labels = load('gui_channel_labels.mat');
    labels = channel_labels.labels;
    handles.label_status = 1;
catch
    labels = string(channels);
    handles.label_status = 0;
end

%Load EEG locations
try
    locs = load('gui_64_Channel_locations.mat');
    handles.topo_status = 1;
catch
    locs = -1;
    handles.topo_status = 0;
end

%Maximum scale makes sure all channels are separated from each other in the
%plot. Compute the range (min-max) of the channel with the maximum range
%and use this as distance betweeen the channel axes
temp1 = max(y,[],2);
temp2 = min(y,[],2);
diff = temp1-temp2;
scale = max(diff);
%Set initial scale
default_scale = scale*INIT_SCALE_RATIO;

%Initialize boxes
set(handles.Marker_Checkbox,'Value',0)
set(handles.Range_Inputbox,'String',PLOT_RANGE);
set(handles.Channels_Inputbox,'String','all');
set(handles.Scale_Slider,'Value',INIT_SCALE_RATIO)
set(handles.Slider_Button,'Value',0);
if(handles.topo_status == 1)
    set(handles.Enable_Mini_Topo_Checkbox,'Value',1);
else
    set(handles.Enable_Mini_Topo_Checkbox,'Value',0);
end
if(handles.label_status==1)
    set(handles.Channel_Name_Checkbox,'Value',1);
else
    set(handles.Channel_Name_Checkbox,'Value',0);
end

%Set button visibility
set(handles.FigureToolBar,'Visible','off');
set(handles.Start_Marker_Button,'visible','on');
set(handles.Restart_Marker_Button,'visible','on');
set(handles.Add_Marker_Button,'visible','off');
set(handles.Stop_Marker_Button,'visible','off');
if(handles.topo_status == 0)
    set(handles.Topoplot_Button,'visible','off');
    set(handles.Enable_Mini_Topo_Checkbox,'visible','off');
    h = handles.Topo_Figure;
    set(h,'visible','off')
    set(get(h,'children'),'visible','off'); %hide the current axes contents
    colorbar(h,'off');
end
if(handles.label_status == 0)
    set(handles.Channel_Name_Checkbox,'visible','off');
end

%Save values in handles struct
handles.y = y;
handles.fs = fs;
handles.t = t;
handles.channels = channels;
handles.scale = default_scale;
handles.max_scale = scale;
handles.labels = labels;
handles.locs = locs;

%Initialize plots and set their xlims equal
axes(handles.Figure_Top);
EEGplot(t,y,0,PLOT_RANGE,channels,default_scale,'-b',handles.label_status,labels);

%Convert marker positions to interactive ROIs
ROIs = marker_positions_to_ROI(handles.marker_positions,handles);

%Store data to be shared between GUIs as appdata (needs to be communicated between GUIs)
setappdata(0  , 'Main_GUI'    , gcf);
setappdata(gcf,   'compute_options'    , {DELAY_SAMPLES,RANK,RANK_OPT});
setappdata(gcf, 'data',y);
setappdata(gcf, 'fs',fs);
setappdata(gcf, 'artifact',-1);
setappdata(gcf, 'clean',-1);
setappdata(gcf, 'ROIs',ROIs);
%Indicates whether marking process busy
setappdata(gcf, 'markingstatus',0);

%Link top and bottom axes so they share their zoom
ax1 = handles.Figure_Top;
ax2 = handles.Figure_Bottom;
linkaxes([ax1,ax2]);

%Add a contextmenu to the top figure that is called at a right click. This
%lets the user create a new marker by calling the new_ROI function
hcmenu = uicontextmenu(gcf);
item1 = uimenu(hcmenu, 'Label', 'New Marker', 'Callback', @(src,event)new_ROI(src,event,hObject,handles));
set(handles.Figure_Top,'uicontextmenu',hcmenu);

%Add contextmenus to the curves in addition to the figure as a whole
c = ax1.Children;
for i = 1:length(c)
    h = c(i);
    hcmenu = uicontextmenu(gcf);
    item1 = uimenu(hcmenu, 'Label', 'New Marker', 'Callback', @(src,event)new_ROI(src,event,hObject,handles));
    set(h,'uicontextmenu',hcmenu);
end

%Automatically update range field and time slider when zooming
addlistener(handles.Figure_Top,'XLim','PostSet',@(src,event)limit_listener(src,event,handles));
%Trigger listener to create initial topoplot
axes(handles.Figure_Top);
x = xlim;
xlim(x);

% Choose default command line output for main_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = main_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Plot Buttons

function Range_Inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to Range_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Range_Inputbox as text
%        str2double(get(hObject,'String')) returns contents of Range_Inputbox as a double

%Check input
input = str2double(get(hObject,'String'));
if(isnan(input))
    waitfor(msgbox('Error: range input should be a number','Error','error'));
else
    %Reposition using the slider value
    h = handles.Slider_Button;
    Slider_Button_Callback(h,eventdata,handles);
end

% --- Executes during object creation, after setting all properties.
function Range_Inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Range_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function Slider_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Slider_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Position slider and adapt limits
axes(handles.Figure_Top);
y = handles.y;
len = length(y)/handles.fs;
p = get(hObject,'Value');
range = str2double(get(handles.Range_Inputbox,'String'));
x1 = p*(len-range);
set(handles.Figure_Top,'XLim',[x1 x1+range]);

% --- Executes during object creation, after setting all properties.
function Slider_Button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function Scale_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Scale_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%Update scale
p = get(hObject,'Value');
handles.scale = p*handles.max_scale;
guidata(hObject,handles);
%Update plots with new scale
updateplot_bottom(handles);
updateplot_top(handles);

% --- Executes during object creation, after setting all properties.
function Scale_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scale_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%Main plot function button
function Channels_Inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to Channels_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Channels_Inputbox as text
%        str2double(get(hObject,'String')) returns contents of Channels_Inputbox as a double
str = get(hObject,'String');
%Parse string to get channel vector
handles.channels = vectorparser(str,handles);

%Check if correct input
max_channel = size(handles.y,1);
status = all(handles.channels >= 1 & handles.channels <= max_channel);
if(status == 0)
    waitfor(msgbox('Error: Invalid channel input','Error','error'));
else

    guidata(hObject,handles);
    %Update plots
    updateplot_bottom(handles);
    updateplot_top(handles);
end

% --- Executes during object creation, after setting all properties.
function Channels_Inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Channels_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Overlay_Checkbox.
function Overlay_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Overlay_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Overlay_Checkbox

%Update top plot with overlay
updateplot_top(handles);


% --- Executes on selection change in Extraction_Removal_Popup.
function Extraction_Removal_Popup_Callback(hObject, eventdata, handles)
% hObject    handle to Extraction_Removal_Popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Extraction_Removal_Popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Extraction_Removal_Popup

%Update plots with output signal selection
updateplot_bottom(handles);
updateplot_top(handles);


% --- Executes during object creation, after setting all properties.
function Extraction_Removal_Popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Extraction_Removal_Popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Channel_Name_Checkbox.
function Channel_Name_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Channel_Name_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channel_Name_Checkbox
updateplot_bottom(handles);
updateplot_top(handles);

%% Marker buttons

% --- Executes on button press in Marker_Checkbox.
function Marker_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Marker_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gcf = getappdata(0, 'Main_GUI');

if(getappdata(gcf,'markingstatus'))
    %Cancel button press during marking process
    set(hObject,'Value',0);
else
    %Add or remove shade markers based on checkbox value
    status = get(hObject,'Value');
    axes(handles.Figure_Top);
    if(status == 0)
        handles = remove_markers(hObject,handles);
    else
        handles = add_markers(hObject,handles);
    end
    guidata(hObject,handles);
end

% --- Executes on button press in Start_Marker_Button.
function Start_Marker_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Marker_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gcf = getappdata(0, 'Main_GUI');
%Initiate marking process
setappdata(gcf,'markingstatus',1);
%Remove current markers
h=handles.Marker_Checkbox;
temp = get(h,'Value');
if(temp == 1)
    handles = remove_markers(hObject,handles);
end
set(h,'Value',0);
%Adapt marker button visibility
set(handles.Add_Marker_Button,'visible','on');
set(handles.Stop_Marker_Button,'visible','on');
set(handles.Restart_Marker_Button,'visible','off');
set(hObject,'visible','off');
axes(handles.Figure_Top);
%Generate interactive ROIs from marker positions
ROIs = marker_positions_to_ROI(handles.marker_positions,handles);
%Set ROIs visible
for i = 1:length(ROIs)
    h = ROIs{i};
    set(h,'Visible','on');
end
gcf = getappdata(0, 'Main_GUI');
setappdata(gcf,'ROIs',ROIs);
guidata(hObject,handles);


% --- Executes on button press in Stop_Marker_Button.
function Stop_Marker_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_Marker_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gcf = getappdata(0, 'Main_GUI');
%Stop marking process
setappdata(gcf,'markingstatus',0);
ROIs = getappdata(gcf,'ROIs');
%Delete any removed ROIs
for i = 1:length(ROIs)
    h = ROIs{i};
    if(~isvalid(h))
        ROIs{i} = [];
    end
end
ROIs = ROIs(~cellfun('isempty',ROIs));

%Convert remaining ROIs to marker positions
marker_positions = ROI_to_marker_positions(ROIs);

%Set ROIs invisible
for i = 1:length(ROIs)
    h = ROIs{i};
    set(h,'Visible','off');
end
setappdata(gcf,'ROIs',ROIs);

%remove negative values from marker positions
handles.marker_positions= max(marker_positions,0);

handles = remove_markers(hObject,handles);

guidata(hObject,handles);
%Show shaded markers
h=handles.Marker_Checkbox;
set(h,'Value',1);
Marker_Checkbox_Callback(h,eventdata,handles);

%Adapt button visibility
set(handles.Add_Marker_Button,'visible','off');
set(handles.Stop_Marker_Button,'visible','off');
set(handles.Start_Marker_Button,'visible','on');
set(handles.Restart_Marker_Button,'visible','on');


% --- Executes on button press in Restart_Marker_Button.
function Restart_Marker_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Restart_Marker_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = questdlg('This will remove all current marker. Are you sure you want to proceed?', ...
	'Warning');
% Handle response
if(strcmp(answer,'Yes'))
    gcf = getappdata(0, 'Main_GUI');
    %Start marking process
    setappdata(gcf,'markingstatus',1);
    %Remove shaded markers
    h=handles.Marker_Checkbox;
    temp = get(h,'Value');
    if(temp == 1)
        handles = remove_markers(hObject,handles);
    end
    set(h,'Value',0);
    %Adapt marker button visibility
    set(handles.Add_Marker_Button,'visible','on');
    set(handles.Stop_Marker_Button,'visible','on');
    set(handles.Start_Marker_Button,'visible','off');
    set(hObject,'visible','off');
    %Clear marker positions and ROIs
    axes(handles.Figure_Top);
    handles.marker_positions = [];
    ROIs = {};
    gcf = getappdata(0, 'Main_GUI');
    setappdata(gcf,'ROIs',ROIs);
    guidata(hObject,handles);   
end

% --- Executes on button press in Add_Marker_Button.
function Add_Marker_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Add_Marker_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Create ROI
axes(handles.Figure_Top);
h = drawrectangle(gca);

%Add a contextmenu to the ROI to be able to remove it
c = cell(1);
c{1} = h;
create_ROI_listeners(c);

%Append the created ROI to the current ROIs
gcf = getappdata(0, 'Main_GUI');
ROIs = getappdata(gcf,'ROIs');
ROIs{end+1} = h;
setappdata(gcf,'ROIs',ROIs);
guidata(hObject,handles);

%% Computation functions

% --- Executes on button press in Compute_button.
function Compute_button_Callback(hObject, eventdata, handles)
% hObject    handle to Compute_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.Figure_Bottom);

gcf = getappdata(0  , 'Main_GUI');
%Load computation options
compute_options = getappdata(gcf,   'compute_options');
if(~isempty(handles.marker_positions))
    %Perform computation
    [handles.clean, handles.estimate] = compute(handles.y,handles.marker_positions,handles.fs,compute_options);
    gcf = getappdata(0, 'Main_GUI');
    %Store results
    setappdata(gcf,'artifact',handles.estimate);
    setappdata(gcf,'clean',handles.clean);
    guidata(hObject,handles);
    
    
     %Plot relevant signal in bottom plot
    updateplot_bottom(handles);
    updateplot_top(handles);

else
    waitfor(msgbox('No markers selected','Error','error'));
end
% --- Executes on button press in Compute_Options_Button.
function Compute_Options_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Comute_Options_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open GUI for computation options 
Compute_options;
h = findobj('Tag','Compute_Options_GUI');
uiwait(h);
gcf = getappdata(0, 'Main_GUI');
compute_options   = getappdata(gcf, 'compute_options');

% --- Executes on button press in Topoplot_Button.
function Topoplot_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Topoplot_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open Topoplot GUI
Topoplot_GUI;
% --- Executes on button press in Enable_Mini_Topo_Checkbox.
function Enable_Mini_Topo_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Enable_Mini_Topo_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Enable_Mini_Topo_Checkbox
h = handles.Topo_Figure;
if(get(hObject,'Value') == 0)
    set(get(h,'children'),'visible','off'); %hide the current axes contents
    colorbar(h,'off');
else    
    %Update minitopopolot
    y = handles.y;
    x= get(handles.Figure_Top,'XLim');
    y_segment = y(:,1+floor(x(1)*handles.fs) : floor(x(2)*handles.fs));
    axes(handles.Topo_Figure);
    mini_topoplot(y_segment,handles.locs);
    
    set(get(h,'children'),'visible','on'); %show the current axes contents

end

%% Menu buttons

% --------------------------------------------------------------------
function File_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to File_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Save_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_Data_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Data_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Select file with standard folder interface
file = uigetfile;
L = load(file);
if(~isempty(L))
    %Load data
    y = L.EEG_data;             % Raw EEG data, contains eye blink artifacts
    fs = L.samplerate;     % EEG sample rate
    t = 1/fs : 1/fs : length(y)/fs; %time vector
    temp1 = max(y,[],2);
    temp2 = min(y,[],2);
    diff = temp1-temp2;
    scale = max(diff);

    %Initialize plots and set their xlims equal
    axes(handles.Figure_Top);
    handles.y = y;
    handles.fs = fs;
    handles.t = t;
    handles.max_scale = scale;

    guidata(hObject,handles);
    
    updateplot_top(handles);
end


% --------------------------------------------------------------------
function Load_Marks_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Marks_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Select file with standard folder interface
[file,path] = uigetfile;
L = load(strcat(path,file));
gcf = getappdata(0, 'Main_GUI');
ROIs = getappdata(gcf,'ROIs');
if(~isempty(L))
    handles.marker_positions = L.marker_positions;
    guidata(hObject,handles);

    %Remove old markers
    h = handles.Marker_Checkbox;
    handles = remove_markers(hObject,handles);
    set(h,'Value',1);
    Marker_Checkbox_Callback(h,eventdata,handles);
    handles = guidata(h);
    
    gcf = getappdata(0, 'Main_GUI');
    if(getappdata(gcf,'markingstatus'))
        for i = 1:length(ROIs)
            delete(ROIs{i});
        end
        ROIs = marker_positions_to_ROI(handles.marker_positions,handles);
        for i = 1:length(ROIs)
            h = ROIs{i};
            set(h,'Visible','on');
        end
        setappdata(gcf,'ROIs',ROIs);
    end
end

guidata(hObject,handles);

function Load_Labels_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Labels_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Select file with standard folder interface
file = uigetfile;
L = load(file);
if(~isempty(L))
    %Load data
    labels = L.labels;
    handles.labels=labels;
    handles.label_status = 1;
    set(handles.Channel_Name_Checkbox,'visible','on');
    set(handles.Channel_Name_Checkbox,'Value',1);
    guidata(hObject,handles);
    updateplot_bottom(handles);
    updateplot_top(handles);    
end

% --------------------------------------------------------------------
function Load_Locations_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Locations_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Select file with standard folder interface

file = uigetfile;
handles.locs = load(file);
if(~isempty(handles.locs))
    %Load data
    handles.topo_status = 1;
    set(handles.Enable_Mini_Topo_Checkbox,'visible','on');
    %set(handles.Enable_Mini_Topo_Checkbox,'Value',1);
    set(handles.Topoplot_Button,'visible','on');

    guidata(hObject,handles);
    %updateplot_bottom(handles);
    %updateplot_top(handles);    
end

% --------------------------------------------------------------------
function Save_Clean_Signal_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Clean_Signal_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isfield(handles,'clean'))
    filter = {'.mat'};
    [file,path] = uiputfile(filter);
    clean = handles.clean;
    save(strcat(path,file),'clean');
else
    waitfor(msgbox('No clean signal to export','Error','error'));
end


% --------------------------------------------------------------------
function Save_Extracted_Signal_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Extracted_Signal_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isfield(handles,'estimate'))
    filter = {'.mat'};
    [file,path] = uiputfile(filter);
    estimate = handles.estimate;
    save(strcat(path,file),'estimate');
else
    waitfor(msgbox('No estimated signal to export','Error','error'));
end

% --------------------------------------------------------------------
function Save_Marks_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Marks_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter = {'.mat'};
[file,path] = uiputfile(filter);
marker_positions = handles.marker_positions;
save(strcat(path,file),'marker_positions');

%% Functions

%Function to plot different EEG channels
%Plots the EEG channels centered around different horizontal axes,
%separated by a distance indicated by scale.
%Input: t:              time vector (1xN)
%       y:              EEG data matrix (CxN), each row is a channel
%       start:          start time (s)
%       len:            plot range(s)
%       channels:       vector containing the channels to be plotted
%       scale:          distance between channel axes
%       linestyle:      plot linestyle (e.g. '-b')
%       enable_label:   enable y axis labeling with channel names (boolean)
%       labels:         string array of channel names

function EEGplot(t,y,start,len,channels,scale,linestyle,enable_label,labels)
%Select channels
y = y(channels,:);
%Add different baseline to each channel to separate them
y = y+scale*(1:length(channels))';
plot(t,y,linestyle);
%Label y axis with channel number or channel names
if(scale > 0)
    yticks(scale*(1:length(channels)));
    if(enable_label)
        yticklabels(labels(channels));
    else
        yticklabels(string(channels));
    end
end
set(gca,'fontsize',6);
xlim([start start+len]);
xlabel('Time [s]');

%Perform computation function of the GUI
%In this instance, the computation is the calculation of a multi-channel
%Wiener filter (MWF) based on the current markers. The MWF is then applied
%to the EEG data
function [n,d] = compute(y,markings,fs,options)

%Build mask from markings
mask = zeros(1,size(y,2));
for i = 1:size(markings,1)
    mask(:,floor(1+markings(i,1)*fs):ceil(markings(i,2)*fs)) = 1;
end
%Decode options
params = mwf_params( 'delay', options{1}, 'rank', options{2}, 'rankopt',options{3});
%Compute MWF
W = mwf_compute_gui(y, mask, params);
%Apply MWF to input data
[n, d] = mwf_apply(y, W);

%Update axis limits of both top and bottom axes simultaneously to [x1, x2]
function updateLim(handles,x1,x2)
axes(handles.Figure_Top)
xlim([x1 x2])
y = ylim;
axes(handles.Figure_Bottom);
xlim([x1 x2]);
ylim(y);

%Add shaded markers to the top figure at the positions indicated by the
%marker_positions field
function new_handles = add_markers(hObject, handles)
axes(handles.Figure_Top);
y=ylim;
handles.hRectangles = {};
[~,idx] = sort(handles.marker_positions(:,1),'ascend');
handles.marker_positions = handles.marker_positions(idx,:);
for i = 1:size(handles.marker_positions,1)
    handles.hRectangles{end+1} = rectangle('Position',[handles.marker_positions(i,1),y(1),handles.marker_positions(i,2)-handles.marker_positions(i,1),y(2)-y(1)],'FaceColor',[1 0 0 .4]);
end

%If marker positions start at beginning
if(~ismember(0,handles.marker_positions) && size(handles.marker_positions,1) >= 1)
    handles.hRectangles{end+1} = rectangle('Position',[0,y(1),handles.marker_positions(1,1),y(2)-y(1)],'FaceColor',[0 1 0 .4]);
end
for i = 1:size(handles.marker_positions,1)-1
    handles.hRectangles{end+1} = rectangle('Position',[handles.marker_positions(i,2),y(1),handles.marker_positions(i+1,1)-handles.marker_positions(i,2),y(2)-y(1)],'FaceColor',[0 1 0 .4]);
end
new_handles = handles;

%Remove the shaded markers from the figure
function new_handles = remove_markers(hObject, handles)
if(isfield(handles,'hRectangles'))
    for i = 1:length(handles.hRectangles)
        delete(handles.hRectangles{i});
    end
    handles = rmfield(handles,'hRectangles');
end
new_handles = handles;

%Extracts channels from input string, that is defined as
%'ch1,ch2,chx-chy,...' with ch1 and ch2 indicating two separate channels to
%be added and chx-chy indicating a range of channels from chx to chy (e.g.
%1,2,5-12 ) Input might also be simply 'all'
function [channels] = vectorparser(str,handles)
if(strcmp(str,'all') == 1)
    channels = 1:size(handles.y,1);
else
    split_str = split(str,',');
    channels = [];
    for i = 1:length(split_str)
        substr = split_str{i};
        if(isempty(strfind(substr,'-')))
            channels = [channels str2num(substr)];
        else
            nums = regexp(substr,'\d*','Match');
            nums = str2double(nums);
            if(nums(2)>nums(1))
                channels = [channels nums(1):nums(2) ];
            else
                channels  = -1;
                break;
            end
        end
    end
end
channels = channels';

%Convert marker positions to interactive ROIs
function ROIs = marker_positions_to_ROI(marker_positions,handles)
axes(handles.Figure_Top);
yl = ylim;
ROIs = {};
for i = 1:size(marker_positions,1)
    xstart = marker_positions(i,1);
    ystart = yl(1);
    width = marker_positions(i,2)-marker_positions(i,1);
    height = yl(2)-yl(1);
    h = drawrectangle('Position',[xstart,ystart,width,height],'Visible','off');
    ROIs{end+1} = h; 
end
create_ROI_listeners(ROIs);

%Extract marker positions from interactive ROIs
function marker_positions = ROI_to_marker_positions(ROIs)
marker_positions = [];
for i = 1:length(ROIs)
  h = ROIs{i};
  pos = get(h,'Position');
  marker_positions = [marker_positions; [pos(1), pos(1) + pos(3)]];

end

%Add uicontextmenu to remove the ROI by rightclicking it. The menu is
%positioned to appear at the center of the ROI. This is done by calling
%setcontextmenu() when the uicontextmenu is made visibile
function create_ROI_listeners(ROIs)
    for i = 1:length(ROIs)
        h = ROIs{i};
        hcmenu = uicontextmenu(gcf);
        item1 = uimenu(hcmenu, 'Label', 'Delete', 'Callback', @(src,event)deleteROI(src,event,h));
        addlistener(hcmenu,'Visible','PostSet',@(src,event)setcontextmenu(src,event,h));
        set(h,'uicontextmenu',hcmenu);
    end

%Delete an ROI (defined as an anonymous function to work in conjunction
%with create_ROI_listeners(ROIs)
function deleteROI(src,event,h)
    delete(h);

%Position uicontextmenu of the ROI to the center of the ROI
function setcontextmenu(src,event,rectangle)
    u = rectangle.UIContextMenu;
    
    %Get axes position in figure (in pixels)
    a = gca;
    set(a,'Units','pixels');
    ax_pos = get(a,'Position');
    set(a,'Units','normalized');
    base = [ax_pos(1) ax_pos(2)];
    
    %Get rectangle position in axes and rescale
    rect_pos_seconds = get(rectangle,'Position');
    
    ax_width_pixels = ax_pos(3);
    ax_height_pixels = ax_pos(4);
    xlim_seconds = xlim;
    ax_width_seconds = diff(xlim_seconds);
    ax_start_x_seconds = xlim_seconds(1);
    ylim_seconds = ylim;
    ax_height_seconds = diff(ylim_seconds);
    ax_start_y_seconds = ylim_seconds(1);
    
    rect_x_pixels = (-ax_start_x_seconds+rect_pos_seconds(1)+rect_pos_seconds(3)/2)* (ax_width_pixels/ax_width_seconds);
    rect_y_pixels = (-ax_start_y_seconds+rect_pos_seconds(2)+rect_pos_seconds(4)/2)* (ax_height_pixels/ax_height_seconds);
    
    offset = [rect_x_pixels rect_y_pixels];
    
    set(u,'Position',base+offset);

%Create new ROI, but only during the marking process
function new_ROI(src,event,hObject,handles)
gcf = getappdata(0, 'Main_GUI');
if(getappdata(gcf,'markingstatus'))
    axes(handles.Figure_Top);
    h = drawrectangle(gca);

    c = cell(1);
    c{1} = h;
    create_ROI_listeners(c);

    ROIs = getappdata(gcf,'ROIs');

    ROIs{end+1} = h;
    setappdata(gcf,'ROIs',ROIs);
end

%Update the top plot with the current GUI settings
function updateplot_top(handles)

%Check if overlay of top and bottom plot is necessary
overlay = get(handles.Overlay_Checkbox,'Value');

gcf = getappdata(0, 'Main_GUI');
ROIs = getappdata(gcf,'ROIs');

%Store current ROIs
marker_positions = ROI_to_marker_positions(ROIs);

%Plot original data with current channels and scale selection
axes(handles.Figure_Top);
x = xlim;
enable_label = get(handles.Channel_Name_Checkbox,'Value');
EEGplot(handles.t,handles.y,x(1),x(2)-x(1),handles.channels,handles.scale,'-b',enable_label,handles.labels);

%Plot overlaid data if necessary
if(overlay == 1)
    hObject = handles.Overlay_Checkbox;

    if(isfield(handles,'estimate') && isfield(handles,'clean'))
        
        h = handles.Extraction_Removal_Popup;
        str = get(h, 'String');
        val = get(h,'Value');

        % Select data to plot
        switch str{val}
            case 'Artifact'
                t = handles.t;
                y = handles.estimate;
                string_legend = 'Artifact';

            case 'Clean'
                t = handles.t;
                y = handles.clean;
                string_legend = 'Clean';
        end

        axes(handles.Figure_Top)
        x=xlim;
        hold on;
        
        EEGplot(t,y,x(1),x(2)-x(1),handles.channels,handles.scale,'-r',enable_label,handles.labels);
        axes(handles.Figure_Top);
        l = get(gca,'Legend');
        if(isempty(l))
            h(1) = plot(NaN,NaN,'-b');
            h(2) = plot(NaN,NaN,'-r');  
            legend(h,'Original',string_legend);
        else
            set(l,'String',{'Original',string_legend});
        end
    else
        waitfor(msgbox('No output signal to overlay','Error','error'));
        set(hObject,'Value',0);
    end
end

hold off;

%Plot markers
hObject = handles.Marker_Checkbox;
gcf = getappdata(0, 'Main_GUI');
if(getappdata(gcf,'markingstatus'))
    set(hObject,'Value',0);
else
    status = get(hObject,'Value');
    axes(handles.Figure_Top);
    if(status == 0)
        handles = remove_markers(hObject,handles);
    else
        handles = add_markers(hObject,handles);
    end
    guidata(hObject,handles);
end
    
ROIs = marker_positions_to_ROI(marker_positions,handles);
%Update ROI when marking
gcf = getappdata(0, 'Main_GUI');
if(getappdata(gcf,'markingstatus'))
    for i = 1:length(ROIs)
        h = ROIs{i};
        set(h,'Visible','on');
    end
end
gcf = getappdata(0, 'Main_GUI');
setappdata(gcf,'ROIs',ROIs);

%Add menus for ROI creation to curves in addition to figure itself
ax1 = handles.Figure_Top;
c = ax1.Children;
for i = 1:length(c)
    h = c(i);
    hcmenu = uicontextmenu(gcf);
    item1 = uimenu(hcmenu, 'Label', 'New Marker', 'Callback', @(src,event)new_ROI(src,event,hObject,handles));
    set(h,'uicontextmenu',hcmenu);
end

guidata(hObject,handles);

%Update the bottom plot with the current GUI settings
function updateplot_bottom(handles)

hObject = handles.Extraction_Removal_Popup;
if(isfield(handles,'estimate') && isfield(handles,'clean'))

    str = get(hObject, 'String');
    val = get(hObject,'Value');

    % Select data to plot
    switch str{val}
        case 'Artifact'
            t = handles.t;
            y = handles.estimate;

        case 'Clean'
            t = handles.t;
            y = handles.clean;
    end

    axes(handles.Figure_Top)
    x=xlim;
    axes(handles.Figure_Bottom)
    enable_label = get(handles.Channel_Name_Checkbox,'Value');
    EEGplot(t,y,x(1),x(2)-x(1),handles.channels,handles.scale,'-b',enable_label,handles.labels);
end

function limit_listener(src,event,handles)
x= get(handles.Figure_Top,'XLim');
%Update range field
range = diff(x);
set(handles.Range_Inputbox,'String',num2str(range));
%Update time slider
y = handles.y;
len = length(y)/handles.fs;
slider_pos = min(max(x(1)/(len-range),0),1);
set(handles.Slider_Button,'Value',slider_pos);

%Update minitopopolot
if(get(handles.Enable_Mini_Topo_Checkbox,'Value') == 1)
    y = handles.y;
    y_segment = y(:,1+floor(x(1)*handles.fs) : floor(x(2)*handles.fs));
    axes(handles.Topo_Figure);
    mini_topoplot(y_segment,handles.locs)
end

function mini_topoplot(data,locs,fs,freq_range)
L = size(data,1);

% Define electrodes placement according to the Emotiv Epoc+ headset
xc = locs.xi;
xc = xc(1:L);
yc = locs.yi;
yc = yc(1:L);
lbls = locs.labels;
lbls = lbls(1:L);
circ = locs.circumference;
r = circ/(2*pi);

if(nargin == 2)
    power = compute_energies(data);
elseif (isequal(freq_range,[-1 -1]))
    power = compute_energies(data);
else
    power = compute_energies(data,fs,freq_range);
end


ri = linspace(0,r,50);
thetai = linspace(0,2*pi,50);
[R, T] = meshgrid(ri,thetai);
XI = R.*cos(T);
YI = R.*sin(T);
[m,n]=size(XI);

F = scatteredInterpolant(xc,yc,power,'natural','linear');
ZI = F(XI,YI);
contourf(XI,YI,ZI,5);

% Turn off the plot labels and axis
set(gca,'Visible','off');
colormap(parula);

%Make sure colorbar insertion does not influence figure size
original_size = get(gca,'Position');
colorbar('eastoutside');
set(gca,'Position',original_size);
hold off;

function [out] = compute_energies(data,fs,freq_range)

L = size(data,2);
if(mod(L,2)==1)
    data = data(:,1:L-1);
    L=L-1;
end
% Method 1: simple FFT

out = [];
Y = fft(data')';
P2 = abs(Y/L);
P1 = P2(:,1:L/2+1);
P1(:,2:end-1) = 2*P1(:,2:end-1);

if(nargin ~= 1)
    f = fs*(0:(L/2))/L;
    [~,start_index] = min(abs(f-freq_range(1)));
    [~,stop_index] = min(abs(f-freq_range(2)));
    P1 = P1(:,start_index:stop_index);
end
pow = P1.^2;
out = sum(pow,2);