# Code Availability — [Manuscript Title], Nature Communications

This repository contains all custom R code used to generate the figures and
perform the statistical/bioinformatic analyses reported in the manuscript.

## Software environment

- **R environment:** RStudio 2025.09.2, Build 418 ("Cucumberleaf Sunflower" release, 2025-10-20)
- **Platform:** Windows NT 10.0; Win64; x64
- All scripts were developed and executed in this RStudio version.

## Repository structure

```
scripts/
├── Fig2a_FPKM_violin_boxplot_stats.R                 # Figure 2a: FPKM violin/boxplots with Kruskal-Wallis & pairwise Wilcoxon (BH-adjusted) statistics
├── Fig2e_2f_2g_transcriptomics_heatmap_10genes.R      # Figure 2e-2g: Log2FC heatmap for 10 selected transcriptomic genes
├── Fig2_Fig4_whole_heatmap_pheatmap.R                 # Figures 2 & 4 (full/whole heatmaps): pheatmap-based clustered heatmaps
├── Fig4e_proteomics_heatmap.R                         # Figure 4e: Log2FC heatmap for proteomics data (LPILM/PLM)
├── Fig6a_KEGG_pathway_barplot.R                       # Figure 6a: KEGG pathway enrichment bar plot (Top 10 per category, regulation-colored)
├── Fig8_scaffold_viability_boxplot.R                  # Figure 8b/8c: Cell viability on pea scaffold, boxplots with raw data points, ANOVA + Tukey HSD
├── GO_KEGG_enrichment_barplot.R                       # GO and KEGG enrichment bar plots
├── GO_semantic_similarity_rrvgo.R                     # GO term semantic similarity/redundancy reduction (rrvgo) used to assess independence of enriched GO terms
├── Kmeans_cluster_profile_plot.R                      # K-means cluster expression profile plots (all clusters, mean ± 95% CI ribbons)
└── Volcano_plot.R                                     # Volcano plot: log2FoldChange vs. -log10(adjusted p-value)
```

## Figure-to-script mapping

| Figure(s) | Script | Description |
|---|---|---|
| Fig. 2a | `Fig2a_FPKM_violin_boxplot_stats.R` | FPKM distribution across groups, with Kruskal-Wallis and pairwise Wilcoxon (BH-adjusted) tests |
| Fig. 2e–2g | `Fig2e_2f_2g_transcriptomics_heatmap_10genes.R` | Log2 fold-change heatmap for 10 selected transcriptomics genes |
| Fig. 2 & 4 (whole heatmaps) | `Fig2_Fig4_whole_heatmap_pheatmap.R` | Full clustered heatmaps (all genes/proteins) using `pheatmap` |
| Fig. 4e | `Fig4e_proteomics_heatmap.R` | Log2 fold-change heatmap for proteomics data |
| Fig. 6a | `Fig6a_KEGG_pathway_barplot.R` | KEGG pathway enrichment bar plot, top 10 pathways per level-1 category, colored by regulation ratio |
| Fig. 8b, 8c | `Fig8_scaffold_viability_boxplot.R` | Cell viability boxplots on pea scaffold across time points and cell lines, with ANOVA + Tukey HSD compact letter display |
| GO/KEGG enrichment figure(s) | `GO_KEGG_enrichment_barplot.R` | GO and KEGG term enrichment bar plots |
| GO term independence check | `GO_semantic_similarity_rrvgo.R` | Semantic similarity analysis (rrvgo) used to evaluate independence/redundancy among enriched GO terms |
| K-means cluster figure(s) | `Kmeans_cluster_profile_plot.R` | Mean expression profile ± 95% CI for each K-means cluster, faceted plot |
| Volcano plot figure | `Volcano_plot.R` | Volcano plot (log2FoldChange vs. -log10(adjusted p-value)) |

## Required R packages

Install once before running any script:

```r
install.packages(c(
  "readxl", "ggplot2", "stringr", "showtext", "sysfonts",
  "ragg", "Cairo", "dplyr", "tidyr", "ggpubr", "rstatix",
  "broom", "multcompView", "pheatmap", "paletteer"
))

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install(c("rrvgo", "org.Bt.eg.db"))
```

## Data availability

Each script reads an input Excel (.xlsx) file, either via an interactive
file-selection dialog (`file.choose()`) or a file path variable at the top of
the script. Replace these with the path to the corresponding source data file
(deposited in the manuscript's Data Availability location) before running.

## How to run

1. Open RStudio (version 2025.09.2 or later recommended).
2. Open the desired script from the `scripts/` folder.
3. Install any missing packages listed above.
4. Run the script top to bottom. When prompted (`file.choose()`), select the
   relevant source data file corresponding to that figure.
5. Output figures are saved automatically as PDF/PNG/TIFF (600 dpi) in the
   working directory, matching Nature Communications figure requirements.

## License

This code is released under the MIT License (see `LICENSE`). No restrictions
apply to its use, provided appropriate citation of the associated publication.

## Citation

If you use this code, please cite:

> [Arian Amirvaresi, Arash Shahsavari, Reza Ovissipour]. [Multi Omics Characterization of CDK4 and hTERT Immortalized Ovine Satellite Cells for Cultivated Meat]. *Nature Communications* 

## Contact

Arian Amirvaresi — [aamirvaresi@tamu.edu]
