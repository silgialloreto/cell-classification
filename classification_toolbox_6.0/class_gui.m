function varargout = class_gui(varargin)

% class_gui is the main routine to open the graphical interface of the Classification Toolbox.
% In order to open the graphical interface, just type on the matlab command line:
%
% class_gui
%
% there are no inputs, data can be loaded and saved directly from the graphical interface
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
                   'gui_OpeningFcn', @class_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @class_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before class_gui is made visible.
function class_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(handles.output,'Position',[100 50 84 14]);
set(handles.listbox_model,'Position',[44 1 37 12]);
set(handles.listbox_data,'Position',[3 1 37 12]);
movegui(handles.class_gui,'center');
% initialize handles
handles = init_handles(handles);
% enable/disable buttons and menu
handles = enable_disable(handles);
% updtae list boxes
update_listbox_data(handles)
update_listbox_model(handles)
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = class_gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --------------------------------------------------------------------
function m_file_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_file_load_data_Callback(hObject, eventdata, handles)
% ask for overwriting
if handles.present.data == 1
    q = questdlg('Data are alreday loaded. Do you wish to overwrite them?','loading data','yes','no','yes');
else
    q = 'yes';
end
if strcmp(q,'yes')
    res = visualize_load(1,0);
    if isnan(res.loaded_file)
        if handles.present.data  == 0
            handles.present.data  = 0;
            handles = reset_labels(handles);
        else
            handles.present.data  = 1;
        end
    elseif res.from_file == 1
        handles = reset_data(handles);
        handles.present.data  = 1;
        handles = reset_labels(handles);
        handles = reset_class(handles);
        if handles.present.model == 2; handles.present.model = 1; end % model becames loaded instead of calculated
        tmp_data = load(res.path);
        handles.data.X = getfield(tmp_data,res.name);
        handles.data.Xraw = handles.data.X;
        handles.data.name_data = res.name;
        % make standard labels, do not set handles.present as 1
        for k=1:size(handles.data.X,1); handles.data.sample_labels{k} = ['S' num2str(k)]; end
        for k=1:size(handles.data.X,2); handles.data.variable_labels{k} = ['V' num2str(k)]; end
    else
        handles = reset_data(handles);
        handles.present.data  = 1;
        handles = reset_labels(handles);
        handles = reset_class(handles); 
        if handles.present.model == 2; handles.present.model = 1; end % model becames loaded instead of calculated
        handles.data.X = evalin('base',res.name);
        handles.data.Xraw = handles.data.X;
        handles.data.name_data = res.name;
        % make standard labels, do not set handles.present as 1
        for k=1:size(handles.data.X,1); handles.data.sample_labels{k} = ['S' num2str(k)]; end
        for k=1:size(handles.data.X,2); handles.data.variable_labels{k} = ['V' num2str(k)]; end
    end
    handles = enable_disable(handles);
    update_listbox_data(handles);
    update_listbox_model(handles);
    guidata(hObject,handles)
end

% --------------------------------------------------------------------
function m_file_load_class_Callback(hObject, eventdata, handles)
% ask for overwriting
if handles.present.class == 1
    q = questdlg('Class is alreday loaded. Do you wish to overwrite it?','loading class','yes','no','yes');
else
    q = 'yes';
end
if strcmp(q,'yes') 
    res = visualize_load(2,size(handles.data.X,1));
    if isnan(res.loaded_file)
        if handles.present.class  == 0
            handles.present.class  = 0;
        else
            handles.present.class  = 1;
        end
    elseif res.from_file == 1
        handles.present.class  = 1;
        tmp_data = load(res.path);
        handles.data.class = getfield(tmp_data,res.name);
        if size(handles.data.class,2) > size(handles.data.class,1)
            handles.data.class = handles.data.class';
        end
        handles.data.name_class = res.name;
    else
        handles.present.class  = 1;
        handles.data.class = evalin('base',res.name);
        if size(handles.data.class,2) > size(handles.data.class,1)
            handles.data.class = handles.data.class';
        end
        handles.data.name_class = res.name;
    end
    if iscell(handles.data.class)
        if handles.present.model
            if length(handles.data.model.labels.class_labels) > 0
                class_string_tmp = handles.data.class;
                handles.data.class_string = handles.data.class;
                [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string,handles.data.model.labels.class_labels);
            else
                % the loaded model is caluclated on a numerical class vector
                handles.data.class_string = handles.data.class;
                [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string);
            end
        else
            handles.data.class_string = handles.data.class;
            [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string);
        end
        if sum(handles.data.class) == 0
            warndlg('The loaded class vector (as cell array) does not contain class labels corresponding to those used to train the loaded model','warning on loaded class')
            handles.data.class_string = class_string_tmp;
            [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string);
        end
    else
        handles.data.class_string = {};
        handles.data.class_labels = {};
    end
    handles = enable_disable(handles);
    update_listbox_data(handles)
    guidata(hObject,handles)
end

% --------------------------------------------------------------------
function m_file_load_model_Callback(hObject, eventdata, handles)
% ask for overwriting
if handles.present.model > 0
    q = questdlg('Model is alreday loaded/calculated. Do you wish to overwrite it?','loading model','yes','no','yes');
else
    q = 'yes';
end
if strcmp(q,'yes')
    res = visualize_load(3,0);
    if isnan(res.loaded_file)
        if handles.present.model  == 0
            handles.present.model  = 0;
        else
            handles.present.model  = 1;
        end
    else
        if res.from_file == 1
            handles.present.model  = 1;
            tmp_data = load(res.path);
            handles.data.model = getfield(tmp_data,res.name);
            handles.data.name_model = res.name;
            handles = reset_pred(handles);
        else
            handles.present.model  = 1;
            handles.data.model = evalin('base',res.name);
            handles.data.name_model = res.name;
            handles = reset_pred(handles);
        end
        if handles.present.class
            % if, when model is loaded, data with class (as string) is already
            % present, check correspondance of class labels
            if length(handles.data.model.labels.class_labels) > 0
                tmp_class = handles.data.class;
                tmp_class_labels = handles.data.class_labels;
                [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string,handles.data.model.labels.class_labels);
                if sum(handles.data.class) == 0
                    warndlg('The loaded class vector (as cell array) does not contain class labels corresponding to those used to train the loaded model','warning on loaded class')
                    handles.data.class = tmp_class;
                    handles.data.class_labels = tmp_class_labels;
                end
            end
        end
    end
    handles = enable_disable(handles);
    update_listbox_data(handles);
    update_listbox_model(handles);
    guidata(hObject,handles)
end

% --------------------------------------------------------------------
function m_file_load_labels_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_file_load_sample_labels_Callback(hObject, eventdata, handles)
res = visualize_load(4,size(handles.data.X,1));
if isnan(res.loaded_file)
    if handles.present.sample_labels == 0
        handles.present.sample_labels  = 0;
    else
        handles.present.sample_labels  = 1;
    end
elseif res.from_file == 1
    handles.present.sample_labels  = 1;
    tmp_data = load(res.path);
    handles.data.sample_labels = getfield(tmp_data,res.name);
    if size(handles.data.sample_labels,2) > size(handles.data.sample_labels,1)
        handles.data.sample_labels = handles.data.sample_labels';
    end
else
    handles.present.sample_labels  = 1;
    handles.data.sample_labels = evalin('base',res.name);
    if size(handles.data.sample_labels,2) > size(handles.data.sample_labels,1)
        handles.data.sample_labels = handles.data.sample_labels';
    end
