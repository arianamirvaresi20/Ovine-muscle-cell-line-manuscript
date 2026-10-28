# Ovine muscle cell line manuscript: analysis code

## Revised figure code — v1.1

Prepared 27 October 2026 for the revised manuscript. This package combines the
original public v1.0 scripts with four updated/additional scripts supplied by
the author. Figure numbers follow the revised figure PDFs and the author's
explicit instructions. The package is prepared locally; it has NOT yet been
uploaded to GitHub or archived as a new Zenodo version.

## Figure-to-code mapping

All analysis scripts are in `scripts/`. Filenames use
`Figure_<number/panel>_<Description>.R`. The GO semantic-similarity analysis has
no confirmed unique figure number, so it is deliberately named
`Analysis_GO_Semantic_Similarity_Reduction.R` rather than assigned a fictitious panel.

| Figure/panel | Script | Purpose |
|---|---|---|
| 2a | `Figure_2a_FPKM_Distribution_Statistics.R` | FPKM distribution and pooled-group statistics |
| 2e–2g | `Figure_2e_2f_2g_Transcriptomics_Log2FC_Heatmaps.R` | Selected transcriptomic gene log2 fold-change heatmaps |
| 2d; 5b | `Figure_2d_Figure_5b_Whole_Expression_Heatmaps.R` | Whole transcriptomic/proteomic expression heatmaps; run separately |
| 3a–3c; 5d | `Figure_3a_3b_3c_Figure_5d_Volcano_Plots.R` | Shared basic volcano plot code; run separately for each comparison |
| 4a–4c | `Figure_4_GO_Combined_Bubble_Plot.R` | Combined GO enrichment bubble plots across three comparisons |
| 5c | `Figure_5c_Kmeans_Cluster_Profiles.R` | Profiles of pre-assigned clusters; does not perform k-means fitting |
| 5e | `Figure_5e_Proteomics_Log2FC_Heatmap.R` | Selected proteomic log2 fold-change heatmap |
| 6 | `Figure_6_GO_Rich_Factor_Bubble_Plot.R` | Top-30 GO rich-factor bubble plot; replaces former Figure 5a implementation |
| 7 | `Figure_7_KEGG_Pathway_Bar_Plot.R` | KEGG pathway bar plot; previously named Figure 6a |
| 9b–9c | `Figure_9b_9c_Scaffold_Viability_Boxplots.R` | Scaffold viability boxplots with ANOVA and Tukey HSD; run per scaffold |
| S1 | `Figure_S1_KEGG_Combined_Bubble_Plot.R` | Combined KEGG enrichment bubble plots across three comparisons |
| S2 | `Figure_S2_GO_Enrichment_Bar_Plot.R` | GO enrichment bar plot and summary table |
| Supporting analysis; no unique panel assigned | `Analysis_GO_Semantic_Similarity_Reduction.R` | GO semantic similarity and redundancy reduction |

## What changed

- New Figure 4 uses the newly supplied combined GO bubble-plot code.
- Figure S1 uses the newly supplied combined KEGG bubble-plot code.
- New Figure 6 uses `Figure-6-11.R`, as instructed, instead of the former Figure 5a implementation.
- Figure S2 uses the newly supplied GO enrichment bar-plot code.
- The former generic `GO_KEGG_enrichment_barplot.R` is superseded and is NOT included as an active script. Its historical version remains in the v1.0 archive.
- The old Figure 4 proteomics panels are now Figure 5: whole heatmap 5b, cluster profiles 5c, volcano 5d, selected-protein heatmap 5e.
- The previous Figure 6a KEGG bar plot is now Figure 7; the previous Figure 8 scaffold plots are now Figure 9b/c.
- Volcano scripts are identified only as volcano plots, without review-process framing.

See `CHANGELOG.md` and `Figure_Code_Mapping.csv` for per-file provenance,
replacement decisions, and SHA-256 hashes. Analysis thresholds and formulas
have not been deliberately changed. Changes are limited to figure/file naming,
output basenames for selected scripts, a K-means-script syntax fix, centralizing
unconditional package installation, and file-selection/label portability fixes.

## Software environment

The author previously supplied an RStudio About screenshot reporting
**RStudio 2025.09.2, Build 418, on Windows**. RStudio is the editor/IDE, NOT the
R interpreter. The screenshot does not establish the R version or R package
versions, and it does not establish the environment used for the October updates.
The original R and package versions have not been supplied; no exact-version
lockfile or claimed historical `sessionInfo()` has been invented.

