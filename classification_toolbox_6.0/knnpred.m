function pred = knnpred(Xtest,X,class,K,dist_type,preprocess_rows,preprocess_columns)

% prediction with k-Nearest Neighbours (kNN)
%
% pred = knnpred(Xtest,X,class,K,dist_type,preprocess_rows,preprocess_columns)
%
% INPUT:            
% Xtest                 dataset to be predicted [samples_test x variables]
% X                     training dataset [samples x variables]
% class                 training class vector, class labels can be 
%                       - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                       - strings. The class vector is a cell array containing the class labels {samples x 1}
% K                     number of neighbors
% dist_type             'euclidean' Euclidean distance
%                       'mahalanobis' Mahalanobis distance
%                       'cityblock' City Block metric
%                       'minkowski' Minkowski metric
%                       'sm' sokal-michener for binary data
%                       'rt' rogers-tanimoto for binary data
%                       'jt' jaccard-tanimoto for binary data
%                       'gle' gleason-dice sorenson for binary data
%                       'ct4' consonni todeschini for binary data
%                       'ac' austin colwell for binary data
% preprocess_rows       row data preprocessing
%                       'none' no scaling
%                       'snv' standard normal variate
%                       'msc' multiplicative scatter correction
%                       'der1' first derivative
%                       'der2' second derivative
% preprocess_columns    column data preprocessing 
%                       'none' no scaling
%                       'cent' centering
%                       'scal' variance scaling
%                       'auto' autoscaling (centering + variance scaling)
%                       'rang' range scaling (0-1)
%
% OUTPUT:
% res is a structure with the following fields:
% class_pred        predicted class as numerical vector [samples_test x 1]
% class_pred_string predicted class as string vector {samples_test x 1}
%                   (available only if model was fitted with the class input vector as a cell array with strings as class labels)
% neighbors         list of k neighbors for each predicted sample [samples_test x k]
% D                 distance matrix [samples_test x samples]
%
% RELATED ROUTINES:
% knnfit            fit of kNN
% knncv             cross-validatation of kNN
% knnksel           selection of the optimal number of neighbors for kNN
% class_gui         main routine to open the graphical interface
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

if iscell(class)
    class_string = class;
    [class,class_labels] = calc_class_string(class_string);
else
    class_string = {};
    class_labels = {};
end
n = size(Xtest,1);
[xscalrow,px_row] = data_pretreatment_rows(X,preprocess_rows);
[X_scal_train,param] = data_pretreatment(xscalrow,preprocess_columns);
X_scal = data_pretreatment_rows(Xtest,preprocess_rows,NaN,NaN,px_row.mean_vector);
X_scal = test_pretreatment(X_scal,param);
D = knn_calc_dist(X_scal_train,X_scal,dist_type);
neighbors = zeros(n,K);
for i=1:n
    D_in = D(i,:);
    [d_tmp,n_tmp] = sort(D_in);
    neighbors(i,:) = n_tmp(1:K);
    d_neighbors = d_tmp(1:K);
    class_calc(i,1) = knnclass(class(neighbors(i,:)),d_neighbors,max(class));
end
pred.neighbors  = neighbors;
pred.D = D;
pred.class_pred = class_calc;
if length(class_labels) > 0
    pred.class_pred_string = calc_class_string(pred.class_pred,class_labels);
end