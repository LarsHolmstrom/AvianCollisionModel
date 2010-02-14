function varargout = AvianCollisionModel(varargin)
% AvianCollisionModel M-file for AvianCollisionModel.fig
%      AvianCollisionModel, by itself, creates a new AvianCollisionModel or raises the existing
%      singleton*.
%
%      H = AvianCollisionModel returns the handle to a new AvianCollisionModel or the handle to
%      the existing singleton*.
%
%      AvianCollisionModel('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AvianCollisionModel.M with the given input arguments.
%
%      AvianCollisionModel('Property','Value',...) creates a new AvianCollisionModel or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AvianCollisionModel_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AvianCollisionModel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AvianCollisionModel

% Last Modified by GUIDE v2.5 13-Feb-2010 17:16:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AvianCollisionModel_OpeningFcn, ...
                   'gui_OutputFcn',  @AvianCollisionModel_OutputFcn, ...
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

% --- Executes just before AvianCollisionModel is made visible.
function AvianCollisionModel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AvianCollisionModel (see VARARGIN)

% Choose default command line output for AvianCollisionModel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using AvianCollisionModel.
if strcmp(get(hObject,'Visible'),'off')
%     plot(rand(5));
end

% UIWAIT makes AvianCollisionModel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AvianCollisionModel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% % --- Executes on button press in pushbutton1.
% function pushbutton1_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% axes(handles.axes1);
% cla;
% 
% popup_sel_index = get(handles.popupmenu1, 'Value');
% switch popup_sel_index
%     case 1
%         plot(rand(5));
%     case 2
%         plot(sin(1:0.01:25.99));
%     case 3
%         bar(1:.5:10);
%     case 4
%         plot(membrane);
%     case 5
%         surf(peaks);
% end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile( ...
	{'*.mat', 'All MAT-Files (*.mat)'; ...
		'*.*','All Files (*.*)'}, ...
	'Select Saved Model Parameters');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
	return
% Otherwise construct the fullfilename and Check and load 
% the file
else
	File = fullfile(pathname,filename);
	% if the MAT-file is not valid, do not save the name
	if Check_And_Load(File,handles)
		handles.Filename = File;
		guidata(hObject, handles);
        filename_no_extension = filename(1:end-4);
        set(handles.config_file,'string', filename_no_extension);
	end
end

function pass = Check_And_Load(file,handles)
% Initialize the variable "pass" to determine if this is
% a valid file.
pass = false;
if exist(file) == 2
	load(file);
    if exist('model_data','var')
        if isfield(model_data,'wingspan')
            pass = true;
        end
    else
        error_string = 'File Does Not Contain Model Data';
        errordlg(error_string,'Error');
    end
end

if pass
    % Set the model data
    %############################################################
    % Set survey variables
    %############################################################
     set(handles.bird_flightpath_distribution_param_1,'string',model_data.bird_flightpath_height);
     set(handles.bird_flightpath_distribution_param_2,'string',model_data.bird_flightpath_height_variance);
     set(handles.bird_rate,'string',model_data.bird_rate);
     set(handles.avoidance_rate,'string',model_data.avoidance_rate);

    %############################################################
    % Set windfarm variables
    %############################################################
     set(handles.windfarm_rows,'string',model_data.num_turbine_rows);
     set(handles.windfarm_columns,'string',model_data.num_turbine_columns);
     set(handles.row_distance,'string',model_data.distance_between_rows);
     set(handles.column_distance,'string',model_data.distance_between_columns);

    %############################################################
    % Set wind variables
    %############################################################
     set(handles.wind_speed,'string',model_data.wind_speed);
     set(handles.wind_direction,'string',model_data.wind_direction);

    %############################################################
    % Set turbine variables
    %############################################################
     set(handles.n_rotors,'string',model_data.n_rotors);
     set(handles.turbine_radius,'string',model_data.turbine_radius);
     set(handles.hub_radius,'string',model_data.hub_radius);
     set(handles.angular_velocity,'string',model_data.angular_velocity);
     set(handles.chord_length,'string',model_data.chord_length);

    %############################################################
    % Set bird variables
    %############################################################
     set(handles.wingspan,'string',model_data.wingspan);
     set(handles.length,'string',model_data.length);
     set(handles.bird_speed,'string',model_data.bird_speed);
     set(handles.bird_direction,'string',model_data.bird_direction);

    %############################################################
    % Set tower variables
    %############################################################
     set(handles.tower_height,'string',model_data.tower_height);
     set(handles.tower_base_diameter,'string',model_data.tower_base_diameter);
     set(handles.tower_hub_diameter,'string',model_data.tower_top_diameter);

    %############################################################
    % Set Enable Switches
    %############################################################
     set(handles.single_turbine,'Value',model_data.windfarm_enabled);
     set(handles.enable_turbine,'Value',model_data.turbine_enabled);
     set(handles.enable_wind,'Value',model_data.wind_enabled);
     
     process_enables(handles)
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});




