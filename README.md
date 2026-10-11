# Cell Classification – Riconoscimento cellulare da feature di motilità

Progetto del corso di **Pattern Recognition & Machine Learning** (A.A. 2024/2025)  
Autori: Silvia Gialloreto, Valerio Luzi

L'obiettivo è classificare tre linee cellulari di prostata a partire da feature che descrivono il **movimento delle cellule** (traiettorie in time-lapse):

| Classe (`Y`) | Linea cellulare | Tipo |
|:---:|---|---|
| 1 | RWPE1 | non neoplastica (sana) |
| 2 | LnCAP | neoplastica |
| 3 | PC3   | neoplastica metastatica |

Il punto critico dell'analisi è ridurre i casi in cui una cellula malata viene classificata come sana.

---

## Struttura della repository

```
cell-classification/
├── data/
│   ├── dataset_cell_line_classification_motility_features.mat   # dataset originale (M, Y, GTE)
│   ├── train_test_data.mat  # split 80/20 generato da train_e_test.m
│   └── Z_selected.mat       # dataset standardizzato con le 8 feature selezionate
├── scripts/
│   ├── train_e_test.m       # esplorazione: split, normalità, t-SNE, LDA, MRMR
│   ├── tentativi.m          # LDA su split 80/20, 90/10, 50/50 (dati grezzi e standardizzati)
│   ├── tentativi2.m         # correlazione feature/target, rimozione feature
│   ├── pca_simca.m          # PCA, F-score, feature selection, LDA sulle feature scelte
│   ├── simca.m              # valutazione dei risultati SIMCA esportati dalla GUI
│   └── FFNET.m              # rete feed-forward (BPNN) e analisi degli errori
├── toolboxes/
│   ├── classification_toolbox_6.0/   # Milano Chemometrics – class_gui
│   └── pca_toolbox_1.5/              # Milano Chemometrics – pca_gui
└── docs/
    ├── read_me_cell_line_classification.docx      # descrizione di variabili e feature
    ├── Learning_Cancer-Related_Drug_Efficacy.pdf  # articolo di riferimento
    └── Ppt PATTERN.pptx                           # slide con risultati e conclusioni
```

---

## Dataset

File: `data/dataset_cell_line_classification_motility_features.mat`

| Variabile | Dimensione | Descrizione |
|---|---|---|
| `M`   | 3268 × 39 | matrice delle misure: una riga per campione, una colonna per feature |
| `Y`   | 3268 × 1  | classe (1 = RWPE1, 2 = LnCAP, 3 = PC3) |
| `GTE` | 3268 × 1  | indice progressivo dell'esperimento (9 esperimenti, utile per la cross-validation) |

Distribuzione delle classi: 1454 campioni RWPE1 (44.5%), 720 LnCAP (22.0%), 1094 PC3 (33.5%).

<details>
<summary><b>Elenco delle 39 feature</b></summary>

| # | Feature |
|---:|---|
| 1 | Velocità lungo l'asse x |
| 2 | Persistenza della velocità lungo l'asse x |
| 3 | Velocità lungo l'asse y |
| 4 | Persistenza della velocità lungo l'asse y |
| 5 | Media della variazione di direzione tra un istante e il successivo |
| 6 | Persistenza del modulo della velocità |
| 7 | Persistenza della traiettoria (dopo smoothing) |
| 8 | Persistenza della variazione di direzione tra un istante e il successivo |
| 9 | Media del modulo della velocità |
| 10 | Deviazione standard del modulo della velocità |
| 11 | Skewness del modulo della velocità |
| 12 | Kurtosis del modulo della velocità |
| 13 | Entropia di Shannon del modulo della velocità |
| 14 | Media del modulo della velocità (derivate con differenze finite) |
| 15 | Media della curvatura |
| 16 | Deviazione standard della curvatura |
| 17 | Skewness della curvatura |
| 18 | Kurtosis della curvatura |
| 19 | Entropia di Shannon della curvatura |
| 20 | Media della velocità angolare |
| 21 | Deviazione standard della velocità angolare |
| 22 | Skewness della velocità angolare |
| 23 | Kurtosis della velocità angolare |
| 24 | Entropia di Shannon della velocità angolare |
| 25 | Logaritmo di 4 volte il coefficiente di diffusione |
| 26 | Media del turning angle |
| 27 | Deviazione standard del turning angle |
| 28 | Skewness del turning angle |
| 29 | Kurtosis del turning angle |
| 30 | Entropia di Shannon del turning angle |
| 31 | Persistenza della traiettoria (senza smoothing) |
| 32 | Media dello scostamento dal centro della traiettoria |
| 33 | Deviazione standard dello scostamento dal centro della traiettoria |
| 34 | Skewness dello scostamento dal centro della traiettoria |
| 35 | Kurtosis dello scostamento dal centro della traiettoria |
| 36 | Entropia di Shannon dello scostamento dal centro della traiettoria |
| 37 | Distanza massima percorsa |
| 38 | X media |
| 39 | Y media |

