function varargout = visualize_smoothing(varargin)

% This is an internal routine for the graphical interface of the toolbox.
% The main routine to open the graphical interface is reg_gui
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
% V. Consonni, G. Baccolo, F. Gosetti, R. Todeschini, D. Ballabio (2021) A MATLAB toolbox for multivariate regression coupled with variable selection. 
% Chemometrics and Intelligent Laboratory Systems, 213, 104313, DOI: 10.1016/j.chemolab.2021.104313
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
                   'gui_OpeningFcn', @visualize_smoothing_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_smoothing_OutputFcn, ...
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


% --- Executes just before visualize_smoothing is made visible.
function visualize_smoothing_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for visualize_smoothing
handles.output = hObject;
% parameters for position
x_position = 3.5;
step_for_text = 1.6;
% set main dimension
handles.manage_size.minimum_size = [0 0 150 38];
set(handles.output,'Position',handles.manage_size.minimum_size);
% uipanel
set(handles.myuipanel,'Position',[3.5 12 30 25]);
set(handles.text_xaxis,'Position',[x_position 21+step_for_text 23 1]);
set(handles.pop_xaxis,'Position',[x_position 21 23 1.5]);
set(handles.text7,'Position',[x_position 17.5+step_for_text 23 1]);
set(handles.pop_window,'Position',[x_position 17.5 23 1.5]);
set(handles.text_yaxis,'Position',[x_position 14+step_for_text 23 1]);
set(handles.pop_degree,'Position',[x_position 14 23 1.5]);
set(handles.button_smooth,'Position',[x_position 10 23 2]);
set(handles.button_cancel,'Position',[x_position 7 23 2]);
set(handles.button_export,'Position',[x_position 4 23 2]);
set(handles.button_help,'Position',[x_position 1 23 2]);
% plot area
[g4,g5] = getplotposition(handles);
set(handles.plot_raw,'Position',g4);
set(handles.plot_scaled,'Position',g5);
movegui(handles.visualize_smoothing,'center');
g2 = get(handles.myuipanel,'Position');
handles.manage_size.initial_frame = get(handles.output,'Position');
handles.manage_size.initial_height_uipanel = g2(2);
% get data
data_here = varargin{1};
handles.data = data_here.Xraw;
handles.class = data_here.class;
handles.class_labels =  data_here.class_labels;
handles.var_labels = data_here.variable_labels;
handles.sample_labels = data_here.sample_labels;
% set combo
str_disp = {};
handles.degree(1) = 1;
handles.degree(2) = 2;
handles.degree(3) = 3;
handles.degree(4) = 4;
for k=1:length(handles.degree)
    str_disp{k} = handles.degree(k);
end
set(handles.pop_degree,'String',str_disp);
if length(data_here.smoothing) > 0
    w = find(handles.degree == data_here.smoothing(2));
    set(handles.pop_degree,'Value',w);
else
    set(handles.pop_degree,'Value',2);
end
handles.window(1) = 5;
handles.window(2) = 10;
handles.window(3) = 15;
handles.window(4) = 20;
handles.window(5) = 25;
handles.window(6) = 50;
handles.window(7) = 100;
str_disp={};
for k=1:length(handles.window)
    str_disp{k} = handles.window(k);
end
set(handles.pop_window,'String',str_disp);
if length(data_here.smoothing) > 0
    w = find(handles.window == data_here.smoothing(1));
    set(handles.pop_window,'Value',w);
else
    set(handles.pop_window,'Value',2);
end
% init profiles combo
str_disp = {};
str_disp{1} = 'all samples';
for k=1:length(handles.sample_labels)
    str_disp{k+1} = handles.sample_labels{k};
end
set(handles.pop_xaxis,'String',str_disp);
set(handles.pop_xaxis,'Value',1);
% update plot
update_plot(handles,0);
% update handles structure
guidata(hObject, handles);
uiwait(handles.visualize_smoothing);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_smoothing_OutputFcn(hObject, eventdata, handles) 
len = length(handles);
if len > 0
    varargout{1} = handles.Xsmooth;
    varargout{2} = handles.window;
    varargout{3} = handles.degree;
    varargout{4} = handles.dosmooth;
    delete(handles.visualize_smoothing)
else
    handles.dosmooth = 0;
    handles.Xsmooth = NaN;
    handles.window = NaN;
    handles.degree = NaN;
    varargout{1} = handles.Xsmooth;
    varargout{2} = handles.window;
    varargout{3} = handles.degree;
    varargout{4} = handles.dosmooth;
end

% --- Executes when visualize_smoothing is resized.
function visualize_smoothing_SizeChangedFcn(hObject, eventdata, handles)
if isfield(handles,'output')
    [g2] = getuipanelposition(handles);
    set(handles.myuipanel,'Position',g2);
    [g4,g5] = getplotposition(handles);
    set(handles.plot_raw,'Position',g4);
    set(handles.plot_scaled,'Position',g5);
end

% ---------------------------------------------------------
function [g2] = getuipanelposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g2(2) = handles.manage_size.initial_height_uipanel + g1(4) - handles.manage_size.initial_frame(4);

