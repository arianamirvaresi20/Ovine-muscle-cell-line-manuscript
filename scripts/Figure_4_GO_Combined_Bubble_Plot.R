# ============================================================================
# Figure_4_GO_Combined_Bubble_Plot.R
# Figure(s): 4a–4c
# Purpose: Combined GO enrichment bubble plots across three comparisons
# Package version: v1.1 (prepared 2026-10-27)
# Run setup/Install_Dependencies.R once before running this script.
# Read README.md for data columns, figure mapping, and validation limitations.
# ============================================================================

# COMBINED GO ENRICHMENT BUBBLE FIGURE
# One bubble = one GO term in each comparison
# x = GeneRatio; size = gene Count; fill = Up/(Up+Down)
# thick black outline = padj <= 0.05; thin grey = padj > 0.05

packages <- c('readxl', 'dplyr', 'ggplot2', 'stringr', 'svglite', 'ragg')
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop('Install these packages first: ', paste(missing, collapse = ', '))
library(dplyr)
library(ggplot2)

message('Select EP vs PLM Excel file')
f1 <- file.choose()
message('Select LP vs PLM Excel file')
f2 <- file.choose()
message('Select LP vs EP Excel file')
f3 <- file.choose()
input_files <- c('EPILM / PLM' = f1, 'LPILM / PLM' = f2, 'LPILM / EPILM' = f3)

parse_ratio <- function(z) {
  vapply(as.character(z), function(value) {
    if (is.na(value) || trimws(value) == '') return(NA_real_)
    s <- strsplit(value, '/', fixed = TRUE)[[1]]
    if (length(s) == 2) {
      a <- suppressWarnings(as.numeric(trimws(s[1])))
      b <- suppressWarnings(as.numeric(trimws(s[2])))
      if (!is.finite(a) || !is.finite(b) || b == 0) return(NA_real_)
      return(a / b)
    }
    suppressWarnings(as.numeric(value))
  }, numeric(1))
}

read_go <- function(path, comparison_name) {
  tbl <- readxl::read_excel(path)
  cols <- c('Category','GOID','Description','GeneRatio','padj','Up','Down')
  if (!all(cols %in% names(tbl))) {
    stop('Missing columns in ', comparison_name, ': ',
         paste(setdiff(cols, names(tbl)), collapse=', '))
  }
  if (!'Count' %in% names(tbl)) {
    tbl$Count <- as.numeric(tbl$Up) + as.numeric(tbl$Down)
  }
  tbl %>% transmute(
    comparison = comparison_name,
    Category = toupper(trimws(as.character(Category))),
    GOID = as.character(GOID),
    Description = as.character(Description),
    GeneRatio = parse_ratio(GeneRatio),
    Count = suppressWarnings(as.numeric(Count)),
    padj = suppressWarnings(as.numeric(padj)),
    Up = suppressWarnings(as.numeric(Up)),
    Down = suppressWarnings(as.numeric(Down))
  ) %>%
    filter(!is.na(GOID), !is.na(Description), !is.na(GeneRatio)) %>%
    distinct(GOID, comparison, .keep_all = TRUE)
}

dat <- bind_rows(lapply(names(input_files), function(nm) read_go(input_files[[nm]], nm)))
if (!nrow(dat)) stop('No valid GO data were found.')

# Shared term order per category across all three comparisons.
# Empty spaces mean a GO term is not included in that file.
term_info <- dat %>%
  group_by(GOID) %>%
  summarise(Category = first(Category), Description = first(Description),
            present = n_distinct(comparison), .groups = 'drop') %>%
  mutate(Category = factor(Category, levels = c('BP','CC','MF'))) %>%
  arrange(Category, desc(present), Description)
term_info$term_id <- paste(term_info$GOID, term_info$Description, sep = '|')
# The factor labels are printed as the original descriptions.
term_levels <- rev(term_info$term_id)
label_dictionary <- setNames(term_info$Description, term_info$term_id)

plot_data <- dat %>%
  left_join(term_info %>% select(GOID, term_id), by = 'GOID') %>%
  mutate(
    comparison = factor(comparison, levels = names(input_files)),
    Category = factor(Category, levels = c('BP','CC','MF')),
    term_id = factor(term_id, levels = term_levels),
    up_fraction = if_else(Up + Down > 0, Up/(Up+Down), 0.5),
    Significance = factor(if_else(!is.na(padj) & padj <= 0.05,
                                   'Significant', 'Not significant'),
                          levels = c('Significant', 'Not significant'))
  )