function wingspan_Callback(hObject, eventdata, handles)
% hObject    handle to wingspan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function wingspan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wingspan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function length_Callback(hObject, eventdata, handles)
% hObject    handle to length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bird_speed_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function bird_speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bird_direction_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function bird_direction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function n_rotors_Callback(hObject, eventdata, handles)
% hObject    handle to n_rotors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function n_rotors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_rotors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function turbine_radius_Callback(hObject, eventdata, handles)
% hObject    handle to turbine_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function turbine_radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to turbine_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hub_radius_Callback(hObject, eventdata, handles)
% hObject    handle to hub_turbine_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function hub_radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hub_turbine_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angular_velocity_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function angular_velocity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function chord_length_Callback(hObject, eventdata, handles)
% hObject    handle to chord_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chord_length as text
%        str2double(get(hObject,'String')) returns contents of chord_length as a double


% --- Executes during object creation, after setting all properties.
function chord_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chord_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function wind_speed_Callback(hObject, eventdata, handles)
% hObject    handle to wind_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function wind_speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wind_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function induction_Callback(hObject, eventdata, handles)
% hObject    handle to induction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function induction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to induction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_dim_Callback(hObject, eventdata, handles)
% hObject    handle to y_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function y_dim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_dim_Callback(hObject, eventdata, handles)
% hObject    handle to z_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function z_dim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_turbine.
function plot_turbine_Callback(hObject, eventdata, handles)
% hObject    handle to plot_turbine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_turbine


% --- Executes on button press in plot_birdpath.
function plot_birdpath_Callback(hObject, eventdata, handles)
% hObject    handle to plot_birdpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_birdpath

function wind_direction_Callback(hObject, eventdata, handles)
% hObject    handle to wind_direction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wind_direction as text
%        str2double(get(hObject,'String')) returns contents of wind_direction as a double


% --- Executes during object creation, after setting all properties.
function wind_direction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wind_direction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function windfarm_rows_Callback(hObject, eventdata, handles)
% hObject    handle to windfarm_rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windfarm_rows as text
%        str2double(get(hObject,'String')) returns contents of windfarm_rows as a double


% --- Executes during object creation, after setting all properties.
function windfarm_rows_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windfarm_rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function row_distance_Callback(hObject, eventdata, handles)
% hObject    handle to row_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of row_distance as text
%        str2double(get(hObject,'String')) returns contents of row_distance as a double


% --- Executes during object creation, after setting all properties.
function row_distance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to row_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function column_distance_Callback(hObject, eventdata, handles)
% hObject    handle to column_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of column_distance as text
%        str2double(get(hObject,'String')) returns contents of column_distance as a double


