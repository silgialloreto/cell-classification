%% 
clc ; close all ; clear all ;
load('dataset_cell_line_classification_motility_features.mat')

%% Fissare il seed per avere sempre la stessa randomizzazione
rng(42); % Puoi cambiare il numero se vuoi una randomizzazione diversa ma costante
% Randomizzazione dei dati e delle classi mantenendo la corrispondenza
idx = randperm(size(M,1)); % Genera una permutazione casuale fissa
datiR = M(idx, :);         % Riordina i dati
classiR = Y(idx, :);       % Riordina le classi
%% Divisione in Training (80%) e Test (20%)
nTrain1 = round(0.80 * size(datiR,1)); % Calcola 80% delle righe
traindati1 = datiR(1:nTrain1, :);
trainclassi1 = classiR(1:nTrain1, :);
testdati1 = datiR(nTrain1+1:end, :);
testclassi1 = classiR(nTrain1+1:end, :);
class_gui; % Richiama la GUI per la classificazione
%% Divisione in Training (90%) e Test (10%)
nTrain2 = round(0.90 * size(datiR,1)); % Calcola 90% delle righe
traindati2 = datiR(1:nTrain2, :);
trainclassi2 = classiR(1:nTrain2, :);
testdati2 = datiR(nTrain2+1:end, :);
testclassi2 = classiR(nTrain2+1:end, :);
class_gui; % Richiama la GUI per la classificazione
%% Divisione in Training (50%) e Test (50%)
nTrain3 = round(0.50 * size(datiR,1)); % Calcola 50% delle righe
traindati3 = datiR(1:nTrain3, :);
trainclassi3 = classiR(1:nTrain3, :);
testdati3 = datiR(nTrain3+1:end, :);
testclassi3 = classiR(nTrain3+1:end, :);
class_gui; % Richiama la GUI per la classificazione
 
%% normalizzazione
% Normalizza il training set
[trainX_norm, mu, sigma] = zscore(datiR); 

% Normalizza il test set usando la stessa media e deviazione standard
testX_norm = (datiR - mu) ./ sigma;

%% Divisione in Training (80%) e Test (20%) STANDARDIZZATI
nTrain1 = round(0.80 * size(datiR,1)); % Calcola 80% delle righe
traindati1_norm = trainX_norm(1:nTrain1, :);
trainclassi1 = classiR(1:nTrain1, :);
testdati1_norm = testX_norm(nTrain1+1:end, :);
testclassi1 = classiR(nTrain1+1:end, :);
class_gui; % Richiama la GUI per la classificazione

%% Divisione in Training (90%) e Test (10%)  STANDARDIZZATI
nTrain2 = round(0.90 * size(datiR,1)); % Calcola 90% delle righe
traindati2_norm = trainX_norm(1:nTrain2, :);
trainclassi2 = classiR(1:nTrain2, :);
testdati2_norm = testX_norm(nTrain2+1:end, :);
testclassi2 = classiR(nTrain2+1:end, :);
class_gui; % Richiama la GUI per la classificazione

%% Divisione in Training (50%) e Test (50%)  STANDARDIZZATI
nTrain3 = round(0.50 * size(datiR,1)); % Calcola 50% delle righe
traindati3_norm = trainX_norm(1:nTrain3, :);
trainclassi3 = classiR(1:nTrain3, :);
testdati3_norm = testX_norm(nTrain3+1:end, :);
testclassi3 = classiR(nTrain3+1:end, :);
class_gui; % Richiama la GUI per la classificazione


%%
pca_gui;

%% istogrammi

figure;
for i = 1:size(M,2)
    subplot(ceil(sqrt(size(M,2))), ceil(sqrt(size(M,2))), i);
    hold on;
    for class = unique(Y)'
        histogram(M(Y==class, i), 'Normalization', 'pdf'); % Normalizzazione PDF
    end
    title(['Feature ', num2str(i)]);
    hold off;
end


%% calcola fscore
num_features = size(M,2);
f_score = zeros(1, num_features);
for i = 1:num_features
    mu_total = mean(M(:,i));
    classes = unique(Y);
    num_classes = length(classes);
    
    var_inter = 0;
    var_intra = 0;
    
    for c = 1:num_classes
        class_data = M(Y == classes(c), i);
        mu_c = mean(class_data);
        var_c = var(class_data);
        var_inter = var_inter + length(class_data) * (mu_c - mu_total)^2;
        var_intra = var_intra + (length(class_data) - 1) * var_c;
    end
    
    f_score(i) = var_inter / (var_intra + eps); % eps per evitare divisione per zero
end

[~, idx_sorted_fisher] = sort(f_score, 'descend');
disp('Feature ordinate per F-score:');
disp(idx_sorted_fisher);


