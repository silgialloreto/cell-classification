function varargout = visualize_settings_big(varargin)

% This is an internal routine for the graphical interface of the toolbox.
% The main routine to open the graphical interface is class_gui
%
% HELP:
% note that a detailed HTML help is provided with the toolbox,
% see the HTML HELP files (help.htm) for futher details and examples
%
% LICENCE:
% This toolbox is distributed with an Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0) licence: https://creativecommons.org/licenses/by-nc-nd/4.0/
% You are free to share - copy and redistribute the material in any medium or format. The licensor cannot revoke these freedoms as long as you follow the following license terms:
% Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
% NonCommercial - You may not use the material for commercial purposes.
% NoDerivatives - If you remix, transform, or build upon the material, you may not distribute the modified material.
%
% REFERENCE:
% The toolbox is freeware and may be used if proper reference is given to the authors, preferably refer to the following paper:
% Ballabio D, Consonni V, (2013) Classification tools in chemistry. Part 1: Linear models. PLS-DA. Analytical Methods, 5, 3790-3798
% 
% Classification toolbox for MATLAB
% version 6.0 - October 2021
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualize_settings_big_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_settings_big_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before visualize_settings_big is made visible.
function visualize_settings_big_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% get inputs
handles.model_type = varargin{1};
handles.num_samples = varargin{2};
handles.model_is_present = varargin{3};
handles.model_loaded = varargin{4};
handles.maxparam = varargin{5};
handles.class_labels_for_combo = varargin{6};
handles.disable_combo = varargin{7};
handles.X  = varargin{8};
handles.class  = varargin{9};
handles.class_labels = varargin{10};
handles.class_string = varargin{11};
% parameters for positions
x_position = 3.5;
x_position_button = 47;
y_position = [29.2 25.2 21.2 17.2 13.2 9.2 5.2 1.2];
translate_form = 11.5;
step_for_text = 1.8;
% reorder list of popup menu
if strcmp(handles.model_type,'svm')
    y_position = y_position([7 8 4 6 1 2 3 5]);
    translate_form = 0;
elseif strcmp(handles.model_type,'pf')
    y_position = y_position([7 8 4 6 1 3 2 5]);
    translate_form = 0;
elseif strcmp(handles.model_type,'backprop')
    y_position = y_position([7 8 4 5 1 2 3 6]);
    translate_form = 0;
elseif strcmp(handles.model_type,'plsda') || strcmp(handles.model_type,'pcada')  || strcmp(handles.model_type,'knn')
    y_position = y_position([5 6 1 3 4 2 7 8]);
    translate_form = 7;
elseif strcmp(handles.model_type,'simca') || strcmp(handles.model_type,'uneq')
    y_position = y_position([5 6 2 4 1 3 7 8]);
    translate_form = 7;
end
y_position = y_position - translate_form;
% set positions
set(hObject,'Position',[103.8571 45.4706 70 36-translate_form]);
set(handles.text01,'Position',[x_position y_position(1)+step_for_text 33 1.1]);
set(handles.pop_menu_cv_type,'Position',[x_position y_position(1) 33 1.7]);
set(handles.text02,'Position',[x_position y_position(2)+step_for_text 33 1.1]);
set(handles.pop_menu_cv_groups,'Position',[x_position y_position(2) 33 1.7]);
set(handles.text03,'Position',[x_position y_position(3)+step_for_text 33 1.1]);
set(handles.pop_menu_03,'Position',[x_position y_position(3) 33 1.7]);
set(handles.text04,'Position',[x_position y_position(4)+step_for_text 33 1.1]);
set(handles.pop_menu_04,'Position',[x_position y_position(4) 33 1.7]);
set(handles.text05,'Position',[x_position y_position(5)+step_for_text 33 1.1]);
set(handles.pop_menu_05,'Position',[x_position y_position(5) 33 1.7]);
set(handles.text06,'Position',[x_position y_position(6)+step_for_text 33 1.1]);
set(handles.pop_menu_06,'Position',[x_position y_position(6) 33 1.7]);
set(handles.text07,'Position',[x_position y_position(7)+step_for_text 33 1.1]);
set(handles.pop_menu_07,'Position',[x_position y_position(7) 33 1.7]);
set(handles.text08,'Position',[x_position y_position(8)+step_for_text 33 1.1]);
set(handles.pop_menu_08,'Position',[x_position y_position(8) 33 1.7]);
% set buttons and panel
set(handles.button_help,'Position',[x_position_button 24-translate_form 21 2]);
set(handles.button_cancel,'Position',[x_position_button 27-translate_form 21 2]);
set(handles.button_optimize,'Position',[x_position_button 30-translate_form 21 2]);
set(handles.button_calculate_model,'Position',[x_position_button 33-translate_form 21 2]);
set(handles.panel_settings,'Position',[3 1.4 42 34-translate_form]);
movegui(handles.visualize_settings_big,'center')
% set cv type combo
str_disp={};
str_disp{1} = 'none';
str_disp{2} = 'venetian blinds cross validation';
str_disp{3} = 'contiguous blocks cross validation';
if handles.disable_combo == 0 % only if no optimisation is needed
    str_disp{4} = 'montecarlo 20% out';
    str_disp{5} = 'bootstrap';
