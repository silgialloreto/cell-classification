% SIMCA Classification in MATLAB with External Predictions

clc; clear; close all;
load('dataset_cell_line_classification_motility_features.mat');
%% Fissare il seed per avere sempre la stessa randomizzazione
rng(42); % Puoi cambiare il numero se vuoi una randomizzazione diversa ma costante
% Randomizzazione dei dati e delle classi mantenendo la corrispondenza
idx = randperm(size(M,1)); % Genera una permutazione casuale fissa
datiR = M(idx, :);         % Riordina i dati
classiR = Y(idx, :);       % Riordina le classi

% Normalizza il training set
[trainX_norm, mu, sigma] = zscore(datiR); 

% Normalizza il test set usando la stessa media e deviazione standard
testX_norm = (datiR - mu) ./ sigma;

% Divisione in Training (90%) e Test (10%) STANDARDIZZATI
nTrain2 = round(0.90 * size(datiR,1)); % Calcola 80% delle righe
traindati2_norm = trainX_norm(1:nTrain2, :);
trainclassi2 = classiR(1:nTrain2, :);
testdati2_norm = testX_norm(nTrain2+1:end, :);
testclassi2 = classiR(nTrain2+1:end, :);

%% SIMCA Classification in MATLAB with External Predictions

% Caricamento dei file di output della SIMCA
pred_classe1 = load('pred1.mat');
pred_classe2 = load('pred2.mat');
pred_classe3 = load('pred3.mat');

% Estrarre i dati dai file utilizzando il campo corretto
field_names1 = fieldnames(pred_classe1);
field_names2 = fieldnames(pred_classe2);
field_names3 = fieldnames(pred_classe3);

pred_class1 = pred_classe1.(field_names1{1});
pred_class2 = pred_classe2.(field_names2{1});
pred_class3 = pred_classe3.(field_names3{1});

if ~exist('testclassi2', 'var')
    error('Il vettore delle classi reali non è presente nel workspace. Assicurati di caricare il dataset correttamente.');
end

% Convertire real_classes in una matrice Nx3 con codifica one-hot
n_test = length(testclassi2);
testclassi2_one_hot = zeros(n_test, 3);
for i = 1:n_test
    testclassi2_one_hot(i, testclassi2(i)) = 1;
end


% Creazione delle matrici per le classi predette
n_test = length(pred_class1);
predicted_classes = zeros(n_test, 3);

% Assegnazione delle classi predette
predicted_classes(:, 1) = pred_class1;
predicted_classes(:, 2) = pred_class2;
predicted_classes(:, 3) = pred_class3;

% Creazione di una tabella con i risultati
results_table = table((1:n_test)', testclassi2_one_hot, predicted_classes, 'VariableNames', {'Sample', 'testclassi2', 'Predicted_Class'});

disp(results_table);

% Calcolo di accuracy, precision, recall per ogni classe
for class_id = 1:3
    TP = sum(predicted_classes(:, class_id) == 1 &  testclassi2_one_hot(:, class_id) == 1);
    FP = sum(predicted_classes(:, class_id) == 1 &  testclassi2_one_hot(:, class_id) == 0);
    FN = sum(predicted_classes(:, class_id) == 0 &  testclassi2_one_hot(:, class_id) == 1);
    TN = sum(predicted_classes(:, class_id) == 0 &  testclassi2_one_hot(:, class_id) == 0);
    
    accuracy = (TP + TN) / (TP + FP + FN + TN);
    precision = TP / (TP + FP);
    recall = TP / (TP + FN);
    
    
    fprintf('Class %d - Accuracy: %.2f, Precision: %.2f, Recall: %.2f', class_id, accuracy, precision, recall);
end


%% Creazione di una tabella con i risultati formattati per una migliore leggibilità

disp('Risultati della Classificazione SIMCA:');
formatted_table = table((1:n_test)', testclassi2, predicted_classes, 'VariableNames', {'Sample', 'Real_Class', 'Predicted_Class'});
head(formatted_table, 20) % Mostra solo le prime 20 righe

% Calcolo della matrice di confusione personalizzata
conf_matrix = zeros(3, 4); % 3 classi reali, 4 categorie di assegnazione (1, 2, 3, multipla)

for i = 1:n_test
    real_class = find(testclassi2_one_hot(i, :) == 1);
    assigned_classes = find(predicted_classes(i, :) == 1);
    
    if length(assigned_classes) == 1
        conf_matrix(real_class, assigned_classes) = conf_matrix(real_class, assigned_classes) + 1;
    else
        conf_matrix(real_class, 4) = conf_matrix(real_class, 4) + 1; % Categoria multipla
    end
end

% Visualizzazione della matrice di confusione con miglior formattazione
disp('Matrice di Confusione Personalizzata:');
conf_table = array2table(conf_matrix, 'VariableNames', {'Classe_1', 'Classe_2', 'Classe_3', 'Multipla'}, 'RowNames', {'Normali', 'Neoplastiche', 'Metastatiche'});
disp(conf_table);

% Grafico migliorato della distribuzione delle classificazioni SIMCA
figure;
bar(conf_matrix, 'stacked');
legend({'Classe 1', 'Classe 2', 'Classe 3', 'Multipla'}, 'Location', 'Best');
xlabel('Classe Reale');
ylabel('Numero di Campioni');
title('Distribuzione delle Classificazioni SIMCA');
grid on;
set(gca, 'XTickLabel', {'Normali', 'Neoplastiche', 'Metastatiche'});



% Analisi dell'errore di classificazione multipla
multi_classifications = sum(conf_matrix(:, 4));
total_samples = sum(conf_matrix, 'all');
percentage_multi = (multi_classifications / total_samples) * 100;

fprintf('\nPercentuale di assegnazioni multiple: %.2f%%\n', percentage_multi);

% Report finale migliorato
disp('----------------------------');
disp(' Riepilogo Classificazione ');
disp('----------------------------');
for class_id = 1:3
    TP = sum(predicted_classes(:, class_id) == 1 & testclassi2_one_hot(:, class_id) == 1);
    FP = sum(predicted_classes(:, class_id) == 1 & testclassi2_one_hot(:, class_id) == 0);
    FN = sum(predicted_classes(:, class_id) == 0 & testclassi2_one_hot(:, class_id) == 1);
    
    accuracy = TP / (TP + FP + FN);
    precision = TP / (TP + FP);
    recall = TP / (TP + FN);
    
    fprintf('Classe %d - Accuracy: %.2f | Precision: %.2f | Recall: %.2f\n', class_id, accuracy, precision, recall);
end

disp('----------------------------');
