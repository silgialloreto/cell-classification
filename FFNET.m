clear all; close all;  clc;
load("dataset_cell_line_classification_motility_features.mat")
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
%% Normalizzazione Min-Max tra [0,1]
datiR_min = min(datiR);
datiR_max = max(datiR);
M_norm = (datiR - datiR_min) ./ (datiR_max - datiR_min);
% Creazione del nuovo dataset normalizzato
M_normalized_dataset = M_norm;
%% Divisione in Training (80%) e Test (20%)
nTrain1_norm = round(0.80 * size(M_normalized_dataset,1)); % Calcola 80% delle righe
traindati1_norm = M_normalized_dataset(1:nTrain1_norm, :);
trainclassi1 = classiR(1:nTrain1_norm, :);
testdati1_norm = M_normalized_dataset(nTrain1_norm+1:end, :);
testclassi1 = classiR(nTrain1_norm+1:end, :);
class_gui; % Richiama la GUI per la classificazione
%% Divisione in Training (90%) e Test (10%)
nTrain2_norm = round(0.90 * size(M_normalized_dataset,1)); % Calcola 90% delle righe
traindati2_norm =M_normalized_dataset(1:nTrain2_norm, :);
trainclassi2 = classiR(1:nTrain2_norm, :);
testdati2_norm = M_normalized_dataset(nTrain2_norm+1:end, :);
testclassi2 = classiR(nTrain2_norm+1:end, :);
class_gui; % Richiama la GUI per la classificazione
%% Divisione in Training (50%) e Test (50%)
nTrain3_norm = round(0.50 * size(M_normalized_dataset,1)); % Calcola 50% delle righe
traindati3_norm = M_normalized_dataset(1:nTrain3_norm, :);
trainclassi3 = classiR(1:nTrain3_norm, :);
testdati3_norm = M_normalized_dataset(nTrain3_norm+1:end, :);
testclassi3 = classiR(nTrain3_norm+1:end, :);
class_gui; % Richiama la GUI per la classificazione

%% classificazione corretta
clc; clear; close all;

% CARICA I FILE .MAT
data_reali = load('reali.mat');  
data_predette = load('predette.mat');     

% ESTRAZIONE DELLE VARIABILI GIUSTE
classi_reali = data_reali.classi1_test_norm;  
classi_predette = data_predette.tmp_predicted_class_test;

% VERIFICA CHE ABBIANO LA STESSA DIMENSIONE
if length(classi_reali) ~= length(classi_predette)
    error('Errore: i due file devono avere lo stesso numero di campioni.');
end

% TROVA LE CLASSI UNICHE PRESENTI NELLE CLASSI REALI
classi_uniche = unique(classi_reali);
num_classi = length(classi_uniche);

% INIZIALIZZA I CONTATORI PER OGNI CLASSE
num_campioni_per_classe = zeros(size(classi_uniche)); % Totale campioni per classe
num_corretti_per_classe = zeros(size(classi_uniche)); % Classificazioni corrette
num_non_classificati = 0;  % Conta i campioni con classe predetta = 0

% INIZIALIZZA LA MATRICE DI CONFUSIONE (quanti campioni della classe i sono stati assegnati alla classe j)
conf_matrix = zeros(num_classi, num_classi);

% SCANSIONE CAMPIONE PER CAMPIONE
for i = 1:length(classi_reali)
    classe_reale = classi_reali(i);
    classe_predetta = classi_predette(i);
    
    % TROVA L'INDICE DELLA CLASSE NEL VETTORE classi_uniche
    idx_reale = find(classi_uniche == classe_reale);
    
    % AGGIORNA IL NUMERO TOTALE DI CAMPIONI PER QUELLA CLASSE
    num_campioni_per_classe(idx_reale) = num_campioni_per_classe(idx_reale) + 1;
    
    % SE LA PREDIZIONE È 0 (NON CLASSIFICATO)
    if classe_predetta == 0
        num_non_classificati = num_non_classificati + 1;
    
    % SE LA PREDIZIONE È CORRETTA
    elseif classe_predetta == classe_reale
        num_corretti_per_classe(idx_reale) = num_corretti_per_classe(idx_reale) + 1;
    
    % SE LA PREDIZIONE È ERRATA, AGGIORNA LA MATRICE DI CONFUSIONE
    else
        idx_predetta = find(classi_uniche == classe_predetta);
        conf_matrix(idx_reale, idx_predetta) = conf_matrix(idx_reale, idx_predetta) + 1;
    end
end

% CALCOLA LA PERCENTUALE DI CLASSIFICAZIONE CORRETTA PER OGNI CLASSE
percentuale_correttezza = (num_corretti_per_classe ./ num_campioni_per_classe) * 100;

% STAMPA I RISULTATI
disp('Percentuale di corretta classificazione per ciascuna classe:');
for j = 1:length(classi_uniche)
    fprintf('Classe %d: %.2f%%\n', classi_uniche(j), percentuale_correttezza(j));
end

% STAMPA QUANTI CAMPIONI NON SONO STATI CLASSIFICATI
fprintf('\nNumero di campioni non classificati (classe predetta = 0): %d\n', num_non_classificati);

% STAMPA LA MATRICE DI CONFUSIONE CON GLI ERRORI
disp('Numero di campioni classificati erroneamente da una classe all''altra:');
conf_table = array2table(conf_matrix, ...
    'VariableNames', strcat("Predetto_", string(classi_uniche)), ...
    'RowNames', strcat("Reale_", string(classi_uniche)));

disp(conf_table);

%%

load("Z_selected.mat");


% Divisione in Training e Test Set (80/20)
rng(42); % Per riproducibilità
idx = randperm(size(Z_selected, 1)); % Shuffle degli indici
nTrain = round(0.80 * size(Z_selected, 1)); % 80% Training, 20% Test

% Creazione dei dataset normalizzati per Training e Test
dati1_train_norm = Z_selected(idx(1:nTrain), :);
classi1_train_norm = Y(idx(1:nTrain), :);
dati1_test_norm = Z_selected(idx(nTrain+1:end), :);
classi1_test_norm = Y(idx(nTrain+1:end), :);

class_gui;