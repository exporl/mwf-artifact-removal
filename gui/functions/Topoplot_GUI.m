function varargout = Topoplot_GUI(varargin)
%TOPOPLOT_GUI MATLAB code file for Topoplot_GUI.fig
%      TOPOPLOT_GUI, by itself, creates a new TOPOPLOT_GUI or raises the existing
%      singleton*.
%
%      H = TOPOPLOT_GUI returns the handle to a new TOPOPLOT_GUI or the handle to
%      the existing singleton*.
%
%      TOPOPLOT_GUI('Property','Value',...) creates a new TOPOPLOT_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Topoplot_GUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TOPOPLOT_GUI('CALLBACK') and TOPOPLOT_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TOPOPLOT_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Topoplot_GUI

% Last Modified by GUIDE v2.5 04-May-2019 20:12:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Topoplot_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Topoplot_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before Topoplot_GUI is made visible.
function Topoplot_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

set(handles.Topoplot_GUI,'Units','Pixels','Position',get(0,'ScreenSize').*[1 1 0.6 0.6]);

%Make topoplot figure square regardless of screensize
%screensize = get(0,'ScreenSize');
screensize = get(handles.Topoplot_GUI,'Position');
current_position = get(handles.axes2,'Position');
set(handles.axes2,'Position',current_position.*[1 1 current_position(4)/current_position(3) 1]);
current_position = get(handles.axes2,'Position');
set(handles.axes2,'Position',current_position.*[1 1 screensize(4)/screensize(3)  1]);

DEFAULT_LOCS = load('gui_64_Channel_locations.mat');
DEFAULT_RANGE = 1;
DEFAULT_FREQ_RANGE = [-1 -1];
DEFAULT_FRAMERATE = 1;
DEFAULT_FRAME_OVERLAP = 0.5;
DEFAULT_FILENAME = 'topoplot.gif';

gcf = getappdata(0, 'Main_GUI');
y = getappdata(gcf,'data');
handles.y = y;
fs = getappdata(gcf,'fs');
handles.fs = fs;
handles.locs = DEFAULT_LOCS;
handles.range = DEFAULT_RANGE;
handles.freq_range = DEFAULT_FREQ_RANGE;
handles.framerate = DEFAULT_FRAMERATE;
handles.frame_overlap = DEFAULT_FRAME_OVERLAP;
handles.filename = DEFAULT_FILENAME;

axes(handles.axes2);
y_segment = y(:,1:DEFAULT_RANGE*fs);
topoplot(y_segment,handles.locs,1);


set(handles.Topo_Range_Inputbox,'String',DEFAULT_RANGE);
set(handles.Time_Outputbox,'String','0-1');
set(handles.Freq_Inputbox,'String','all');