end
set(handles.pop_menu_cv_type,'String',str_disp);
set(handles.pop_menu_cv_type,'Value',2);
% set cv groups combo
handles = set_cvgroups_combo(handles);
% customize window
handles = custom_form(handles);
% initialize values
handles.domodel = 0;
% enable/disable combo
handles = enable_disable(handles);
guidata(hObject, handles);
uiwait(handles.visualize_settings_big);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_settings_big_OutputFcn(hObject, eventdata, handles)
len = length(handles);
if len > 0
    w = get(handles.pop_menu_cv_groups,'Value');
    cv_groups = get(handles.pop_menu_cv_groups,'String');
    cv_groups = cv_groups{w};
    cv_groups = str2num(cv_groups);
    varargout{1} = cv_groups;
    if get(handles.pop_menu_cv_type,'Value') == 1
        set_this = 'none';
    elseif get(handles.pop_menu_cv_type,'Value') == 2
        set_this = 'vene';
    elseif get(handles.pop_menu_cv_type,'Value') == 3
        set_this = 'cont'; 
    elseif get(handles.pop_menu_cv_type,'Value') == 4
        set_this = 'rand';
    else
        set_this = 'boot';
    end
    varargout{2} = set_this;
    varargout{3} = takevaluefrompopmenu(get(handles.pop_menu_03,'String'),get(handles.pop_menu_03,'Value'));
    varargout{4} = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
    varargout{5} = takevaluefrompopmenu(get(handles.pop_menu_05,'String'),get(handles.pop_menu_05,'Value'));
    varargout{6} = takevaluefrompopmenu(get(handles.pop_menu_06,'String'),get(handles.pop_menu_06,'Value'));
    varargout{7} = takevaluefrompopmenu(get(handles.pop_menu_07,'String'),get(handles.pop_menu_07,'Value'));
    if strcmp(handles.model_type,'backprop')
        varargout{8} = get(handles.pop_menu_08,'Value') - 1;
    else
        varargout{8} = takevaluefrompopmenu(get(handles.pop_menu_08,'String'),get(handles.pop_menu_08,'Value'));
    end
    varargout{9} = handles.domodel;
    delete(handles.visualize_settings_big)
else
    handles.settings.cv_groups = NaN;
    handles.settings.cv_type = NaN;
    handles.domodel = 0;
    varargout{1} = handles.settings.cv_groups;
    varargout{2} = handles.settings.cv_type;
    varargout{3} = 0;
    varargout{4} = 0;
    varargout{5} = 0;
    varargout{6} = 0;
    varargout{7} = 0;
    varargout{8} = 0;
    varargout{9} = handles.domodel;
end

% --- Executes on button press in button_calculate_model.
function button_calculate_model_Callback(hObject, eventdata, handles)
handles.domodel = 1;
guidata(hObject,handles)
uiresume(handles.visualize_settings_big)

% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
handles.settings = NaN;
guidata(hObject,handles)
uiresume(handles.visualize_settings_big)

% --- Executes on button press in button_optimize.
function button_optimize_Callback(hObject, eventdata, handles)
do_optimal(handles);

% --- Executes on button press in button_help.
function button_help_Callback(hObject, eventdata, handles)
web('help/gui_calculate.htm','-browser')

% --- Executes during object creation, after setting all properties.
function pop_menu_cv_groups_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_cv_groups.
function pop_menu_cv_groups_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_cv_type_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_cv_type.
function pop_menu_cv_type_Callback(hObject, eventdata, handles)
handles = set_cvgroups_combo(handles);
handles = enable_disable(handles);
guidata(hObject,handles)

% --- Executes on selection change in pop_menu_04.
function pop_menu_04_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_04_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_05.
function pop_menu_05_Callback(hObject, eventdata, handles)
if strcmp(handles.model_type,'svm')
    handles = setparamcombo(handles,NaN);
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_05_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_06.
function pop_menu_06_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_06_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_07.
function pop_menu_07_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_07_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_08.
function pop_menu_08_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_08_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------------
function A = takevaluefrompopmenu(list,val)
A = list(val);
A = cell2mat(A);
[num, status] = str2num(A);
if ischar(A)
    if strcmp(A,'linear')
        status = 0;
    end
end
if status
    A = num;
else
    % exceptions
    if strcmp(A,'mean centering')
        A = 'cent';
    elseif strcmp(A,'autoscaling')
        A = 'auto';
    elseif strcmp(A,'gaussian')
        A = 'gaus';
    elseif strcmp(A,'triangular')
        A = 'tria';
    elseif strcmp(A,'standard normal variate')
        A = 'snv';
    elseif strcmp(A,'multiplicative scatter correction')
        A = 'msc';
    elseif strcmp(A,'first derivative')
        A = 'der1';
    elseif strcmp(A,'second derivative')
        A = 'der2';
    elseif strcmp(A,'range scaling')
        A = 'rang';
    elseif strcmp(A,'variance scaling')
        A = 'scal';
    end
end

% ------------------------------------------------------------------------
function handles = enable_disable(handles)
val = get(handles.pop_menu_cv_type,'value');
if val == 1
    set(handles.pop_menu_cv_groups,'Enable','off');    
else
    set(handles.pop_menu_cv_groups,'Enable','on');
end

% ------------------------------------------------------------------------
function handles = custom_form(handles)
% param 
str_param={};
for j=1:handles.maxparam; str_param{j} = num2str(j); end
% memory of loaded model
if handles.model_is_present == 2 && handles.disable_combo == 0 % a model is already calculated
    model_memory = 1;
else
    model_memory = 0;
end
% scaling
str_scaling={};
str_scaling{1} = 'none';
str_scaling{2} = 'mean centering';
str_scaling{3} = 'autoscaling';
str_scaling{4} = 'variance scaling';
str_scaling{5} = 'range scaling';
str_scaling_row={};
str_scaling_row{1} = 'none';
str_scaling_row{2} = 'standard normal variate';
str_scaling_row{3} = 'multiplicative scatter correction';
str_scaling_row{4} = 'first derivative';
str_scaling_row{5} = 'second derivative';
if strcmp(handles.model_type,'plsda')
    set(handles.visualize_settings_big,'Name','PLS-DA settings')
    set(handles.button_optimize,'String','optimal LV')
    % num comp
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of LV:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && strcmp(handles.model_loaded.type,'plsda')
        set(handles.pop_menu_03,'Value',size(handles.model_loaded.T,2));
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','column pre-processing:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'plsda')
        if strcmp(handles.model_loaded.settings.preprocess_columns,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'cent')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'auto')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'scal')
            set_this = 4;         
        else
            set_this = 5;     
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % assignation
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','assignation criterion:');
    str_disp = {};
    str_disp{1} = 'bayes';
    str_disp{2} = 'max';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'plsda')
        if strcmp(handles.model_loaded.settings.assign_method,'bayes')
            set(handles.pop_menu_05,'Value',1);
        else
            set(handles.pop_menu_05,'Value',2);
        end
    end
    % row scaling
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','row pre-processing:');
    set(handles.pop_menu_06,'String',str_scaling_row);
    set(handles.pop_menu_06,'Visible','on');
    if model_memory && strcmp(handles.model_loaded.type,'plsda')
        if strcmp(handles.model_loaded.settings.preprocess_rows,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'snv')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'msc')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'der1')
            set_this = 4;
        else
            set_this = 5;
        end
        set(handles.pop_menu_06,'Value',set_this);
    else
        set(handles.pop_menu_06,'Value',1);
    end
    % disabled
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
    set(handles.text08,'Visible','off');
    set(handles.pop_menu_08,'String',{'NaN'});
    set(handles.pop_menu_08,'Visible','off');