</details>

Per il significato delle feature si rimanda a:
> D. Di Giuseppe, F. Corsi, A. Mencattini, M.C. Comes, P. Casti, C. Di Natale, L. Ghibelli, E. Martinelli,
> *Learning Cancer-Related Drug Efficacy Exploiting Consensus in Coordinated Motility Within Cell Clusters*,
> IEEE Trans. Biomed. Eng. 66 (2019) 2882–2888. https://doi.org/10.1109/tbme.2019.2897825 (copia in `docs/`).

---

## Requisiti

- MATLAB (sviluppato con R2024b)
- Statistics and Machine Learning Toolbox (`fitcdiscr`, `zscore`, `tsne`, `fscmrmr`, `confusionchart`, ...)
- Classification toolbox 6.0 e PCA toolbox 1.5 del *Milano Chemometrics and QSAR Research Group* (già inclusi in `toolboxes/`, vedi http://www.michem.unimib.it)

## Come usarlo

1. Aprire MATLAB nella cartella principale della repository e aggiungere al path dati, script e toolbox:
   ```matlab
   addpath('data', 'scripts', 'toolboxes/classification_toolbox_6.0')   % per class_gui
   % addpath('toolboxes/pca_toolbox_1.5')                              % per pca_gui
   ```
   I due toolbox hanno funzioni con lo stesso nome (`pca_model`, `visualize_*`, ...): conviene tenerne nel path uno alla volta (`rmpath` per toglierlo).  
   `load` cerca i file `.mat` anche nel path di MATLAB, quindi i dati in `data/` vengono trovati.
2. Aprire uno script in `scripts/` ed eseguirlo **per sezioni** (`Ctrl+Enter`): gli script sono pensati come notebook di analisi, e molte sezioni aprono `class_gui` per addestrare il modello in modo interattivo.

> `tentativi2.m` e `train_e_test.m` caricano il dataset da un percorso assoluto (`C:\Users\silgi\Desktop\Progetto Pattern\...`): su un altro computer va sostituito con `load('dataset_cell_line_classification_motility_features.mat')`.

### Flusso dell'analisi

1. **Esplorazione** (`train_e_test.m`, `tentativi2.m`): statistiche per feature, test di normalità di Kolmogorov-Smirnov (le feature non sono gaussiane), visualizzazione t-SNE, correlazione con il target.
2. **Preparazione**: permutazione riproducibile (`rng(42)`), split training/test 80/20, 90/10 e 50/50, dati grezzi oppure standardizzati con z-score (in `FFNET.m` anche min-max).
3. **Classificatori**
   - **LDA**: `fitcdiscr` (`tentativi.m`, `pca_simca.m`) e `class_gui`
   - **SIMCA**: modellato in `class_gui`. Le predizioni per classe vanno esportate in `pred1.mat`, `pred2.mat`, `pred3.mat` e poi valutate con `simca.m` (matrice di confusione con categoria "assegnazione multipla")
   - **FFNET** (backpropagation neural network): addestrata in `class_gui`. Classi reali e predette vanno esportate in `reali.mat` e `predette.mat`, poi `FFNET.m` calcola le percentuali di corretta classificazione, i non classificati e la matrice degli errori
4. **Feature selection** (`pca_simca.m`): F-score di Fisher, top 15 feature, scelta finale di 8 feature `[9, 13, 14, 8, 32, 15, 16, 19]` (velocità, curvatura e posizione), salvate standardizzate in `Z_selected.mat`.

> **Nota:** i file `pred*.mat`, `reali.mat` e `predette.mat` sono generati esportando i risultati dalla GUI e non sono inclusi nella repository.

---

## Risultati principali

| Modello | Split | Accuratezza in test |
|---|---|---|
| LDA (39 feature) | 80/20 | 83% |
| LDA (39 feature) | 90/10 | 82% |
| LDA (39 feature) | 50/50 | 81% |
| LDA (8 feature selezionate) | 80/20 | 80% |
| LDA (8 feature selezionate) | 50/50 | 78% |
| **FFNET (8 feature selezionate)** | **80/20** | **87%** |

**Conclusioni:** lo split migliore è 80/20. FFNET e LDA restano accurati anche dopo la riduzione a 8 feature, quindi le feature scelte sono davvero discriminanti. FFNET è il classificatore migliore perché sbaglia meno spesso classificando come sana una cellula malata: con le feature selezionate, solo 20 dei 73 errori finiscono nella classe dei sani, contro 54 su 131 per LDA.

Dettagli e grafici in `docs/Ppt PATTERN.pptx`.
