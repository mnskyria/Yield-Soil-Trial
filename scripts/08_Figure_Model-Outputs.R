# ============================================================
# 08_Figure_Model-Outputs-Balanced.R
# ============================================================

# ----------------- 1. INDICATOR SETS AND LABELS -----------------
SOIL_INDICATORS <- c(
  "pH", "EC", "totalN", "NH4", "P",
  "K", "Ca", "Mg", "Cu", "Mn", "Zn",
  "SOC", "BD", "POXC"
)

YIELD_INDICATORS <- c("totalYield", "bean", "carrot")  # kale excluded

SLAKES_INDICATORS <- "SLAKES"

YLABS <- c(
  pH         = "Soil pH",
  EC         = "Electrical Conductivity (dS/m)",
  totalN     = "Total N (%)",
  NH4        = "NH₄⁺ Mineralization (ppm)",
  P          = "MIII P (ppm)",
  K          = "MIII K (ppm)",
  Ca         = "MIII Ca (ppm)",
  Mg         = "MIII Mg (ppm)",
  Cu         = "MIII Cu (ppm)",
  Mn         = "MIII Mn (ppm)",
  Zn         = "MIII Zn (ppm)",
  SOC        = "SOC (%)",
  BD         = "Bulk Density (g/cm³)",
  POXC       = "POX-C (mg/kg)",
  totalYield = "Total Yield (g)",
  bean       = "Bean Yield (g)",
  carrot     = "Carrot Yield (g)",
  carrot1    = "Carrot Yield (g)",
  kale       = "Kale Yield (g)",
  SLAKES     = "Aggregate Stability (STAB10)"
)

# ----------------- 2. PLOT FUNCTION: TREATMENT X YEAR (CATEGORICAL) -----------------
plot_with_raw <- function(model, data, response_var,
                          x           = "treatment",
                          facet_by    = "year",
                          y_label     = NULL,
                          year_labels = NULL,
                          point_alpha = 0.4,
                          point_size  = 2) {
  
  if (is.null(y_label)) {
    if (exists("YLABS") && response_var %in% names(YLABS)) {
      y_label <- YLABS[[response_var]]
    } else {
      y_label <- response_var
    }
  }
  
  year_levels <- sort(unique(data$year))
  
  # Use custom labels if provided, otherwise auto-generate
  if (is.null(year_labels)) {
    year_labels <- paste("Year", seq_along(year_levels))
  }
  
  newdat <- expand_grid(
    treatment = unique(data$treatment),
    year      = unique(data$year)
  )
  
  p <- predict(model, newdata = newdat, se.fit = TRUE, re.form = NA)
  
  preds <- newdat %>%
    mutate(
      fit   = p$fit,
      se    = p$se.fit,
      lower = fit - 1.96 * se,
      upper = fit + 1.96 * se,
      year  = factor(year, levels = year_levels, labels = year_labels)
    )
  
  raw <- data %>%
    select(treatment, year, all_of(response_var)) %>%
    rename(y = all_of(response_var)) %>%
    mutate(year = factor(year, levels = year_levels, labels = year_labels))
  
  ggplot() +
    geom_jitter(
      data  = raw,
      aes_string(x = x, y = "y"),
      width = 0.1, alpha = point_alpha,
      size  = point_size, color = "grey40"
    ) +
    geom_errorbar(
      data = preds,
      aes_string(x = x, ymin = "lower", ymax = "upper"),
      width = 0.15, size = 0.7
    ) +
    geom_point(
      data = preds,
      aes_string(x = x, y = "fit"),
      size = 3
    ) +
    facet_wrap(as.formula(paste("~", facet_by))) +
    labs(x = "Treatment", y = y_label, title = NULL) +
    theme_bw(base_size = 14) +
    theme(strip.text = element_text(face = "bold"))
}