elseif strcmp(handles.model_type,'simca')
    set(handles.visualize_settings_big,'Name','SIMCA settings')
    set(handles.button_optimize,'String','optimal PC')
    % num comp
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of PCs:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && strcmp(handles.model_loaded.type,'simca')
        set(handles.pop_menu_03,'Value',size(handles.model_loaded.T,2));
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','column pre-processing:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'simca')
        if strcmp(handles.model_loaded.settings.preprocess_columns,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'cent')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'auto')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'scal')
            set_this = 4;         
        else
            set_this = 5;     
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % target class
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','target class:');
    str_disp = handles.class_labels_for_combo;
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'simca')
        if isnumeric(handles.model_loaded.settings.target_class)
            set(handles.pop_menu_05,'Value',handles.model_loaded.settings.target_class);
        else    
            where = find(strcmp(handles.model_loaded.settings.target_class,handles.class_labels_for_combo));
            if length(where) > 0
                set(handles.pop_menu_05,'Value',where);
            else
                set(handles.pop_menu_05,'Value',1);
            end
        end
    end
    % row scaling
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','row pre-processing:');
    set(handles.pop_menu_06,'String',str_scaling_row);
    set(handles.pop_menu_06,'Visible','on');
    if model_memory && strcmp(handles.model_loaded.type,'simca')
        if strcmp(handles.model_loaded.settings.preprocess_rows,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'snv')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'msc')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'der1')
            set_this = 4;
        else
            set_this = 5;
        end
        set(handles.pop_menu_06,'Value',set_this);
    else
        set(handles.pop_menu_06,'Value',1);
    end
    % disabled
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
    set(handles.text08,'Visible','off');
    set(handles.pop_menu_08,'String',{'NaN'});
    set(handles.pop_menu_08,'Visible','off');
elseif strcmp(handles.model_type,'uneq')
    set(handles.visualize_settings_big,'Name','UNEQ settings')
    set(handles.button_optimize,'String','optimal PC')
    % num comp
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of PCs:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && strcmp(handles.model_loaded.type,'uneq')
        set(handles.pop_menu_03,'Value',size(handles.model_loaded.T,2));
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','column pre-processing:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'uneq')
        if strcmp(handles.model_loaded.settings.preprocess_columns,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'cent')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'auto')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'scal')
            set_this = 4;         
        else
            set_this = 5;     
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % target class
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','target class:');
    str_disp = handles.class_labels_for_combo;
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'uneq')
        if isnumeric(handles.model_loaded.settings.target_class)
            set(handles.pop_menu_05,'Value',handles.model_loaded.settings.target_class);
        else    
            where = find(strcmp(handles.model_loaded.settings.target_class,handles.class_labels_for_combo));
            if length(where) > 0
                set(handles.pop_menu_05,'Value',where);
            else
                set(handles.pop_menu_05,'Value',1);
            end
        end
    end
    % row scaling
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','row pre-processing:');
    set(handles.pop_menu_06,'String',str_scaling_row);
    set(handles.pop_menu_06,'Visible','on');
    if model_memory && strcmp(handles.model_loaded.type,'uneq')
        if strcmp(handles.model_loaded.settings.preprocess_rows,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'snv')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'msc')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'der1')
            set_this = 4;
        else
            set_this = 5;
        end
        set(handles.pop_menu_06,'Value',set_this);
    else
        set(handles.pop_menu_06,'Value',1);
    end
    % disabled
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
    set(handles.text08,'Visible','off');
    set(handles.pop_menu_08,'String',{'NaN'});
    set(handles.pop_menu_08,'Visible','off');
elseif strcmp(handles.model_type,'knn')
    set(handles.visualize_settings_big,'Name','k-NN settings')
    set(handles.button_optimize,'String','optimal k')
    % num k
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of neighbours (K):');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && strcmp(handles.model_loaded.type,'knn')
        set(handles.pop_menu_03,'Value',handles.model_loaded.settings.K);
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','column pre-processing:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'knn')
        if strcmp(handles.model_loaded.settings.preprocess_columns,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'cent')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'auto')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'scal')
            set_this = 4;         
        else
            set_this = 5;     
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % distance
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','distance:');
    str_disp={};
    str_disp{1} = 'euclidean';
    str_disp{2} = 'mahalanobis';
    str_disp{3} = 'cityblock';
    str_disp{4} = 'minkowski';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'knn')
        if strcmp(handles.model_loaded.settings.dist_type,'euclidean')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.dist_type,'mahalanobis')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.dist_type,'cityblock')
            set_this = 3;
        else
            set_this = 4;
        end
        set(handles.pop_menu_05,'Value',set_this);
    end
    % row scaling
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','row pre-processing:');
    set(handles.pop_menu_06,'String',str_scaling_row);
    set(handles.pop_menu_06,'Visible','on');
    if model_memory && strcmp(handles.model_loaded.type,'knn')
        if strcmp(handles.model_loaded.settings.preprocess_rows,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'snv')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'msc')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'der1')
            set_this = 4;
        else
            set_this = 5;
        end
        set(handles.pop_menu_06,'Value',set_this);
    else
        set(handles.pop_menu_06,'Value',1);
    end
    % disabled
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
    set(handles.text08,'Visible','off');
    set(handles.pop_menu_08,'String',{'NaN'});
    set(handles.pop_menu_08,'Visible','off');
