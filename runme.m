function varargout = runme(varargin)
% RUNME MATLAB code for runme.fig
%      RUNME, by itself, creates a new RUNME or raises the existing
%      singleton*.
%
%      H = RUNME returns the handle to a new RUNME or the handle to
%      the existing singleton*.
%
%      RUNME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNME.M with the given input arguments.
%
%      RUNME('Property','Value',...) creates a new RUNME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before runme_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to runme_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help runme

% Last Modified by GUIDE v2.5 18-Jun-2018 23:23:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @runme_OpeningFcn, ...
                   'gui_OutputFcn',  @runme_OutputFcn, ...
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


% --- Executes just before runme is made visible.
function runme_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to runme (see VARARGIN)

% Choose default command line output for runme
handles.output = hObject;

% Default Settings
handles.pixel_to_crop  = 60;
handles.max_corner_distance = 10;


handles.winSize   = 61;
handles.bgTh      = 30;

handles.locX      = 149;
handles.locY      = 12;
handles.locW      = 94;
handles.locH      = 270;

% Default background image
handles.background_img = '..\INPUT\background.jpg';
default_gui_bg = '..\INPUT\background7.jpg';
% Check stabilized Video
handles.stabilized_vidPath = '..\OUTPUT\stabilized.avi';
if exist(handles.stabilized_vidPath, 'file') == 2
    set(handles.pushbutton_play_stabilization,'Enable','on')
else
    set(handles.pushbutton_play_stabilization,'Enable','off')
end
% Check extracted Video
handles.extracted_vidPath = '..\OUTPUT\extracted.avi';
if exist(handles.stabilized_vidPath, 'file') == 2
    set(handles.pushbutton_play_stabilization,'Enable','on')
else
    set(handles.pushbutton_play_stabilization,'Enable','off')
end
% Check matted Video
handles.matted_vidPath = '..\OUTPUT\matted.avi';
if exist(handles.stabilized_vidPath, 'file') == 2
    set(handles.pushbutton_play_stabilization,'Enable','on')
else
    set(handles.pushbutton_play_stabilization,'Enable','off')
end
% Check OUTPUT Video
handles.OUTPUT_vidPath = '..\OUTPUT\OUTPUT.avi';
if exist(handles.stabilized_vidPath, 'file') == 2
    set(handles.pushbutton_play_stabilization,'Enable','on')
else
    set(handles.pushbutton_play_stabilization,'Enable','off')
end

% % This creates the 'background' axes for gui
% ha = axes('units','normalized','position',[0 0 1 1]);
% % Move the background axes to the bottom
% uistack(ha,'bottom'); gui_bg=imread(default_gui_bg); imagesc(gui_bg);
% % Also, make the axes invisible
% set(ha,'handlevisibility','off', 'visible','off')


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes runme wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = runme_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_input_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_input_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_input_path as text
%        str2double(get(hObject,'String')) returns contents of edit_input_path as a double


% --- Executes during object creation, after setting all properties.
function edit_input_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_input_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_output_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_output_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_output_path as text
%        str2double(get(hObject,'String')) returns contents of edit_output_path as a double


% --- Executes during object creation, after setting all properties.
function edit_output_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_output_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_input.
function pushbutton_input_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file_name,dir_path] = uigetfile('*.avi', 'Select INPUT video', '..\INPUT\INPUT.avi');
if file_name == 0
    set(handles.edit_input_path, 'String', '..\INPUT\INPUT.avi');
else
    if strcmp(dir_path(end-5:end),'INPUT\')
        set(handles.edit_input_path, 'String', ['..\INPUT\' file_name]);
    else
        set(handles.edit_input_path, 'String', [dir_path file_name]);
    end
end


% --- Executes on button press in pushbutton_output.
function pushbutton_output_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir_path = uigetdir('..\OUTPUT\', 'Select output directory');
if dir_path == 0
    set(handles.edit_output_path, 'String', '..\OUTPUT\');
else
    if strcmp(dir_path(end-5:end),'OUTPUT')
        set(handles.edit_output_path, 'String', '..\OUTPUT\');
    else
        set(handles.edit_output_path, 'String', dir_path);
    end
end


% --- Executes on button press in pushbutton_run_all.
function pushbutton_run_all_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_run_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_stabilization.
function pushbutton_stabilization_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stabilization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ handles.stabilization_status ] = stabilize( get(handles.edit_input_path,'String'), get(handles.edit_output_path,'String'), handles.pixel_to_crop, handles.max_corner_distance);
if handles.stabilization_status == 0
    set(handles.text_err,'String','Stabilization completed', 'ForegroundColor', [0 1 0])
else
    set(handles.text_err,'String','Stabilization failed', 'ForegroundColor', [1 0 0])
end
set(handles.pushbutton_play_stabilization,'Enable','on')



% --- Executes on button press in pushbutton_background.
function pushbutton_background_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_matting.
function pushbutton_matting_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_matting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_tracking.
function pushbutton_tracking_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_person.
function checkbox_person_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_person (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_person


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_close_Callback(hObject, eventdata, handles)
% hObject    handle to menu_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq;


% --------------------------------------------------------------------
function menu_option_Callback(hObject, eventdata, handles)
% hObject    handle to menu_option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_play_stabilization.
function pushbutton_play_stabilization_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_stabilization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if exist(handles.stabilized_vidPath, 'file') == 2
        implay(handles.stabilized_vidPath);
        set(handles.text_err,'String',' ')
    else 
        set(handles.text_err,'String','First Run video stabilization to create video', 'ForegroundColor', [1 0 0])
    end


% --- Executes on button press in pushbutton_play_background.
function pushbutton_play_background_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if exist(handles.extracted_vidPath, 'file') == 2
        implay(handles.stabilized_vidPath);
        set(handles.text_err,'String',' ')
    else 
        set(handles.text_err,'String','First Run background subtraction to create video', 'ForegroundColor', [1 0 0])
    end


% --- Executes on button press in pushbutton_play_matting.
function pushbutton_play_matting_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_matting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if exist(handles.matted_vidPath, 'file') == 2
        implay(handles.stabilized_vidPath);
        set(handles.text_err,'String',' ')
    else 
        set(handles.text_err,'String','First Run video matting to create video', 'ForegroundColor', [1 0 0])
    end


% --- Executes on button press in pushbutton_play_person.
function pushbutton_play_person_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_person (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if exist(handles.OUTPUT_vidPath, 'file') == 2
        implay(handles.stabilized_vidPath);
        set(handles.text_err,'String',' ')
    else 
        set(handles.text_err,'String','First Run person tracking to create video', 'ForegroundColor', [1 0 0])
    end


% --- Executes on button press in pushbutton_change_background.
function pushbutton_change_background_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_change_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file_name,dir_path] = uigetfile('*.jpg', 'Select Background image', '..\INPUT\background.jpg');
if file_name == 0
    handles.background_img = '..\INPUT\background.jpg';
else
    if strcmp(dir_path(end-5:end),'INPUT\')
        handles.background_img = ['..\INPUT\' file_name];
    else
        handles.background_img = [dir_path file_name];
    end
end




% --- Executes on button press in pushbutton_manual_person_selection.
function pushbutton_manual_person_selection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_manual_person_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_play_INPUT_video.
function pushbutton_play_INPUT_video_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_INPUT_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if exist(get(handles.edit_input_path, 'String'), 'file') == 2
        implay(get(handles.edit_input_path, 'String'));
        set(handles.text_err,'String',' ')
    else 
        set(handles.text_err,'String','First select INPUT video', 'ForegroundColor', [1 0 0])
    end
