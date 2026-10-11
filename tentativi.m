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


%% LDA su diverse divisioni dei dati (80/20, 90/10, 50/50) STANDARDIZZATI

% Definiamo le percentuali di training
trainSizes = [0.80, 0.90, 0.50];
trainDataList = {traindati1_norm, traindati2_norm, traindati3_norm};
testDataList = {testdati1_norm, testdati2_norm, testdati3_norm};
trainClassList = {trainclassi1, trainclassi2, trainclassi3};
testClassList = {testclassi1, testclassi2, testclassi3};

for i = 1:length(trainSizes)
    % Prendiamo il dataset corrispondente alla percentuale di training
    traindati = trainDataList{i};
    testdati = testDataList{i};
    trainclassi = trainClassList{i};
    testclassi = testClassList{i};
    
    % Addestriamo il modello LDA
    MdlLDA = fitcdiscr(traindati, trainclassi);

    % Predizione sul test set
    Ypred = predict(MdlLDA, testdati);

    % Calcoliamo la matrice di confusione
    [C, order] = confusionmat(testclassi, Ypred);

    % Calcoliamo l'accuratezza
    accuracy = sum(diag(C)) / sum(C(:));
    disp(['Accuratezza LDA con Training al ', num2str(trainSizes(i)*100), '%: ', num2str(accuracy)]);

    % Visualizziamo la matrice di confusione
    figure;
    confusionchart(C, order);
    title(['Matrice di Confusione LDA (Train ', num2str(trainSizes(i)*100), '%)']);
    
    % Calcoliamo i discriminant scores per la visualizzazione
    ldaScores = testdati * MdlLDA.Coeffs(1,2).Linear;
    
    % Assicuriamoci che ci siano almeno 2 componenti (per 3 classi)
    if size(MdlLDA.Coeffs,1) > 2
        ldaScores = testdati * [MdlLDA.Coeffs(1,2).Linear, MdlLDA.Coeffs(2,3).Linear];
    end
    
    % Visualizziamo i dati nei primi due discriminant scores
    figure;
    gscatter(ldaScores(:,1), ldaScores(:,2), testclassi);
    xlabel('LD1 - Prima Componente Discriminante');
    ylabel('LD2 - Seconda Componente Discriminante');
    title(['Visualizzazione LDA Scores (Test ', num2str(trainSizes(i)*100), '%)']);
    grid on;
end


%% LDA su diverse divisioni dei dati (80/20, 90/10, 50/50) - SENZA NORMALIZZAZIONE

% Definiamo le percentuali di training
trainSizes = [0.80, 0.90, 0.50];
trainDataList = {traindati1, traindati2, traindati3};  % Dati NON normalizzati
testDataList = {testdati1, testdati2, testdati3};      % Dati NON normalizzati
trainClassList = {trainclassi1, trainclassi2, trainclassi3};
testClassList = {testclassi1, testclassi2, testclassi3};

for i = 1:length(trainSizes)
    % Prendiamo il dataset corrispondente alla percentuale di training
    traindati = trainDataList{i};
    testdati = testDataList{i};
    trainclassi = trainClassList{i};
    testclassi = testClassList{i};
    
    % Addestriamo il modello LDA
    MdlLDA = fitcdiscr(traindati, trainclassi);

    % Predizione sul test set
    Ypred = predict(MdlLDA, testdati);

    % Calcoliamo la matrice di confusione
    [C, order] = confusionmat(testclassi, Ypred);

    % Calcoliamo l'accuratezza
    accuracy = sum(diag(C)) / sum(C(:));
    disp(['Accuratezza LDA (senza normalizzazione) con Training al ', num2str(trainSizes(i)*100), '%: ', num2str(accuracy)]);

    % Visualizziamo la matrice di confusione
    figure;
    confusionchart(C, order);
    title(['Matrice di Confusione LDA (No Normalizzazione, Train ', num2str(trainSizes(i)*100), '%)']);
    
    % Calcoliamo i discriminant scores per la visualizzazione
    ldaScores = testdati * MdlLDA.Coeffs(1,2).Linear;
    
    % Assicuriamoci che ci siano almeno 2 componenti (per 3 classi)
    if size(MdlLDA.Coeffs,1) > 2
        ldaScores = testdati * [MdlLDA.Coeffs(1,2).Linear, MdlLDA.Coeffs(2,3).Linear];
    end
    
    % Visualizziamo i dati nei primi due discriminant scores
    figure;
    gscatter(ldaScores(:,1), ldaScores(:,2), testclassi);
    xlabel('LD1 - Prima Componente Discriminante');
    ylabel('LD2 - Seconda Componente Discriminante');
    title(['Visualizzazione LDA Scores (No Normalizzazione, Train ', num2str(trainSizes(i)*100), '%)']);
    grid on;
end



%% test per verificare la scala delle features
format long g
disp('Media e deviazione standard delle feature originali:');
disp([mean(traindati1); std(traindati1)]);

%%
format long g
disp('Prima riga dei dati originali:');
disp(traindati1(1,:));

disp('Prima riga dei dati normalizzati:');
disp(traindati1_norm(1,:));


%%
format long g
disp('Matrice di covarianza dati originali:');
disp(cov(traindati1));

disp('Matrice di covarianza dati normalizzati:');
disp(cov(traindati1_norm));
clear all; clc;
load('dataset_cell_line_classification_motility_features.mat'); % Ricarica il file
whos  % Mostra le variabili caricate

%%
format long;
disp('Prime righe di M prima della randomizzazione:');
disp(M(1:5, :));

%%
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