elseif strcmp(handles.model_type,'pcada')
    set(handles.visualize_settings_big,'Name','PCA-DA settings')
    set(handles.button_optimize,'String','optimal PC')
    % num comp
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of components:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && (strcmp(handles.model_loaded.type,'pcalda') || strcmp(handles.model_loaded.type,'pcaqda'))
        set(handles.pop_menu_03,'Value',size(handles.model_loaded.settings.modelpca.T,2));
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','column pre-processing:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && (strcmp(handles.model_loaded.type,'pcalda') || strcmp(handles.model_loaded.type,'pcaqda'))
        if strcmp(handles.model_loaded.settings.preprocess_columns,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'cent')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'auto')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'scal')
            set_this = 4;         
        else
            set_this = 5;     
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % discrimination
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','discrimination:');
    str_disp={};
    str_disp{1} = 'linear';
    str_disp{2} = 'quadratic';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'pcalda')
        set(handles.pop_menu_05,'Value',1);
    elseif model_memory && strcmp(handles.model_loaded.type,'pcaqda')
        set(handles.pop_menu_05,'Value',2);
    end
    % row scaling
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','row pre-processing:');
    set(handles.pop_menu_06,'String',str_scaling_row);
    set(handles.pop_menu_06,'Visible','on');
    if model_memory && (strcmp(handles.model_loaded.type,'pcalda') || strcmp(handles.model_loaded.type,'pcaqda'))
        if strcmp(handles.model_loaded.settings.preprocess_rows,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'snv')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'msc')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'der1')
            set_this = 4;
        else
            set_this = 5;
        end
        set(handles.pop_menu_06,'Value',set_this);
    else
        set(handles.pop_menu_06,'Value',1);
    end
    % disabled
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
    set(handles.text08,'Visible','off');
    set(handles.pop_menu_08,'String',{'NaN'});
    set(handles.pop_menu_08,'Visible','off');
elseif strcmp(handles.model_type,'svm')
    set(handles.visualize_settings_big,'Name','SVM settings')
    set(handles.button_optimize,'String','optimal parameters')
    % num comp
    str_param_here{1} = 'none';
    str_param_here{2} = 'automatic';
    for j=3:handles.maxparam+2; str_param_here{j} = num2str(j-2); end
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','Apply on PCs:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param_here);
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        if isnan(handles.model_loaded.settings.num_comp)
            set_this = 1;
        elseif handles.model_loaded.settings.num_comp == 0
            set_this = 2;
        else
            set_this = handles.model_loaded.settings.num_comp + 2;
        end
        set(handles.pop_menu_03,'Value',set_this);
    else
        set(handles.pop_menu_03,'Value',1);
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','column pre-processing:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        if strcmp(handles.model_loaded.settings.preprocess_columns,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'cent')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'auto')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'scal')
            set_this = 4;         
        else
            set_this = 5;     
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % kernel type
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','kernel type:');
    str_disp={};
    str_disp{1} = 'linear';
    str_disp{2} = 'polynomial';
    str_disp{3} = 'rbf';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        if strcmp(handles.model_loaded.settings.kernel,'linear')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.kernel,'polynomial')
            set_this = 2;
        else
            set_this = 3;
        end
        set(handles.pop_menu_05,'Value',set_this);
    else
        set(handles.pop_menu_05,'Value',1);
    end
    % kernel parameter
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','kernel parameter:');
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        set_this = handles.model_loaded.settings.kernelpar;
    else
        set_this = NaN;
    end
    handles = setparamcombo(handles,set_this);
    if handles.disable_combo
        set(handles.pop_menu_06,'Enable','off');
    end
    % cost
    set(handles.text07,'Visible','on');
    set(handles.text07,'String','cost:');
    cost_seq = [0.1 1 10 100 1000];
    str_disp={};
    for j=1:length(cost_seq); str_disp{j} = cost_seq(j); end
    set(handles.pop_menu_07,'String',str_disp);
    set(handles.pop_menu_07,'Visible','on');
    set(handles.pop_menu_07,'Value',1);
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        set_this = log10(handles.model_loaded.settings.C) + 2;
        if mod(set_this,1) == 0 
            set(handles.pop_menu_07,'Value',set_this);
        end
    end
    if handles.disable_combo
        set(handles.pop_menu_07,'Enable','off');
    end
    % row scaling
    set(handles.text08,'Visible','on');
    set(handles.text08,'String','row pre-processing:');
    set(handles.pop_menu_08,'String',str_scaling_row);
    set(handles.pop_menu_08,'Visible','on');
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        if strcmp(handles.model_loaded.settings.preprocess_rows,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'snv')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'msc')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'der1')
            set_this = 4;
        else
            set_this = 5;
        end
        set(handles.pop_menu_08,'Value',set_this);
    else
        set(handles.pop_menu_08,'Value',1);
    end