Run `setup/Capture_Session_Info.R` in the environment actually used for the
revised analyses to record R, OS, and package versions. Those outputs record
the current environment only, not the original environment retrospectively.
Some retained plots request Calibri/Arial; font availability affects rendering.
Some exports use Cairo; Cairo/system-font support may be required.

## Install and run

1. Extract the entire package. Keep the `scripts/` and `setup/` directories.
2. Open an interactive R/RStudio session. Set the working directory to a writable output folder for the figure you are running.
3. Open `setup/Install_Dependencies.R` and run it once. This installs missing CRAN/Bioconductor packages; it does not pin historical versions. Installation may require internet access and platform-specific system libraries.
4. Open ONE relevant script from `scripts/` in a fresh session and run it top to bottom. Do not run all scripts automatically: each expects its own source-data table(s).
5. Select the correct Excel file(s) when prompted. The combined GO/KEGG scripts each request THREE tables, in order: EPILM versus PLM, LPILM versus PLM, LPILM versus EPILM.
6. For reusable plots, run the script again with the appropriate other comparison or dataset. Use separate output folders to avoid overwriting files.
7. Run `setup/Capture_Session_Info.R` after the analysis to save `Package_Versions.csv` and `Session_Info_Current.txt`.

Read `INPUT_DATA_REQUIREMENTS.md` before running. Each script reads the FIRST
Excel sheet unless the code says otherwise. Scripts use interactive file
selection; they are not configured as a noninteractive batch pipeline.

## Output behavior

New Figures 4 and S1 save PDF/SVG/PNG; new Figure 6 saves PNG; Figure S2 saves
PNG/PDF and a CSV summary. The full heatmap and basic volcano scripts display
plots without automatically saving them. Scaffold exports remain commented out,
as in the supplied original script; uncomment the final export block to save.
Other retained scripts save the files specified in their code. Do not assume all
scripts produce all formats, or that export settings alone prove journal compliance.

For Figure 9, the reusable scaffold script defaults to the soy-scaffold axis
label/output prefix (panel 9b). For panel 9c, change only `scaffold_label` and
`output_prefix` at the start of that script and select the pea-scaffold worksheet.
The original filename/header referred to pea, but its actual x-axis label said
soy; the new configuration makes this discrepancy explicit instead of silently
assigning one dataset to both panels.

## Data and coverage

No experimental source-data spreadsheets are bundled in this update. Use the
author's final source data or the manuscript's Data availability location; the
old Source-Data upload is not available in this session. No synthetic data were
created, and the figure PDFs are reference images, not raw input spreadsheets.

The supplied scripts are NOT a complete raw sequencing/proteomics pipeline.
GO/KEGG scripts visualize precomputed enrichment results; they do not calculate
enrichment from raw sequencing reads. The K-means profile script summarizes
PRE-ASSIGNED clusters; it does not call `kmeans()` or standardize raw expression.
No code was supplied here for the revised PCA/Venn panels (2b, 2c, 5a), image
acquisition, microscopy, or schematics. The retained basic volcano code does not
contain every label/count annotation visible in the assembled revised figures.
No replacement code for those missing tasks has been invented.

## Validation and interpretation limits

All packaged R files receive a static R-grammar syntax check. They have NOT
been executed against source data, and numerical results/figure equivalence
have NOT been validated. Read `VALIDATION.md` for details.

- Figure S2 retains the author-specified denominator **711** for percentages and raw `P-value < 0.05` filtering. Confirm that denominator against the final data; it is not inferred or recalculated from the PDF.
- Figure 6 retains raw `Pvalue <= 0.05` outlines and top-30 selection. Figures 4 and S1 use adjusted `padj <= 0.05`. These are intentionally documented, not silently made identical.
- The semantic-similarity code retains bovine `org.Bt.eg.db`, method `Rel`, and threshold 0.7. Semantic non-redundancy is not proof of statistical independence; the annotation choice should be disclosed for an ovine study.
- The FPKM distribution tests retain pooled gene-level values. Packaging is not a statistical endorsement or verification of replicate-level inference.
- Constant rows can produce undefined row z-scores in the retained whole-heatmap code. The original handling of missing/infinite values is retained; source-data review remains necessary.

## License and citation

The MIT license from the existing public repository is retained in `LICENSE`.
Use and redistribution are subject to its terms; this is not an unrestricted
or public-domain dedication.

Original archived code: https://doi.org/10.5281/zenodo.22288674 (v1.0).
That DOI identifies the OLD files, NOT this revised package. After publishing
v1.1, cite the new version-specific Zenodo DOI for the final manuscript.
See `UPLOAD_AND_RELEASE.md` for the replacement and archiving steps.
