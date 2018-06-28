function varargout = test_fig(varargin)
% TEST_FIG MATLAB code for test_fig.fig
%      TEST_FIG, by itself, creates a new TEST_FIG or raises the existing
%      singleton*.
%
%      H = TEST_FIG returns the handle to a new TEST_FIG or the handle to
%      the existing singleton*.
%
%      TEST_FIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_FIG.M with the given input arguments.
%
%      TEST_FIG('Property','Value',...) creates a new TEST_FIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_fig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_fig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test_fig

% Last Modified by GUIDE v2.5 28-Jun-2018 00:44:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_fig_OpeningFcn, ...
                   'gui_OutputFcn',  @test_fig_OutputFcn, ...
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


% --- Executes just before test_fig is made visible.
function test_fig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test_fig (see VARARGIN)

% Choose default command line output for test_fig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test_fig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = test_fig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_input_Callback(hObject, eventdata, handles)
% hObject    handle to edit_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_input as text
%        str2double(get(hObject,'String')) returns contents of edit_input as a double


% --- Executes during object creation, after setting all properties.
function edit_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_play.
function pushbutton_play_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    implay(get(handles.edit_input, 'String'));