end
handles = enable_disable(handles);
update_listbox_data(handles)
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_file_load_variable_labels_Callback(hObject, eventdata, handles)
res = visualize_load(5,size(handles.data.X,2));
if isnan(res.loaded_file)
    if handles.present.variable_labels == 0
        handles.present.variable_labels  = 0;
    else
        handles.present.variable_labels  = 1;
    end
elseif res.from_file == 1
    handles.present.variable_labels  = 1;
    tmp_data = load(res.path);
    handles.data.variable_labels = getfield(tmp_data,res.name);
    if size(handles.data.variable_labels,2) > size(handles.data.variable_labels,1)
        handles.data.variable_labels = handles.data.variable_labels';
    end
else
    handles.present.variable_labels  = 1;
    handles.data.variable_labels = evalin('base',res.name);
    if size(handles.data.variable_labels,2) > size(handles.data.variable_labels,1)
        handles.data.variable_labels = handles.data.variable_labels';
    end
end
handles = enable_disable(handles);
update_listbox_data(handles)
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_file_save_model_Callback(hObject, eventdata, handles)
visualize_export(handles.data.model,'model')

% --------------------------------------------------------------------
function m_file_save_pred_Callback(hObject, eventdata, handles)
visualize_export(handles.data.pred,'pred')

% --------------------------------------------------------------------
function m_file_clear_data_Callback(hObject, eventdata, handles)
handles = reset_data(handles);
handles = reset_class(handles);
handles = reset_labels(handles);
handles = enable_disable(handles);
update_listbox_data(handles)
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_file_clear_model_Callback(hObject, eventdata, handles)
handles = reset_model(handles);
handles = enable_disable(handles);
update_listbox_model(handles)
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_file_exit_Callback(hObject, eventdata, handles)
close

% --------------------------------------------------------------------
function m_view_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_view_data_Callback(hObject, eventdata, handles)
assignin('base','tmp_data_matrix',handles.data.X);
openvar('tmp_data_matrix');

% --------------------------------------------------------------------
function m_view_class_Callback(hObject, eventdata, handles)
if length(handles.data.class_labels) == 0
    assignin('base','tmp_class',handles.data.class);
else
    assignin('base','tmp_class',handles.data.class_string);
end
openvar('tmp_class');

% --------------------------------------------------------------------
function m_view_smoothing_Callback(hObject, eventdata, handles)
[Xsmooth,window,degree,dosmooth] = visualize_smoothing(handles.data);
if dosmooth
    h1 = ['Data have been smoothed by means of Savitzky-Golay smoothing with window equal to ' num2str(window) ' and degree equal to ' num2str(degree)];
    warndlg([h1],'Smoothing')
    handles.data.X = Xsmooth;
    handles.data.smoothing = [window degree];
    guidata(hObject,handles)    
end

% --------------------------------------------------------------------
function m_view_plot_univariate_Callback(hObject, eventdata, handles)
visualize_univariate(handles.data)

% --------------------------------------------------------------------
function m_view_plot_profiles_Callback(hObject, eventdata, handles)
visualize_profiles_samples(handles.data);

% --------------------------------------------------------------------
function m_view_wilks_Callback(hObject, eventdata, handles)
var_in = visualize_lambda(handles.data);
if length(var_in) > 0
    samples_in = [1:size(handles.data.X,1)];
    handles = reduce_data(handles,samples_in,var_in);
    guidata(hObject,handles)
end

% --------------------------------------------------------------------
function m_view_delete_Callback(hObject, eventdata, handles)
out = visualize_delete_samples(size(handles.data.X,1),handles.data.class,handles.data.sample_labels,handles.data.class_string);
if ~isnan(out)
    if size(handles.data.X,1) > 1
        dodelete = 0;
        if handles.present.class
            in = ones(size(handles.data.X,1),1);
            in(out) = 0;
            in = find(in);
            tmpclass = handles.data.class(in);
            if max(tmpclass) < 2 
                h1 = 'sample can not be deleted sice the number of classes would be reduced to just one!';
                warndlg([h1],'Delete samples')
            else
                dodelete = 1;
            end
        else
            dodelete = 1;
        end
        if dodelete
            in = ones(size(handles.data.X,1),1);
            in(out) = 0;
            samples_in = find(in);
            variables_in = [1:size(handles.data.X,2)];
            handles = reduce_data(handles,samples_in,variables_in);
            guidata(hObject,handles)
        end
    else
        h1 = ['There is just one sample in the dataset. It is not possible to delete it!'];
        warndlg([h1],'Delete samples')
    end
end

% --------------------------------------------------------------------
function m_calculate_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_da_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_calculate_multinormality_Callback(hObject, eventdata, handles)
damultinormality(handles.data.X);