% Choose default command line output for Topoplot_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Topoplot_GUI wait for user response (see UIRESUME)
% uiwait(handles.Topoplot_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = Topoplot_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in Topo_Signal_Popup.
function Topo_Signal_Popup_Callback(hObject, eventdata, handles)
% hObject    handle to Topo_Signal_Popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Topo_Signal_Popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Topo_Signal_Popup

gcf = getappdata(0, 'Main_GUI');

str = get(hObject, 'String');
val = get(hObject,'Value');

switch str{val}
    case 'Original'
        handles.y = getappdata(gcf,'data');
    case 'Artifact'
        y = getappdata(gcf,'artifact');
        if(y == -1)
            waitfor(msgbox('No artifact signal has been computed yet','Error','error'));
            set(hObject,'Value',1);
        else
            handles.y=y;
        end
    case 'Clean'
        y = getappdata(gcf,'clean');
        if(y == -1)
            waitfor(msgbox('No clean signal has been computed yet','Error','error'));
            set(hObject,'Value',1);
        else
            handles.y=y;
        end
            
end
guidata(hObject,handles);
h = handles.Topo_Slider_Button;
Topo_Slider_Button_Callback(h,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function Topo_Signal_Popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Topo_Signal_Popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on Topo_Slider movement.
function Topo_Slider_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Topo_Slider_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of Topo_Slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of Topo_Slider
%Position Topo_Slider and adapt limits
axes(handles.axes2);
y = handles.y;
fs=handles.fs;
len = size(y,2)/fs;
p = get(hObject,'Value');
start = p*(len-handles.range);
y_segment = y(:,1+floor(start*fs):floor((start+handles.range)*fs));
enable_label = get(handles.Topo_Channel_Names_Checkbox,'Value');
topoplot(y_segment,handles.locs,enable_label,fs,handles.freq_range);

str = [num2str(round(start,1)) '-' num2str(round(start+handles.range,1))];
set(handles.Time_Outputbox,'String',str);


% --- Executes during object creation, after setting all properties.
function Topo_Slider_Button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Topo_Slider_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% Hint: Topo_Slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function Topo_Range_Inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to Topo_Range_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Topo_Range_Inputbox as text
%        str2double(get(hObject,'String')) returns contents of Topo_Range_Inputbox as a double
%Update range value
input = str2double(get(hObject,'String'));
if(isnan(input) || input < 0 || input > size(handles.y,2)/handles.fs)
    waitfor(msgbox(['Input should be a positive number between 0 and ' num2str(size(handles.y,2)/handles.fs)] ,'Error','error'));
else

    handles.range = input;
    guidata(hObject, handles);
    %Reposition using the Topo_Slider value
    h = handles.Topo_Slider_Button;
    Topo_Slider_Button_Callback(h,eventdata,handles);
end
% --- Executes during object creation, after setting all properties.
function Topo_Range_Inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Topo_Range_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Time_Outputbox_Callback(hObject, eventdata, handles)
% hObject    handle to Time_Outputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Time_Outputbox as text
%        str2double(get(hObject,'String')) returns contents of Time_Outputbox as a double
axes(handles.axes2);
y = handles.y;
fs=handles.fs;
len = size(y,2)/fs;
p = str2double(get(hObject,'String'))/(len-handles.range);
if(isnan(p) || p<0 || p> 1)
    waitfor(msgbox(['Input should be a positive number between 0 and ' num2str(len-handles.range)] ,'Error','error'));
else
    h = handles.Topo_Slider_Button;
    set(h,'Value',p);
    Topo_Slider_Button_Callback(h,eventdata,handles);
end


% --- Executes during object creation, after setting all properties.
function Time_Outputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Time_Outputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Freq_Inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to Freq_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Freq_Inputbox as text
%        str2double(get(hObject,'String')) returns contents of Freq_Inputbox as a double
str = get(hObject,'String');
[start,stop] = freqparser(str,handles);

if(stop < start || stop > handles.fs/2)
    waitfor(msgbox(['Invalid frequency range input, enter a range between ' num2str(0) ' and ' num2str(handles.fs/2) ' Hz'],'Error','error'));
else

    handles.freq_range = [start stop];
    guidata(hObject,handles);
    h = handles.Topo_Slider_Button;
    Topo_Slider_Button_Callback(h, eventdata, handles);
end


% --- Executes during object creation, after setting all properties.
function Freq_Inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Freq_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [start,stop] = freqparser(str,handles)
if(strcmp(str,'all') == 1)
    start = -1;
    stop = -1;
else
    split_str = split(str,'-');
    start = str2double(split_str{1});
    stop = str2double(split_str{2});
end


function topoplot(data,locs,enable_label,fs,freq_range)
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

if(nargin == 3)
    power = compute_energies(data);
elseif (isequal(freq_range,[-1 -1]))
    power = compute_energies(data);
else
    power = compute_energies(data,fs,freq_range);
end


ri = linspace(0,r,200);
thetai = linspace(0,2*pi,200);
[R, T] = meshgrid(ri,thetai);
XI = R.*cos(T);
YI = R.*sin(T);
[m,n]=size(XI);

F = scatteredInterpolant(xc,yc,power,'natural','linear');
ZI = F(XI,YI);


%figure;
contourf(XI,YI,ZI,15);
hold on;
scatter(xc,yc,'k','filled');
if(enable_label)
    text(xc+1.5,yc-1.5,lbls,'FontSize',7,'FontUnits','normalized');
else
    text(xc+1.5,yc-1.5,string(1:length(xc)),'FontSize',7,'FontUnits','normalized');
end


% Turn off the plot labels and axis
set(gca,'Visible','off');
%colormap(flipud(autumn));
%colormap(jet);
colormap(parula);
%Make sure colorbar insertion does not influence figure size
original_size = get(gca,'Position');
colorbar('southoutside');
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

% Calculating power of each electrode
% for i=1:L
% ftr = (data(i,:));
% ftr = fft(ftr);
% pow = ftr.*conj(ftr);
% tpow = sum(pow);
% power = vertcat(power,tpow);
% end
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


% --- Executes on button press in Generate_GIF_Button.
function Generate_GIF_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Generate_GIF_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enable_label = get(handles.Topo_Channel_Names_Checkbox,'Value');
topoplot_time(handles.y,handles.fs,handles.filename,handles.range,handles.frame_overlap,handles.freq_range,handles.framerate,handles.locs,enable_label)

function Framerate_Inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to Framerate_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Framerate_Inputbox as text
%        str2double(get(hObject,'String')) returns contents of Framerate_Inputbox as a double
handles.framerate = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Framerate_Inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Framerate_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Filename_Inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to Filename_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Filename_Inputbox as text
%        str2double(get(hObject,'String')) returns contents of Filename_Inputbox as a double
handles.filename = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Filename_Inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filename_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Frame_Overlap_Inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to Frame_Overlap_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Frame_Overlap_Inputbox as text
%        str2double(get(hObject,'String')) returns contents of Frame_Overlap_Inputbox as a double
handles.frame_overlap = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Frame_Overlap_Inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frame_Overlap_Inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function topoplot_time(y,fs,filename,window_seconds,n_overlap_seconds,freq_range,framerate,locs,enable_label)

window = window_seconds*fs;
n_overlap = n_overlap_seconds*fs;

N = size(y,2);

finished = false;
index = 0;
delaytime = 1/framerate;
f= waitbar(0,'Starting gif generation','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(f,'canceling',0);

while ~finished
    
    if getappdata(f,'canceling')
        break
    end
    if(index ~=0)
        start = index+(window-n_overlap);
        stop = min(start+window-1, N);
    elseif(index == 0)
        start = 1;
        stop = window;
    end
    
    y_segment = y(:,start:stop);
    figure('visible','off');
    topoplot(y_segment,locs,enable_label,fs,freq_range);
    
    h = gcf;
    start_seconds = num2str(round(start/fs,1));
    stop_seconds = num2str(round(stop/fs,1));
    title([start_seconds 's - ' stop_seconds 's']);
    set(findall(gca, 'type', 'text'), 'visible', 'on')
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
      % Write to the GIF File 
      if index == 0 
          imwrite(imind,cm,filename,'gif', 'DelayTime',delaytime,'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','DelayTime',delaytime,'WriteMode','append'); 
      end 
   
    if(stop == N)
        finished = true;
    end
    index = start;
    if(index==0)
        index = 1;
    end
    waitbar(stop/N,f,'Processing');

  
end
delete(f);
if(finished)
    waitfor(msgbox('Gif generation finished!'));
else
    waitfor(msgbox('Gif generation aborted'));
end


% --- Executes on button press in Topo_Channel_Names_Checkbox.
function Topo_Channel_Names_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Topo_Channel_Names_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Topo_Channel_Names_Checkbox
Topo_Slider_Button_Callback(handles.Topo_Slider_Button,eventdata,handles);