elseif strcmp(handles.model_type,'pf')
    set(handles.visualize_settings_big,'Name','Potential Functions settings')
    set(handles.button_optimize,'String','optimal smoothing')
    % num comp
    str_param_here{1} = 'none';
    str_param_here{2} = 'automatic';
    for j=3:handles.maxparam+2; str_param_here{j} = num2str(j-2); end
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','Apply on PCs:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param_here);
    if model_memory && strcmp(handles.model_loaded.type,'pf')
        if isnan(handles.model_loaded.settings.num_comp)
            set_this = 1;
        elseif handles.model_loaded.settings.num_comp == 0
            set_this = 2;
        else
            set_this = handles.model_loaded.settings.num_comp + 2;
        end
        set(handles.pop_menu_03,'Value',set_this);
    else
        set(handles.pop_menu_03,'Value',1);
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','column pre-processing:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'pf')
        if strcmp(handles.model_loaded.settings.preprocess_columns,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'cent')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'auto')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_columns,'scal')
            set_this = 4;         
        else
            set_this = 5;     
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % target class
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','target class:');
    str_disp = handles.class_labels_for_combo;
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'pf')
        if isnumeric(handles.model_loaded.settings.target_class)
            set(handles.pop_menu_05,'Value',handles.model_loaded.settings.target_class);
        else    
            where = find(strcmp(handles.model_loaded.settings.target_class,handles.class_labels_for_combo));
            if length(where) > 0
                set(handles.pop_menu_05,'Value',where);
            else
                set(handles.pop_menu_05,'Value',1);
            end
        end
    end
    % percentile
    str_disp={};
    perc_list(1) = 80;
    perc_list(2) = 90;
    perc_list(3) = 95;
    perc_list(4) = 99;
    for j=1:length(perc_list); str_disp{j} = perc_list(j); end
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','percentile:');
    set(handles.pop_menu_06,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'pf')
        if handles.model_loaded.settings.perc == 80
            set_this = 1;
        elseif handles.model_loaded.settings.perc == 90
            set_this = 2;
        elseif handles.model_loaded.settings.perc == 99
            set_this = 4;
        else
            set_this = 3;
        end
        set(handles.pop_menu_06,'Value',set_this);
    else
        set(handles.pop_menu_06,'Value',3);
    end
    % smoothing parameter
    set(handles.text07,'Visible','on');
    set(handles.text07,'String','smoothing:');
    smooth_seq = [0.1:0.1:1.2];
    str_disp={};
    for j=1:length(smooth_seq); str_disp{j} = smooth_seq(j); end
    set(handles.pop_menu_07,'String',str_disp);
    set(handles.pop_menu_07,'Visible','on');
    set(handles.pop_menu_07,'Value',1);
    if model_memory && strcmp(handles.model_loaded.type,'pf')
        set_this = findvalue(handles.model_loaded.settings.smoot,smooth_seq);
        if length(set_this) == 0 
            set(handles.pop_menu_07,'Value',1);
        else
            set(handles.pop_menu_07,'Value',set_this(1));
        end
    end
    if handles.disable_combo
        set(handles.pop_menu_07,'Enable','off');
    end
    % row scaling
    set(handles.text08,'Visible','on');
    set(handles.text08,'String','row pre-processing:');
    set(handles.pop_menu_08,'String',str_scaling_row);
    set(handles.pop_menu_08,'Visible','on');
    if model_memory && strcmp(handles.model_loaded.type,'pf')
        if strcmp(handles.model_loaded.settings.preprocess_rows,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'snv')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'msc')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.preprocess_rows,'der1')
            set_this = 4;
        else
            set_this = 5;
        end
        set(handles.pop_menu_08,'Value',set_this);
    else
        set(handles.pop_menu_08,'Value',1);
    end
elseif strcmp(handles.model_type,'backprop')
    set(handles.visualize_settings_big,'Name','Backpropagation settings')
    set(handles.button_optimize,'String','optimal parameter')
    set(handles.button_optimize,'enable','off')
    % alpha
    str_disp={};
    str_param_here = [0.1:0.1:0.9];
    for j=1:length(str_param_here); str_disp{j} = num2str(str_param_here(j)); end
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','alpha (momentum term):');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'backprop')
        set_this = handles.model_loaded.settings.network_settings.alpha;
        set_this = round(set_this*10);
        set(handles.pop_menu_03,'Value',set_this);
    else
        set(handles.pop_menu_03,'Value',5);
    end
    % iterations
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','iterations:');
    str_disp={};
    str_param_here = [100 500 1000 5000];
    for j=1:length(str_param_here); str_disp{j} = num2str(str_param_here(j)); end
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'backprop')
        set_this = find(str_param_here == handles.model_loaded.settings.network_settings.iter);
        if length(set_this) == 0
            set_this = 3;
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % hidden layers
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','number of hidden layers:');
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_param);
    if model_memory && strcmp(handles.model_loaded.type,'backprop')
        set_this = length(handles.model_loaded.settings.network_settings.num_hidden_neurons);
        set(handles.pop_menu_05,'Value',set_this);
    else
        set(handles.pop_menu_05,'Value',1);
    end
    % number of neurons
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','nunber of neurons in each layer:');
    str_disp={};
    str_param_here = [5:5:50];
    for j=1:length(str_param_here); str_disp{j} = num2str(str_param_here(j)); end
    set(handles.pop_menu_06,'Visible','on');
    set(handles.pop_menu_06,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'backprop')
        set_this = handles.model_loaded.settings.network_settings.num_hidden_neurons(1);
        set_this = round(set_this/5);
        if set_this == 0; set_this = 1; end
        set(handles.pop_menu_06,'Value',set_this);
    else
        set(handles.pop_menu_06,'Value',2);
    end
    if handles.disable_combo
        set(handles.pop_menu_06,'Enable','off');
    end
    % learning rate
    set(handles.text07,'Visible','on');
    set(handles.text07,'String','learning rate:');
    cost_seq = [0.0001 0.001 0.01 0.1];
    str_disp={};
    for j=1:length(cost_seq); str_disp{j} = cost_seq(j); end
    set(handles.pop_menu_07,'String',str_disp);
    set(handles.pop_menu_07,'Visible','on');
    set(handles.pop_menu_07,'Value',3);
    if model_memory && strcmp(handles.model_loaded.type,'backprop')
        set_this = log10(handles.model_loaded.settings.network_settings.learning_rate) + 5;
        if mod(set_this,1) == 0 
            set(handles.pop_menu_07,'Value',set_this);
        end
    end
    if handles.disable_combo
        set(handles.pop_menu_07,'Enable','off');
    end
    set(handles.text08,'Visible','on');
    set(handles.text08,'String','show error plot:');
    str_disp={};
    str_disp{1} = 'no (fast)';
    str_disp{2} = 'at the end of training (medium)';
    str_disp{3} = 'during training (slow)';
    set(handles.pop_menu_08,'String',str_disp);
    set(handles.pop_menu_08,'Visible','on');
    set(handles.pop_menu_08,'Value',2);
    if model_memory && strcmp(handles.model_loaded.type,'backprop')
        set_this = handles.model_loaded.settings.network_settings.doplot + 1;
        set(handles.pop_menu_08,'Value',set_this);
    end
