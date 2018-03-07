function varargout = imfit(varargin)
% IMFIT MATLAB code for imfit.fig
%      IMFIT, by itself, creates a new IMFIT or raises the existing
%      singleton*.
%
%      H = IMFIT returns the handle to a new IMFIT or the handle to
%      the existing singleton*.
%
%      IMFIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMFIT.M with the given input arguments.
%
%      IMFIT('Property','Value',...) creates a new IMFIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imfit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imfit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imfit

% Last Modified by GUIDE v2.5 20-Jan-2018 13:04:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imfit_OpeningFcn, ...
                   'gui_OutputFcn',  @imfit_OutputFcn, ...
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


% --- Executes just before imfit is made visible.
function imfit_OpeningFcn(hObject, eventdata, handles, varargin)
setappdata(0,'ODK',[]);
setappdata(0,'ODRb',[]);
setappdata(0,'KSlice1',[]);
setappdata(0,'KSlice2',[]);
setappdata(0,'RbSlice1',[]);
setappdata(0,'RbSlice2',[]);
setappdata(0,'KFitResult',[]);
setappdata(0,'RbFitResult',[]);
setappdata(0,'KFrame',[]);
setappdata(0,'RbFrame',[]);


handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imfit wait for user response (see UIRESUME)
% uiwait(handles.figure1);

set(handles.MessageString,'String',['Hello Colorado! Today is ' datestr(now,'mmmm dd, yyyy') '. Good luck!']);

% --- Outputs from this function are returned to the command line.
function varargout = imfit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function filepath_Callback(hObject, eventdata, handles)

function filepath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browsebutton_Callback(hObject, eventdata, handles)
[X,Y] = uigetfile('*.spe','Load spe file',get(handles.filepath,'String'));
Path = [Y,X];
if Path ~= 0
    set(handles.filepath,'String',Path)
end

function Loadbutton_Callback(hObject, eventdata, handles)
    Path = get(handles.filepath,'String');
    
    bin = get(handles.BinnedTag,'Value') + 1;
    tprobe = str2num(get(handles.ProbeTime, 'String'));
    
    if exist(Path,'file') ~= 2
        set(handles.MessageString,'String','Error: File not found','BackgroundColor',[1 0 0]);
        return
    elseif isempty(tprobe)
        set(handles.MessageString,'String','Error: Probe time must be a number!','BackgroundColor',[1 0 0])
    else
        set(handles.MessageString,'String','File Loaded!','BackgroundColor',[173 235 255]./255)
    end
%%%Clear Previous fits
    axes(handles.AxSlice1); cla;
    axes(handles.AxSlice2); cla;
    setappdata(0,'KSlice1',[]);
    setappdata(0,'KSlice2',[]);
    setappdata(0,'RbSlice1',[]);
    setappdata(0,'RbSlice2',[]);
    setappdata(0,'KFitResult',[]);
    setappdata(0,'RbFitResult',[]);

    
    %%%Load image and calculate OD
    X = SpeReader(Path);
    imgs = read(X);
    
    %%%Potassium loading and calculating
    RegionHandles = {'KYc','KXc','KCropY','KCropX'};
    for k = 1 : 4
        x = str2num(get(findobj('Tag',RegionHandles{k}),'String'));
        if isempty(x)
            set(handles.MessageString,'String','Error: Fitting region must contain numbers only!','BackgroundColor',[1 0 0]);
            return
        else
            Region(k) = x;
        end
    end

    filtertypes = get(handles.filtermenu,'String');
    
    [ODK, KFrame] = calc_OD(imgs,'K',bin,tprobe,Region,filtertypes(get(handles.filtermenu,'Value')), get(handles.FilterPower,'String'));
    setappdata(0,'ODK',ODK);
    setappdata(0,'KFrame',KFrame);
    
    %%%Rubidium loading and calculating
    RegionHandles = {'RbYc','RbXc','RbCropY','RbCropX'};
    for k = 1 : 4
        x = str2num(get(findobj('Tag',RegionHandles{k}),'String'));
        if isempty(x)
            set(handles.MessageString,'String','Error: Fitting region must contain numbers only!','BackgroundColor',[1 0 0]);
            return
        else
            Region(k) = x;
        end
    end
    
    [ODRb, RbFrame] = calc_OD(imgs,'Rb',bin,tprobe,Region,filtertypes(get(handles.filtermenu,'Value')), get(handles.FilterPower,'String'));
    setappdata(0,'ODRb',ODRb);
    setappdata(0,'RbFrame',RbFrame);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    plotOD(handles);
    
    if get(handles.AutoFitTag,'Value')
        FitPushButton_Callback(hObject, eventdata, handles);
    end
        
