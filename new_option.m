function varargout = new_option(varargin)
% NEW_OPTION MATLAB code for new_option.fig
%      NEW_OPTION, by itself, creates a new NEW_OPTION or raises the existing
%      singleton*.
%
%      H = NEW_OPTION returns the handle to a new NEW_OPTION or the handle to
%      the existing singleton*.
%
%      NEW_OPTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEW_OPTION.M with the given input arguments.
%
%      NEW_OPTION('Property','Value',...) creates a new NEW_OPTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before new_option_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to new_option_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help new_option

% Last Modified by GUIDE v2.5 28-Jun-2018 00:37:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @new_option_OpeningFcn, ...
                   'gui_OutputFcn',  @new_option_OutputFcn, ...
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


% --- Executes just before new_option is made visible.
function new_option_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to new_option (see VARARGIN)

% Choose default command line output for new_option
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes new_option wait for user response (see UIRESUME)
% uiwait(handles.gui_2_option);


% --- Outputs from this function are returned to the command line.
function varargout = new_option_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2_ok.
function pushbutton2_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = findobj('Tag', 'gui_main');

if ~isempty(h)
   gui1Data = guidata(h);
   
   pixel_to_crop   = str2num(get(handles.edit2_px_to_crop,   'String'));
   max_corner_distance  = str2num(get(handles.edit2_px_max_dist,  'String'));
   bg_thresh        = str2num(get(handles.edit2_bg_thresh,        'String'));
   win_size     = str2num(get(handles.edit2_win_size,     'String'));
   loc_x        = str2num(get(handles.edit2_loc_x,        'String'));
   loc_y        = str2num(get(handles.edit2_loc_y,        'String'));
   loc_w        = str2num(get(handles.edit2_loc_w,        'String'));
   loc_h        = str2num(get(handles.edit2_loc_h,        'String'));
   
   if pixel_to_crop < 0
       errordlg('Invalid number of pixels to crop');
       return;
   elseif max_corner_distance < 0
   	    errordlg('Invalid maximum distance between points');
        return;
   elseif (bg_thresh < 0) && (bg_thresh > 255)
        errordlg('Invalid background theshold');
        return;
   elseif win_size == 0
       errordlg('Window size should be odd');
       return;
   elseif loc_x < 0 || loc_y < 0 || loc_w < 0 || loc_h < 0
       errordlg('Person bounding rect coordinates should be positive');
       return;
   end
   
   gui1Data.pixel_to_crop  = pixel_to_crop;
   gui1Data.max_corner_distance = max_corner_distance;
   gui1Data.bg_thresh      = bg_thresh;
   gui1Data.win_size   = win_size;
   gui1Data.loc_X      = loc_x;
   gui1Data.loc_Y      = loc_y;
   gui1Data.loc_W      = loc_w;
   gui1Data.loc_H      = loc_h;
   
  
   guidata(h, gui1Data);
end

closereq;


% --- Executes on button press in pushbutton2_cancel.
function pushbutton2_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq;



function edit2_loc_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit2_loc_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2_loc_x as text
%        str2double(get(hObject,'String')) returns contents of edit2_loc_x as a double


% --- Executes during object creation, after setting all properties.
function edit2_loc_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2_loc_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_loc_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit2_loc_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2_loc_y as text
%        str2double(get(hObject,'String')) returns contents of edit2_loc_y as a double


% --- Executes during object creation, after setting all properties.
function edit2_loc_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2_loc_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_loc_w_Callback(hObject, eventdata, handles)
% hObject    handle to edit2_loc_w (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2_loc_w as text
%        str2double(get(hObject,'String')) returns contents of edit2_loc_w as a double


% --- Executes during object creation, after setting all properties.
function edit2_loc_w_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2_loc_w (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_loc_h_Callback(hObject, eventdata, handles)
% hObject    handle to edit2_loc_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2_loc_h as text
%        str2double(get(hObject,'String')) returns contents of edit2_loc_h as a double


% --- Executes during object creation, after setting all properties.
function edit2_loc_h_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2_loc_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_bg_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit2_bg_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2_bg_thresh as text
%        str2double(get(hObject,'String')) returns contents of edit2_bg_thresh as a double


% --- Executes during object creation, after setting all properties.
function edit2_bg_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2_bg_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_win_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit2_win_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2_win_size as text
%        str2double(get(hObject,'String')) returns contents of edit2_win_size as a double


% --- Executes during object creation, after setting all properties.
function edit2_win_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2_win_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_px_max_dist_Callback(hObject, eventdata, handles)
% hObject    handle to edit2_px_max_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2_px_max_dist as text
%        str2double(get(hObject,'String')) returns contents of edit2_px_max_dist as a double


% --- Executes during object creation, after setting all properties.
function edit2_px_max_dist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2_px_max_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_px_to_crop_Callback(hObject, eventdata, handles)
% hObject    handle to edit2_px_to_crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2_px_to_crop as text
%        str2double(get(hObject,'String')) returns contents of edit2_px_to_crop as a double


% --- Executes during object creation, after setting all properties.
function edit2_px_to_crop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2_px_to_crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
