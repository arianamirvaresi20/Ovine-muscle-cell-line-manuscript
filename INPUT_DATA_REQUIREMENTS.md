# Input data requirements

These schemas are read directly from the supplied scripts. Use actual study
data, not values copied from figure graphics. No data files are included.

| Script / figure | Required Excel structure |
|---|---|
| Figure 2a: FPKM | `gene_id`, `PrimaryMusc`, `PrimaryMusc2`, `ImmorMuscEP`, `ImmorMuscEP2`, `ImmorMuscLP`, `ImmorMuscLP2`; numeric FPKM values. Original plot labels Control/TRT1/TRT2 are retained. |
| Figure 2e–2g: selected-gene heatmaps | `Gene`, `Log2FC`. Run separately for each comparison and keep outputs in separate folders. |
| Figures 2d / 5b: whole heatmaps | First column is the gene/protein identifier; every remaining column is a numeric sample/group measurement. The script row-standardizes and clusters the matrix. |
| Figures 3a–3c / 5d: volcano | `log2FoldChange`, `padj`; adjusted p-values should be valid probabilities. Zero adjusted p-values yield infinite y-values in the retained code; no arbitrary replacement is imposed. Run separately per comparison. |
| Figure 4: combined GO bubbles | Three tables, selected EPILM/PLM, LPILM/PLM, LPILM/EPILM. Each needs `Category` (BP/CC/MF), `GOID`, `Description`, `GeneRatio`, `padj`, `Up`, `Down`. `Count` is optional and defaults to `Up + Down`. `GeneRatio` accepts numeric ratios or plain `a/b` strings. |
| Figure 5c: cluster profiles | First column = identifier, second column = existing cluster assignment (`Sub_class`), all remaining columns = numeric sample values in the intended sample order. Colors are supplied for cluster labels 1–7. Input values are assumed to be appropriately standardized already. |
| Figure 5e: selected-protein heatmap | `Gene`, `PLM`, `LPILM`; optional `Regulation`. Original calculation uses `log2((LPILM + 0.015)/(PLM + 0.015))`. |
| Figure 6: GO rich-factor bubbles | `Ontology`, `Description`, `BgRatio`, `Pvalue`, `Up`, `Down`, plus `Count` or `DiffRatio`. Spaces, hyphens, and periods are removed from headers by the script, so `P-value` becomes `Pvalue`. `BgRatio` must contain the background-term count as its numerator. Rich factor = Count / background-term count. |
| Figure 7: KEGG bars | `DiffRatio`, `P-value` (or `P_value` after the script's header cleanup), `Up`, `Down`, `Count`, `KEGG_level_1`, `KEGG_Pathway`. The script parses a ratio from `DiffRatio` and retains top 10 significant pathways per category. |
| Figure 9b / 9c: scaffold viability | First row = headers. First 12 nonempty measurement columns must be ordered 4h PLM, 4h EPILM, 4h LPILM, 24h PLM, 24h EPILM, 24h LPILM, 48h PLM, 48h EPILM, 48h LPILM, 72h PLM, 72h EPILM, 72h LPILM. Subsequent rows = raw replicate observations. Do not put an ID/notes column before the measurements. Run separately for soy (9b) and pea (9c), changing the two label/output settings. |
| Figure S1: combined KEGG bubbles | Three tables selected in the same comparison order as Figure 4. Each needs an ID column (`KEGGID`, `keggID`, `ID`, `PathwayID`, or `pathway_id`), `Description`, `GeneRatio`, `padj`, `Up`, `Down`. Optional `Count` defaults to `Up + Down`. Duplicate pathway IDs within one table cause an explicit error. |
| Figure S2: GO bars | `Ontology`, `Description`, `P-value`, `Count`, `Up`, `Down`, and `FDR` (needed for the final CSV export). Original ontology labels are `Biological process`, `Molecular function`, `Cellular component`. Percentage denominator is fixed at 711; top 15 per ontology and raw P-value < 0.05. |
| GO semantic similarity | Three GO result tables: `Category` (BP/CC/MF), `GOID`, `Description`, `padj`. Prompts are EPILM versus PLM, LPILM versus EPILM, LPILM versus PLM (note the DIFFERENT order from combined bubble scripts). Existing comparison names in exported results are preserved. |

## Interpretation cautions

The K-means profile ribbons are calculated as mean ± 1.96 × SD/sqrt(N) across
rows/genes in a cluster/sample, not inferred biological-replicate confidence
intervals. `N = n()` is retained, including the original behavior with missing
values. Semantic similarity counts denote clusters under the chosen threshold,
not a statistical test of independence. Genes shared across GO terms can appear
in more than one term; summed counts in Figure S2 are not automatically unique
gene counts. The author should verify all study-specific statistical claims.
