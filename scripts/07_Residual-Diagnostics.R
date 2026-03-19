# ============================================================
# 07_Residual-Diagnostics.R
# ============================================================

# ----------------- 1. YEAR RECODE HELPER -----------------
recode_years <- function(data, levels, labels) {
  data$year <- factor(
    as.character(droplevels(factor(as.character(data$year)))),
    levels = levels,
    labels = labels
  )
  data
}

# ----------------- 2. SHAPIRO EXCEL WRITER -----------------
write_shapiro_excel <- function(results, outfile) {
  wb <- createWorkbook()
  addWorksheet(wb, "Shapiro")
  
  df <- data.frame(
    Variable = names(results),
    W        = sapply(results, function(x) round(unname(x$shapiro$statistic), 4)),
    p_value  = sapply(results, function(x) round(unname(x$shapiro$p.value), 4)),
    stringsAsFactors = FALSE
  )
  
  writeDataTable(wb, "Shapiro", df)
  saveWorkbook(wb, outfile, overwrite = TRUE)
  message("✓ Shapiro results saved: ", outfile)
}

# ----------------- 3. WRAPPER -----------------
run_all_diagnostics <- function(vars, data, formula_list = NULL,
                                fig_dir, width = 10, height = 6, dpi = 300) {
  
  dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
  results <- list()
  
  for (v in vars) {
    message("Running diagnostics: ", v)
    tryCatch({
      
      if (!is.null(formula_list) && v %in% names(formula_list)) {
        fml <- formula_list[[v]]
      } else {
        fml <- as.formula(paste(v, "~ treatment * year"))
      }
      
      mod <- lm(fml, data = data, na.action = na.omit)
      outfile <- file.path(fig_dir, paste0("diagnostics_", v, ".png"))
      png(outfile, width = width, height = height, units = "in", res = dpi)
      results[[v]] <- check_diagnostics(mod, data = data)
      dev.off()
      message("  ✓ ", v)
      
    }, error = function(e) {
      message("  ✗ Error for ", v, ": ", e$message)
      try(dev.off(), silent = TRUE)
    })
  }
  
  invisible(results)
}

# ----------------- 4. RUN MODEL DIAGNOSTICS -----------------

# --- Soil: balanced (T0 + Year 3) ---
diag_soil <- run_all_diagnostics(
  vars    = soil_vars,
  data    = recode_years(dat_2024_T0,
                         c("T0", "2024"),
                         c("T0", "Year 3")),
  fig_dir = file.path(CONFIG$diag_dir, "Soil Models (Balanced)")
)
write_shapiro_excel(
  diag_soil,
  file.path(CONFIG$diag_dir, "Soil Models (Balanced)",
            "shapiro_soil_balanced.xlsx")
)

# --- Soil: raw (T0 + Year 3 unaveraged) ---
diag_soil_raw <- run_all_diagnostics(
  vars    = soil_vars,
  data    = recode_years(dat_RAW,
                         c("T0", "2024"),
                         c("T0", "Year 3")),
  fig_dir = file.path(CONFIG$diag_dir, "Soil Models (Raw)")
)
write_shapiro_excel(
  diag_soil_raw,
  file.path(CONFIG$diag_dir, "Soil Models (Raw)",
            "shapiro_soil_raw.xlsx")
)

# --- Aggregate stability: Years 1-3 ---
diag_slakes <- run_all_diagnostics(
  vars    = "SLAKES",
  data    = recode_years(dat_slakes,
                         c("2022", "2023", "2024"),
                         c("Year 1", "Year 2", "Year 3")),
  fig_dir = file.path(CONFIG$diag_dir, "Slakes Model")
)
write_shapiro_excel(
  diag_slakes,
  file.path(CONFIG$diag_dir, "Slakes Model", "shapiro_slakes.xlsx")
)

# --- Crop yield: Years 1-3 (kale excluded) ---
diag_yield <- run_all_diagnostics(
  vars    = c("totalYield", "bean", "carrot"),
  data    = recode_years(dat_yield,
                         c("2022", "2023", "2024"),
                         c("Year 1", "Year 2", "Year 3")),
  fig_dir = file.path(CONFIG$diag_dir, "Yield Models")
)
write_shapiro_excel(
  diag_yield,
  file.path(CONFIG$diag_dir, "Yield Models", "shapiro_yield.xlsx")
)

# --- Kale yield: Years 2-3 only ---
diag_kale <- run_all_diagnostics(
  vars    = "kale",
  data    = recode_years(dat_kale,
                         c("2023", "2024"),
                         c("Year 2", "Year 3")),
  fig_dir = file.path(CONFIG$diag_dir, "Kale Model")
)
write_shapiro_excel(
  diag_kale,
  file.path(CONFIG$diag_dir, "Kale Model", "shapiro_kale.xlsx")
)

# --- AIC candidate models (custom formulas) ---
diag_aic <- run_all_diagnostics(
  vars         = c("bean", "carrot1"),
  data         = recode_years(dat_yearly_means,
                              c("2022", "2023", "2024"),
                              c("Year 1", "Year 2", "Year 3")),
  formula_list = list(
    bean    = bean ~ NH4 + year,
    carrot1 = carrot1 ~ Mg + year
  ),
  fig_dir = file.path(CONFIG$diag_dir, "AIC Model")
)

message("\n✓ All diagnostics complete.")