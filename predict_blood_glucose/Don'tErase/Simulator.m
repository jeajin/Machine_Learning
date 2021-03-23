%> @file Simulator.m
%> @brief Main GUI that prepares scenarios, hardware profiles, and subjects; runs simulation with prepared specifications.
%> 
%> - M-file for Simulator.fig
%>
%> @par Calls 
%> @link accross_output @endlink @n
%> @link accrossscenario_output @endlink @n
%> @link choose_outcome @endlink @n
%> @link compstr @endlink @n
%> @link create_output @endlink @n
%> @link eliminate @endlink @n
%> @link error_window @endlink @n
%> @link hardware_window @endlink @n
%> @link load_hardware @endlink @n
%> @link load_subject @endlink @n
%> @link remove_list @endlink @n
%> @link run_simulation @endlink @n
%> @link Scenario_GUI @endlink @n
%> @link select_metab_meas @endlink @n
%> @link statusbar @endlink @n
%> 
%> @copyright 2008-2013 University of Virginia.
%> @copyright 2013 The Epsilon Group, An Alere Company.

function [varargout, O1, e] = Simulator(varargin) %#ok<*STOUT>
% SIMULATOR M-file for Simulator.fig
%      SIMULATOR, by itself, creates a new SIMULATOR or raises the existing
%      singleton*.
%
%      H = SIMULATOR returns the handle to a new SIMULATOR or the handle to
%      the existing singleton*.
%
%      SIMULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMULATOR.M with the given input arguments.
%
%      SIMULATOR('Property','Value',...) creates a new SIMULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before user_interface_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Simulator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Simulator
% Last Modified by GUIDE v2.5 24-Mar-2014 10:49:12
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Simulator_OpeningFcn, ...
    'gui_OutputFcn',  @Simulator_OutputFcn, ...
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


% --- Executes just before Simulator is made visible.
function Simulator_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Simulator (see VARARGIN)
try 
    rt = licChecker('T1DMS','3.2','epsilongrp','http://a106.hostedactivation.com');
    clear licChecker
catch
    [~,licMessageOut] = system('licChecker');
    licMessageOut = strsplit(licMessageOut,' ');
    if iscell(licMessageOut) && (numel(licMessageOut) == 6)
        rt.code = cellfun(@(x)sscanf(x,'%d'),licMessageOut(2:5));
        rt.text = licMessageOut{1};
    else
        rt.code = 'fail';
        rt.text = strjoin(licMessageOut,' ');
        error(rt.text);
    end