%% Caricamento dati
load('dataset_cell_line_classification_motility_features.mat'); % Assicurati che il dataset sia caricato correttamente

%% Calcolo dell'F-score per ogni feature
num_features = size(M, 2);
F_scores = zeros(1, num_features);

for i = 1:num_features
    classes = unique(Y);
    mu_total = mean(M(:, i));
    var_total = var(M(:, i));
    
    num = 0; % Numeratore (varianza tra classi)
    den = 0; % Denominatore (varianza intra-classe)

    for c = 1:length(classes)
        idx = (Y == classes(c));
        mu_c = mean(M(idx, i));
        var_c = var(M(idx, i));
        n_c = sum(idx);
        
        num = num + n_c * (mu_c - mu_total)^2;
        den = den + (n_c - 1) * var_c;
    end

    F_scores(i) = num / den; % Calcolo F-score
end

% Controllo output
disp('F-score per ogni feature:');
disp(F_scores);

%% Selezione delle top 10 o 15 feature
[~, sorted_indices] = sort(F_scores, 'descend'); % Ordina per F-score
top_features = sorted_indices(1:15); % Cambia in 1:15 per le top 15

disp('Top feature selezionate:');
disp(top_features);


%% Selezione delle top  15 feature
[~, sorted_indices] = sort(F_scores, 'descend'); % Ordina per F-score decrescente
top_features = sorted_indices(1:15); % Cambia in 1:15 per le top 15

% Creazione di nuovo dataset con solo le feature selezionate
M_selected = M(:, top_features);

% Divisione in Training e Test Set (80/20)
rng(42); % Per riproducibilità
idx = randperm(size(M_selected, 1));
nTrain = round(0.80 * size(M_selected, 1));

dati1_train = M_selected(idx(1:nTrain), :);
classi1_train = Y(idx(1:nTrain), :);
dati1_test = M_selected(idx(nTrain+1:end), :);
classi1_test = Y(idx(nTrain+1:end), :);

% Addestramento modello (LDA)
Mdl = fitcdiscr(dati1_train, classi1_train); % LDA

% Predizione sul Test Set
Y_pred = predict(Mdl, dati1_test);

% Calcolo dell'accuratezza
accuracy = sum(Y_pred == classi1_test) / length(classi1_test);
disp(['Accuratezza del modello con le top 15 feature: ', num2str(accuracy)]);

% Matrice di confusione
figure;
confusionchart(classi1_test, Y_pred);
title('Matrice di Confusione con le top 15 feature');


%% ripeto con dati standardizzati
% Standardizzazione dei dati
[Z, mu, sigma] = zscore(M); % Standardizzazione: media 0, deviazione standard 1

% Selezione delle top 15 feature
[~, sorted_indices] = sort(F_scores, 'descend'); % Ordina per F-score decrescente
top_features = sorted_indices(1:15); % Cambia in 1:15 per le top 15

% Creazione di nuovo dataset con solo le feature selezionate
Z_selected = Z(:, top_features);

% Divisione in Training e Test Set (80/20)
rng(42); % Per riproducibilità
idx = randperm(size(Z_selected, 1));
nTrain = round(0.80 * size(Z_selected, 1));

dati1_train_norm = Z_selected(idx(1:nTrain), :);
classi1_train_norm = Y(idx(1:nTrain), :);
dati1_test_norm = Z_selected(idx(nTrain+1:end), :);
classi1_test_norm = Y(idx(nTrain+1:end), :);

% Addestramento modello (LDA)
Mdl = fitcdiscr(dati1_train_norm, classi1_train_norm); % LDA

% Predizione sul Test Set
Y_pred_norm = predict(Mdl, dati1_test_norm);

% Calcolo dell'accuratezza
accuracy = sum(Y_pred_norm == classi1_test_norm) / length(classi1_test_norm);
disp(['Accuratezza del modello con le top 15 feature standardizzate: ', num2str(accuracy)]);

% Matrice di confusione
figure;
confusionchart(classi1_test_norm, Y_pred_norm);
title('Matrice di Confusione con le top 15 feature standardizzate');


%% istogrammi correlazione
% Numero di feature per finestra
num_features_per_fig = 5;
num_figs = ceil(length(top_features) / num_features_per_fig);

% Definizione dei colori per le classi
colors = {'r', 'g', 'b'}; % Rosso, Verde, Blu

