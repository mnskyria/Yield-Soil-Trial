# ============================================================
# 07_Residual-Diagnostics.R
# ============================================================

# ----------------- 1. CORE DIAGNOSTIC FUNCTION -----------------
run_diagnostics_single <- function(response_var,
                                   data,
                                   fig_dir  = "diagnostics_figs",
                                   width    = 10,
                                   height   = 6,
                                   dpi      = 300,
                                   formula  = NULL) {
  
  if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)
  
  if (!(response_var %in% names(data))) {
    stop(paste("Variable", response_var, "not found in data."))
  }
  
  if (is.null(formula)) {
    fml <- as.formula(paste(response_var, "~ treatment * year"))
  } else {
    fml <- formula
  }
  
  mod <- lm(fml, data = data, na.action = na.exclude)
  
  # ── Use model.frame to get exactly the rows the model used ──
  mf <- model.frame(mod)
  
  df <- data.frame(
    resid     = residuals(mod)[!is.na(residuals(mod))],
    fitted    = fitted(mod)[!is.na(fitted(mod))],
    treatment = factor(data$treatment[as.integer(rownames(mf))]),
    year      = factor(data$year[as.integer(rownames(mf))])
  )
  
  sh <- shapiro.test(df$resid)
  cat("Shapiro for", response_var, "| W =", round(sh$statistic, 4),
      "p =", round(sh$p.value, 4), "\n")
  
  outfile <- file.path(fig_dir, paste0("diagnostics_", response_var, ".png"))
  png(outfile, width = width, height = height, units = "in", res = dpi)
  
  par(mfrow = c(2, 3), mar = c(4, 4, 2, 1))
  
  car::qqPlot(df$resid,
              main = paste("Q-Q plot:", response_var),
              ylab = "Residuals", col = "black", pch = 19)
  
  hist(df$resid, breaks = 30, freq = FALSE,
       main = "Residuals", xlab = "Residuals", col = "grey")
  lines(density(df$resid), col = "red", lwd = 2)
  
  plot(df$fitted, df$resid,
       xlab = "Fitted values", ylab = "Residuals",
       main = "Residuals vs Fitted", pch = 19)
  abline(h = 0, lty = 2)
  
  boxplot(resid ~ treatment, data = df,
          main = "Residuals by Treatment",
          xlab = "Treatment", ylab = "Residuals")
  abline(h = 0, lty = 2)
  
  boxplot(resid ~ year, data = df,
          main = "Residuals by Year",
          xlab = "Year", ylab = "Residuals")
  abline(h = 0, lty = 2)
  
  boxplot(resid ~ interaction(treatment, year), data = df,
          main = "Residuals by Trt-Year",
          xlab = "", ylab = "Residuals", las = 2)
  abline(h = 0, lty = 2)
  
  dev.off()
  
  invisible(list(model = mod, shapiro = sh, df = df, file = outfile))
}

# ----------------- 2. BATCH RUNNER -----------------
run_all_diagnostics <- function(vars, data, fig_dir,
                                width = 10, height = 6, dpi = 300) {
  results <- list()
  for (v in vars) {
    message("Running diagnostics: ", v)
    tryCatch({
      results[[v]] <- run_diagnostics_single(
        response_var = v,
        data         = data,
        fig_dir      = fig_dir,
        width        = width,
        height       = height,
        dpi          = dpi
      )
    }, error = function(e) {
      message("  ✗ Error for ", v, ": ", e$message)
    })
  }
  invisible(results)
}

# ----------------- 3. SHAPIRO EXCEL WRITER -----------------
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

# ----------------- 4. RUN MODEL DIAGNOSTICS -----------------
# --- Soil fertility & condition: treatment * year (balanced) ---
diag_soil <- run_all_diagnostics(
  vars    = soil_vars,
  data    = dat_2024_T0,
  fig_dir = file.path(CONFIG$diag_dir, "Soil Models (Balanced)")
)

write_shapiro_excel(
  diag_soil,
  outfile = file.path(CONFIG$diag_dir, "Soil Models (Balanced)",
                      "shapiro_soil_balanced.xlsx")
)

# --- Soil fertility & condition: treatment * year (raw) ---
diag_soil_raw <- run_all_diagnostics(
  vars    = soil_vars,
  data    = dat_RAW,
  fig_dir = file.path(CONFIG$diag_dir, "Soil Models (Raw)")
)

write_shapiro_excel(
  diag_soil_raw,
  outfile = file.path(CONFIG$diag_dir, "Soil Models (Raw)",
                      "shapiro_soil_raw.xlsx")
)

# --- Aggregate stability: treatment * year (Years 1-3) ---
diag_slakes <- run_all_diagnostics(
  vars    = "SLAKES",
  data    = dat_slakes,
  fig_dir = file.path(CONFIG$diag_dir, "Slakes Model")
)

write_shapiro_excel(
  diag_slakes,
  outfile = file.path(CONFIG$diag_dir, "Slakes Model",
                      "shapiro_slakes.xlsx")
)

# --- Crop yield: treatment * year (Years 1-3) ---
diag_yield <- run_all_diagnostics(
  vars    = c("totalYield", "bean", "carrot"),  # kale excluded
  data    = dat_yield,
  fig_dir = file.path(CONFIG$diag_dir, "Yield Models")
)

write_shapiro_excel(
  diag_yield,
  outfile = file.path(CONFIG$diag_dir, "Yield Models",
                      "shapiro_yield.xlsx")
)

# --- Kale yield: treatment * year (Years 2-3 only) ---
diag_kale <- run_all_diagnostics(
  vars    = "kale",
  data    = dat_kale,
  fig_dir = file.path(CONFIG$diag_dir, "Kale Model")
)

write_shapiro_excel(
  diag_kale,
  outfile = file.path(CONFIG$diag_dir, "Kale Model",
                      "shapiro_kale.xlsx")
)

# --- AIC candidate models: bean ~ NH4 ---
diag_bean_nh4 <- run_diagnostics_single(
  response_var = "bean",
  data         = dat_yearly_means,
  fig_dir      = file.path(CONFIG$diag_dir, "AIC Model"),
  formula      = bean ~ NH4 + year
)

# --- AIC candidate models: carrot ~ Mg ---
diag_carrot_mg <- run_diagnostics_single(
  response_var = "carrot1",
  data         = dat_yearly_means,
  fig_dir      = file.path(CONFIG$diag_dir, "AIC Model"),
  formula      = carrot1 ~ Mg + year
)

message("\n✓ All diagnostics complete.")