% ---------------------------------------------------------
function [g4,g5] = getplotposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g4 = get(handles.plot_raw,'Position');
g5 = get(handles.plot_scaled,'Position');
p  = (g1(3) - g2(3) - 4*g2(1))/g1(3);
g4(1) = 1 - p;
g4(3) = p*0.95;
g5(1) = 1 - p;
g5(3) = p*0.95;

% --- Executes on selection change in pop_xaxis.
function pop_xaxis_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes during object creation, after setting all properties.
function pop_xaxis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_degree.
function pop_degree_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes during object creation, after setting all properties.
function pop_degree_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_window.
function pop_window_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes during object creation, after setting all properties.
function pop_window_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_export.
function button_export_Callback(hObject, eventdata, handles)
update_plot(handles,1)

% --- Executes on button press in button_help.
function button_help_Callback(hObject, eventdata, handles)
web('help/gui_view.htm','-browser')

% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
handles.dosmooth = 0;
handles.Xsmooth = NaN;
handles.window = NaN;
handles.degree = NaN;
guidata(hObject,handles)
uiresume(handles.visualize_smoothing)

% --- Executes on button press in button_smooth.
function button_smooth_Callback(hObject, eventdata, handles)
handles.dosmooth = 1;
data_raw = handles.data;
degree = get(handles.pop_degree,'Value');
degree = handles.degree(degree);
window = get(handles.pop_window,'Value');
window = handles.window(window);
handles.Xsmooth = data_pretreatment_rows(data_raw,'smooth',window,degree,NaN);
handles.window = window;
handles.degree = degree;
guidata(hObject,handles)
uiresume(handles.visualize_smoothing)

% ---------------------------------------------------------
function update_plot(handles,external)
data_raw = handles.data;
class = handles.class;
class_labels = handles.class_labels;
which_sample = get(handles.pop_xaxis,'Value') - 1;
degree = get(handles.pop_degree,'Value');
degree = handles.degree(degree);
window = get(handles.pop_window,'Value');
window = handles.window(window);
axis_label = 'smoothed data';
data_smoothed = data_pretreatment_rows(data_raw,'smooth',window,degree,NaN);
% plot raw data
if external
    figure; set(gcf,'color','white'); subplot(2,1,1); box on;
else
    axes(handles.plot_raw);
end
cla;
if get(handles.pop_xaxis,'Value') == 1 % all samples
    plot_samples(data_raw,class,handles.var_labels,'raw data',class_labels)
else % average
    plot_single_sample(data_raw(which_sample,:),handles.var_labels,'raw data')
end
% plot scaled data
if external
    subplot(2,1,2); box on;
else
    axes(handles.plot_scaled);
end
cla;
if get(handles.pop_xaxis,'Value') == 1 % all samples
    plot_samples(data_smoothed,class,handles.var_labels,axis_label,class_labels)
else % average
    plot_single_sample(data_smoothed(which_sample,:),handles.var_labels,axis_label)
end
xlabel('variables')

% -------------------------------------------------------------------------
function plot_single_sample(X,variable_labels,add_ylabel)
cla
max_variable_for_barplot = 20;
hold on
plot(X,'Color','k')
if size(X,2) < max_variable_for_barplot
    plot(X,'o','MarkerEdgeColor','k','MarkerFaceColor','w')
end
hold off
box on
ylabel(add_ylabel)
range_y = max(max(X)) - min(min(X)); 
add_space_y = range_y/20;
y_lim = [min(min(X))-add_space_y max(max(X))+add_space_y];
if y_lim(1) == y_lim(2)
    y_lim(1) = -1;
    y_lim(2) = 1;
end
axis([0.5 size(X,2)+0.5 y_lim(1) y_lim(2)])
if size(X,2) < max_variable_for_barplot
    set(gca,'XTick',[1:size(X,2)])
    set(gca,'XTickLabel',variable_labels)
else
    step = round(size(X,2)/10);
    set(gca,'XTick',[1:step:size(X,2)])
    set(gca,'XTickLabel',variable_labels([1:step:size(X,2)]))
end
legend('off')

% -------------------------------------------------------------------------
function plot_samples(X,class,variable_labels,add_ylabel,class_labels)
cla
max_variable_for_barplot = 20;
col_ass = visualize_colors;
hold on
if length(class) == 0
    plot(X','Color','k')
else
    for g=1:max(class)
        in = find(class==g);
        color_in = col_ass(g+1,:);
        legend_here = plot(X(in,:)','Color',color_in);
        plegend(g) = legend_here(1);
        if length(class_labels) == 0
            str_legend{g} = ['class ' num2str(g)];
        else
            str_legend{g} = class_labels{g};
        end
    end
    legend(plegend,str_legend);
end
hold off
box on
ylabel(['samples - ' add_ylabel])
range_y = max(max(X)) - min(min(X)); 
add_space_y = range_y/20;
y_lim = [min(min(X))-add_space_y max(max(X))+add_space_y];
if y_lim(1) == y_lim(2)
    y_lim(1) = -1;
    y_lim(2) = 1;
end
axis([0.5 size(X,2)+0.5 y_lim(1) y_lim(2)])
if size(X,2) < max_variable_for_barplot
    set(gca,'XTick',[1:size(X,2)])
    set(gca,'XTickLabel',variable_labels)
else
    step = round(size(X,2)/10);
    set(gca,'XTick',[1:step:size(X,2)])
    set(gca,'XTickLabel',variable_labels([1:step:size(X,2)]))
end
