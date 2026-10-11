% ============================
% SCRIPT: train_test_split.m
% Divisone del dataset in training e test
% ============================

clc; clear; close all;  % Pulisce la memoria, la command window e chiude eventuali figure

% Caricare il dataset (assicurati che il file sia nella cartella di lavoro)
load('C:\Users\silgi\Desktop\Progetto Pattern\dataset_cell_line_classification_motility_features.mat');  % Sostituisci con il nome corretto del file

% Controlla la struttura dei dati
disp('Dimensioni del dataset:');
disp(['M (feature): ', num2str(size(M,1)), ' campioni x ', num2str(size(M,2)), ' feature']);
disp(['Y (classi): ', num2str(length(Y)), ' campioni']);

% Divisione in Training (80%) e Test (20%)
cv = cvpartition(size(M,1), 'HoldOut', 0.2); % 80% training, 20% test

% Indici dei dati di training e test
train_idx = training(cv);
test_idx = test(cv);

% Creazione dei set di training e test
trainX = M(train_idx, :);  % Feature di training
trainY = Y(train_idx);      % Classi di training
testX = M(test_idx, :);     % Feature di test
testY = Y(test_idx);        % Classi di test

% Controlla il bilanciamento delle classi
figure;
bar(unique(trainY), histc(trainY, unique(trainY)));
xlabel('Classi');
ylabel('Numero di campioni');
title('Distribuzione delle classi nel Training Set');

figure;
bar(unique(testY), histc(testY, unique(testY)));
xlabel('Classi');
ylabel('Numero di campioni');
title('Distribuzione delle classi nel Test Set');

% Salva i dati divisi per usarli nel Classification Toolbox
save('train_test_data.mat', 'trainX', 'trainY', 'testX', 'testY');

disp('Divisione in Training e Test completata con successo!');
disp('Dati salvati in train_test_data.mat');

%%
% Normalizza il training set
[trainX_norm, mu, sigma] = zscore(trainX); 

% Normalizza il test set usando la stessa media e deviazione standard
testX_norm = (testX - mu) ./ sigma;
%% test se i dati sono gaussiani
figure;
for i = 1:min(10, size(trainX_norm,2)) % Mostra i primi 10 istogrammi
    subplot(2,5,i);
    histogram(trainX_norm(:,i), 30);
    title(['Feature ', num2str(i)]);
end
sgtitle('Distribuzione delle Feature');

%% test di normalità, se p<0.5 feature non normale 
for i = 1:size(trainX_norm,2)
    [h, p] = kstest((trainX_norm(:,i) - mean(trainX_norm(:,i))) / std(trainX_norm(:,i))); 
    if h == 1
        disp(['Feature ', num2str(i), ' NON segue una distribuzione normale (p = ', num2str(p), ')']);
    else
        disp(['Feature ', num2str(i), ' segue una distribuzione normale (p = ', num2str(p), ')']);
    end
end
% non seguono distribuzione gaussiana, allora uso t-sne

%% t-SNE
Y_tsne_train = tsne(trainX_norm, 'NumDimensions', 2, 'Perplexity', 30, 'Standardize', true);
Y_tsne_test = tsne(testX_norm, 'NumDimensions', 2, 'Perplexity', 30, 'Standardize', true);
figure;
gscatter(Y_tsne_train(:,1), Y_tsne_train(:,2), trainY, 'bgr', 'o', 8);
xlabel('t-SNE Component 1');
ylabel('t-SNE Component 2');
title('Visualizzazione t-SNE del Training Set');
legend('RWPE1', 'LnCAP', 'PC3');
grid on;

%% LDA
lda_model = fitcdiscr(trainX_norm, trainY);
predicted_lda = predict(lda_model, testX_norm);
accuracy_lda = sum(predicted_lda == testY) / length(testY);
disp(['Accuratezza LDA senza t-SNE: ', num2str(accuracy_lda)]);

cm = confusionmat(testY, predicted_lda);
confusionchart(cm);
title('Matrice di Confusione per LDA senza t-SNE');

%% visualizzo LDA
[trainX_lda, ~] = lda(trainX_norm, trainY, 2); % Forza LDA a restituire due componenti

figure;
gscatter(trainX_lda(:,1), trainX_lda(:,2), trainY, 'bgr', 'o', 8);
xlabel('LDA Component 1');
ylabel('LDA Component 2');
title('Visualizzazione 2D delle classi con LDA forzato');
legend('RWPE1', 'LnCAP', 'PC3');
grid on;



%% provo features 5 e 26
figure;
gscatter(trainX_norm(:,5), trainX_norm(:,26), trainY, 'bgr', 'o', 8);
xlabel('Feature 5');
ylabel('Feature 26');
title('Distribuzione delle classi rispetto alle feature più discriminanti');
legend('RWPE1', 'LnCAP', 'PC3');
grid on;

%%
lda_model_reduced = fitcdiscr(trainX_norm(:,[5,26]), trainY);
predicted_lda_reduced = predict(lda_model_reduced, testX(:,[5,26]));

accuracy_lda_reduced = sum(predicted_lda_reduced == testY) / length(testY);
disp(['Accuratezza LDA usando solo Feature 5 e 26: ', num2str(accuracy_lda_reduced)]);



%% feature piu imp
% 🔹 Ordina le feature in base al contributo alla prima componente principale
[~, sortedIdx] = sort(abs(coeff(:,1)), 'descend');

% 🔹 Mostra le prime 20 feature più importanti
disp('Le 20 feature più importanti per PCA:');
disp(sortedIdx(1:20));  % Indici delle feature più rilevanti

%% 🔹 Mostra la varianza spiegata da ogni componente
figure;
plot(cumsum(explained), 'o-');
xlabel('Numero di Componenti');
ylabel('Varianza cumulativa spiegata (%)');
title('Varianza spiegata da PCA');
grid on;

%% 🔹 Somma l'importanza di ogni feature su tutte le componenti
featureImportance = sum(abs(coeff(:, 1:numComponents)), 2);

% 🔹 Ordina le feature più informative
[~, sortedFeatureIdx] = sort(featureImportance, 'descend');

% 🔹 Mostra le prime 20 feature più influenti
disp('Le feature più importanti considerando tutte le componenti:');
disp(sortedFeatureIdx(1:20));

%%
% 🔹 Seleziona le feature più informative con MRMR (Minimum Redundancy Maximum Relevance)
[idx, scores] = fscmrmr(trainX_norm, trainY);

% 🔹 Mostra le prime 10 feature più importanti
disp('Le 20 feature più importanti secondo MRMR:');
disp(idx(1:20));