# Draw a fully accurate significance legend key: black thick vs grey thin.
# This avoids guide_legend(override.aes = list(stroke = c(...))),
# which causes the 'replacement has 2 rows, data has 1' error.
significance_key <- function(data, params, size) {
  is_sig <- tolower(as.character(data$colour)) %in% c('black', '#000000')
  grid::pointsGrob(
    x = 0.5, y = 0.5, pch = 21,
    size = grid::unit(4.2, 'mm'),
    gp = grid::gpar(
      col = if (is_sig) '#000000' else '#777777',
      fill = '#FFFFFF',
      lwd = if (is_sig) 2.7 else 0.8
    )
  )
}

up_col <- '#B12020'
down_col <- '#84A2CF'
category_labels <- c(BP='BP',
                     CC='CC',
                     MF='MF')
category_cols <- c(BP='#1F4E79', CC='#2C5D8A', MF='#0B2545')

# Optional: separate, colored BP/CC/MF heading strips with bold 12-pt text.
# The strip color is the same navy across categories here; category-specific
# heading colors can be applied in a later styling pass using ggh4x.

p <- ggplot(plot_data, aes(x=GeneRatio, y=term_id)) +
  geom_point(
    aes(size=Count, fill=up_fraction, colour=Significance),
    shape=21, stroke=0.45, alpha=0.97,
    key_glyph=significance_key
  ) +
  geom_point(
    data = filter(plot_data, Significance == 'Significant'),
    aes(size=Count, fill=up_fraction),
    shape=21, colour='black', stroke=1.25, alpha=0.97,
    show.legend=FALSE
  ) +
  facet_grid(
    rows=vars(Category), cols=vars(comparison),
    scales='free_y', space='free_y', switch='y',
    labeller=labeller(Category=category_labels)
  ) +
  scale_y_discrete(labels=function(keys) unname(label_dictionary[as.character(keys)])) +
  scale_x_continuous(name='GeneRatio',
                     expand=expansion(mult=c(0.07,0.12))) +
  scale_fill_gradient2(
    low=down_col, mid='#F7F7F7', high=up_col, midpoint=0.5,
    limits=c(0,1), breaks=c(0,0.5,1),
    labels=c('Down','Balanced','Up'),
    name='Regulation (circle fill)',
    guide=guide_colourbar(order=1, direction='horizontal',
                          title.position='top', label.position='bottom',
                          barwidth=grid::unit(28,'mm'),
                          barheight=grid::unit(3.5,'mm'))
  ) +
  scale_colour_manual(
    values=c('Significant'='#000000','Not significant'='#777777'),
    breaks=c('Significant','Not significant'),
    name='Adjusted p-value',
    guide=guide_legend(order=2,
                       override.aes=list(shape=21, size=4.2, fill='white'))
  ) +
  scale_size_area(max_size=5.2, name='Gene count',
                  guide=guide_legend(order=3,
                                    override.aes=list(shape=21, fill='#9BAEC4', colour='#444444')))+
  theme_minimal(base_family='sans') +
  theme(
    panel.border=element_rect(fill=NA, colour='#A3AFBC', linewidth=0.35),
    panel.grid.major.y=element_line(colour='#E7ECF0', linewidth=0.25),
    panel.grid.major.x=element_line(colour='#E7ECF0', linewidth=0.25),
    panel.grid.minor=element_blank(),
    axis.text.y=element_text(size=11, colour='#17263B'),
    axis.text.x=element_text(size=11, colour='#17263B'),
    axis.title.x=element_text(size=11, face='bold', colour='#163B63'),
    axis.title.y=element_blank(),
    strip.placement='outside',
    strip.text.x=element_text(size=10.5, face='bold', colour='#163B63'),
    strip.text.y.left=element_text(size=12, face='bold', colour='#163B63', angle=90),
    strip.background=element_rect(fill='#EEF3F8', colour='#CBD5DF', linewidth=0.4),
    panel.spacing.x=grid::unit(3,'mm'),
    panel.spacing.y=grid::unit(4,'mm'),
    legend.position='bottom',
    legend.box='horizontal',
    legend.direction='horizontal',
    legend.title=element_text(size=8, face='bold'),
    legend.text=element_text(size=7.5),
    plot.margin=margin(8,8,8,8,unit='pt')
  )

print(p)
output <- file.path(getwd(), 'Figure_4_GO_Combined_Bubble_Plot')
ggsave(paste0(output,'.pdf'), plot=p, width=13.5, height=10.5,
       units='in', device=grDevices::cairo_pdf, bg='white')
ggsave(paste0(output,'.svg'), plot=p, width=13.5, height=10.5,
       units='in', device=svglite::svglite, bg='white')
ggsave(paste0(output,'.png'), plot=p, width=13.5, height=10.5,
       units='in', dpi=600, device=ragg::agg_png, bg='white')
message('Saved PDF, SVG, PNG: ', output)
