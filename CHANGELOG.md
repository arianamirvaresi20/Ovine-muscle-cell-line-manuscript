# Change log — proposed v1.1

Prepared 27 October 2026. This file documents local packaging changes, not an
already-published release.

## Replacements and numbering

- Superseded `GO_KEGG_enrichment_barplot.R`: the old generic single-file enrichment plotting implementation is removed from the active code set. The new Figure 4, Figure 6, Figure S1 and Figure S2 scripts are kept as distinct, explicitly named analyses; the user specifically identified Figure 6 as replacing the former Figure 5a implementation.
- Former `Fig6a_KEGG_pathway_barplot.R` is RETAINED as Figure 7. It is a KEGG bar plot, not the new GO Figure 6 script; these are not interchangeable.
- Selected-protein heatmap, whole proteomic heatmap and clustering now map to Figure 5e, 5b and 5c respectively; the shared volcano script also applies to Figure 5d.
- Scaffold plots map to Figure 9b/c, not Figure 8. Figure 8 is the revised microscopy figure.
- The GO semantic-similarity support analysis has no confirmed unique panel and is not assigned an invented figure number.

## Per-file edits

### Figure_2a_FPKM_Distribution_Statistics.R

Source: `Fig2a_FPKM_violin_boxplot_stats.R` (GitHub archived v1.0).

- Added a consistent current-figure header and filename.
- Standardized existing output basenames to current figure numbers; plotting calculations unchanged.

### Figure_2e_2f_2g_Transcriptomics_Log2FC_Heatmaps.R

Source: `Fig2e_2f_2g_transcriptomics_heatmap_10genes.R` (GitHub archived v1.0).

- Added a consistent current-figure header and filename.

### Figure_2d_Figure_5b_Whole_Expression_Heatmaps.R

Source: `Fig2_Fig4_whole_heatmap_pheatmap.R` (GitHub archived v1.0).

- Added a consistent current-figure header and filename.
- Moved package installation to setup/Install_Dependencies.R (original call retained as comment).

### Figure_3a_3b_3c_Figure_5d_Volcano_Plots.R

Source: `Volcano_plot.R` (GitHub archived v1.0).

- Added a consistent current-figure header and filename.
- Moved package installation to setup/Install_Dependencies.R (original call retained as comment).

### Figure_4_GO_Combined_Bubble_Plot.R

Source: `GO_combined_bubble_corrected-Figure4-13.R` (2026-10-27 user upload).

- Added a consistent current-figure header and filename.
- Standardized existing output basenames to current figure numbers; plotting calculations unchanged.

### Figure_5c_Kmeans_Cluster_Profiles.R

Source: `Kmeans_cluster_profile_plot.R` (GitHub archived v1.0).

- Added a consistent current-figure header and filename.
- Moved package installation to setup/Install_Dependencies.R (original call retained as comment).
- Commented an un-commented equals-sign separator that prevented R parsing.
- Standardized existing output basenames to current figure numbers; plotting calculations unchanged.

### Figure_5e_Proteomics_Log2FC_Heatmap.R

Source: `Fig4e_proteomics_heatmap.R` (GitHub archived v1.0).

- Added a consistent current-figure header and filename.
- Standardized existing output basenames to current figure numbers; plotting calculations unchanged.

### Figure_6_GO_Rich_Factor_Bubble_Plot.R

Source: `Figure-6-11.R` (2026-10-27 user upload).

- Added a consistent current-figure header and filename.
- Standardized existing output basenames to current figure numbers; plotting calculations unchanged.

### Figure_7_KEGG_Pathway_Bar_Plot.R

Source: `Fig6a_KEGG_pathway_barplot.R` (GitHub archived v1.0).

- Added a consistent current-figure header and filename.
- Standardized existing output basenames to current figure numbers; plotting calculations unchanged.

### Figure_9b_9c_Scaffold_Viability_Boxplots.R

Source: `Fig8_scaffold_viability_boxplot.R` (GitHub archived v1.0).

- Added a consistent current-figure header and filename.
- Updated Figure 8 references to Figure 9, made scaffold axis label/output prefix configurable, and retained the originally optional commented exports.

### Figure_S1_KEGG_Combined_Bubble_Plot.R

Source: `KEGG_combined_bubble_corrected-Figure-S1-10.R` (2026-10-27 user upload).

- Added a consistent current-figure header and filename.
- Standardized existing output basenames to current figure numbers; plotting calculations unchanged.

### Figure_S2_GO_Enrichment_Bar_Plot.R

Source: `Figure-S2-12.R` (2026-10-27 user upload).

- Added a consistent current-figure header and filename.
- Standardized existing output basenames to current figure numbers; plotting calculations unchanged.

### Analysis_GO_Semantic_Similarity_Reduction.R

Source: `GO_semantic_similarity_rrvgo.R` (GitHub archived v1.0).

- Added a consistent current-figure header and filename.
- Moved package installation to setup/Install_Dependencies.R (original call retained as comment).
- Replaced three author-specific Windows paths with prompted Excel selection; comparison names and rrvgo parameters retained.

## Documentation corrections

The old `SESSION_INFO.txt` incorrectly implied that knowing the RStudio version
established the exact R execution environment. It is replaced by clear README
limitations and an actual environment-capture helper. No R version, package
version, input dataset, result, or runtime is fabricated. The earlier README
also overstated automatic exports and completeness; those statements have
been corrected. The existing MIT license is preserved, without imposing a new
citation license condition or saying that no restrictions apply.
