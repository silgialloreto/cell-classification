%%
clc; clear; close all;  
load('C:\Users\silgi\Desktop\Progetto Pattern\dataset_cell_line_classification_motility_features.mat');  
% Controlla la struttura dei dati
disp('Dimensioni del dataset:');
disp(['M (feature): ', num2str(size(M,1)), ' campioni x ', num2str(size(M,2)), ' feature']);
disp(['Y (classi): ', num2str(length(Y)), ' campioni']);

%% controllo dati
format long g  % Evita la notazione scientifica

max_values = max(M);  % Massimo per colonna
min_values = min(M);  % Minimo per colonna
avg_values = mean(M); % Media per colonna

disp('Min, Max e Media per ogni colonna:');

% Inizializza i valori min e max delle medie
avg_max = -Inf;
avg_min = Inf;

for i = 1:size(M,2)
    % Aggiorna il massimo e il minimo delle medie
    if avg_values(i) > avg_max
        avg_max = avg_values(i);
    end
    if avg_values(i) < avg_min
        avg_min = avg_values(i);
    end
    
    % Stampa i valori per la colonna corrente
    fprintf('Feature %d\n', i);
    fprintf('  Min: %f\n', min_values(i));
    fprintf('  Max: %f\n', max_values(i));
    fprintf('  Avg: %f\n\n', avg_values(i));
end

% Stampa il minimo e il massimo delle medie
fprintf('Minimo tra le medie: %f\n', avg_min);
fprintf('Massimo tra le medie: %f\n', avg_max);

%% correlazione features
% Numero di feature
numFeatures = size(M, 2);

% Inizializza il vettore delle correlazioni
correlations = zeros(1, numFeatures);

% Calcola la correlazione di Pearson per ogni feature con il target
for i = 1:numFeatures
    correlations(i) = corr(M(:, i), Y, 'Rows', 'complete');
end

% Applica la funzione sigmoide e scala in percentuale
sigmoidCorrelation = 100 ./ (1 + exp(-correlations));

% Stampa tutte le correlazioni trasformate con la sigmoide
fprintf('Correlazioni tra le feature e il target (trasformate con la sigmoide, in percentuale):\n');
for i = 1:numFeatures
    fprintf('Feature %2d: Correlazione Sigmoide = %.2f%%\n', i, sigmoidCorrelation(i));
end

% Trova la feature più correlata dopo la trasformazione
[~, bestFeatureIdx] = max(sigmoidCorrelation);

% Mostra la feature più correlata
fprintf('\nLa feature più correlata con il target è la colonna %d (correlazione sigmoide = %.2f%%)\n', ...
        bestFeatureIdx, sigmoidCorrelation(bestFeatureIdx));

% Grafico della correlazione sigmoide per tutte le feature
figure;
bar(sigmoidCorrelation);
xlabel('Feature Index');
ylabel('Correlazione Sigmoide (%)');
title('Correlazione Sigmoide tra Feature e Target');
grid on;
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
%% normalizzo
% Normalizza il training set
[trainX_norm, mu, sigma] = zscore(datiR); 

% Normalizza il test set usando la stessa media e deviazione standard
testX_norm = (datiR - mu) ./ sigma;

%% Divisione in Training (50%) e Test (50%) STANDARDIZZATI
nTrain1 = round(0.50 * size(datiR,1)); % Calcola 80% delle righe
traindati1_norm = trainX_norm(1:nTrain1, :);
trainclassi1 = classiR(1:nTrain1, :);
testdati1_norm = testX_norm(nTrain1+1:end, :);
testclassi1 = classiR(nTrain1+1:end, :);
class_gui; % Richiama la GUI per la classificazione

%% rimuivi features
% Indici delle feature da rimuovere
featuresToRemove = [2, 4, 6, 7, 11, 12, 13, 15, 16, 31, 36, 38, 39];
% Verifica che gli indici siano validi
if any(featuresToRemove > size(M, 2)) || any(featuresToRemove < 1)
    error('Uno o più indici delle feature da rimuovere non sono validi.');
end
% Crea il nuovo dataset senza le feature specificate
M_new = M;
M_new(:, featuresToRemove) = [];
% Stampa informazioni
fprintf('Le feature [%s] sono state rimosse. Il nuovo dataset ha dimensione %dx%d.\n', ...
        num2str(featuresToRemove), size(M_new,1), size(M_new,2));
% Salva il nuovo dataset in un file .mat
save('dataset_senza_features_selezionate.mat', 'M_new', 'Y');
% Conferma il salvataggio
fprintf('Il nuovo dataset è stato salvato come "dataset_senza_features_selezionate.mat".\n');

%% Fissare il seed per avere sempre la stessa randomizzazione
rng(42); % Seed per randomizzazione riproducibile
% Randomizzazione dei dati e delle classi mantenendo la corrispondenza
idx = randperm(size(M_new,1)); % Genera una permutazione casuale fissa
datiR = M_new(idx, :);         % Riordina i dati
classiR = Y(idx, :);           % Riordina le classi
%% Divisione in Training (80%) e Test (20%)
nTrain1 = round(0.80 * size(datiR,1)); % Calcola 80% delle righe
traindati1 = datiR(1:nTrain1, :);
trainclassi1 = classiR(1:nTrain1, :);
testdati1 = datiR(nTrain1+1:end, :);
testclassi1 = classiR(nTrain1+1:end, :);
class_gui; % Richiama la GUI per la classificazione