% --- Executes during object creation, after setting all properties.
function column_distance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to column_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function windfarm_columns_Callback(hObject, eventdata, handles)
% hObject    handle to windfarm_columns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windfarm_columns as text
%        str2double(get(hObject,'String')) returns contents of windfarm_columns as a double


% --- Executes during object creation, after setting all properties.
function windfarm_columns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windfarm_columns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function tower_height_Callback(hObject, eventdata, handles)
% hObject    handle to tower_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tower_height as text
%        str2double(get(hObject,'String')) returns contents of tower_height as a double


% --- Executes during object creation, after setting all properties.
function tower_height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tower_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tower_width_Callback(hObject, eventdata, handles)
% hObject    handle to tower_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tower_width as text
%        str2double(get(hObject,'String')) returns contents of tower_width as a double


% --- Executes during object creation, after setting all properties.
function tower_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tower_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tower_base_diameter_Callback(hObject, eventdata, handles)
% hObject    handle to tower_base_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tower_base_diameter as text
%        str2double(get(hObject,'String')) returns contents of tower_base_diameter as a double


% --- Executes during object creation, after setting all properties.
function tower_base_diameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tower_base_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tower_hub_diameter_Callback(hObject, eventdata, handles)
% hObject    handle to tower_hub_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tower_hub_diameter as text
%        str2double(get(hObject,'String')) returns contents of tower_hub_diameter as a double


% --- Executes during object creation, after setting all properties.
function tower_hub_diameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tower_hub_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tower_max_diameter_Callback(hObject, eventdata, handles)
% hObject    handle to tower_max_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tower_max_diameter as text
%        str2double(get(hObject,'String')) returns contents of tower_max_diameter as a double


% --- Executes during object creation, after setting all properties.
function tower_max_diameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tower_max_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tower_widest_height_Callback(hObject, eventdata, handles)
% hObject    handle to tower_widest_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tower_widest_height as text
%        str2double(get(hObject,'String')) returns contents of tower_widest_height as a double


% --- Executes during object creation, after setting all properties.
function tower_widest_height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tower_widest_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function bird_speed_variance_Callback(hObject, eventdata, handles)
% hObject    handle to bird_speed_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bird_speed_variance as text
%        str2double(get(hObject,'String')) returns contents of bird_speed_variance as a double


% --- Executes during object creation, after setting all properties.
function bird_speed_variance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bird_speed_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bird_direction_variance_Callback(hObject, eventdata, handles)
% hObject    handle to bird_direction_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bird_direction_variance as text
%        str2double(get(hObject,'String')) returns contents of bird_direction_variance as a double


% --- Executes during object creation, after setting all properties.
function bird_direction_variance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bird_direction_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wind_speed_variance_Callback(hObject, eventdata, handles)
% hObject    handle to wind_speed_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wind_speed_variance as text
%        str2double(get(hObject,'String')) returns contents of wind_speed_variance as a double


% --- Executes during object creation, after setting all properties.
function wind_speed_variance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wind_speed_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wind_direction_variance_Callback(hObject, eventdata, handles)
% hObject    handle to wind_direction_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wind_direction_variance as text
%        str2double(get(hObject,'String')) returns contents of wind_direction_variance as a double


% --- Executes during object creation, after setting all properties.
function wind_direction_variance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wind_direction_variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function bird_flightpath_distribution_param_1_Callback(hObject, eventdata, handles)
% hObject    handle to bird_flightpath_distribution_param_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bird_flightpath_distribution_param_1 as text
%        str2double(get(hObject,'String')) returns contents of bird_flightpath_distribution_param_1 as a double


% --- Executes during object creation, after setting all properties.
function bird_flightpath_distribution_param_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bird_flightpath_distribution_param_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bird_flightpath_distribution_param_2_Callback(hObject, eventdata, handles)
% hObject    handle to bird_flightpath_distribution_param_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bird_flightpath_distribution_param_2 as text
%        str2double(get(hObject,'String')) returns contents of bird_flightpath_distribution_param_2 as a double