% --------------------------------------------------------------------
function m_calculate_da_Callback(hObject, eventdata, handles)
handles = do_da(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_calculate_pcada_Callback(hObject, eventdata, handles)
handles = do_pcada(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_calculate_cart_Callback(hObject, eventdata, handles)
handles = do_cart(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_pls_Callback(hObject, eventdata, handles)
handles = do_pls(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_pf_Callback(hObject, eventdata, handles)
handles = do_pf(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_svm_Callback(hObject, eventdata, handles)
handles = do_svm(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_simca_Callback(hObject, eventdata, handles)
handles = do_simca(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_uneq_Callback(hObject, eventdata, handles)
handles = do_uneq(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_knn_Callback(hObject, eventdata, handles)
handles = do_knn(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_calculate_backprop_Callback(hObject, eventdata, handles)
handles = do_backprop(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_results_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_class_Callback(hObject, eventdata, handles)
visualize_classification_measures(handles.data.model,handles.data.pred);

% --------------------------------------------------------------------
function m_results_view_boundaries_Callback(hObject, eventdata, handles)
visualize_plotprediction(handles.data.model)

% --------------------------------------------------------------------
function m_results_da_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_canonical_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_canonical_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_view_pcada_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred,'pca')

% --------------------------------------------------------------------
function m_results_view_pcada_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model,'pca')

% --------------------------------------------------------------------
function m_results_eigen_pcada_Callback(hObject, eventdata, handles)
disp_eigen_pca(handles)

% --------------------------------------------------------------------
function m_results_view_cart_Callback(hObject, eventdata, handles)
disp_tree(handles)

% --------------------------------------------------------------------
function m_results_pls_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_plsda_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_plsda_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_view_roc_Callback(hObject, eventdata, handles)
disp_roc(handles)

% --------------------------------------------------------------------
function m_results_view_roc_simca_Callback(hObject, eventdata, handles)
disp_roc_simca(handles)

% --------------------------------------------------------------------
function m_results_view_roc_uneq_Callback(hObject, eventdata, handles)
disp_roc_simca(handles)

% --------------------------------------------------------------------
function m_results_view_roc_backprop_Callback(hObject, eventdata, handles)
disp_roc(handles)

% --------------------------------------------------------------------
function m_results_eigen_pls_Callback(hObject, eventdata, handles)
disp_eigen(handles)

% --------------------------------------------------------------------
function m_results_simca_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_simca_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_simca_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_eigen_simca_Callback(hObject, eventdata, handles)
disp_eigen_simca(handles)

% --------------------------------------------------------------------
function m_results_uneq_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_uneq_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_uneq_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_eigen_uneq_Callback(hObject, eventdata, handles)
disp_eigen_simca(handles)

% --------------------------------------------------------------------
function m_results_view_pf_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_svm_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_backprop_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_backprop_output_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_predict_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_predict_samples_Callback(hObject, eventdata, handles)
handles = predict_samples(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_predict_samples_view_Callback(hObject, eventdata, handles)
if strcmp(handles.data.model.type,'pcaqda')
    visualize_scores(handles.data.model,handles.data.pred,'pca')
else
    visualize_scores(handles.data.model,handles.data.pred)
end

% --------------------------------------------------------------------
function m_predict_class_Callback(hObject, eventdata, handles)
if isfield(handles.data.pred,'class_pred_string')
    assignin('base','tmp_class_predicted',handles.data.pred.class_pred_string);
else
    assignin('base','tmp_class_predicted',handles.data.pred.class_pred);
end
openvar('tmp_class_predicted');

% --------------------------------------------------------------------
function m_predict_results_Callback(hObject, eventdata, handles)
visualize_classification_measures(handles.data.model,handles.data.pred);

% --------------------------------------------------------------------
function m_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_help_html_Callback(hObject, eventdata, handles)
h1 = ['A complete HTML guide is provided.'];
hr = sprintf('\n');
h3 = ['Look for the help.htm file in the toolbox folder' sprintf('\n') 'and open it in your favourite browser!'];
web('help.htm','-browser')
helpdlg([h1 hr h3],'HTML help')

% --------------------------------------------------------------------
function m_how_to_cite_Callback(hObject, eventdata, handles)
h1 = ['The toolbox is freeware and may be used (but not modified) if proper reference is given to the authors. Preferably refer to the following paper:'];
hr = sprintf('\n');
h3 = ['Ballabio D, Consonni V, (2013) Classification tools in chemistry. Part 1: Linear models. PLS-DA. Analytical Methods, 5, 3790-3798'];
helpdlg([h1 hr hr h3 hr hr],'How to cite')

% --------------------------------------------------------------------
function m_about_Callback(hObject, eventdata, handles)
h1 = 'classification toolbox for MATLAB version 6.0';
hr = sprintf('\n');
h2 = 'Milano Chemometrics and QSAR Research Group ';
h3 = 'University of Milano-Bicocca, Italy';
h4 = 'http://www.michem.unimib.it/';
helpdlg([h1 hr h2 hr h3 hr h4],'About')

% --- Executes during object creation, after setting all properties.
function listbox_data_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in listbox_data.
function listbox_data_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox_model_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in listbox_model.
function listbox_model_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function handles = do_da(handles)
% open do settings
[cv_groups,cv_type,model_type,domodel] = visualize_settings_small('da',size(handles.data.X,1),handles.present.model,handles.data.model);
noinvert = 0;
errortype = [''];
if strcmp(model_type,'lda')
    method = 'linear';
    if size(handles.data.X,2) > size(handles.data.X,1)
        noinvert = 1;
        errortype = (['LDA can be calculated only if the number of samples is greater than the number of variables']);
    end
else
    method = 'quadratic';
    for g=1:max(handles.data.class)
        objinclass(g) = length(find(handles.data.class==g));
    end
    if size(handles.data.X,2) > min(objinclass)
        noinvert = 1;
        errortype = (['QDA can be calculated only if the number of samples of each class is greater than the number of variables']);
    end
end
% check for more variable than samples
if noinvert
    domodel = 0;
    errordlg(errortype,'calculation error') 
end
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = dafit(handles.data.X,class_to_fit,2,method);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
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
            cv = [];
        else
            cv = dacv(handles.data.X,class_to_fit,cv_type,cv_groups,2,method);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_cart(handles)
% open do settings
[cv_groups,cv_type,~,domodel] = visualize_settings_small('cart',size(handles.data.X,1),NaN,NaN);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = cartfit(handles.data.X,class_to_fit,handles.data.variable_labels);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
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
            cv = [];
        else
            cv = cartcv(handles.data.X,class_to_fit,cv_type,cv_groups);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_pls(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 20; maxcomp = 20; end
[cv_groups,cv_type,num_comp,preprocess_columns,assign_method,preprocess_rows,~,~,domodel] = visualize_settings_big('plsda',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,NaN,0,handles.data.X,handles.data.class,NaN,NaN);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = plsdafit(handles.data.X,class_to_fit,num_comp,preprocess_rows,preprocess_columns,assign_method,1);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
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
            cv = [];
        else
            cv = plsdacv(handles.data.X,class_to_fit,num_comp,preprocess_rows,preprocess_columns,cv_type,cv_groups,assign_method);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_simca(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 20; maxcomp = 20; end
if length(handles.data.class_labels) == 0
    for g=1:max(handles.data.class)
        class_labels{g} = g;
    end
else
    class_labels = handles.data.class_labels;
end
[cv_groups,cv_type,num_comp,preprocess_columns,target_class,preprocess_rows,~,~,domodel] = visualize_settings_big('simca',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,class_labels,0,handles.data.X,handles.data.class,handles.data.class_labels,handles.data.class_string);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = simcafit(handles.data.X,class_to_fit,target_class,num_comp,preprocess_rows,preprocess_columns);
    if strcmp('none',cv_type)
        cv = [];
    else
        if length(handles.data.class_labels) == 0
            class_check = calc_class_modellinglabels(handles.data.class,target_class);
        else
            class_check = calc_class_modellinglabels(handles.data.class,target_class,handles.data.class_labels);
        end
        err_cv = check_cv_err(class_check,cv_type,cv_groups);
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
            cv = [];
        else
            cv = simcacv(handles.data.X,class_to_fit,target_class,num_comp,preprocess_rows,preprocess_columns,cv_type,cv_groups);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_uneq(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 20; maxcomp = 20; end
if length(handles.data.class_labels) == 0
    for g=1:max(handles.data.class)
        class_labels{g} = g;
    end
else
    class_labels = handles.data.class_labels;
end
[cv_groups,cv_type,num_comp,preprocess_columns,target_class,preprocess_rows,~,~,domodel] = visualize_settings_big('uneq',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,class_labels,0,handles.data.X,handles.data.class,handles.data.class_labels,handles.data.class_string);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = uneqfit(handles.data.X,class_to_fit,target_class,num_comp,preprocess_rows,preprocess_columns);
    if strcmp('none',cv_type)
        cv = [];
    else
        if length(handles.data.class_labels) == 0
            class_check = calc_class_modellinglabels(handles.data.class,target_class);
        else
            class_check = calc_class_modellinglabels(handles.data.class,target_class,handles.data.class_labels);
        end
        err_cv = check_cv_err(class_check,cv_type,cv_groups);
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
            cv = [];
        else
            cv = uneqcv(handles.data.X,class_to_fit,target_class,num_comp,preprocess_rows,preprocess_columns,cv_type,cv_groups);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_pf(handles)
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 10; maxcomp = 10; end
if length(handles.data.class_labels) == 0
    for g=1:max(handles.data.class)
        class_labels{g} = g;
    end
else
    class_labels = handles.data.class_labels;
end
[cv_groups,cv_type,num_comp,preprocess_columns,target_class,perc,smoot,preprocess_rows,domodel] = visualize_settings_big('pf',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,class_labels,0,handles.data.X,handles.data.class,handles.data.class_labels,handles.data.class_string);
if ischar(num_comp)
    % exceptions
    if strcmp(num_comp,'automatic')
        num_comp = 0;
    else
        num_comp = NaN;
    end
end
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = potfit(handles.data.X,class_to_fit,target_class,smoot,perc,preprocess_rows,preprocess_columns,num_comp);
    if strcmp('none',cv_type)
        cv = [];
    else
         if length(handles.data.class_labels) == 0
            class_check = calc_class_modellinglabels(handles.data.class,target_class);
        else
            class_check = calc_class_modellinglabels(handles.data.class,target_class,handles.data.class_labels);
        end
        err_cv = check_cv_err(class_check,cv_type,cv_groups);
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
            cv = [];
        else
            cv = potcv(handles.data.X,class_to_fit,target_class,smoot,perc,preprocess_rows,preprocess_columns,cv_type,cv_groups,num_comp);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_svm(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 10; maxcomp = 10; end
[cv_groups,cv_type,num_comp,preprocess_columns,kernel,param,cost,preprocess_rows,domodel] = visualize_settings_big('svm',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,NaN,0,handles.data.X,handles.data.class,NaN,NaN);
if ischar(num_comp)
    % exceptions
    if strcmp(num_comp,'automatic')
        num_comp = 0;
    else
        num_comp = NaN;
    end
end
if ischar(param)
    param = [];
end
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = svmfit(handles.data.X,class_to_fit,kernel,cost,param,preprocess_rows,preprocess_columns,num_comp);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
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
            cv = [];
        else
            cv = svmcv(handles.data.X,class_to_fit,kernel,cost,param,preprocess_rows,preprocess_columns,cv_type,cv_groups,num_comp);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_pcada(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 20; maxcomp = 20; end
[cv_groups,cv_type,num_comp,preprocess_columns,method,preprocess_rows,~,~,domodel] = visualize_settings_big('pcada',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,NaN,0,handles.data.X,handles.data.class,NaN,NaN);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = dafit(handles.data.X,class_to_fit,2,method,num_comp,preprocess_rows,preprocess_columns);    
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
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
            cv = [];
        else
            cv = dacv(handles.data.X,class_to_fit,cv_type,cv_groups,2,method,num_comp,preprocess_rows,preprocess_columns);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_knn(handles)
% open do settings
[cv_groups,cv_type,num_k,preprocess_columns,dist_type,preprocess_rows,~,~,domodel] = visualize_settings_big('knn',size(handles.data.X,1),handles.present.model,handles.data.model,10,NaN,0,handles.data.X,handles.data.class,NaN,NaN);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = knnfit(handles.data.X,class_to_fit,num_k,dist_type,preprocess_rows,preprocess_columns);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
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
            cv = [];
        else
            cv = knncv(handles.data.X,class_to_fit,num_k,dist_type,preprocess_rows,preprocess_columns,cv_type,cv_groups);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_backprop(handles)
% open do settings
[cv_groups,cv_type,alpha,iter,num_hidden_layers,num_neurons,learning_rate,doplot,domodel] = visualize_settings_big('backprop',size(handles.data.X,1),handles.present.model,handles.data.model,5,NaN,0,handles.data.X,handles.data.class,NaN,NaN);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    num_hidden_neurons = ones(1,num_hidden_layers)*num_neurons;
    backpropagation_settings = backpropagationsettings(num_hidden_neurons,learning_rate);
    backpropagation_settings.iter = iter;
    backpropagation_settings.alpha = alpha;
    backpropagation_settings.doplot = doplot;
    model = backpropagationfit(handles.data.X,class_to_fit,backpropagation_settings);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
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
            cv = [];
        else
            cv = backpropagationcv(handles.data.X,class_to_fit,backpropagation_settings,cv_type,cv_groups);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        if length(handles.data.smoothing) > 0
            handles.data.model.smoothing.window = handles.data.smoothing(1);
            handles.data.model.smoothing.degree = handles.data.smoothing(2);
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function update_listbox_data(handles)
if handles.present.data == 0
    set(handles.listbox_data,'String','data not loaded');
else
    str{1} = ['data: loaded'];
    str{2} = ['name: ' handles.data.name_data];
    str{3} = ['samples: ' num2str(size(handles.data.X,1))];
    str{4} = ['variables: ' num2str(size(handles.data.X,2))];
    if handles.present.sample_labels
        str{5} = ['sample labels: loaded'];
    else
        str{5} = ['sample labels: not loaded'];
    end
    if handles.present.variable_labels
        str{6} = ['variable labels: loaded'];
    else
        str{6} = ['variable labels: not loaded'];
    end
    if handles.present.class == 1
        str{7} = ['class: loaded'];
        str{8} = ['name: ' handles.data.name_class];
        str{9} = ['number of classes: ' num2str(max(handles.data.class))];
    end
    set(handles.listbox_data,'String',str);
end

% ------------------------------------------------------------------------
function update_listbox_model(handles)
if handles.present.model == 0
    set(handles.listbox_model,'String','model not loaded/calculated');
elseif strcmp(handles.data.model.type,'lda') || strcmp(handles.data.model.type,'qda') || strcmp(handles.data.model.type,'cart')
    er = round(handles.data.model.class_param.er*100)/100;
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    cnt = 3;
    if isfield(handles.data.model,'smoothing')
        str{cnt} = ['training sampels were smoothed']; cnt = cnt + 1;
    end
    str{cnt} = ['error rate: ' num2str(er)]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'plsda') || strcmp(handles.data.model.type,'pcalda') || strcmp(handles.data.model.type,'pcaqda') 
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    if strcmp(handles.data.model.type,'plsda')
        nc = size(handles.data.model.T,2);
        ev = round(handles.data.model.cumvar(end,1)*100);
        scal = handles.data.model.settings.preprocess_columns;
        scal_row = handles.data.model.settings.preprocess_rows;
    else
        nc = size(handles.data.model.settings.modelpca.T,2);
        ev = round(handles.data.model.settings.modelpca.cum_var(end,1)*100);
        scal = handles.data.model.settings.modelpca.settings.param.preprocess_columns;
        scal_row = handles.data.model.settings.preprocess_rows;
    end
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    elseif strcmp(scal,'rang')
        set_this = 'range scaling';
    elseif strcmp(scal,'scal')
        set_this = 'variance scaling';
    else
        set_this = 'autoscaling';
    end
    if strcmp(scal_row,'der1')
        scal_row = 'first derivative';
    elseif strcmp(scal_row,'der2')
        scal_row = 'second derivative';
    end
    cnt = 3;
    if isfield(handles.data.model,'smoothing')
        str{cnt} = ['training sampels were smoothed']; cnt = cnt + 1;
    end
    str{cnt} = ['row pre-process: ' scal_row]; cnt = cnt + 1;
    str{cnt} = ['column pre-process: ' set_this]; cnt = cnt + 1;
    str{cnt} = ['components in the model: ' num2str(nc)]; cnt = cnt + 1;
    str{cnt} = ['explained var. (X): ' num2str(ev) ' %']; cnt = cnt + 1;
    er = round(handles.data.model.class_param.er*100)/100; 
    str{cnt} = ['error rate: ' num2str(er)]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'simca') || strcmp(handles.data.model.type,'uneq')
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    nc = num2str(size(handles.data.model.T,2));
    ev = num2str(round(handles.data.model.modelpca.cum_var(end)*100));
    scal = handles.data.model.settings.preprocess_columns;
    scal_row = handles.data.model.settings.preprocess_rows;
    if isnumeric(handles.data.model.settings.target_class)
        set_this = num2str(handles.data.model.settings.target_class);
    else
        set_this = handles.data.model.settings.target_class;
    end
    str{3} = ['target class: ' set_this];
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    elseif strcmp(scal,'rang')
        set_this = 'range scaling';
    elseif strcmp(scal,'scal')
        set_this = 'variance scaling';
    else
        set_this = 'autoscaling';
    end
    if strcmp(scal_row,'der1')
        scal_row = 'first derivative';
    elseif strcmp(scal_row,'der2')
        scal_row = 'second derivative';
    end
    cnt = 4;
    if isfield(handles.data.model,'smoothing')
        str{cnt} = ['training sampels were smoothed']; cnt = cnt + 1;
    end
    str{cnt} = ['row pre-process: ' scal_row]; cnt = cnt + 1;
    str{cnt} = ['column pre-process: ' set_this]; cnt = cnt + 1;
    str{cnt} = ['PCs: ' nc]; cnt = cnt + 1;
    str{cnt} = ['explained var. (%): ' ev]; cnt = cnt + 1;
    er = round(handles.data.model.class_param.er*100)/100;
    str{cnt} = ['error rate: ' num2str(er)]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'knn')
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    num_k = handles.data.model.settings.K;
    scal = handles.data.model.settings.param.preprocess_columns;
    scal_row = handles.data.model.settings.preprocess_rows;
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    elseif strcmp(scal,'rang')
        set_this = 'range scaling';
    elseif strcmp(scal,'scal')
        set_this = 'variance scaling';
    else
        set_this = 'autoscaling';
    end
    if strcmp(scal_row,'der1')
        scal_row = 'first derivative';
    elseif strcmp(scal_row,'der2')
        scal_row = 'second derivative';
    end
    cnt = 3;
    if isfield(handles.data.model,'smoothing')
        str{cnt} = ['training sampels were smoothed']; cnt = cnt + 1;
    end
    str{cnt} = ['row pre-process: ' scal_row]; cnt = cnt + 1;
    str{cnt} = ['column pre-process: ' set_this]; cnt = cnt + 1;
    str{cnt} = ['K value: ' num2str(num_k)]; cnt = cnt + 1;
    str{cnt} = ['distance: ' handles.data.model.settings.dist_type]; cnt = cnt + 1;
    er = round(handles.data.model.class_param.er*100)/100;
    str{cnt} = ['error rate: ' num2str(er)]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'pf')
    sm = num2str(handles.data.model.settings.smoot(1));
    for g = 2:length(handles.data.model.settings.smoot); sm = [sm ', ' num2str(handles.data.model.settings.smoot(g))]; end
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    if isnumeric(handles.data.model.settings.target_class)
        set_this = num2str(handles.data.model.settings.target_class);
    else
        set_this = handles.data.model.settings.target_class;
    end
    str{3} = ['target class: ' set_this];
    scal = handles.data.model.settings.preprocess_columns;
    scal_row = handles.data.model.settings.preprocess_rows;
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    elseif strcmp(scal,'rang')
        set_this = 'range scaling';
    elseif strcmp(scal,'scal')
        set_this = 'variance scaling';
    else
        set_this = 'autoscaling';
    end
    if strcmp(scal_row,'der1')
        scal_row = 'first derivative';
    elseif strcmp(scal_row,'der2')
        scal_row = 'second derivative';
    end
    cnt = 4;
    if isfield(handles.data.model,'smoothing')
        str{cnt} = ['training sampels were smoothed']; cnt = cnt + 1;
    end
    str{cnt} = ['row pre-process: ' scal_row]; cnt = cnt + 1;
    str{cnt} = ['column pre-process: ' set_this]; cnt = cnt + 1;
    str{cnt} = ['percentile: ' num2str(handles.data.model.settings.perc)]; cnt = cnt + 1;
    er = round(handles.data.model.class_param.er*100)/100;
    str{cnt} = ['smoothing: ' sm]; cnt = cnt + 1;
    if isnan(handles.data.model.settings.num_comp)
        str{cnt} = ['not calculated on PCs']; cnt = cnt + 1;
    else
        set_this = num2str(size(handles.data.model.settings.Xclass,2));
        str{cnt} = ['calculated on ' num2str(set_this) ' PCs']; cnt = cnt + 1;
    end
    str{cnt} = ['error rate: ' num2str(er)]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'svm')
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    scal = handles.data.model.settings.preprocess_columns;
    scal_row = handles.data.model.settings.preprocess_rows;
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    elseif strcmp(scal,'rang')
        set_this = 'range scaling';
    elseif strcmp(scal,'scal')
        set_this = 'variance scaling';
    else
        set_this = 'autoscaling';
    end
    if strcmp(scal_row,'der1')
        scal_row = 'first derivative';
    elseif strcmp(scal_row,'der2')
        scal_row = 'second derivative';
    end
    cnt = 3;
    if isfield(handles.data.model,'smoothing')
        str{cnt} = ['training sampels were smoothed']; cnt = cnt + 1;
    end
    str{cnt} = ['row pre-process: ' scal_row]; cnt = cnt + 1;
    str{cnt} = ['column pre-process: ' set_this]; cnt = cnt + 1;
    str{cnt} = ['kernel: ' handles.data.model.settings.kernel]; cnt = cnt + 1;
    if strcmp(handles.data.model.settings.kernel,'linear')
        str{cnt} = ['kernel param: ' 'none']; cnt = cnt + 1;
    else
        str{cnt} = ['kernel param: ' num2str(handles.data.model.settings.kernelpar)]; cnt = cnt + 1;
    end
    str{cnt} = ['cost: ' num2str(handles.data.model.settings.C)]; cnt = cnt + 1;
    str{cnt} = ['support vectors: ' num2str(length(handles.data.model.svind))]; cnt = cnt + 1;
    er = round(handles.data.model.class_param.er*100)/100;
    if isnan(handles.data.model.settings.num_comp)
        str{cnt} = ['not calculated on PCs']; cnt = cnt + 1;
    else
        set_this = num2str(size(handles.data.model.settings.svind_data_scaled,2));
        str{cnt} = ['calculated on ' num2str(set_this) ' PCs']; cnt = cnt + 1;
    end
    str{cnt} = ['error rate: ' num2str(er)]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'backprop')
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    cnt = 3;
    if isfield(handles.data.model,'smoothing')
        str{cnt} = ['training sampels were smoothed']; cnt = cnt + 1;
    end
    num_hidden_layers = length(handles.data.model.settings.network_settings.num_hidden_neurons);
    str{cnt} = ['hidden layers: ' num2str(num_hidden_layers)]; cnt = cnt + 1;
    str{cnt} = ['neurons per layer: ' num2str(handles.data.model.settings.network_settings.num_hidden_neurons(1))]; cnt = cnt + 1;
    str{cnt} = ['learning rate: ' num2str(handles.data.model.settings.network_settings.learning_rate)]; cnt = cnt + 1;
    str{cnt} = ['alpha: ' num2str(handles.data.model.settings.network_settings.alpha)]; cnt = cnt + 1;
    str{cnt} = ['iterations: ' num2str(handles.data.model.settings.network_settings.iter)]; cnt = cnt + 1;
    er = round(handles.data.model.class_param.er*100)/100;
    str{cnt} = ['error rate: ' num2str(er)]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);    
end

% ------------------------------------------------------------------------
function disp_tree(handles)
view(handles.data.model.tree,'Mode','graph')

% ------------------------------------------------------------------------
function disp_roc(handles)
[~,col_default] = visualize_colors;
model = handles.data.model;
num_class = max(model.settings.class);
figure
hold on
cnt = 0;
set(gcf,'color','white')
for g=1:num_class
    % roc curve
    cnt = cnt + 1;
    subplot(num_class,2,cnt)
    TPR = model.settings.sn(:,g)';
    FPR = 1 - model.settings.sp(:,g)';
    area(FPR,TPR,'FaceColor',col_default(1,:));
    box on
    xlabel('1 - specificity')
    ylabel('sensitivity')
    % area under ROC curve
    FPRarea = [0 FPR 1 0];
    TPRarea = [0 TPR 0 0];
    AUC = polyarea(FPRarea,TPRarea);
    AUC = round(AUC*100)/100;
    if length(model.labels.class_labels) == 0
        title(['ROC curve - class ' num2str(g) ' (AUC: ' num2str(AUC) ')'])
    else
        title(['ROC curve - ' model.labels.class_labels{g} ' (AUC: ' num2str(AUC) ')'])
    end
    % specificity and sensitivity
    cnt = cnt + 1;
    subplot(num_class,2,cnt)
    hold on;
    plot(model.settings.thr_val(g,2:end-1),model.settings.sn(2:end-1,g)','b')
    plot(model.settings.thr_val(g,2:end-1),model.settings.sp(2:end-1,g)','r')
    axis([min(model.settings.thr_val(g,2:end-1)) max(model.settings.thr_val(g,2:end-1)) 0 1])
    xlabel('threshold')
    ylabel('sn and sp ')
    if length(model.labels.class_labels) == 0
        title(['sensitivity (blue) and specificity (red) - class ' num2str(g)])
    else
        title(['sensitivity (blue) and specificity (red) - ' model.labels.class_labels{g}])
    end  
    hold off
    box on
end
hold off

% ------------------------------------------------------------------------
function disp_roc_simca(handles)
[~,col_default] = visualize_colors;
model = handles.data.model;
figure
hold on
cnt = 0;
set(gcf,'color','white')
% roc curve
cnt = cnt + 1;
subplot(1,2,cnt)
TPR = model.settings.sn';
FPR = 1 - model.settings.sp';
area(FPR,TPR,'FaceColor',col_default(1,:));
box on
xlabel('1 - specificity')
ylabel('sensitivity')
% area under ROC curve
FPRarea = [0 FPR 1 0];
TPRarea = [0 TPR 0 0];
AUC = polyarea(FPRarea,TPRarea);
AUC = round(AUC*100)/100;
if length(model.labels.class_labels) == 0
    title(['ROC curve - class ' num2str(model.settings.target_class) ' (AUC: ' num2str(AUC) ')'])
else
    title(['ROC curve - ' model.settings.target_class ' (AUC: ' num2str(AUC) ')'])
end
% specificity and sensitivity
cnt = cnt + 1;
subplot(1,2,cnt)
hold on;
plot(model.settings.thr_val(2:end-1),model.settings.sn(2:end-1)','b')
plot(model.settings.thr_val(2:end-1),model.settings.sp(2:end-1)','r')
axis([min(model.settings.thr_val(2:end-1)) max(model.settings.thr_val(2:end-1)) 0 1])
xlabel('threshold')
ylabel('sn and sp ')
if length(model.labels.class_labels) == 0
    title(['sensitivity (blue) and specificity (red) - class ' num2str(model.settings.target_class)])
else
    title(['sensitivity (blue) and specificity (red) - ' model.settings.target_class])
end
hold off
box on


% ------------------------------------------------------------------------
function disp_eigen(handles)
[~,col_default] = visualize_colors;
exp_var = handles.data.model.expvar;
num_comp = length(exp_var);
figure
subplot(1,2,1)
hold on
bar(exp_var(:,1)*100,'FaceColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.5 (num_comp + 0.5) 0 100])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('exp var (%)')
xlabel('latent variables')
box on
set(gca,'YGrid','on','GridLineStyle',':')
title('variance on X')
subplot(1,2,2)
hold on
bar(exp_var(:,2)*100,'FaceColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.5 (num_comp + 0.5) 0 100])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('exp var (%)')
xlabel('latent variables')
box on
set(gca,'YGrid','on','GridLineStyle',':')
title('variance on Y')
box on
set(gcf,'color','white')

% ------------------------------------------------------------------------
function disp_eigen_pca(handles)
[~,col_default] = visualize_colors;
exp_var = handles.data.model.settings.modelpca.exp_var;
eigen = handles.data.model.settings.modelpca.E;
num_comp = length(exp_var);
figure
subplot(1,2,1)
hold on
plot(eigen,'Color',col_default(1,:))
plot(eigen,'o','MarkerSize',6,'MarkerFaceColor','w','MarkerEdgeColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.6 (num_comp + 0.4) ylim(1) ylim(2)])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('eigenvalues')
xlabel('principal components')
box on
set(gca,'YGrid','on','GridLineStyle',':')
subplot(1,2,2)
hold on
bar(exp_var(:,1)*100,'FaceColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.5 (num_comp + 0.5) 0 100])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('exp var (%)')
xlabel('principal components')
set(gca,'YGrid','on','GridLineStyle',':')
box on
set(gcf,'color','white')

% ------------------------------------------------------------------------
function disp_eigen_simca(handles)
[~,col_default] = visualize_colors;
eigen = handles.data.model.modelpca.E;
exp_var = handles.data.model.modelpca.exp_var;
num_comp = length(exp_var);
if isnumeric(handles.data.model.settings.target_class)
    target_class = num2str(handles.data.model.settings.target_class);
else
    target_class = handles.data.model.settings.target_class;
end
figure
cnt = 0;
cnt = cnt + 1;
subplot(1,2,cnt)
hold on
plot(eigen,'Color',col_default(1,:))
plot(eigen,'o','MarkerSize',6,'MarkerFaceColor','w','MarkerEdgeColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.6 (num_comp + 0.4) ylim(1) ylim(2)])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('eigenvalues')
xlabel(['PCs - class ' target_class])
box on
set(gca,'YGrid','on','GridLineStyle',':')
hold off
cnt = cnt + 1;
subplot(1,2,cnt)
hold on
bar(exp_var*100,'FaceColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.5 (num_comp + 0.5) 0 100])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('exp var (%)')
xlabel(['PCs - class ' target_class])
box on
set(gca,'YGrid','on','GridLineStyle',':')
hold off
set(gcf,'color','white')

% ------------------------------------------------------------------------
function handles = predict_samples(handles)
% check data and model size
Xpred = handles.data.X;
if isfield(handles.data.model,'smoothing')
    h1 = ['samples to be predicted have been smoothed like training samples (Savitzky-Golay smoothing with window equal to ' num2str(handles.data.model.smoothing.window) ' and degree equal to ' num2str(handles.data.model.smoothing.degree) ')'];
    warndlg([h1],'Smoothing')
    Xpred = data_pretreatment_rows(Xpred,'smooth',handles.data.model.smoothing.window,handles.data.model.smoothing.degree,NaN);
end
if size(handles.data.model.settings.raw_data,2) == size(Xpred,2)
    errortype = 'none';
else
    errortype = ['mismatch in the number of variables: data have ' num2str(size(Xpred,2)) ...
                 ' variables, but model was calculated with ' num2str(size(handles.data.model.settings.raw_data,2)) ' variables'];
end
if strcmp(errortype,'none')
    if strcmp(handles.data.model.type,'lda') || strcmp(handles.data.model.type,'qda') || strcmp(handles.data.model.type,'pcalda') || strcmp(handles.data.model.type,'pcaqda')
        pred = dapred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'cart')
        pred = cartpred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'plsda')
        pred = plsdapred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'simca')
        pred = simcapred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'uneq')
        pred = uneqpred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'knn')
        if length(handles.data.model.labels.class_labels) == 0
            class_to_fit = handles.data.model.settings.class;
        else
            class_to_fit = handles.data.model.settings.class_string;
        end
        pred = knnpred(Xpred,handles.data.model.settings.raw_data,class_to_fit,handles.data.model.settings.K,handles.data.model.settings.dist_type,handles.data.model.settings.preprocess_columns);
    elseif strcmp(handles.data.model.type,'pf')
        pred = potpred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'svm')
        pred = svmpred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'backprop')
        pred = backpropagationpred(Xpred,handles.data.model);
    end
    handles.present.pred = 1;
    handles.data.pred = pred;
    handles.data.pred.X = Xpred;
    if handles.present.sample_labels == 1
        handles.data.pred.sample_labels = handles.data.sample_labels;
    else
        for k=1:size(Xpred,1)
            handles.data.pred.sample_labels{k} = ['P' num2str(k)];
        end
        handles.data.pred.sample_labels = handles.data.pred.sample_labels';
    end
    if handles.present.class == 1
        if strcmp(handles.data.model.type,'simca') || strcmp(handles.data.model.type,'uneq') || strcmp(handles.data.model.type,'pf')
            handles.data.pred.class = handles.data.class;
            if length(handles.data.model.labels.class_labels) == 0
                [class] = calc_class_modellinglabels(handles.data.class,handles.data.model.settings.target_class);
            else
                [class] = calc_class_modellinglabels(handles.data.class,handles.data.model.settings.target_class,handles.data.model.labels.class_labels);
            end
            handles.data.pred.class_classmodelling = class;
            handles.data.pred.class_param = calc_class_param_classmodelling(handles.data.pred.class_pred,class);
        else
            handles.data.pred.class = handles.data.class;
            handles.data.pred.class_param = calc_class_param(handles.data.pred.class_pred,handles.data.pred.class);
        end
        update_listbox_model(handles)
    end
    h1 = 'Samples have been predicted.';
    helpdlg(h1)
    handles = enable_disable(handles);
else
    errordlg(errortype,'error comparing data and model sizes') 
end

% ------------------------------------------------------------------------
function handles = reduce_data(handles,samples_in,variables_in)
variables_in = sort(variables_in);
samples_in = sort(samples_in);
handles.data.X = handles.data.X(samples_in,variables_in);
if handles.present.class
    handles.data.class = handles.data.class(samples_in);
    if length(handles.data.class_labels) > 0
        handles.data.class_string = handles.data.class_string(samples_in);
    end
end
handles.data.sample_labels = handles.data.sample_labels(samples_in);
handles.data.variable_labels = handles.data.variable_labels(variables_in);
update_listbox_data(handles);
if handles.present.model == 2
    handles = reset_model(handles);
    update_listbox_model(handles);
    handles = enable_disable(handles);
end

% ------------------------------------------------------------------------
function handles = init_handles(handles)
handles.present.data  = 0;
handles.present.class = 0;
handles.present.model = 0;  % = 1 is loaded, = 2 is calculated
handles.present.sample_labels = 0;
handles.present.variable_labels = 0;
handles.present.pred = 0;
handles.data.name_class = [];
handles.data.name_data = [];
handles.data.name_model = [];
handles.data.X = [];
handles.data.Xraw = []; % to be used as input for smoothing
handles.data.class = [];
handles.data.class_string = {};
handles.data.class_labels = {};
handles.data.model = [];
handles.data.pred = [];
handles.data.smoothing = [];

% ------------------------------------------------------------------------
function handles = reset_data(handles)
handles.present.data  = 0;
handles.present.pred = 0;
handles.data.X = [];
handles.data.Xraw = []; % to be used as input for smoothing
handles.data.name_data = [];
handles.data.pred = [];
handles.data.smoothing = [];

% ------------------------------------------------------------------------
function handles = reset_pred(handles)
handles.present.pred = 0;
handles.data.pred = [];

% ------------------------------------------------------------------------
function handles = reset_labels(handles)
handles.present.sample_labels = 0;
handles.present.variable_labels = 0;
handles.data.sample_labels = [];
handles.data.variable_labels = [];

% ------------------------------------------------------------------------
function handles = reset_class(handles)
handles.present.class = 0;
handles.data.name_class = [];
handles.data.class = [];
handles.data.class_string = {};
handles.data.class_labels = {};

% ------------------------------------------------------------------------
function handles = reset_model(handles)
handles.present.model = 0;
handles.present.pred = 0;
handles.data.name_model = [];
handles.data.model = [];
handles.data.pred = [];

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

% -------------------------------------------------------------------------
function dobound = chkboundaries(model)
dobound = 0;
if size(model.settings.raw_data,2) == 2
    dobound = 1; 
elseif strcmp(model.type,'plsda')
    if size(model.T,2) == 2
        dobound = 1; 
    end
elseif strcmp(model.type,'pcalda') || strcmp(model.type,'pcaqda')
    if size(model.settings.modelpca.T,2) == 2
        dobound = 1; 
    end
elseif strcmp(model.type,'svm')
    if isstruct(model.settings.model_pca) && model.settings.num_comp == 2
        dobound = 1; 
    end
end

% ------------------------------------------------------------------------
function handles = enable_disable(handles)
if ~license('test','statistics_toolbox')
    statistics_toolbox = 0;
else
    statistics_toolbox = 1;
end
if handles.present.data == 0
    set(handles.m_file_load_class,'Enable','off');    
    set(handles.m_file_clear_data,'Enable','off');
    set(handles.m_view_data,'Enable','off');
    set(handles.m_view_smoothing,'Enable','off');
    set(handles.m_view_plot_profiles,'Enable','off');
    set(handles.m_view_plot_univariate,'Enable','off');
    set(handles.m_view_delete,'Enable','off');
    set(handles.m_file_load_sample_labels,'Enable','off');   
    set(handles.m_file_load_variable_labels,'Enable','off');
else
    set(handles.m_file_clear_data,'Enable','on');
    set(handles.m_file_load_class,'Enable','on');
    set(handles.m_view_data,'Enable','on');
    set(handles.m_view_smoothing,'Enable','on');
    set(handles.m_view_plot_profiles,'Enable','on');
    set(handles.m_view_plot_univariate,'Enable','on');
    set(handles.m_view_delete,'Enable','on');    
    set(handles.m_file_load_sample_labels,'Enable','on');   
    set(handles.m_file_load_variable_labels,'Enable','on');
end
if handles.present.class == 0
    set(handles.m_da,'Enable','off');
    set(handles.m_calculate_da,'Enable','off');
    set(handles.m_calculate_multinormality,'Enable','off');
    set(handles.m_calculate_cart,'Enable','off');
    set(handles.m_calculate_pcada,'Enable','off');   
    set(handles.m_pls,'Enable','off');   
    set(handles.m_pf,'Enable','off');   
    set(handles.m_svm,'Enable','off'); 
    set(handles.m_simca,'Enable','off'); 
    set(handles.m_uneq,'Enable','off'); 
    set(handles.m_knn,'Enable','off');
    set(handles.m_calculate_backprop,'Enable','off');
    set(handles.m_view_class,'Enable','off');
    set(handles.m_view_wilks,'Enable','off');
else
    if statistics_toolbox == 1
        set(handles.m_da,'Enable','on');
        set(handles.m_calculate_da,'Enable','on');
        set(handles.m_calculate_multinormality,'Enable','on');
        set(handles.m_calculate_cart,'Enable','on');
        set(handles.m_calculate_pcada,'Enable','on');   
        set(handles.m_simca,'Enable','on'); 
        set(handles.m_uneq,'Enable','on'); 
    else
        set(handles.m_da,'Enable','off');
        set(handles.m_calculate_da,'Enable','off');
        set(handles.m_calculate_multinormality,'Enable','off');
        set(handles.m_calculate_cart,'Enable','off');
        set(handles.m_calculate_pcada,'Enable','off');   
        set(handles.m_simca,'Enable','off'); 
        set(handles.m_uneq,'Enable','off');  
    end
    set(handles.m_pls,'Enable','on');   
    set(handles.m_pf,'Enable','on');
    if max(handles.data.class) == 2 && statistics_toolbox == 1
        set(handles.m_svm,'Enable','on');
    else
        set(handles.m_svm,'Enable','off');
    end
    set(handles.m_knn,'Enable','on');
    set(handles.m_calculate_backprop,'Enable','on');
    set(handles.m_view_class,'Enable','on');
    set(handles.m_view_wilks,'Enable','on');
end
if handles.present.model == 0
    set(handles.m_file_save_model,'Enable','off');
    set(handles.m_file_clear_model,'Enable','off');
    set(handles.m_results_view_class,'Enable','off');
    set(handles.m_results_view_boundaries,'Enable','off');
    set(handles.m_results_da,'Enable','off');
    set(handles.m_results_view_canonical_scores,'Enable','off');
    set(handles.m_results_view_canonical_loadings,'Enable','off');
    set(handles.m_results_view_cart,'Enable','off');
    set(handles.m_results_eigen_pls,'Enable','off');
    set(handles.m_results_pls,'Enable','off');
    set(handles.m_results_view_plsda_scores,'Enable','off');
    set(handles.m_results_view_plsda_loadings,'Enable','off');
    set(handles.m_results_eigen_simca,'Enable','off');
    set(handles.m_results_simca,'Enable','off');
    set(handles.m_results_view_simca_scores,'Enable','off');
    set(handles.m_results_view_simca_loadings,'Enable','off');
    set(handles.m_results_view_roc,'Enable','off');
    set(handles.m_results_view_roc_simca,'Enable','off');    
    set(handles.m_results_eigen_uneq,'Enable','off');
    set(handles.m_results_uneq,'Enable','off');
    set(handles.m_results_view_uneq_scores,'Enable','off');
    set(handles.m_results_view_uneq_loadings,'Enable','off');
    set(handles.m_results_view_roc_uneq,'Enable','off');  
    set(handles.m_results_view_pcada_scores,'Enable','off');
    set(handles.m_results_view_pcada_loadings,'Enable','off');
    set(handles.m_results_eigen_pcada,'Enable','off');
    set(handles.m_results_view_pf,'Enable','off');
    set(handles.m_results_view_svm,'Enable','off');
    set(handles.m_results_backprop,'Enable','off');
    set(handles.m_results_view_backprop_output,'Enable','off');
    set(handles.m_results_view_roc_backprop,'Enable','off');
else
    set(handles.m_file_clear_model,'Enable','on');   
    set(handles.m_file_save_model,'Enable','on');
    set(handles.m_results_view_class,'Enable','on');
    dobound = chkboundaries(handles.data.model);
    if dobound
        set(handles.m_results_view_boundaries,'Enable','on');
    else
        set(handles.m_results_view_boundaries,'Enable','off');
    end
    if strcmp(handles.data.model.type,'qda') || strcmp(handles.data.model.type,'knn')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'lda')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','on');
        set(handles.m_results_view_canonical_scores,'Enable','on');
        set(handles.m_results_view_canonical_loadings,'Enable','on');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'cart')
        set(handles.m_results_view_cart,'Enable','on');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'plsda')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','on');
        set(handles.m_results_pls,'Enable','on');
        set(handles.m_results_view_plsda_scores,'Enable','on');
        set(handles.m_results_view_plsda_loadings,'Enable','on');
        set(handles.m_results_view_roc,'Enable','on');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'pcalda')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','on');
        set(handles.m_results_view_canonical_scores,'Enable','on');
        set(handles.m_results_view_canonical_loadings,'Enable','on');
        set(handles.m_results_view_pcada_scores,'Enable','on');
        set(handles.m_results_view_pcada_loadings,'Enable','on');
        set(handles.m_results_eigen_pcada,'Enable','on');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'pcaqda')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','on');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','on');
        set(handles.m_results_view_pcada_loadings,'Enable','on');
        set(handles.m_results_eigen_pcada,'Enable','on');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'simca')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');     
        if ~isnan(handles.data.model.settings.thr(1))
            set(handles.m_results_view_roc_simca,'Enable','on');
        else
            set(handles.m_results_view_roc_simca,'Enable','off');
        end
        set(handles.m_results_eigen_simca,'Enable','on');
        set(handles.m_results_simca,'Enable','on');
        set(handles.m_results_view_simca_scores,'Enable','on');
        set(handles.m_results_view_simca_loadings,'Enable','on');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'uneq')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');     
        if ~isnan(handles.data.model.settings.thr(1))
            set(handles.m_results_view_roc_uneq,'Enable','on');
        else
            set(handles.m_results_view_roc_uneq,'Enable','off');
        end
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_uneq,'Enable','on');
        set(handles.m_results_view_uneq_scores,'Enable','on');
        set(handles.m_results_view_uneq_loadings,'Enable','on');
        set(handles.m_results_eigen_uneq,'Enable','on');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'pf')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','on');
        set(handles.m_results_view_svm,'Enable','off');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'svm')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','on');
        set(handles.m_results_backprop,'Enable','off');
        set(handles.m_results_view_backprop_output,'Enable','off');
        set(handles.m_results_view_roc_backprop,'Enable','off');
    elseif strcmp(handles.data.model.type,'backprop')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');   
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_backprop,'Enable','on');
        set(handles.m_results_view_backprop_output,'Enable','on');        
        if strcmp(handles.data.model.settings.network_settings.assignation_type,'thr')
            set(handles.m_results_view_roc_backprop,'Enable','on');
        else
            set(handles.m_results_view_roc_backprop,'Enable','off');
        end
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
    end
