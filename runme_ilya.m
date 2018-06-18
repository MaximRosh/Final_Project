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

% Last Modified by GUIDE v2.5 05-Jun-2016 19:47:49

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
handles.pxToCrop  = 30;
handles.pxMaxDist = 10;
handles.winSize   = 61;
handles.bgTh      = 30;

handles.locX      = 149;
handles.locY      = 12;
handles.locW      = 94;
handles.locH      = 270;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes runme wait for user response (see UIRESUME)
% uiwait(handles.gui1);


% --- Outputs from this function are returned to the command line.
function varargout = runme_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radioRunAll.
function radioRunAll_Callback(hObject, eventdata, handles)
% hObject    handle to radioRunAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioRunAll


% --- Executes on button press in radioStabilize.
function radioStabilize_Callback(hObject, eventdata, handles)
% hObject    handle to radioStabilize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioStabilize


% --- Executes on button press in radioBGSubstract.
function radioBGSubstract_Callback(hObject, eventdata, handles)
% hObject    handle to radioBGSubstract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioBGSubstract


% --- Executes on button press in radioMatting.
function radioMatting_Callback(hObject, eventdata, handles)
% hObject    handle to radioMatting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioMatting


% --- Executes on button press in radioTracking.
function radioTracking_Callback(hObject, eventdata, handles)
% hObject    handle to radioTracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioTracking


% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

codeDir    = pwd;
inputDir   = get(handles.inputDir, 'String');
outputDir  = get(handles.outputDir, 'String');
selectType = get(handles.manualSelect, 'Value');

inputVideoFile          = fullfile(inputDir,  'INPUT.avi');
inputBGFile             = fullfile(inputDir,  'background.jpg');
stabilizedVideoFile     = fullfile(outputDir, 'stabilized.avi');
binaryVideoFile         = fullfile(outputDir, 'binary.avi');
extractedVideoFile      = fullfile(outputDir, 'extracted.avi');
mattedVideoFile         = fullfile(outputDir, 'matted.avi');
outputVideoFile         = fullfile(outputDir, 'OUTPUT.avi');

objROI = [handles.locX, handles.locY, handles.locW, handles.locH];