% --- Executes during object creation, after setting all properties.
function bird_flightpath_distribution_param_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bird_flightpath_distribution_param_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function avoidance_rate_Callback(hObject, eventdata, handles)
% hObject    handle to avoidance_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of avoidance_rate as text
%        str2double(get(hObject,'String')) returns contents of avoidance_rate as a double


% --- Executes during object creation, after setting all properties.
function avoidance_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avoidance_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function bird_rate_Callback(hObject, eventdata, handles)
% hObject    handle to bird_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bird_rate as text
%        str2double(get(hObject,'String')) returns contents of bird_rate as a double


% --- Executes during object creation, after setting all properties.
function bird_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bird_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in hamer.
function hamer_Callback(hObject, eventdata, handles)
% hObject    handle to hamer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hamer

% --- Executes during object creation, after setting all properties.
function hamer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hamer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in tucker.
function tucker_Callback(hObject, eventdata, handles)
% hObject    handle to tucker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tucker


% --- Executes during object creation, after setting all properties.
function tucker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tucker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in podolski.
function podolski_Callback(hObject, eventdata, handles)
% hObject    handle to podolski (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of podolski


% --- Executes during object creation, after setting all properties.
function podolski_CreateFcn(hObject, eventdata, handles)
% hObject    handle to podolski (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in clear_figures.
function clear_figures_Callback(hObject, eventdata, handles)
% hObject    handle to clear_figures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;


% --- Executes on button press in enable_wind.
function enable_wind_Callback(hObject, eventdata, handles)
% hObject    handle to enable_wind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_wind
process_enables(handles)

% --- Executes on button press in enable_turbine.
function enable_turbine_Callback(hObject, eventdata, handles)
% hObject    handle to enable_turbine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_turbine
process_enables(handles)

% --- Executes on button press in single_turbine.
function single_turbine_Callback(hObject, eventdata, handles)
% hObject    handle to single_turbine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of single_turbine
process_enables(handles)

function process_enables(handles)
%Process single turbine enables
enabled = get(handles.single_turbine,'Value');
if ~enabled
    set(handles.bird_flightpath_distribution_param_1,'Enable','on');
	set(handles.bird_flightpath_distribution_param_2,'Enable','on');
    set(handles.bird_rate,'Enable','on');
    set(handles.avoidance_rate,'Enable','on');
    set(handles.windfarm_rows,'Enable','on');
    set(handles.windfarm_columns,'Enable','on');
    set(handles.row_distance,'Enable','on');
    set(handles.column_distance,'Enable','on');
    set(handles.tower_height,'Enable','on');
    set(handles.tower_base_diameter,'Enable','on');
    set(handles.tower_hub_diameter,'Enable','on');
else
    set(handles.bird_flightpath_distribution_param_1,'Enable','off');
	set(handles.bird_flightpath_distribution_param_2,'Enable','off');
    set(handles.bird_rate,'Enable','off');
    set(handles.avoidance_rate,'Enable','off');
    set(handles.windfarm_rows,'Enable','off');
    set(handles.windfarm_columns,'Enable','off');
    set(handles.row_distance,'Enable','off');
    set(handles.column_distance,'Enable','off');
    set(handles.tower_height,'Enable','off');
    set(handles.tower_base_diameter,'Enable','off');
    set(handles.tower_hub_diameter,'Enable','off');
end
%Process turbine enable
enabled = get(handles.enable_turbine,'Value');
if enabled
    set(handles.n_rotors,'Enable','on');
	set(handles.turbine_radius,'Enable','on');
    set(handles.hub_radius,'Enable','on');
    set(handles.angular_velocity,'Enable','on');
    set(handles.chord_length,'Enable','on');
else
    set(handles.n_rotors,'Enable','off');
	set(handles.turbine_radius,'Enable','off');
    set(handles.hub_radius,'Enable','off');
    set(handles.angular_velocity,'Enable','off');
    set(handles.chord_length,'Enable','off');
end

enabled = get(handles.enable_wind,'Value');
if enabled
    set(handles.wind_speed,'Enable','on');
	set(handles.wind_direction,'Enable','on');
else
    set(handles.wind_speed,'Enable','off');
	set(handles.wind_direction,'Enable','off');
end

% --- Executes on button press in plot_button.
function plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get all variables from the AvianCollisionModel


%############################################################
% Get survey variables
%############################################################
bird_flightpath_height = str2double(get(handles.bird_flightpath_distribution_param_1,'string'));
bird_flightpath_height_variance = str2double(get(handles.bird_flightpath_distribution_param_2,'string'));
bird_rate = str2double(get(handles.bird_rate,'string'));
avoidance_rate = str2double(get(handles.avoidance_rate,'string'));

%############################################################
% Get windfarm variables
%############################################################
num_turbine_rows = round(str2double(get(handles.windfarm_rows,'string')));
num_turbine_columns = round(str2double(get(handles.windfarm_columns,'string')));
distance_between_rows = str2double(get(handles.row_distance,'string'));
distance_between_columns = str2double(get(handles.column_distance,'string'));

%############################################################
% Get wind variables
%############################################################
wind_speed = str2double(get(handles.wind_speed,'string'));
wind_direction = str2double(get(handles.wind_direction,'string'));

%############################################################
% Get turbine variables
%############################################################
n_rotors = str2double(get(handles.n_rotors,'string'));
turbine_radius = str2double(get(handles.turbine_radius,'string'));
hub_radius = str2double(get(handles.hub_radius,'string'));
angular_velocity = str2double(get(handles.angular_velocity,'string'));
chord_length = str2double(get(handles.chord_length,'string'));
chord_length_at_hub = str2double(get(handles.chord_length_at_hub,'string'));

%############################################################
% Get bird variables
%############################################################
wingspan = str2double(get(handles.wingspan,'string'));
length = str2double(get(handles.length,'string'));
bird_speed = str2double(get(handles.bird_speed,'string'));
bird_direction = str2double(get(handles.bird_direction,'string'));

%############################################################
% Get tower variables
%############################################################
tower_height = str2double(get(handles.tower_height,'string'));
tower_base_diameter = str2double(get(handles.tower_base_diameter,'string'));
tower_top_diameter = str2double(get(handles.tower_hub_diameter,'string'));

model_type = 0;
if get(handles.hamer,'value') == 1
    model_type = 0;
elseif get(handles.tucker,'value') == 1
    model_type = 1;
else
    model_type = 2;
end

% Flight height distribution types:
%   0: Gaussian, param1 = mean, param2 = variance
%   1: Uniform, param1 = minimun height, param2 = maximum height
distribution_type = 0;
if get(handles.uniform_distribution,'value') == 1
    distribution_type = 1;
elseif get(handles.gaussian_distribution,'value') == 1
    distribution_type = 0;
else
    distribution_type = 2;
    error_string = 'Gamma distribution for flight height not yet implemented.';
    errordlg(error_string,'Error');
    error('Gamma distribution for flight height not yet implemented.');
end
bird_flightpath_distribution_param_1 = str2double(get(handles.bird_flightpath_distribution_param_1,'string'));
bird_flightpath_distribution_param_2 = str2double(get(handles.bird_flightpath_distribution_param_2,'string'));

flight_corridor_width = str2double(get(handles.flight_corridor_width,'string'));

%Hardcoded for now
resolution = 3; %Pixels per meter
% resolution = 30; %Pixels per meter
induction = 0.25;

% y_dim = 10;
% z_dim = 0.5;
% y_dim = -0.83721;
% z_dim = 3.5163;
% plot_type = 3;

%############################################################
% Determine plot type based on UI preferences
%############################################################
windfarm_enabled = ~get(handles.single_turbine,'Value');
turbine_enabled = get(handles.enable_turbine,'Value');
wind_enabled = get(handles.enable_wind,'Value');

if windfarm_enabled
    plot_type = 3;
else
    if ~turbine_enabled
        error_string = {'Cannot disable turbine characteristics and view',...
                        'single turbine probabilities at the same time.'};
        errordlg(error_string,'Error');
        error('Cannot disable turbine characteristics and view single turbine probabilities at the same time.');
    end
    plot_type = 1;
end

if ~wind_enabled
    wind_direction = bird_direction;
    wind_speed = 0;
end


distribution_type = 1;
survey_width = 3000;

% bird_direction 

if plot_type == 1
    [oblique_probabilities angle_of_approach] = TurbineCollision(wingspan, ...
                                                                 length, ...
                                                                 n_rotors, ...
                                                                 turbine_radius, ...
                                                                 hub_radius, ...
                                                                 angular_velocity, ...
                                                                 chord_length, ...
                                                                 chord_length_at_hub, ...
                                                                 induction, ...
                                                                 wind_speed, ...
                                                                 wind_direction, ...
                                                                 bird_speed, ...
                                                                 bird_direction, ...
                                                                 1, ...
                                                                 resolution, ...
                                                                 model_type);
elseif plot_type == 2
    [oblique_probabilities angle_of_approach] = TurbineCollision(wingspan, ...
                                                                 length, ...
                                                                 n_rotors, ...
                                                                 turbine_radius, ...
                                                                 hub_radius, ...
                                                                 angular_velocity, ...
                                                                 chord_length, ...
                                                                 chord_length_at_hub, ...
                                                                 induction, ...
                                                                 wind_speed, ...
                                                                 wind_direction, ...
                                                                 bird_speed, ...
                                                                 bird_direction, ...
                                                                 2, ...
                                                                 resolution, ...
                                                                 model_type, ...
                                                                 y_dim, ...
                                                                 z_dim);
else
    %Generate a grid of towers
    [turbine_locations_x turbine_locations_y] = GenerateWindFarmGrid(num_turbine_rows, ...
                                                                     num_turbine_columns, ...
                                                                     distance_between_rows, ...
                                                                     distance_between_columns);
    [windfarm_probabilities ...
     x_ticks ...
     y_ticks ] = WindFarmProbabilities(wingspan, ...
                                       length, ...
                                       n_rotors, ...
                                       turbine_radius, ...
                                       hub_radius, ...
                                       angular_velocity, ...
                                       chord_length, ...
                                       induction, ...
                                       wind_speed, ...
                                       wind_direction, ...
                                       bird_speed, ...
                                       bird_direction, ...
                                       turbine_locations_x, ...
                                       turbine_locations_y, ...
                                       tower_height, ...
                                       tower_base_diameter, ...
                                       tower_top_diameter, ...
                                       resolution, ...
                                       model_type, ...
                                       turbine_enabled, ...
                                       false);
                                   
    collision_rate = CalculateCollisionRate(windfarm_probabilities, ...
                                            x_ticks, ...
                                            y_ticks, ...
                                            distribution_type, ...
                                            bird_flightpath_distribution_param_1, ...
                                            bird_flightpath_distribution_param_2, ...
                                            bird_rate, ...
                                            avoidance_rate, ...
                                            flight_corridor_width, ...
                                            true);
                                 
                                        
                                        
%     save('WindFarmProbabilityData','windfarm_probabilities','x_ticks','y_ticks');
end

% save('TurbineCollisionData','oblique_probabilities','bird_direction_of_approach');





% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
index = get(hObject,'Value');
%1 = GE 1.5se
%2 = Gamesa G80
%3 = Vestas V80
%4 = Vestas V90
%5 = Siemens WT 2.3-10

switch index
    case 1 
        set(handles.n_rotors,'string', '3');
        set(handles.turbine_radius,'string','35.25');
        set(handles.hub_radius,'string','2');
        set(handles.angular_velocity,'string','16.6');
        set(handles.chord_length,'string','1.5');
        set(handles.chord_length_at_hub,'string','0.8');
        set(handles.tower_height,'string','64.7');
        set(handles.tower_base_diameter,'string','3.5');
        set(handles.tower_hub_diameter,'string','2');
%         set(handles.tower_max_diameter,'string','3.5');
%         set(handles.tower_widest_height,'string','0');
    case 2 
        set(handles.n_rotors,'string', '3');
        set(handles.turbine_radius,'string','40');
        set(handles.hub_radius,'string','1.8');
        set(handles.angular_velocity,'string','14');
        set(handles.chord_length,'string','3.36');
        set(handles.chord_length_at_hub,'string','1.88');
        set(handles.tower_height,'string','78');
        set(handles.tower_base_diameter,'string','4.038');
        set(handles.tower_hub_diameter,'string','2.314');
%         set(handles.tower_max_diameter,'string','4.038');
%         set(handles.tower_widest_height,'string','0');
    case 3 
        set(handles.n_rotors,'string', '3');
        set(handles.turbine_radius,'string','40');
        set(handles.hub_radius,'string','2.02');
        set(handles.angular_velocity,'string','14');
        set(handles.chord_length,'string','3.52');
        set(handles.chord_length_at_hub,'string','1.88');
        set(handles.tower_height,'string','78');
        set(handles.tower_base_diameter,'string','3.65');
        set(handles.tower_hub_diameter,'string','2.3');
%         set(handles.tower_max_diameter,'string','3.65');
%         set(handles.tower_widest_height,'string','0');
    case 4
        set(handles.n_rotors,'string', '3');
        set(handles.turbine_radius,'string','45');
        set(handles.hub_radius,'string','2.02');
        set(handles.angular_velocity,'string','14.15');
        set(handles.chord_length,'string','3.512');
        set(handles.chord_length_at_hub,'string','1.88');
        set(handles.tower_height,'string','80');
        set(handles.tower_base_diameter,'string','3.65');
        set(handles.tower_hub_diameter,'string','2.3');
%         set(handles.tower_max_diameter,'string','3.65');
%         set(handles.tower_widest_height,'string','0');
    case 5 %Siemens WT2.3-10
        set(handles.n_rotors,'string', '3');
        set(handles.turbine_radius,'string','50.5');
        set(handles.hub_radius,'string','1.9');
        set(handles.angular_velocity,'string','16');
        set(handles.chord_length,'string','3.4');
        set(handles.chord_length_at_hub,'string','2.4');
        set(handles.tower_height,'string','80');
        set(handles.tower_base_diameter,'string','4.2');
        set(handles.tower_hub_diameter,'string','4.2');
end
    

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the Tag of the menu selected
Tag = get(hObject, 'Tag');
% Get the model data
%############################################################
% Get survey variables
%############################################################
model_data.bird_flightpath_height = get(handles.bird_flightpath_distribution_param_1,'string');
model_data.bird_flightpath_height_variance = get(handles.bird_flightpath_distribution_param_2,'string');
model_data.bird_rate = get(handles.bird_rate,'string');
model_data.avoidance_rate = get(handles.avoidance_rate,'string');

%############################################################
% Get windfarm variables
%############################################################
model_data.num_turbine_rows = get(handles.windfarm_rows,'string');
model_data.num_turbine_columns = get(handles.windfarm_columns,'string');
model_data.distance_between_rows = get(handles.row_distance,'string');
model_data.distance_between_columns = get(handles.column_distance,'string');

%############################################################
% Get wind variables
%############################################################
model_data.wind_speed = get(handles.wind_speed,'string');
model_data.wind_direction = get(handles.wind_direction,'string');

%############################################################
% Get turbine variables
%############################################################
model_data.n_rotors = get(handles.n_rotors,'string');
model_data.turbine_radius = get(handles.turbine_radius,'string');
model_data.hub_radius = get(handles.hub_radius,'string');
model_data.angular_velocity = get(handles.angular_velocity,'string');
model_data.chord_length = get(handles.chord_length,'string');

%############################################################
% Get bird variables
%############################################################
model_data.wingspan = get(handles.wingspan,'string');
model_data.length = get(handles.length,'string');
model_data.bird_speed = get(handles.bird_speed,'string');
model_data.bird_direction = get(handles.bird_direction,'string');

%############################################################
% Get tower variables
%############################################################
model_data.tower_height = get(handles.tower_height,'string');
model_data.tower_base_diameter = get(handles.tower_base_diameter,'string');
model_data.tower_top_diameter = get(handles.tower_hub_diameter,'string');

%############################################################
% Enable Switches
%############################################################
model_data.windfarm_enabled = get(handles.single_turbine,'Value');
model_data.turbine_enabled = get(handles.enable_turbine,'Value');
model_data.wind_enabled = get(handles.enable_wind,'Value');


if ~isfield(handles,'Filename')
    Tag = 'save_as';
end
% Based on the item selected, take the appropriate action
switch Tag
case 'save'
	% Save to the default addrbook file
	File = handles.Filename;
	save(File,'model_data')
case 'save_as'
	% Allow the user to select the file name to save to
	[filename, pathname] = uiputfile( ...
		{'*.mat';'*.*'}, ...
		'Save as');	
	% If 'Cancel' was selected then return
	if isequal([filename,pathname],[0,0])
		return
	else
		% Construct the full path and save
		File = fullfile(pathname,filename);
		save(File,'model_data')
		handles.Filename = File;
		guidata(hObject, handles)
        filename_no_extension = filename(1:end-4);
        set(handles.config_file,'string', filename_no_extension);
	end
end

% --------------------------------------------------------------------
function new_Callback(hObject, eventdata, handles)
% hObject    handle to new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.config_file,'string') '?'],...
                     ['Close ' get(handles.config_file,'string') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
delete(handles.figure1)
AvianCollisionModel()



% --- Executes on button press in gaussian_distribution.
function uniform_distribution_Callback(hObject, eventdata, handles)
% hObject    handle to gaussian_distribution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.flight_distribution_param_1,'String','Minimum (m)')
set(handles.flight_distribution_param_2,'String','Maximum (m)')
% Hint: get(hObject,'Value') returns toggle state of gaussian_distribution