# ----------------- 3. BATCH RUNNER: TREATMENT X YEAR MODELS -----------------
run_lm_plots <- function(
    indicators,
    data,
    out_dir     = file.path(CONFIG$figs_dir, "LM Outputs"),
    year_labels = NULL,
    width       = 7,
    height      = 4,
    dpi         = 300
) {
  
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  for (response_var in indicators) {
    message("Processing: ", response_var)
    
    tryCatch({
      fml <- as.formula(paste0(response_var, " ~ treatment * year"))
      mod <- lm(fml, data = data, na.action = na.omit)
      
      p <- plot_with_raw(
        model        = mod,
        data         = data,
        response_var = response_var,
        year_labels  = year_labels
      )
      
      ggsave(
        filename = file.path(out_dir, paste0(response_var, "_LM_balanced.png")),
        plot     = p,
        width    = width,
        height   = height,
        dpi      = dpi,
        units    = "in"
      )
    }, error = function(e) {
      message("  ✗ Error for ", response_var, ": ", e$message)
    })
  }
  
  message("✓ Completed: ", out_dir)
}

# ----------------- 4. RUN: TREATMENT X YEAR MODELS -----------------
# Soil: balanced (T0 + Year 3)
run_lm_plots(
  indicators  = SOIL_INDICATORS,
  data        = dat_2024_T0,
  out_dir     = file.path(CONFIG$figs_dir, "LM Outputs", "Soil Models (Balanced)"),
  year_labels = c("T0", "Year 3")
)

# Soil: raw/full (T0 + Year 3 unaveraged)
run_lm_plots(
  indicators  = SOIL_INDICATORS,
  data        = dat_RAW,
  out_dir     = file.path(CONFIG$figs_dir, "LM Outputs", "Soil Models (Full)"),
  year_labels = c("T0", "Year 3")
)

# Crop yield: Years 1-3 (kale excluded)
run_lm_plots(
  indicators  = YIELD_INDICATORS,
  data        = dat_yield,
  out_dir     = file.path(CONFIG$figs_dir, "LM Outputs", "Yield Models"),
  year_labels = c("Year 1", "Year 2", "Year 3")
)

# Kale yield: Years 2-3 only
run_lm_plots(
  indicators  = "kale",
  data        = dat_kale,
  out_dir     = file.path(CONFIG$figs_dir, "LM Outputs", "Kale Model"),
  year_labels = c("Year 2", "Year 3")
)

# Aggregate stability: Years 1-3
run_lm_plots(
  indicators  = SLAKES_INDICATORS,
  data        = dat_slakes,
  out_dir     = file.path(CONFIG$figs_dir, "LM Outputs", "Slakes Model"),
  year_labels = c("Year 1", "Year 2", "Year 3")
)

# ----------------- 5. AIC CANDIDATE MODEL PLOTS (CONTINUOUS PREDICTOR) -----------------
aic_out_dir <- file.path(CONFIG$figs_dir, "LM Outputs", "AIC Models")
if (!dir.exists(aic_out_dir)) dir.create(aic_out_dir, recursive = TRUE)

# --- Bean ~ NH4 (Years 1 and 3; Year 2 missing NH4) ---
beanNH4mod <- lm(bean ~ NH4 + year,
                 data = dat_yearly_means, na.action = na.omit)

beanNH4plot <- plot_pred_with_raw_indicator(
  beanNH4mod,
  dat_yearly_means,
  response_var  = "bean",
  indicator_var = "NH4",
  x_label       = "NH₄⁺ Mineralization (ppm)",
  y_label       = "Bean Yield (g)"
)

ggsave(
  filename = file.path(aic_out_dir, "bean_NH4_AIC.png"),
  plot     = beanNH4plot,
  width    = 7, height = 4, dpi = 300, units = "in"
)

# --- Carrot ~ Mg (Years 1 and 3; Year 2 missing Mg) ---
carrotMgmod <- lm(carrot1 ~ Mg + year,
                  data = dat_yearly_means, na.action = na.omit)

carrotMgplot <- plot_pred_with_raw_indicator(
  carrotMgmod,
  dat_yearly_means,
  response_var  = "carrot1",
  indicator_var = "Mg",
  x_label       = "MIII Magnesium (ppm)",
  y_label       = "Carrot Yield (g)"
)

ggsave(
  filename = file.path(aic_out_dir, "carrot_Mg_AIC.png"),
  plot     = carrotMgplot,
  width    = 7, height = 4, dpi = 300, units = "in"
)

message("\n✓ All model output figures complete.")
