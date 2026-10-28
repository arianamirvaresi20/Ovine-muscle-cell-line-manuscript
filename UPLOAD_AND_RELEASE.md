# Replace the repository and create the new archive

Repository: https://github.com/arianamirvaresi20/Ovine-muscle-cell-line-manuscript

## Before publishing

Run the relevant scripts against the FINAL real source-data worksheets and
check that results match the final figures. This package was statically syntax
checked, not executed against data. Capture the real environment with
`setup/Capture_Session_Info.R` and include the resulting version information.
The old screenshots only identify RStudio, not R itself. If the four October
scripts ran under a different environment, record that environment too.

## Replace files on GitHub

1. Download and extract this package.
2. Open the repository's **Code** tab, on branch `main`.
3. Remove the TEN superseded root-level script filenames listed below. Do NOT leave old `.R` files at the root alongside the newly renamed versions, because readers could run outdated code.
4. Replace the root `README.md`, retain/replace the same `LICENSE`, and remove the misleading old `SESSION_INFO.txt` (the new README explains what is actually known).
5. Upload the CONTENTS of the extracted package, including the entire `scripts/` and `setup/` folders and all root documentation files. Upload extracted files/folders, not just the ZIP. Keep the folder structure.
6. Commit with the message: `Update analyses and figure numbering for revised manuscript`.
7. After testing, create a NEW release with tag `v1.1` and title `Revised manuscript analysis code v1.1`. Do not overwrite or reuse tag `v1.0`.

Root script filenames to remove from the current `main` branch:

- `Fig2_Fig4_whole_heatmap_pheatmap.R`
- `Fig2a_FPKM_violin_boxplot_stats.R`
- `Fig2e_2f_2g_transcriptomics_heatmap_10genes.R`
- `Fig4e_proteomics_heatmap.R`
- `Fig6a_KEGG_pathway_barplot.R`
- `Fig8_scaffold_viability_boxplot.R`
- `GO_KEGG_enrichment_barplot.R`
- `GO_semantic_similarity_rrvgo.R`
- `Kmeans_cluster_profile_plot.R`
- `Volcano_plot.R`

The old source files remain recoverable from the `v1.0` tag and its Zenodo archive;
there is no need to copy outdated scripts into the active new package.

## Release notes to paste

> Revised manuscript analysis code. Replaces the combined GO bubble plot for Figure 4, adds the updated GO rich-factor bubble plot for Figure 6 and supplementary Figures S1 (combined KEGG bubble plot) and S2 (GO bar plot), and updates retained scripts to the revised figure numbering. Standardizes script naming, corrects a K-means-script comment syntax error, improves file-path portability, and documents input and environment requirements. Experimental source data are not bundled; see the manuscript's Data availability statement.

## Zenodo and the manuscript

Keep the repository enabled in Zenodo's GitHub integration BEFORE publishing
the new release. Zenodo documents that new releases of an enabled repository
are archived automatically:
https://help.zenodo.org/docs/github/enable-repository/

Your old DOI `10.5281/zenodo.22288674` is specific to v1.0. Updating GitHub does
not change that archive's code. A new version receives its own record/identifier:
https://help.zenodo.org/docs/deposit/manage-versions/

After v1.1 is archived, copy its NEW version-specific DOI into the final manuscript.
Do not claim the September v1.0 DOI contains the October replacement scripts.
If automatic archiving fails, inspect the Zenodo GitHub integration status before
creating additional releases or duplicate deposits.

Once the revised archive exists, use this wording (replace the bracketed value):

> Custom R code used for the analyses and figure generation in this study is available on Zenodo (version v1.1): https://doi.org/[NEW-V1.1-DOI].

This final DOI is intentionally not guessed. No upload or remote change has been
made by preparing this local code package.