function KFitSelect_Callback(hObject, eventdata, handles)

function KFitSelect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BinnedTag_Callback(hObject, eventdata, handles)

function ProbeTime_Callback(hObject, eventdata, handles)

function ProbeTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plotOD(handles)

    if get(handles.Kplotbutton,'Value')
      OD = getappdata(0,'ODK');
      Frame = getappdata(0,'KFrame');
    else
      OD = getappdata(0,'ODRb');
      Frame = getappdata(0,'RbFrame');
    end
    
        ODMin = str2double(get(handles.EditMinOD,'String'));
        ODMax = get(handles.ODScale,'Value');
        C = [ODMin ODMax];
        
        axes(handles.ImgDisp); cla;
        x = Frame(1):Frame(2);
        y = Frame(3):Frame(4);
        
               
        imagesc(y,x,OD,C); 
        
        colormap('jet')


% --- Executes on button press in Kplotbutton.
function Kplotbutton_Callback(hObject, eventdata, handles)
    OD = getappdata(0,'ODK');
    Frame = getappdata(0,'KFrame');
    plotOD(handles);
    
    PDat = getappdata(0,'KSlice1');
    if isempty(PDat)
        return
    end
    
    axes(handles.AxSlice1);
    plot(PDat{1},PDat{2},'r.',PDat{3},PDat{4},'b')
    axis([min(PDat{3}), max(PDat{3}), min(PDat{2})-0.05*abs(min(PDat{2})), max(PDat{2})+0.05*abs(max(PDat{2}))])
    ylabel('OD');

    PDat = getappdata(0,'KSlice2');
    axes(handles.AxSlice2);
    plot(PDat{1},PDat{2},'r.',PDat{3},PDat{4},'b')
    axis([min(PDat{3}), max(PDat{3}), min(PDat{2})-0.05*abs(min(PDat{2})), max(PDat{2})+0.05*abs(max(PDat{2}))])
    ylabel('OD');
    


% --- Executes on button press in Rbplotbutton.
function Rbplotbutton_Callback(hObject, eventdata, handles)
    OD = getappdata(0,'ODRb');
    Frame = getappdata(0,'RbFrame');
    plotOD(handles);
    
    PDat = getappdata(0,'RbSlice1');
    if isempty(PDat)
        return
    end
    
    axes(handles.AxSlice1);
    plot(PDat{1},PDat{2},'r.',PDat{3},PDat{4},'b')
    axis([min(PDat{3}), max(PDat{3}), min(PDat{2})-0.05*abs(min(PDat{2})), max(PDat{2})+0.05*abs(max(PDat{2}))])
    set(gca,'XTickLabel',[]);
    ylabel('OD');

    PDat = getappdata(0,'RbSlice2');
    axes(handles.AxSlice2);
    plot(PDat{1},PDat{2},'r.',PDat{3},PDat{4},'b')
    axis([min(PDat{3}), max(PDat{3}), min(PDat{2})-0.05*abs(min(PDat{2})), max(PDat{2})+0.05*abs(max(PDat{2}))])
    ylabel('OD');
   


% --- Executes on button press in FitPushButton.
function FitPushButton_Callback(hObject, eventdata, handles)
    clc
    if isempty(getappdata(0,'ODK'))
        set(handles.MessageString,'String','Error: Load an image first');
        return
    end
    
    OD = getappdata(0,'ODK');
    Frame = getappdata(0,'KFrame');
    [FitResults, Slices] = fit_OD(OD,Frame,get(handles.KFitSelect,'Value'),handles);
    setappdata(0,'KSlice1',{Slices{1};Slices{2};Slices{5};Slices{6}});
    setappdata(0,'KSlice2',{Slices{3};Slices{4};Slices{7};Slices{8}});
    setappdata(0,'KFitResult',FitResults);
    
    OD = getappdata(0,'ODRb');
    Frame = getappdata(0,'RbFrame');
    [FitResults, Slices] = fit_OD(OD,Frame,get(handles.RbFitSelect,'Value'),handles);
    setappdata(0,'RbSlice1',{Slices{1};Slices{2};Slices{5};Slices{6}});
    setappdata(0,'RbSlice2',{Slices{3};Slices{4};Slices{7};Slices{8}});
    setappdata(0,'RbFitResult',FitResults);
    clear FitResults Slices; 
    
    if get(handles.Kplotbutton,'Value')
        Kplotbutton_Callback(hObject, eventdata, handles)

    else
        Rbplotbutton_Callback(hObject, eventdata, handles)
    end
    
    if get(handles.AutoOriginBox,'Value')
        OriginButton_Callback(hObject, eventdata, handles)
    end  