for f = 1:num_figs
    figure; % Crea una nuova finestra di visualizzazione
    start_idx = (f-1) * num_features_per_fig + 1;
    end_idx = min(f * num_features_per_fig, length(top_features));

    for i = start_idx:end_idx
        subplot(ceil(num_features_per_fig/2), 2, i - start_idx + 1); % Organizza la visualizzazione
        hold on;

        % Creazione di un istogramma per ogni classe
        for class_idx = 1:3
            class_data = Z(Y == class_idx, top_features(i)); % Seleziona i dati per la classe
            histogram(class_data, 20, 'Normalization', 'pdf', 'FaceColor', colors{class_idx}, 'FaceAlpha', 0.5);
        end
        
        hold off;
        title(['Feature ', num2str(top_features(i))]);
        xlabel('Valore normalizzato');
        ylabel('Densità');
        legend({'Classe 1', 'Classe 2', 'Classe 3'}); % Legenda con le classi
    end
    sgtitle(['Distribuzione delle Feature (Finestra ', num2str(f), ')']); % Titolo della finestra
end

%% correlazione features e classi (numerico)
num_classes = length(unique(Y));
correlation_matrix = zeros(length(top_features), num_classes);

for c = 1:num_classes
    class_mask = (Y == c); % Crea un vettore binario: 1 per la classe, 0 per le altre
    for i = 1:length(top_features)
        correlation_matrix(i, c) = corr(Z(:, top_features(i)), class_mask, 'type', 'Spearman'); % Correlazione Spearman
    end
end

% Stampare i risultati
disp('Correlazione tra le feature e le classi:');
disp(array2table(correlation_matrix, 'VariableNames', {'Classe_1', 'Classe_2', 'Classe_3'}, 'RowNames', arrayfun(@num2str, top_features, 'UniformOutput', false)));

%% lda solo con features selezionate 
% Standardizzazione dei dati
[Z, mu, sigma] = zscore(M); % Standardizzazione: media 0, deviazione standard 1

% Selezione delle feature specificate manualmente
selected_features = [9, 13, 14, 8, 32, 15, 16, 19]; 
Z_selected = Z(:, selected_features); % Estrai solo le feature selezionate

% Divisione in Training e Test Set (80/20)
rng(42); % Per riproducibilità
idx = randperm(size(Z_selected, 1)); % Shuffle degli indici
nTrain = round(0.80 * size(Z_selected, 1)); % 80% Training, 20% Test

% Creazione dei dataset normalizzati per Training e Test
dati1_train_norm = Z_selected(idx(1:nTrain), :);
classi1_train_norm = Y(idx(1:nTrain), :);
dati1_test_norm = Z_selected(idx(nTrain+1:end), :);
classi1_test_norm = Y(idx(nTrain+1:end), :);

% Addestramento modello (LDA)
Mdl = fitcdiscr(dati1_train_norm, classi1_train_norm); % LDA

% Predizione sul Test Set
Y_pred_norm = predict(Mdl, dati1_test_norm);

% Calcolo dell'accuratezza
accuracy = sum(Y_pred_norm == classi1_test_norm) / length(classi1_test_norm);
disp(['Accuratezza del modello con le feature selezionate: ', num2str(accuracy)]);

% Matrice di confusione
figure;
confusionchart(classi1_test_norm, Y_pred_norm);
title('Matrice di Confusione con le feature selezionate');


%% istogrammi solo con features selezionate

% Definisci le feature che vuoi visualizzare (inserisci gli indici delle colonne di M/Z)
selected_features = [9, 13, 14, 8, 32, 15, 16, 19];  % <-- MODIFICA QUI

% Numero di feature per ogni figura
num_features_per_fig = 5;
num_figs = ceil(length(selected_features) / num_features_per_fig);

% Definizione dei colori per le classi
colors = {'r', 'g', 'b'}; % Rosso, Verde, Blu

for f = 1:num_figs
    figure; % Crea una nuova finestra di visualizzazione
    start_idx = (f-1) * num_features_per_fig + 1;
    end_idx = min(f * num_features_per_fig, length(selected_features));

    for i = start_idx:end_idx
        subplot(ceil(num_features_per_fig/2), 2, i - start_idx + 1); % Organizza la visualizzazione
        hold on;

        % Creazione di un istogramma per ogni classe
        for class_idx = 1:3
            class_data = Z(Y == class_idx, selected_features(i)); % Seleziona i dati per la classe
            histogram(class_data, 20, 'Normalization', 'pdf', 'FaceColor', colors{class_idx}, 'FaceAlpha', 0.5);
        end
        
        hold off;
        title(['Feature ', num2str(selected_features(i))]);
        xlabel('Valore normalizzato');
        ylabel('Densità');
        legend({'Classe 1', 'Classe 2', 'Classe 3'}); % Legenda con le classi
    end
    sgtitle(['Distribuzione delle Feature (Finestra ', num2str(f), ')']); % Titolo della finestra
end
