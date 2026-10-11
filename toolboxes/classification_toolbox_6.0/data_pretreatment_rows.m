function [X_scal,param] = data_pretreatment_rows(X,preprocess_rows,window,degree,mean_vector)

% row data preprocessing
%
% X_scal = data_pretreatment_rows(X,preprocess_rows,window,degree,mean_vector)
%
% INPUT:
% X                     dataset [samples x variables]
% preprocess_rows       row data preprocessing
%                       'none' no scaling
%                       'snv' standard normal variate
%                       'msc' multiplicative scatter correction
%                       'der1' first derivative
%                       'der2' second derivative
%                       'smooth' Savitzky-Golay smoothing 
% OPTIONAL
% window                number of data points to be used in the Savitzky-Golay calculation
% degree                polynomial degree for Savitzky-Golay; must be less than window
% mean_vector           vector [1 x variables] to be used for multiplicative scatter correction.
%                       This is usually the vector with average values of the training samples 
%
% OUTPUT:
% X_scal                pretreated data matrix [samples x variables]
% param                 training parameters to scale test samples (used for multiplicative scatter correction)
% 
%
% This is an internal routine of the toolbox.
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

if nargin < 3
    window = NaN;
    degree = NaN;
    mean_vector = mean(X)';
end
param.mean_vector = mean_vector;
if strcmp(preprocess_rows,'msc')
    for k=1:size(X,1)
        x = X(k,:)';
        m_reg = [ones(size(mean_vector,1),1) mean_vector]; %this is for the intercept
        b = inv(m_reg'*m_reg)*m_reg'*x;
        X_scal(k,:) = (X(k,:) - b(1))./b(2);
    end
elseif strcmp(preprocess_rows,'snv')
    X = X';
    a = mean(X);
    s = std(X);
    f = find(s>0);
    amat = repmat(a,size(X,1),1);
    smat = repmat(s,size(X,1),1);
    X_scal = zeros(size(X,1),size(X,2));
    X_scal(:,f) = (X(:,f) - amat(:,f))./smat(:,f);
    X_scal = X_scal';
elseif strcmp(preprocess_rows,'der1')
    X_scal = gradient(X);
elseif strcmp(preprocess_rows,'der2')
    X_scal = gradient(X);
    X_scal = gradient(X_scal);
elseif strcmp(preprocess_rows,'smooth')
    X_scal = zeros(size(X));
    for i = 1:size(X,1)
        X_scal(i,:) = smooth(X(i,:),window,'sgolay',degree);
    end
else
    X_scal = X;
end