% --- Executes on button press in AutoFitTag.
function AutoFitTag_Callback(hObject, eventdata, handles)


% --- Executes on button press in AutoLoadTag.
function AutoLoadTag_Callback(hObject, eventdata, handles)

        dtstr = datevec(now);
        %dtstr = [2017 7 25];
        Direc = ['G:\DATA\' datestr(now,'yyyy') '\' datestr(now,'mmmm') '\' sprintf('%d',dtstr(3)) '\Raw Files\'];
        %Direc = ['G:\DATA\2017\July\24\Raw Files\'];
        
    while hObject.Value
        FileN = str2num(get(handles.FileString, 'String'));

        if not(hObject.Value)
            return
        elseif isempty(FileN)
            set(handles.MessageString,'String','Error: File number must be valid','BackgroundColor',[1 0 0]);
            set(hObject.Value,0)
            return
        end

        dtstr = datevec(now);
        File = ['ABS ' num2str(FileN) ' ' sprintf('%d-%d-%d',dtstr(2),dtstr(3),dtstr(1)) '.spe'];
        %File = ['ABS ' num2str(FileN) ' 7-25-2017.spe'];
        Path = [Direc File];

        if exist(Path,'file') == 2
            pause(0.5)
            set(handles.filepath,'String',Path);
            Loadbutton_Callback(hObject, eventdata, handles)
            FileN = FileN + 1;
            set(handles.FileString,'String',num2str(FileN))
        else
            pause(0.1);
        end
    end

function FileString_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function FileString_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OriginButton.
function OriginButton_Callback(hObject, eventdata, handles)

originObj=actxserver('Origin.ApplicationSI');
OriginSheets = {'Gauss1','Gauss2'};

KFitFunc = get(handles.KFitSelect,'Value');
data = process_fitresult(getappdata(0,'KFitResult'),KFitFunc,get(handles.BinnedTag,'Value') + 1);



if get(handles.AxialCheck,'Value')
    LoadTo = 'KGauss1Axial';
else 
    LoadTo = ['K' OriginSheets{KFitFunc}];
end
invoke(originObj,'PutWorksheet',LoadTo,data,-1,0);

RbFitFunc = get(handles.RbFitSelect,'Value');
data = process_fitresult(getappdata(0,'RbFitResult'),RbFitFunc,get(handles.BinnedTag,'Value') + 1);
if get(handles.AxialCheck,'Value')
    LoadTo = 'RbGauss1Axial';
else 
    LoadTo = ['Rb' OriginSheets{KFitFunc}];
end
invoke(originObj,'PutWorksheet',LoadTo,data,-1,0);



% --- Executes on button press in AutoOriginBox.
function AutoOriginBox_Callback(hObject, eventdata, handles)

function KXc_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)
    
function KXc_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    
function KYc_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)
    
function KYc_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    
function KCropX_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)
   
function KCropX_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function KCropY_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)

function KCropY_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
   

function RbXc_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)

function RbXc_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RbYc_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)

function RbYc_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RbCropX_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)
    
function RbCropX_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RbCropY_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)
    
function RbCropY_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function ODScale_Callback(hObject, eventdata, handles)
    plotOD(handles)

function ODScale_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function EditMaxOD_Callback(hObject, eventdata, handles)
    x = str2num(hObject.String);
    if isempty(x)
        set(handles.MessageString,'String','Error:MaxOD must be a number!','BackgroundColor',[1 0 0]);
        return
    elseif x < get(handles.ODScale,'Value')
        set(handles.MessageString,'String','Error:MaxOD cannot be less than value!','BackgroundColor',[1 0 0]);
        return
    end
    set(handles.ODScale,'max',x);

function EditMaxOD_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditMinOD_Callback(hObject, eventdata, handles)

function EditMinOD_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RbFitSelect.
function RbFitSelect_Callback(hObject, eventdata, handles)
% hObject    handle to RbFitSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RbFitSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RbFitSelect


% --- Executes during object creation, after setting all properties.
function RbFitSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RbFitSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AxialCheck.
function AxialCheck_Callback(hObject, eventdata, handles)
% hObject    handle to AxialCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AxialCheck


% --- Executes on selection change in filtermenu.
function filtermenu_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to filtermenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filtermenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filtermenu


% --- Executes during object creation, after setting all properties.
function filtermenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filtermenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FilterPower_Callback(hObject, eventdata, handles)
    Loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FilterPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterPower as text
%        str2double(get(hObject,'String')) returns contents of FilterPower as a double


% --- Executes during object creation, after setting all properties.
function FilterPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