end
if ~strcmp(char(rt.code(:)./(1:4)')','pass') || strcmp(char(rt.code(:)./(1:4)')','fail')
    if isempty(rt.text)
       error('Unknown error or rlm1402.dll is missing');
    end
    try
        error(char(matlab.net.base64decode(rt.text)));
    catch
        if isempty(javachk('jvm'))
            error(char(org.apache.commons.codec.binary.Base64.decodeBase64(uint8(rt.text)))');
        else
            error('Trouble parsing error message');
        end
    end
    close
end

mCurVer = version('-release');
mVerCheck = strrep(mCurVer, 'a', '0');
mVerCheck = strrep(mVerCheck, 'b', '1');
mVerNum = str2num(mVerCheck);

% simulink R2011b, R2011a, R2010b, AND R2010a
if mVerNum <= 20111
sVerNum = 2010;
end
% simulink 2012a and LATER
if mVerNum > 20111
simInfo = Simulink.MDLInfo('testing_platform');
sCurVer = simInfo.ReleaseName(2:end);
sVerCheck = strrep(sCurVer, 'a', '0');
sVerCheck = strrep(sVerCheck, 'b', '1');
sVerNum = str2num(sVerCheck);
end

if mVerNum >= 20151  % ver >= 2015b
    % Check compatible model version
    if sVerNum >= 20151 % Match
	% Do nothing
    elseif sVerNum >= 20121% May not be compatible
       warning('The simulink model may not be compatible. Please replace current "testing_platform.slx" with "testing_platform.slx.2015b" for better compatiblity.');
    else
       warning('The simulink model is too old. Please replace current "testing_platform.mdl" with "testing_platform.slx.2015b" for better compatiblity.');
    end        
elseif mVerNum >= 20121 %  2012b <= ver < 2015b
    if sVerNum >= 20151
        warning('The simulink model may not be compatible. Please replace current "testing_platform.slx" with "testing_platform.slx.2012b" for better compatiblity.');
    elseif sVerNum >=20121 % Match
        % Do nothing
    else
        warning('The simulink model may not be compatible. Please replace current "testing_platform.mdl" with "testing_platform.slx.2012b" for better compatiblity.');
    end
else % < 2012b
    if sVerNum >= 20151
        warning('The simulink model may not be compatible. Please remove current "testing_platform.slx" and use "testing_platform.mdl.2010a" (remove ".2010a" from the filename) for better compatiblity.');
    elseif sVerNum >=20121 % 
        warning('The simulink model may not be compatible. Please remove current "testing_platform.slx" and use "testing_platform.mdl.2010a" (remove ".2010a" from the filename) for better compatiblity.');
    else % Match
        % Do nothing        
    end
end   

if sVerNum == 2010
        warning('Check simulink model compatibility. Use "testing_platform.mdl.2010a" (change name to "testing_platform.mdl" Before Starting Simulations)');
end

% Choose default command line output for Simulator
handles.output = hObject;
warning('off','all')
% Update handles structure
guidata(hObject, handles);
Lstruttura=[];
Lscenario.SQ_Gluc.time=[0];
Lscenario.SQ_Gluc.signals.dimensions=[1];
Lscenario.SQ_Gluc.signals.values=[0];
Lscenario.SQ_Pram.time=[0];
Lscenario.SQ_Pram.signals.dimensions=[1];
Lscenario.SQ_Pram.signals.values=[0];
Lscenario.SQ_insulin.time=[0];
Lscenario.SQ_insulin.signals.dimensions=[1];
Lscenario.SQ_insulin.signals.values=[0];
Lscenario.meals=[];
Lscenario.meal_announce=[];
Lscenario.dose=[30000]; %#ok<*NBRAK> % match dosekempt
Lscenario.Tdose=[0];
Lscenario.Tclosed=[];
Lscenario.Tsimul=[];
Lscenario.Qmeals=[];
Lscenario.simToD=0;
Lscenario.BGinit=[];
Lscenario.Qbasal=[];
Lscenario.Qbolus=[];
Lscenario.Treg=[];
Lscenario.CR=[];
Lscenario.SQg=1;
Lscenario.IV_insulin.time=[0];
Lscenario.IV_insulin.signals.dimension=[1];
Lscenario.IV_insulin.signals.values=[0];
Lscenario.IV_glucose.time=[0];
Lscenario.IV_glucose.signals.dimension=[1];
Lscenario.IV_glucose.signals.values=[0];
Lscenario.SQ_Pram.time=[0];
Lscenario.SQ_Pram.signals.dimension=[1];
Lscenario.SQ_Pram.signals.values=[0];
Lscenario.SCNname=[];
% %------------- Default values for standard pump & sensor ---------------
% ------- Default values for hardware  -----------------------------------
% ------- Default values - load hardware files --------------------------- 
hardwareN.sensor='IV.scs';
hardware.SensorType=0;
hardwareN.pump='Generic_1.pmp';
hardware=load_hardware(hardwareN,hardware);

save sim_data Lstruttura Lscenario hardware

%outcomes=[1 1 1 1 1 1 1 1 1 1 1 1 1 0 0]; % most projects
%graphs=[0 0 0 0 0 1 0]; % most projects
outcomes=[1 0 0 1 1 0 0 1 0 0 0 1 0 0 0];
graphs=[0 0 0 0 0 0 0]; 
tgt=[70 180];
output.outcomes=outcomes;
output.graphs=graphs;
output.tgt=tgt;
% UIWAIT makes Simulator wait for user response (see UIRESUME)
% uiwait(handles.figure1);
save sim_out output
cwd=cd;
addpath([cwd filesep 'controller setup'],[cwd filesep 'scenario'],[cwd filesep 'results'],[cwd filesep 'hardware'])





% --- Outputs from this function are returned to the command line.
function varargout = Simulator_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes during listsubj creation, after setting all properties.
function listsubj_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to listsubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
cd subjects
subjlist=dir('*.mat');
subjlistc = {subjlist.name};
cd ..
handles.ListSubject=subjlistc;
set(hObject,'String',subjlistc)
guidata(hObject,handles)



% --- Executes on button press in **add**.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load sim_data Lstruttura Lscenario hardware
subjlist=get(handles.listsubj,'String');
if isempty(subjlist)
    return
end
newsubj=subjlist{get(handles.listsubj,'Value')};
exists=false;

for i=1:length(Lstruttura);
    exists=exists || strcmp(Lstruttura(i).names,newsubj);
end
if ~exists
    if isempty(Lstruttura)
        Lstruttura=load_subject(newsubj);
        
    else
        Lstruttura(length(Lstruttura)+1)=load_subject(newsubj);
        
    end
end
if ~isnumeric(Lstruttura)
    for i=1:length(Lstruttura)
        selectsubj{i}=Lstruttura(i).names;
    end
    set(handles.subject_check,'Value',1,'BackgroundColor','g')

else
    Lstruttura=[];
    selectsubj='';
    set(handles.subject_check,'Value',0,'BackgroundColor','r')
    display('one or more subject file is corrupted')
end
set(handles.selectedsubj,'String',selectsubj)
save sim_data Lstruttura Lscenario hardware




% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load sim_data Lstruttura Lscenario hardware
if ~isempty(Lstruttura)
    subjlist=get(handles.selectedsubj,'String');
    newsubj=subjlist(get(handles.selectedsubj,'Value'));
    exists=false;
    for i=1:length(Lstruttura);
        if strcmp(Lstruttura(i).names,newsubj);
            exists=true;
            ind=i;
        end
    end
    
    if exists
        if ind>1 && ind<length(Lstruttura)
            Lstruttura=Lstruttura([1:ind-1 ind+1:end]);
        elseif ind==1 && length(Lstruttura)>1
            Lstruttura=Lstruttura(2:end);
        elseif ind==1 && length(Lstruttura)==1
            Lstruttura=[];
        elseif ind==length(Lstruttura)
            Lstruttura=Lstruttura(1:end-1);
        end
    end
    for i=1:length(Lstruttura)
        selectsubj{i}=Lstruttura(i).names;
    end
    if isempty(Lstruttura)
        selectsubj=[];
        set(handles.subject_check,'Value',0,'BackgroundColor','r')
        
    end
else
    selectsubj=[];
    set(handles.subject_check,'Value',0,'BackgroundColor','r')
    
end
set(handles.selectedsubj,'Value',1)
set(handles.selectedsubj,'String',selectsubj)
save sim_data Lstruttura Lscenario hardware




% --- execute on button press in Add List
function add_all_Callback(hObject, eventdata, handles)
% hObject    handle to add_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load sim_data Lstruttura Lscenario hardware
subjects=get(handles.listsubj, 'String');
ind=[];
if get(handles.subj_list,'Value')
    subjects=strtrim(regexp(get(handles.edit24,'String'),',','split')); % Fix whitespace error. Steven 3/21/2014
    n=length(subjects);
    
%  
%  
%  
%  
else
    if get(handles.kids,'Value')
        test='child';
    elseif get(handles.teens,'Value')
        test='adolescent';
    elseif get(handles.adults,'Value')
        test='adult';
    elseif get(handles.avge,'Value')
        test='average';
    else
        test='#';
    end
    
    for k=1:length(subjects)
        ref=subjects{k};
        if compstr(test,ref)==1
            ind=[ind k];
        end
    end
    
    subjects=subjects(ind);
    n=length(subjects);
    
%   
%   
%  
%  

   
end
ind=[];
if ~isempty(Lstruttura)
    for i=1:n
        for j=1:length(Lstruttura)
            if strcmp(Lstruttura(j).names,subjects{i})
                ind=[ind i];
            end
        end
    end
end
subjects=subjects(eliminate([1:n],ind));
n=length(subjects);
for i=1:n
    try
    subj=load_subject(subjects{i});
    if isnumeric(subj)
   display(['no ' subjects{i} ' subject']) % better error return. Steven 3/21/2014
    else
    Lstruttura=[Lstruttura subj];
    end
%  
    catch e
        rethrow(e);
    end
end

selectsubj=[];
for i=1:length(Lstruttura)
    selectsubj{i}=Lstruttura(i).names;
end
% 


% 
% 
% 
% 
% 

set(handles.selectedsubj,'String',selectsubj)
save sim_data Lstruttura Lscenario hardware
set(handles.subject_check,'Value',1,'BackgroundColor','g')





% --- Executes on button press in Remove List.
function rem_all_Callback(hObject, eventdata, handles)
% hObject    handle to rem_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load sim_data Lstruttura Lscenario hardware

subjects=get(handles.selectedsubj,'String');
if get(handles.subj_list,'Value')
    remsubj=strtrim(regexp(get(handles.edit24,'String'),',','split')); % Fix whitespace error. Steven 3/21/2014
    n=length(subjects);
    
%     
%     
%     
%     
    ind=[];
    for k=1:n
        test=subjects{k};
        if sum(strcmp(test,remsubj)) %ind the first valid subject file, since all subject files start by subjects#
            ind=[ind k];
        end
%     
    end

else
    if get(handles.kids,'Value')
        substr='child';
    elseif get(handles.teens,'Value')
        substr='adolescent';
    elseif get(handles.adults,'Value')
        substr='adult';
    elseif get(handles.avge,'Value')
        substr='average';
    else
        substr='#';
    end
    ind=[];
    n=length(subjects);
    
    
%    
%   
%    
%     
    for k=1:n
        test=subjects{k};
        if ~isempty(strfind(test,substr)) %ind the first valid subject file, since all subject files start by subjects#
            ind=[ind k];
        end
%      
    end
end
Lstruttura=remove_list(Lstruttura,ind);
subjects=remove_list(subjects,ind);
% 
set(handles.selectedsubj,'String',subjects)
save sim_data Lstruttura Lscenario hardware
if isempty(Lstruttura)
    set(handles.subject_check,'Value',0,'BackgroundColor','r')
end

save sim_data Lstruttura Lscenario hardware




% --- Executes on button press in **Select Hardware Files**.
function choose_hardware_Callback(hObject, eventdata, handles)
% hObject    handle to choose_hardware (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load sim_data Lstruttura Lscenario hardware
cd hardware
Lsensor=dir('*.scs');
Lpump=dir('*.pmp');
cd ..
hardwareN=hardware_window('list_sensor',{Lsensor.name},'list_pump',{Lpump.name});
if ~isempty(hardwareN)
    hardware=load_hardware(hardwareN,hardware);
    set(handles.pumpText,'String',hardwareN.pump)
    set(handles.sensorText,'String',hardwareN.sensor)
    set(handles.run,'Enable','on')
end
save sim_data Lstruttura Lscenario hardware


% --- Executes on button press in Select Scenario Files.
function load_mult_file_Callback(hObject, eventdata, handles)
% hObject    handle to load_mult_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load sim_data Lstruttura hardware
Lscenario=scenario_window;
if ~isempty(Lscenario)
    set(handles.scenario_check,'Value',1);
    set(handles.scenario_check,'BackgroundColor','g');
else
    set(handles.scenario_check,'Value',0);
    set(handles.scenario_check,'BackgroundColor','r');
end
save sim_data Lstruttura Lscenario hardware
% error_window('String','In construction')


% --- Executes on button press in Run Simulation.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 display('T1DMS Simulation IN PROGRESS, please wait . . .')
warning('off','all')
load sim_data Lstruttura Lscenario hardware
Lst=Lstruttura;
hd=hardware;
Nscenario=length(Lscenario);

for scen=1:Nscenario
    scenario=Lscenario(scen);
    
    if isempty(scenario.CR)
        scenario.CR='off';
    end
    
    sc_checked=get(handles.scenario_check,'Value');
    sb_checked=get(handles.subject_check,'Value');
    
    if ~sc_checked
        error_window('string','You need to select a scenario')
    elseif ~sb_checked
        error_window('string','You need to select at least 1 subject')
    else
        
%          sb = statusbar(hObject,['Scenario ' num2str(scen) '/' num2str(Nscenario) ' simulation in progress, please wait.']);
%                 sb.getParent.setVisible(1)
%                 set(sb.ProgressBar, 'Visible','on', 'Indeterminate','off');
%                 set(sb.ProgressBar, 'Visible','on', 'StringPainted','on');
%                 set(sb.ProgressBar,'Value',0)
        n=length(Lstruttura);
        
        rep=round(str2double(get(handles.repeat,'String')))*get(handles.repInd,'Value');
        
        if isempty(rep)
            rep=1;
        elseif rep<=0
            rep=1;
        end
        
        %creating a single randomgenerator per patient ensures independence
        %accross subject AND reproducibility.
        seed=str2double(get(handles.seed,'String'));
        if isnan(seed) || isempty(seed)
            seed=sum(100*clock);
        end
        for ind=1:n
            Lst(ind).rg=RandStream.create('mrg32k3a','NumStreams',n,'StreamIndices',ind,'Seed',seed);
        end
        
        bck_SQinsulin=scenario.SQ_insulin.signals;
        
        bck_meals=scenario.meals;
        bck_meal_announce=scenario.meal_announce;
        scenario_bck=scenario;
        tic % tic toc tic toc tic toc tic toc 
        addpath('controller setup')
%      
%      
%      
%      
%       
%      
%      
%      
%      

        parfor ind=1:n    % % 
            try
            sc=scenario_bck;
            struttura=Lst(ind);
            display(['simulating ' struttura.names])
            drawnow
            res_aux=run_simulation(sc,struttura,hd,rep,bck_meals,...
                bck_meal_announce,bck_SQinsulin,ind);
            resultsb(ind).res=res_aux;
            display(['end of ' struttura.names])        
            catch e                
                rethrow(e);
            end
        end

        toc % tic toc tic toc tic toc tic toc 
        for ind=1:n
            for k=1:rep
                results((ind-1)*rep+k)=resultsb(ind).res{k};
            end
        end
        
        clear resultsb
        data(scen).results=results;
        data(scen).scenario=scenario_bck;
        data(scen).hardware=hd;    % % for Audit in dataFile
        % ***** Store ctrlsetup settings ***** 
        % Subject Specific (Quest calculated) values are reported as 0
        % All Values may not be used in The Controller
         data(scen).ctrlsetup = ctrlsetup(...
             struct('basal',0,'OB',0,'MD',0,'names',0,'weight',0,'fastingBG',0),...
             [],...
             [],...
             [],[]);  % {'basal','OB','MD','CR','CF','name','BW','fastingBG'});
            data(scen).ctrlsetup.Note_1 = 'Subject Specific Values (Quest.*, OB, CR, basal, etc.) may be reported = 0';
            data(scen).ctrlsetup.Note_2 = 'ctrlsetup.m ctrller.* Info is not necessarily included in Simulink controller';
            data(scen).ctrlsetup.Note_3 = 'ctrlsetup.m Info provided for auditing purposes';
        %***** Done storing ctrolsetup *****
        save sim_results data
        display('T1DMS Simulation of Subjects is complete, Computing Outcomes . . .')
        load sim_out output
        delete(['tempres' filesep '*'])
        %    
        create_output(results,output,[scenario.Tdose(2:end)' scenario.dose(2:end)'],scenario.Treg,get(handles.saveastxt,'Value'));
        clear results
           SCEN1 = int2str(scen);
           SCEN2 = int2str(Nscenario);
            message1 = strcat('Scenario_', SCEN1,'_of_',SCEN2);
            disp(message1)        
            display('T1DMS Simulation has ended . . .')
            if scen < Nscenario
                display('WAIT for next Scenario Simulation . . .')
                display('T1DMS Simulation IN PROGRESS, please wait . . .')
            end

    end
    
        
    guidata(hObject,handles)
    
    
end
if length(Lscenario)>1
    popstat=accrossscenario_output('String','Do you want summary statistics and graphs (accross scenario)?');
    if popstat
        load sim_out output
        accross_output(data,output,get(handles.saveastxt,'Value'));
        display(' accross_outpu')
    end
end




% --- Executes on button press in Choose outcome measures.
function outcome_Callback(hObject, eventdata, handles)
% hObject    handle to outcome (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load sim_out output

output=choose_outcome(output);

save sim_out output


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


% --- Executes on selection change in `listsubj`.
function listsubj_Callback(hObject, eventdata, handles)
% hObject    handle to listsubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns listsubj contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listsubj


% --- Executes on selection change in selectedsubj.
function selectedsubj_Callback(hObject, eventdata, handles)
% hObject    handle to selectedsubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns selectedsubj contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectedsubj

% --- Executes during object creation, after setting all properties.
function selectedsubj_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectedsubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








% --- Executes on button press in repInd.
function repInd_Callback(hObject, eventdata, handles)
% hObject    handle to repInd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of repInd


function repeat_Callback(hObject, eventdata, handles)
% hObject    handle to repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repeat as text
%        str2double(get(hObject,'String')) returns contents of repeat as a double


% --- Executes during object creation, after setting all properties.
function repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function seed_Callback(hObject, eventdata, handles)
% hObject    handle to seed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of seed as text
%        str2double(get(hObject,'String')) returns contents of seed as a double


% --- Executes during object creation, after setting all properties.
function seed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function regtime_Callback(hObject, eventdata, handles)
% hObject    handle to regtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of regtime as text
%        str2double(get(hObject,'String')) returns contents of regtime as a double


% --- Executes during object creation, after setting all properties.
function regtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

select_metab_meas;


% --- Executes on button press in radiobutton22.
function radiobutton22_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton22


% --- Executes on button press in radiobutton23.
function radiobutton23_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton23


% --- Executes on button press in radiobutton24.
function radiobutton24_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton24


% --- Executes on button press in Use GUI to Create Scenario.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SCcheck=Scenario_GUI;
if SCcheck==1
    set(handles.scenario_check,'Value',1);
    set(handles.scenario_check,'BackgroundColor','g');
elseif SCcheck==0
    set(handles.scenario_check,'Value',0);
    set(handles.scenario_check,'BackgroundColor','r');
end


function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when press 'enter' in enter subject text field.%
function edit24_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

subjlist=handles.ListSubject;
if strcmp(eventdata.Key,'return') %Detect 'enter'
    drawnow
    set(handles.subj_list,'value',1)    
    uipanel8_SelectionChangeFcn(handles.uipanel8, [], handles);       
    handles = guidata(hObject);
else
    return;
end
 
% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
load sim_out output

if get(hObject,'Value')
    output.graphs(6)=1;
else
    output.graphs(6)=0;
end
save sim_out output

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
load sim_out output

if get(hObject,'Value')
    output.graphs(1)=1;
else
    output.graphs(1)=0;
end
save sim_out output


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
load sim_out output

if get(hObject,'Value')
    output.graphs(7)=1;
else
    output.graphs(7)=0;
end
save sim_out output

% --- Executes on button press in **clear scenario**.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load sim_data Lstruttura Lscenario hardware % it might be better to use -append method when saving 'mat' file.
Lscenario = []; % Fix multi-scenario error
Lscenario.SQ_Gluc.time=[0];
Lscenario.SQ_Gluc.signals.dimensions=[1];
Lscenario.SQ_Gluc.signals.values=[0];
Lscenario.SQ_Pram.time=[0];
Lscenario.SQ_Pram.signals.dimensions=[1];
Lscenario.SQ_Pram.signals.values=[0];
Lscenario.SQ_insulin.time=[0];
Lscenario.SQ_insulin.signals.dimensions=[1];
Lscenario.SQ_insulin.signals.values=[0];
Lscenario.meals=[];
Lscenario.meal_announce=[];
Lscenario.dose=[30]; % match dosekempt
Lscenario.Tdose=[0];
Lscenario.Tclosed=[];
Lscenario.Tsimul=[];
Lscenario.Qmeals=[];
Lscenario.simToD=0;
Lscenario.BGinit=[];
Lscenario.Qbasal=[];
Lscenario.Qbolus=[];
Lscenario.Treg=[];
Lscenario.CR=[];
Lscenario.SQg=1;
Lscenario.IV_insulin.time=[0];
Lscenario.IV_insulin.signals.dimension=[1];
Lscenario.IV_insulin.signals.values=[0];
Lscenario.IV_glucose.time=[0];
Lscenario.IV_glucose.signals.dimension=[1];
Lscenario.IV_glucose.signals.values=[0];
Lscenario.SQ_Pram.time=[0];
Lscenario.SQ_Pram.signals.dimension=[1];
Lscenario.SQ_Pram.signals.values=[0];
Lscenario.SCNname=[];
    set(handles.scenario_check,'Value',0);
    set(handles.scenario_check,'BackgroundColor','r');
save sim_data Lstruttura Lscenario hardware


% --- Executes on button press in *scenario_check*.
function scenario_check_Callback(hObject, eventdata, handles)
% hObject    handle to scenario_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of scenario_check


% --- Executes when selected object is changed in uipanel19.
function uipanel19_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel19 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
load sim_data Lstruttura Lscenario hardware
hardware.SensorType=1;
if get(handles.radiobutton6,'Value')
    hardwareN.sensor='IV.scs';
    hardware.SensorType=0;
elseif get(handles.radiobutton7,'Value')
    hardwareN.sensor='SMBG.scs';
    hardware.SensorType=2;
else
    hardwareN.sensor='Default_1s.scs';
     hardware.SensorType=1;
end

if get(handles.radiobutton11,'Value')
    hardwareN.pump='ComplexOne.pmp';
elseif get(handles.radiobutton12,'Value')
    hardwareN.pump='No_Error.pmp';
else
    hardwareN.pump='Generic_1.pmp';
end
hardware=load_hardware(hardwareN,hardware);
save sim_data Lstruttura Lscenario hardware

% --- Executes when selected object is changed in uipanel20.
% --- Executes when selected object is changed in uipanel20.
function uipanel20_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel20 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

uipanel19_SelectionChangeFcn(handles.uipanel19, eventdata, handles);
handles = guidata(hObject);
guidata(hObject, handles);


% --- Executes on button press in subject_check.
function subject_check_Callback(hObject, eventdata, handles)
% hObject    handle to subject_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of subject_check


% --- Executes on button press in saveastxt.
function saveastxt_Callback(hObject, eventdata, handles)
% hObject    handle to saveastxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in uipanel8.
function uipanel8_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel8 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
subjlist=handles.ListSubject;
if get(handles.all,'Value')
     L=1:length(subjlist);
elseif get(handles.teens,'Value')
    L=[];
    for i=1:length(subjlist)
        if strfind(subjlist{i},'adolescent')
            L=[L i];
        end
    end
elseif get(handles.adults,'Value')
    L=[];
    for i=1:length(subjlist)
        if strfind(subjlist{i},'adult')
            L=[L i];
        end
    end
elseif get(handles.kids,'Value')
    L=[];
    for i=1:length(subjlist)
        if strfind(subjlist{i},'child')
            L=[L i];
        end
    end
elseif get(handles.avge,'Value')
    L=[];
    for i=1:length(subjlist)
        if strfind(subjlist{i},'average')
            L=[L i];
        end
    end
elseif get((handles.subj_list),'Value') % Steven 3/21/2014
    % Check what's in the list
    mySubjects=strtrim(regexp(get(handles.edit24,'String'),',','split'));
    [~,L] =intersect(subjlist,mySubjects);
end
new_subj_list=subjlist(L);
set(handles.listsubj,'Value',1); % Fix listsubj disappearing issue. Steven 3/26/2014
% The `Subject Listbox` sometimes disappears because the index was set out of range due to previous subject selction.
% How to reproduce: Click `all` -> select the last subject -> click `Adult`
set(handles.listsubj,'String',new_subj_list)
drawnow % better do drawnow in case the GUI does not update

% --- Executes on button press in builtIn.
function builtIn_Callback(hObject, eventdata, handles)
% hObject    handle to builtIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of builtIn    
    set( hObject, 'Value', 1 );
    set( handles.run,'Enable','on');
    set( handles.fromFile, 'Value', 0);
    set( handles.pumpText, 'Enable', 'off' );
    set( handles.sensorText, 'Enable', 'off' );
    set( handles.choose_hardware, 'Enable', 'off' );
    set(findall(handles.uipanel19, '-property', 'Enable'),'Enable','on');
    set(findall(handles.uipanel20, '-property', 'Enable'),'Enable','on');
    uipanel19_SelectionChangeFcn(handles.uipanel19, eventdata, handles);
    set( handles.pumpText, 'String', 'No selection.');
    set( handles.sensorText, 'String', 'No selection.');

% --- Executes on button press in fromFile.
function fromFile_Callback(hObject, eventdata, handles)
% hObject    handle to fromFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fromFile
    if get( handles.builtIn, 'Value') == 1 % Built-in was previously selected
        set( handles.run, 'Enable', 'off')
    end
    set( hObject, 'Value', 1 );    
    set( handles.builtIn, 'Value', 0);
    set( handles.pumpText, 'Enable', 'on' );
    set( handles.sensorText, 'Enable', 'on' );
    set( handles.choose_hardware, 'Enable', 'on' );
    set(findall(handles.uipanel19, '-property', 'Enable'),'Enable','off');
    set(findall(handles.uipanel20, '-property', 'Enable'),'Enable','off');