end

% --- Executes during object creation, after setting all properties.
function pop_menu_03_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_03.
function pop_menu_03_Callback(hObject, eventdata, handles)

% --------------------------------------------------------
function w = findvalue(param_range,v)
w = find(param_range == v);
if length(w) == 0
    param_range = round(param_range*10);
    v = round(v * 10);
    w = find(param_range == v);
    if length(w) == 0
        w = 1;
    end
end

% ------------------------------------------------------------------------
function handles = setparamcombo(handles,loaded_param)
% set kernel parameter combo
val = get(handles.pop_menu_05,'string');
w = get(handles.pop_menu_05,'value');
val = val{w};
if strcmp(val,'linear')
    str_disp{1} = 'none';
    set(handles.pop_menu_06,'String',str_disp);
    set(handles.pop_menu_06,'Value',1);
else
    kernalparam_seq = [0.05	0.07	0.10	0.14	0.20	0.28	0.40	0.57	0.80	1.13	1.60	2.26	3.20	4.53	6.40	9.00];
    handles.kernalparam_seq = kernalparam_seq;
    str_disp={};
    for j=1:length(handles.kernalparam_seq)
        str_disp{j} = handles.kernalparam_seq(j);
    end
    set(handles.pop_menu_06,'String',str_disp);
    if isnan(loaded_param)
        set(handles.pop_menu_06,'Value',1);
    else
        w = find(kernalparam_seq == loaded_param);
        if length(w) == 1
            set(handles.pop_menu_06,'Value',w);
        else
            set(handles.pop_menu_06,'Value',1);
        end
    end
end

% --------------------------------------------------------
function handles = set_cvgroups_combo(handles)
str_disp={};
if get(handles.pop_menu_cv_type,'Value') < 4
    cv_group(1) = 2;
    cv_group(2) = 3;
    cv_group(3) = 4;
    cv_group(4) = 5;
    cv_group(5) = 10;
    cv_group(6) = handles.num_samples;
    for j=1:length(cv_group)
        str_disp{j} = cv_group(j);
    end
    set(handles.text02,'String','number of cv groups:');
    set(handles.pop_menu_cv_groups,'String',str_disp);
    set(handles.pop_menu_cv_groups,'Value',4);
else
    cv_group(1) = 100;
    cv_group(2) = 500;
    cv_group(3) = 1000;
    for j=1:length(cv_group)
        str_disp{j} = cv_group(j);
    end
    set(handles.text02,'String','number of iterations:');
    set(handles.pop_menu_cv_groups,'String',str_disp);
    set(handles.pop_menu_cv_groups,'Value',3);
end

% ------------------------------------------------------------------------
function err_cv = check_cv_err(class,cv_type,cv_groups)
nobj = length(class);
err_cv = 0;
obj_in_block = fix(nobj/cv_groups);
left_over = mod(nobj,cv_groups);
st = 1;
en = obj_in_block;
if nobj ~= cv_groups %avoid loo
    if strcmp(cv_type,'vene') || strcmp(cv_type,'cont')
        for i=1:cv_groups
            % prepares objects
            in = ones(nobj,1);
            out = [];
            if strcmp(cv_type,'vene')
                out = [i:cv_groups:nobj];
            else % contiguous blocks
                if left_over == 0
                    out = [st:en];
                    st =  st + obj_in_block;  en = en + obj_in_block;
                else
                    if i < cv_groups - left_over
                        out = [st:en];
                        st =  st + obj_in_block;  en = en + obj_in_block;
                    elseif i < cv_groups
                        out = [st:en + 1];
                        st =  st + obj_in_block + 1;  en = en + obj_in_block + 1;
                    else
                        out = [st:nobj];
                    end
                end
            end
            in(out) = 0;
            class_training = class(find(in==1));
            class_test = class(find(in==0));
            % check class partition
            cin = [1:max(class)];
            for g = 1:length(cin)
                rep_train = length(find(class_training == g));
                rep_test = length(find(class_test == g));
                if rep_train == 0 || rep_test == 0
                    err_cv = 1;
                    return
                end
            end
        end
    end
end

% --------------------------------------------------------
function do_optimal(handles)
if get(handles.pop_menu_cv_type,'Value') == 1 || get(handles.pop_menu_cv_type,'Value') > 3
    h1 = ['Optimisation must be based on venetian blind or contiguous block cross validation'];
    warndlg([h1],'Variable selection')