end
if handles.present.pred == 1
    set(handles.m_predict_class,'Enable','on');
    set(handles.m_file_save_pred,'Enable','on');
    if strcmp(handles.data.model.type,'plsda') || strcmp(handles.data.model.type,'pcaqda') ...
            || strcmp(handles.data.model.type,'pcalda') || strcmp(handles.data.model.type,'simca')...
            || strcmp(handles.data.model.type,'uneq') || strcmp(handles.data.model.type,'lda')...
            || strcmp(handles.data.model.type,'pf') || strcmp(handles.data.model.type,'svm') || strcmp(handles.data.model.type,'backprop')
        set(handles.m_predict_samples_view,'Enable','on');
    else % case ok kNN
        set(handles.m_predict_samples_view,'Enable','off');
    end
else
    set(handles.m_file_save_pred,'Enable','off');
    set(handles.m_predict_class,'Enable','off');
    set(handles.m_predict_samples_view,'Enable','off');
end
if handles.present.pred == 1 && handles.present.class == 1 && isfield(handles.data.pred,'class_param')
    set(handles.m_predict_results,'Enable','on');
else
    set(handles.m_predict_results,'Enable','off');
end
% predict new samples is active when
% 1. model is loaded and data are already loaded
% 2. data are loaded and model is already loaded
% is not active when
% 3. model is calculated with the loaded data
if handles.present.model == 1 && handles.present.data == 1
    set(handles.m_predict_samples,'Enable','on');
else
    set(handles.m_predict_samples,'Enable','off');
end
