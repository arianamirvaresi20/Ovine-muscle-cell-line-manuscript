# Validation record

Package: proposed v1.1, prepared 27 October 2026.

## Completed

- Recovered all ten original analysis scripts from the public GitHub `v1.0` tag (commit `b7a27cde2d414506b96f00150f048d4b3b31b7f8`).
- Read all four newly supplied R scripts and used them for revised Figures 4, 6, S1 and S2.
- Visually inspected all nine revised main-figure PDFs for panel mapping. S1/S2 PDFs were not supplied in this update; those labels follow the author's instruction and script contents.
- Standardized all 13 analysis script names and their leading documentation.
- Performed a static parse of all 13 analysis scripts plus both setup helpers with the tree-sitter R grammar: 15/15 PASS. Individual checks are recorded in `Syntax_Check_Results.csv`.
- Found and fixed a bare equals-sign separator in the old K-means profile code that was invalid R syntax.
- Confirmed no author-specific Windows absolute paths remain in packaged R scripts.
- Retained the original MIT license and recorded source/package SHA-256 hashes in `Figure_Code_Mapping.csv`.

## Not completed / not claimed

- No R interpreter was available in this packaging environment. A tree-sitter syntax parse is NOT an R execution test or a substitute for `parse()` in R.
- No source-data spreadsheets for the revised plots were provided in this update. End-to-end execution, numeric/statistical verification, figure matching, and output export were NOT tested.
- Package installation, fonts, Cairo rendering, R/Bioconductor compatibility, runtime and exact historical dependencies were NOT validated.
- No claim is made that the supplied scripts reproduce every annotation or every panel, or that the journal has approved this deposit.
- No new GitHub release or Zenodo DOI has been created by this local packaging work.

## Items to verify with actual data

1. Confirm the fixed denominator 711 in Figure S2 and the final source-data schemas.
2. Confirm raw-versus-adjusted p-value descriptions for the new figures; the supplied code deliberately differs across plots.
3. Confirm bovine annotation use in the ovine GO semantic-similarity method, and describe it accurately.
4. Supply/confirm any missing raw-processing, PCA, Venn, k-means fitting or custom volcano annotation code required to support the final paper.
5. Run the two scaffold datasets separately with the correct soy/pea labels; export instructions are deliberately left as originally optional.
6. Record the actual R and package versions used for the revised analyses and check statistical inference at the appropriate replicate level.