else
    w = get(handles.pop_menu_cv_groups,'Value');
    cv_groups = get(handles.pop_menu_cv_groups,'String');
    cv_groups = cv_groups{w};
    cv_groups = str2num(cv_groups);
    if get(handles.pop_menu_cv_type,'Value') == 1
        cv_type = 'none';
    elseif get(handles.pop_menu_cv_type,'Value') == 2
        cv_type = 'vene';
    elseif get(handles.pop_menu_cv_type,'Value') == 3
        cv_type = 'cont'; 
    elseif get(handles.pop_menu_cv_type,'Value') == 4
        cv_type = 'rand';
    else
        cv_type = 'boot';
    end
    if strcmp(handles.model_type,'pf') || strcmp(handles.model_type,'simca') || strcmp(handles.model_type,'uneq')
        if length(handles.class_labels) == 0
            target_class = get(handles.pop_menu_05,'value');
            class_check = calc_class_modellinglabels(handles.class,target_class);
        else
            val = get(handles.pop_menu_05,'string');
            w = get(handles.pop_menu_05,'value');
            target_class = val{w};
            class_check = calc_class_modellinglabels(handles.class,target_class,handles.class_labels);
        end
        err_cv = check_cv_err(class_check,cv_type,cv_groups);
    else
        err_cv = check_cv_err(handles.class,cv_type,cv_groups);
    end
    if err_cv == 1
        if strcmp(cv_type,'vene')
            meth = 'venetian blinds';
        else
            meth = 'contiguous blocks';
        end
        str = ['cross validation failed: samples are not correctly distributed with ' meth...
            '; try to use other cross validation procedures or'...
            ' a different number of cross-validation groups.'];
        warndlg(str,'cross validation')
    else
        % activate pointer
        set(handles.visualize_settings_big,'Pointer','watch')
        % run
        if strcmp(handles.model_type,'plsda')
            preprocess_columns = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
            val = get(handles.pop_menu_05,'string');
            w = get(handles.pop_menu_05,'value');
            assign_method = val{w};
            preprocess_rows = takevaluefrompopmenu(get(handles.pop_menu_06,'String'),get(handles.pop_menu_06,'Value'));
            res = plsdacompsel(handles.X,handles.class,preprocess_rows,preprocess_columns,cv_type,cv_groups,assign_method);
            if length(res.er) > 1
                plot_er(res,'plsda');
            end
        elseif strcmp(handles.model_type,'pcada')
            max_comp = min([size(handles.X,2) size(handles.X,1)]);
            if max_comp > 20; max_comp = 20; end
            val = get(handles.pop_menu_05,'string');
            w = get(handles.pop_menu_05,'value');
            method = val{w};
            preprocess_columns = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
            preprocess_rows = takevaluefrompopmenu(get(handles.pop_menu_06,'String'),get(handles.pop_menu_06,'Value'));
            res = dacompsel(handles.X,handles.class,cv_type,cv_groups,2,method,preprocess_rows,preprocess_columns,max_comp);
            if length(res.er) > 1
                plot_er(res,'pcada');
            end
        elseif strcmp(handles.model_type,'simca')
            preprocess_columns = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
            if length(handles.class_labels) == 0
                target_class = get(handles.pop_menu_05,'value');
                class_to_fit = handles.class;
            else
                val = get(handles.pop_menu_05,'string');
                w = get(handles.pop_menu_05,'value');
                target_class = val{w};
                class_to_fit = handles.class_string;
            end
            preprocess_rows = takevaluefrompopmenu(get(handles.pop_menu_06,'String'),get(handles.pop_menu_06,'Value'));
            res = simcacompsel(handles.X,class_to_fit,target_class,preprocess_rows,preprocess_columns,cv_type,cv_groups);
            if length(res.er) > 1
                plot_ercv_classmodelling(res,'simca',[1:size(res.er,1)],handles.class_labels)
            end
       elseif strcmp(handles.model_type,'uneq')
            preprocess_columns = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
            if length(handles.class_labels) == 0
                target_class = get(handles.pop_menu_05,'value');
                class_to_fit = handles.class;
            else
                val = get(handles.pop_menu_05,'string');
                w = get(handles.pop_menu_05,'value');
                target_class = val{w};
                class_to_fit = handles.class_string;
            end
            preprocess_rows = takevaluefrompopmenu(get(handles.pop_menu_06,'String'),get(handles.pop_menu_06,'Value'));
            res = uneqcompsel(handles.X,class_to_fit,target_class,preprocess_rows,preprocess_columns,cv_type,cv_groups);
            if length(res.er) > 1
                plot_ercv_classmodelling(res,'uneq',[1:size(res.er,1)],handles.class_labels)
            end
        elseif strcmp(handles.model_type,'pf')
            preprocess_columns = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
            if length(handles.class_labels) == 0
                target_class = get(handles.pop_menu_05,'value');
                class_to_fit = handles.class;
            else
                val = get(handles.pop_menu_05,'string');
                w = get(handles.pop_menu_05,'value');
                target_class = val{w};
                class_to_fit = handles.class_string;
            end
            perc = takevaluefrompopmenu(get(handles.pop_menu_06,'String'),get(handles.pop_menu_06,'Value'));
            num_comp = takevaluefrompopmenu(get(handles.pop_menu_03,'String'),get(handles.pop_menu_03,'Value'));
            if ischar(num_comp)
                % exceptions
                if strcmp(num_comp,'automatic')
                    num_comp = 0;
                else
                    num_comp = NaN;
                end
            end
            preprocess_rows = takevaluefrompopmenu(get(handles.pop_menu_08,'String'),get(handles.pop_menu_08,'Value'));
            res = potsmootsel(handles.X,class_to_fit,target_class,perc,preprocess_rows,preprocess_columns,cv_type,cv_groups,num_comp);            
            if length(res.er) > 1
                for k=1:length(res.settings.smoot_range); smoot_range{k} = res.settings.smoot_range(k); end
                plot_ercv_classmodelling(res,'pf',smoot_range,handles.class_labels)
            end
        elseif strcmp(handles.model_type,'knn')
            val = get(handles.pop_menu_05,'string');
            w = get(handles.pop_menu_05,'value');
            dist_type = val{w};
            preprocess_columns = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
            preprocess_rows = takevaluefrompopmenu(get(handles.pop_menu_06,'String'),get(handles.pop_menu_06,'Value'));
            res = knnksel(handles.X,handles.class,dist_type,preprocess_rows,preprocess_columns,cv_type,cv_groups);
            if length(res.er) > 1
                plot_er(res,'knn');
            end
        else
            preprocess_columns = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
            kernel = takevaluefrompopmenu(get(handles.pop_menu_05,'String'),get(handles.pop_menu_05,'Value'));
            num_comp = takevaluefrompopmenu(get(handles.pop_menu_03,'String'),get(handles.pop_menu_03,'Value'));
            if ischar(num_comp)
                % exceptions
                if strcmp(num_comp,'automatic')
                    num_comp = 0;
                else
                    num_comp = NaN;
                end
            end
            preprocess_rows = takevaluefrompopmenu(get(handles.pop_menu_08,'String'),get(handles.pop_menu_08,'Value'));
            res = svmcostsel(handles.X,handles.class,kernel,preprocess_rows,preprocess_columns,cv_type,cv_groups,num_comp);
            if length(res.er) > 1
                plot_ercv_svm(res)
            end
        end
        set(handles.visualize_settings_big,'Pointer','arrow')
    end