% --- Executes on button press in gaussian_distribution.
function gaussian_distribution_Callback(hObject, eventdata, handles)
% hObject    handle to gaussian_distribution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.flight_distribution_param_1,'String','Mean (m)')
set(handles.flight_distribution_param_2,'String','Variance (m)')

% Hint: get(hObject,'Value') returns toggle state of gaussian_distribution

% --- Executes on button press in gamma_distribution.
function gamma_distribution_Callback(hObject, eventdata, handles)
% hObject    handle to gamma_distribution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.flight_distribution_param_1,'String','Shape (m)')
set(handles.flight_distribution_param_2,'String','Scale (m)')

% Hint: get(hObject,'Value') returns toggle state of gamma_distribution






function flight_corridor_width_Callback(hObject, eventdata, handles)
% hObject    handle to flight_corridor_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flight_corridor_width as text
%        str2double(get(hObject,'String')) returns contents of flight_corridor_width as a double


% --- Executes during object creation, after setting all properties.
function flight_corridor_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flight_corridor_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function chord_length_at_hub_Callback(hObject, eventdata, handles)
% hObject    handle to chord_length_at_hub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chord_length_at_hub as text
%        str2double(get(hObject,'String')) returns contents of chord_length_at_hub as a double


% --- Executes during object creation, after setting all properties.
function chord_length_at_hub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chord_length_at_hub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