action = get(get(handles.actionGroup, 'SelectedObject'), 'Tag');
switch action
    case 'radioRunAll'
        
        fprintf('Action selected: run all\n');
        
        % Select stabilized video
        cd(inputDir);
        [FileName, PathName] = ...
            uigetfile('*.avi', 'Select an input video');    

        if isequal(FileName, 0)
            fprintf('No avi video was chosen!\n');
            return;
        end
        iVidPath = [PathName, FileName];
        
        % Select background image
        [FileName, PathName] = ...
            uigetfile('*.jpg', 'Select background image');    

        if isequal(FileName, 0)
            fprintf('No jpg image was chosen!\n');
            return;
        end
        bgImPath = [PathName, FileName];
              
        cd(codeDir);

        status = stabilize(iVidPath, stabilizedVideoFile, ...
                           handles.pxToCrop, handles.pxMaxDist);
        if status == 0
        	fprintf('Stabilization completed\n');
        else
            fprintf('Stabilization failed\n');
            return;
        end
        
        status = bg_substract(stabilizedVideoFile, extractedVideoFile, ...
                              binaryVideoFile, handles.bgTh, handles.winSize, 0);
        if status == 0
        	fprintf('Background substraction completed\n');
        else
            fprintf('Stabilization failed\n');
            return;
        end
        
        status = matting(stabilizedVideoFile, binaryVideoFile, mattedVideoFile, bgImPath);
        if status == 0
        	fprintf('Matting completed\n');
        else
            fprintf('Matting failed\n');
            return;
        end
        
        status = tracking(mattedVideoFile, outputVideoFile, selectType, objROI);
        if status == 0
        	msgbox(sprintf(['Running completed.\n', ...
                            'Output video: \n%s'], ...
                           outputVideoFile), 'Success');
        else
        	msgbox('Running Failed', 'Error', 'error');
        end
        
    case 'radioStabilize'
        
        fprintf('Action selected: stabilization\n');
        
        cd(inputDir);
        [FileName, PathName] = ...
            uigetfile('*.avi', 'Select a video for stabilization');    
        cd(codeDir);

        if isequal(FileName, 0)
            fprintf('No avi video was chosen!\n');
            return;
        end

        vidPath = [PathName, FileName];

        status = stabilize(vidPath, stabilizedVideoFile, ...
                           handles.pxToCrop, handles.pxMaxDist);
        if status == 0
        	msgbox(sprintf(['Stabilization completed.\n', ...
                            'Stabilized video: \n%s'], ...
                           stabilizedVideoFile), 'Success');
        else
        	msgbox('Stabilization Failed', 'Error', 'error');
        end
        
    case 'radioBGSubstract'
        
        fprintf('Action selected: background substraction\n');
        
        cd(outputDir);
        [FileName, PathName] = ...
            uigetfile('*.avi', 'Select a video for BG substraction');    
        cd(codeDir);

        if isequal(FileName, 0)
            fprintf('No avi video was chosen!\n');
            return;
        end

        vidPath = [PathName, FileName];

        status = bg_substract(vidPath, extractedVideoFile, ...
                              binaryVideoFile, handles.bgTh, handles.winSize, 0);
        if status == 0
        	msgbox(sprintf(['BG substraction completed.\n', ...
                           'Extracted video: %s\n', ...
                           'Binary video: %s\n'], ...
                           extractedVideoFile, binaryVideoFile), ...
                           'Success'); 
        else
        	msgbox('BG substraction Failed', 'Error', 'error');
        end
        
    case 'radioMatting'
        
        fprintf('Action selected: matting\n');
        
        % Select stabilized video
        cd(outputDir);
        [FileName, PathName] = ...
            uigetfile('*.avi', 'Select a stabilized video for matting');    

        if isequal(FileName, 0)
            fprintf('No avi video was chosen!\n');
            return;
        end
        sVidPath = [PathName, FileName];
        
        % Select binary video
        [FileName, PathName] = ...
            uigetfile('*.avi', 'Select binary video for matting');    

        if isequal(FileName, 0)
            fprintf('No avi video was chosen!\n');
            return;
        end
        bVidPath = [PathName, FileName];
        
        % Select background
        cd(inputDir);
        [FileName, PathName] = ...
            uigetfile('*.jpg', 'Select background for matting');    

        if isequal(FileName, 0)
            fprintf('No jpg image was chosen!\n');
            return;
        end
        bgImPath = [PathName, FileName];
              
        cd(codeDir);

        status = matting(sVidPath, bVidPath, mattedVideoFile, bgImPath);
        if status == 0
        	msgbox(sprintf(['Matting completed.\n', ...
                            'Output video: %s\n'], ...
                           mattedVideoFile), ...
                           'Success'); 
        else
        	msgbox('Matting Failed', 'Error', 'error');
        end
        
    case 'radioTracking'
        
        fprintf('Action selected: tracking\n');
        
        cd(outputDir);
        [FileName, PathName] = ...
            uigetfile('*.avi', 'Select a video for tracking');    
        cd(codeDir);

        if isequal(FileName, 0)
            fprintf('No avi video was chosen!\n');
            return;
        end

        vidPath = [PathName, FileName];

        status = tracking(vidPath, outputVideoFile, selectType, objROI);
        if status == 0
        	msgbox(sprintf(['Tracking completed.\n', ...
                            'Output video: %s\n'], ...
                           vidPath), ...
                           'Success'); 
        else
        	msgbox('Tracking Failed', 'Error', 'error');
        end
        
end
 

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    dir = uigetdir('../Output/', 'Select output directory');
    set(handles.outputDir, 'String', dir);

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    codeDir = pwd;
    
    cd('../Output');
    [FileName, PathName] = ...
        uigetfile('*.avi', 'Select a video playing');    
    cd(codeDir);
    
    if isequal(FileName, 0)
        fprintf('No avi video was chosen!\n');
        return;
    end
    
    vidPath = [PathName, FileName];
    implay(vidPath);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in actionGroup.
function actionGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in actionGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in displayMode.
function displayMode_Callback(hObject, eventdata, handles)
% hObject    handle to displayMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayMode



function outputDir_Callback(hObject, eventdata, handles)
% hObject    handle to outputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputDir as text
%        str2double(get(hObject,'String')) returns contents of outputDir as a double


% --- Executes during object creation, after setting all properties.
function outputDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    dir = uigetdir('../Input/', 'Select input directory');
    set(handles.inputDir, 'String', dir);


function inputDir_Callback(hObject, eventdata, handles)
% hObject    handle to inputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputDir as text
%        str2double(get(hObject,'String')) returns contents of inputDir as a double


% --- Executes during object creation, after setting all properties.
function inputDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_Callback(hObject, eventdata, handles)
% hObject    handle to settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

settings;
h = findobj('Tag', 'gui2');

if ~isempty(h)
   gui2Data = guidata(h);
   
   set(gui2Data.px_to_crop,  'String', handles.pxToCrop);
   set(gui2Data.px_max_dist, 'String', handles.pxMaxDist);
   set(gui2Data.bg_th,       'String', handles.bgTh);
   set(gui2Data.win_size,    'String', handles.winSize);
   
   set(gui2Data.loc_x,       'String', handles.locX);
   set(gui2Data.loc_y,       'String', handles.locY);
   set(gui2Data.loc_w,       'String', handles.locW);
   set(gui2Data.loc_h,       'String', handles.locH);
end


% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq;


% --- Executes on button press in manualSelect.
function manualSelect_Callback(hObject, eventdata, handles)
% hObject    handle to manualSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manualSelect