end

% ------------------------------------------------------------------------
function plot_er(res,model_type)
[~,col_default] = visualize_colors;
num_comp = length(res.er);
figure
set(gcf,'color','white')
if length(find(res.not_ass > 0)) > 0
    subplot(2,1,1)    
end
hold on
plot(res.er,'Color',col_default(1,:))
plot(res.er,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
ylabel('error rate cv')
ylim = get(gca, 'YLim');
axis([0.6 (num_comp + 0.4) ylim(1) ylim(2)])
set(gca,'xtick',[1:num_comp]);
hold off
if strcmp(model_type,'plsda')
    lab = 'latent variables';
elseif strcmp(model_type,'knn')
    lab = 'k neighbours';
else
    lab = 'principal components';
end
xlabel(lab)
set(gca,'YGrid','on','GridLineStyle',':')
box on
if length(find(res.not_ass > 0)) > 0
    subplot(2,1,2)
    hold on
    plot(res.not_ass,'Color',col_default(1,:))
    plot(res.not_ass,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
    ylabel('not assigned samples')
    ylim = get(gca, 'YLim');
    axis([0.6 (num_comp + 0.4) ylim(1) ylim(2)])
    set(gca,'xtick',[1:num_comp]);
    hold off
    lab = 'latent variables';
    xlabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
    hold off
end

% ------------------------------------------------------------------------
function plot_ercv_classmodelling(res,type,xvalues,class_labels)
[~,col_default] = visualize_colors;
if strcmp(type,'simca') || strcmp(type,'uneq')
    labaxis = 'principal components';
else
    labaxis = 'smoothing values';
end
num_values = length(xvalues);
figure
set(gcf,'color','white')
cnt = 0;
lab_xaxis = labaxis;
if length(class_labels) == 0
    lab_class = ['class ' num2str(res.settings.target_class)];
else
    g = find(strcmp(res.settings.target_class,class_labels));
    lab_class = class_labels{g};
end
cnt = cnt + 1;
subplot(2,1,cnt)
hold on
plot(res.er,'Color',col_default(1,:))
plot(res.er,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
if cnt == 1
    title([lab_class])
end
ylabel('error rate in cv')
ylim = get(gca, 'YLim');
axis([0.6 (num_values + 0.4) ylim(1) ylim(2)])
set(gca,'xtick',[1:num_values]);
set(gca,'xticklabel',xvalues);
hold off
xlabel(lab_xaxis)
set(gca,'YGrid','on','GridLineStyle',':')
box on
cnt = cnt + 1;
subplot(2,1,cnt)
hold on
plot(res.sensitivity,'o','MarkerEdgeColor','k','MarkerSize',6,'MarkerFaceColor','k')
plot(res.specificity,'o','MarkerEdgeColor','k','MarkerSize',6,'MarkerFaceColor','w')
plot(res.sensitivity,'k')
plot(res.specificity,'k')
legend('sensitivity','specificity')
ylabel('sensitivity and specificity in cv')
ylim = get(gca, 'YLim');
axis([0.6 (num_values + 0.4) ylim(1) ylim(2)])
set(gca,'xtick',[1:num_values]);
set(gca,'xticklabel',xvalues);
hold off
xlabel(lab_xaxis)
set(gca,'YGrid','on','GridLineStyle',':')
box on

% ------------------------------------------------------------------------
function plot_ercv_svm(res)
[~,col_default] = visualize_colors;
for k=1:length(res.cost_seq); cost_labels{k} = res.cost_seq(k); end
if strcmp(res.settings.kernel,'linear')
    num_val = length(res.er);
    figure
    subplot(2,1,1)
    set(gcf,'color','white');
    hold on
    plot(res.er,'Color',col_default(1,:))
    plot(res.er,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
    ylim = get(gca, 'YLim');
    axis([0.6 (num_val + 0.4) ylim(1) ylim(2)])
    set(gca,'xtick',[1:num_val]);
    set(gca,'xticklabel',cost_labels);
    hold off
    ylabel('error rate cv')
    lab = 'cost values';
    xlabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
    subplot(2,1,2)
    set(gcf,'color','white');
    hold on
    plot(res.average_svind,'Color',col_default(1,:))
    plot(res.average_svind,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
    ylim = get(gca, 'YLim');
    axis([0.6 (num_val + 0.4) ylim(1) ylim(2)])
    set(gca,'xtick',[1:num_val]);
    set(gca,'xticklabel',cost_labels);
    hold off
    ylabel('average number of support vectors')
    lab = 'cost values';
    xlabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
else
    for k=1:length(res.kernalparam_seq); param_labels{k} = res.kernalparam_seq(k); end
    [num_cost,num_param] = size(res.er);
    figure
    subplot(2,1,1)
    set(gcf,'color','white');
    hold on
    [C,h] = contourf(res.er,'ShowText','on');
    colormap(autumn);
    clabel(C,h,'FontSize',8,'Color','black');
    ylim = get(gca, 'YLim');
    %axis([0.6 (num_val + 0.4) ylim(1) ylim(2)])
    set(gca,'ytick',[1:num_cost]);
    set(gca,'yticklabel',cost_labels);
    set(gca,'xtick',[1:num_param]);
    set(gca,'xticklabel',param_labels);    
    hold off
    xlabel('kernel parameter')
    title('error rate cv')
    lab = 'cost values';
    ylabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
    subplot(2,1,2)
    set(gcf,'color','white');
    hold on
    [C,h] = contourf(res.average_svind,'ShowText','on');
    colormap(autumn);
    clabel(C,h,'FontSize',8,'Color','black');
    ylim = get(gca, 'YLim');
    %axis([0.6 (num_val + 0.4) ylim(1) ylim(2)])
    set(gca,'ytick',[1:num_cost]);
    set(gca,'yticklabel',cost_labels);
    set(gca,'xtick',[1:num_param]);
    set(gca,'xticklabel',param_labels);      
    hold off
    xlabel('kernel parameter')
    title('average number of support vectors')
    lab = 'cost values';
    ylabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
end
