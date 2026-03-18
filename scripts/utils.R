# R/utils.R
# VARS LABELS------
soil_vars <- c("pH", "EC", "totalN", "NH4", "P", "K", "Ca", "Mg", "Cu", "Mn", "Zn", "BD", "SOC", "POXC")
crop_vars <- c("totalYield", "bean", "carrot1", "kale")
YEAR_LEVELS <- c("T0", "2022", "2023", "2024")

treat_labels_threshold <- c(
  "1" = "1\nT + F",
  "2" = "2\nT + F\n+Cc",
  "3" = "3\nT + C\n+Cc",
  "4" = "4\nT + C\n+Cc + Gz",
  "5" = "5\nNT + C\n+Cc + Gz"
)

# DATA - T0-2024-----
# Collapse (average) subsamples for 2024
dat_2024_trt_rep_means <- dat %>%
  filter(year == "2024") %>%
  group_by(trt_rep, treatment, replicate) %>%
  summarise(
    across(all_of(soil_vars), ~ mean(.x, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  mutate(year = factor("2024", levels = YEAR_LEVELS)) %>% 
  arrange(treatment, replicate)

# Keep T0 as-is
dat_T0 <- dat %>%
  filter(year == "T0") %>%
  select(trt_rep, treatment, replicate, year, all_of(soil_vars)) %>%
  mutate(year = factor(year, levels = YEAR_LEVELS)) %>% 
  arrange(treatment, replicate)

# Combine T0 + 2024
dat_2024_T0 <- bind_rows(dat_T0, dat_2024_trt_rep_means) %>%
  arrange(treatment, replicate, year)

# DATA - T0-2024 (ALL RAW ROWS; NO COLLAPSING) -----------------------------

dat_RAW <- dat %>%
  filter(year %in% c("T0", "2024")) %>%
  mutate(
    year = factor(year, levels = YEAR_LEVELS),
    treatment = as.factor(treatment)  # optional, only if you want it treated as categorical
  ) %>%
  select(trt_rep, treatment, replicate, year, all_of(soil_vars)) %>%
  arrange(treatment, replicate, year)


# DATA - YIELD ------
dat_yield <- dat %>%
  filter(year != "T0") %>%
  group_by(year, treatment, trt_rep) %>%   # or bed / plot ID
  summarise(
    totalYield = sum(totalYield, na.rm = TRUE),
    bean = sum(bean, na.rm = TRUE),
    carrot = sum(carrot1, na.rm = TRUE),
    kale = sum(kale, na.rm = TRUE),
    .groups = "drop"
  )

# DATA - KALE YIELD -----
dat_kale <- dat %>%
  filter(year != "2022") %>%
  filter(!is.na(kale)) %>%
  mutate(
    year      = factor(as.character(year), levels = c("2023", "2024")),
    treatment = factor(as.character(treatment), levels = c("1","2","3","4","5"))
  )

# DATA - SLAKES------
dat_slakes <- dat %>%
  filter(year %in% c("2022", "2023", "2024")) %>%
  group_by(trt_rep, treatment, year) %>%
  summarise(
    SLAKES = mean(SLAKES, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    year      = factor(year, levels = c("2022", "2023", "2024")),
    treatment = factor(treatment)
  )

# RESIDUAL DIAGNOSTICS -----
check_diagnostics <- function(model, data = NULL) {
  
  # 1. Accept formula input
  if (inherits(model, "formula")) {
    if (is.null(data)) stop("If providing a formula, you must supply data.")
    model <- lm(model, data = data, na.action = na.exclude)
  }
  
  if (!inherits(model, "lm"))
    stop("Model must be an lm object or a formula.")
  
  # Extract model frame
  mf <- model.frame(model)
  df <- data.frame(
    resid  = residuals(model),
    fitted = fitted(model),
    mf
  )
  df <- df[!is.na(df$resid), ]
  
  # Attach external grouping variables from 'data'
  if (!is.null(data)) {
    
    # Try common names for treatment
    treatment_names <- c("treatment", "Treatment", "trt", "Trt")
    trt_col <- treatment_names[treatment_names %in% names(data)][1]
    
    if (!is.na(trt_col)) {
      df$treatment <- factor(data[[trt_col]][match(rownames(df), rownames(data))])
    }
    
    # Year
    if ("year" %in% names(data)) {
      df$year <- factor(data$year[match(rownames(df), rownames(data))])
    }
    
    # Construct trt_year if both exist
    if ("treatment" %in% names(df) && "year" %in% names(df)) {
      df$trt_year <- interaction(df$treatment, df$year, sep = "_")
    }
  }
  
  # 3. Determine grouping variables
  group_vars <- c("treatment", "year", "trt_year")
  group_vars <- group_vars[group_vars %in% names(df)]
  
  # 4. Shapiro Test
  shapiro_result <- shapiro.test(df$resid)
  cat("Shapiro-Wilk test for residuals:\n")
  cat("W =", round(shapiro_result$statistic, 4),
      "| p-value =", round(shapiro_result$p.value, 4), "\n\n")
  
  # 5. Plot layout
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par))
  par(mfrow = c(2, 3), mar = c(4, 4, 2, 1))
  
  # --- Q-Q Plot ---
  car::qqPlot(df$resid, main = "Q-Q Plot",
              ylab = "Residuals", col = "black", pch = 19)
  
  # --- Histogram ---
  hist(df$resid, breaks = 30, freq = FALSE,
       main = "Residuals", xlab = "Residuals", col = "grey")
  lines(density(df$resid), col = "red", lwd = 2)
  
  # --- Residuals vs Fitted ---
  plot(df$fitted, df$resid,
       xlab = "Fitted values", ylab = "Residuals",
       main = "Residuals vs Fitted", pch = 19)
  abline(h = 0, lty = 2)
  
  # --- Residuals grouped by trt/year/trt_year ---
  slots_remaining <- 3
  i <- 1
  
  while (i <= slots_remaining) {
    if (i <= length(group_vars)) {
      gv <- group_vars[i]
      boxplot(df$resid ~ df[[gv]],
              main = paste("Residuals by", gv),
              xlab = gv, ylab = "Residuals")
      abline(h = 0, lty = 2)
    } else {
      plot.new()
    }
    i <- i + 1
  }
  
  invisible(list(model = model,
                 shapiro = shapiro_result,
                 residual_df = df))
}


# PLOT MODEL WITH RAW VALUES -----

plot_pred_with_raw <- function(model, data, response_var,
                               x = "treatment", facet_by = "year",
                               y_label = NULL,
                               point_alpha = 0.4, point_size = 2) {
  
  # If user didn't specify a label, use the column name
  if (is.null(y_label)) {
    y_label <- response_var
  }
  
  # 1. Build prediction grid
  newdat <- expand_grid(
    treatment = unique(data$treatment),
    year      = unique(data$year)
  )
  
  # 2. Predict with SE from fixed effects only
  p <- predict(model, newdata = newdat, se.fit = TRUE, re.form = NA)
  
  preds <- newdat %>%
    mutate(
      fit   = p$fit,
      se    = p$se.fit,
      lower = fit - 1.96 * se,
      upper = fit + 1.96 * se
    )
  
  # 3. Raw data
  raw <- data %>%
    select(treatment, year, all_of(response_var)) %>%
    rename(y = all_of(response_var))
  
  # 4. Plot
  ggplot() +
    geom_jitter(
      data = raw,
      aes_string(x = x, y = "y"),
      width = 0.1, alpha = point_alpha,
      size = point_size, color = "grey40"
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
    labs(
      x = "Treatment",
      y = y_label,
      title = paste("Fitted Model Predictions + Raw Data for", response_var)
    ) +
    theme_bw(base_size = 14)
}

# MODELS WITH RAW - CONTINUOUS -------
plot_pred_with_raw_indicator <- function(model, data, response_var, indicator_var,
                                         facet_by = "year",
                                         x_label = NULL,
                                         y_label = NULL,
                                         point_alpha = 0.4, point_size = 2) {
  
  # Auto label
  if (is.null(y_label)) y_label <- response_var
  
  # --- Determine which years were used in the model ---
  model_years <- model$xlevels$year   # ensures no "new level" mismatch
  
  # --- Generate prediction grid ---
  newdat <- expand_grid(
    !!sym(indicator_var) := seq(
      min(data[[indicator_var]], na.rm = TRUE),
      max(data[[indicator_var]], na.rm = TRUE),
      length.out = 100
    ),
    year = factor(model_years, levels = model_years)
  )
  
  # --- Predictions ---
  p <- predict(model, newdata = newdat, se.fit = TRUE)
  
  preds <- newdat %>%
    mutate(
      fit   = p$fit,
      se    = p$se.fit,
      lower = fit - 1.96 * se,
      upper = fit + 1.96 * se
    )
  
  # --- Raw data ---
  raw <- data %>%
    filter(year %in% model_years) %>%  # prevent raw-level mismatch too
    select(all_of(indicator_var), year, all_of(response_var)) %>%
    rename(
      x = all_of(indicator_var),
      y = all_of(response_var)
    )
  
  # --- Plot ---
  ggplot() +
    geom_point(
      data = raw,
      aes(x = x, y = y),
      alpha = point_alpha,
      size  = point_size,
      color = "grey40"
    ) +
    geom_ribbon(
      data = preds,
      aes(x = !!sym(indicator_var), ymin = lower, ymax = upper, fill = year),
      alpha = 0.15
    ) +
    geom_line(
      data = preds,
      aes(x = !!sym(indicator_var), y = fit, color = year),
      size = 1
    ) +
    facet_wrap(as.formula(paste("~", facet_by))) +
    labs(
      x = x_label,
      y = y_label,
      title = element_blank()
    ) +
    theme_bw(base_size = 14)
}

# PLOT WITH THRESHOLDS --------
plot_model_with_thresholds <- function(
    model,
    data,
    response_var,
    adequacy_low = NULL,
    adequacy_high = NULL,
    excessive = NULL,
    y_label = NULL,
    star_y_offset = 25,
    raw_alpha = 0.35,
    raw_size = 2,
    dodge_width = 0.45,
    y_limits = NULL,
    y_break_by = NULL
) {
  
# Build thresholds list internally
  thresholds <- NULL
  
  if (!is.null(adequacy_low) | !is.null(adequacy_high)) {
    thresholds <- list(
      low    = if (!is.null(adequacy_low))  c(0, adequacy_low) else NULL,
      medium = if (!is.null(adequacy_low) & !is.null(adequacy_high))
        c(adequacy_low, adequacy_high) else NULL,
      high   = if (!is.null(adequacy_high))
        c(adequacy_high, ifelse(is.null(excessive), Inf, excessive)) else NULL,
      vhigh  = if (!is.null(excessive)) c(excessive, Inf) else NULL
    )
  }
  

# 1. Factor order + label
  data <- data %>%
    mutate(
      year = factor(year, levels = c("T0", "2024")),
      treatment = factor(treatment, levels = c("1","2","3","4","5"))
    )
  
  if (is.null(y_label)) y_label <- response_var
  
# 2. Prediction grid
  newdat <- expand_grid(
    treatment = levels(data$treatment),
    year      = levels(data$year)
  )
  
  p <- predict(model, newdata = newdat, se.fit = TRUE, re.form = NA)
  
  preds <- newdat %>%
    mutate(
      fit   = p$fit,
      se    = p$se.fit,
      lower = fit - 1.96 * se,
      upper = fit + 1.96 * se,
      year  = factor(year, levels = c("T0", "2024"))
    )
  
# 3. Raw data
  raw <- data %>%
    rename(y = all_of(response_var))

# 4. Significance (T0 vs 2024)
  emm <- emmeans(model, ~ treatment * year)
  
  cont <- contrast(emm, method = "pairwise", by = "treatment", adjust = "tukey") %>%
    as.data.frame() %>%
    filter(contrast %in% c("2024 - T0", "T0 - 2024")) %>%
    mutate(
      stars = case_when(
        p.value < 0.001 ~ "***",
        p.value < 0.01  ~ "**",
        p.value < 0.05  ~ "*",
        TRUE           ~ ""
      )
    )
  
 # find max upper CI across both years
  star_df <- preds %>%
    group_by(treatment) %>%
    summarise(max_upper = max(upper, na.rm = TRUE)) %>%
    left_join(cont %>% select(treatment, stars), by = "treatment") %>%
    mutate(star_y = max_upper + star_y_offset)
  
  

# 5. Build plot

  g <- ggplot()
  
  # --- Threshold shading ---
  if (!is.null(thresholds)) {
    
    # Helper to clip shading to y-limits
    clip_range <- function(x, lims) {
      c(max(x[1], lims[1]), min(x[2], lims[2]))
    }
    
    # Determine visible y-range for clipping
    lims <- if (!is.null(y_limits)) y_limits else c(-Inf, Inf)
    
    # LOW zone
    if (!is.null(thresholds$low)) {
      r <- clip_range(thresholds$low, lims)
      if (r[1] < r[2]) {
        g <- g + annotate("rect", xmin=-Inf, xmax=Inf,
                          ymin=r[1], ymax=r[2],
                          fill="grey70", alpha=0.10)
      }
    }
    
    # ADEQUATE zone
    if (!is.null(thresholds$medium)) {
      r <- clip_range(thresholds$medium, lims)
      if (r[1] < r[2]) {
        g <- g + annotate("rect", xmin=-Inf, xmax=Inf,
                          ymin=r[1], ymax=r[2],
                          fill="green4", alpha=0.15)
      }
    }
    
    # HIGH zone
    if (!is.null(thresholds$high)) {
      r <- clip_range(thresholds$high, lims)
      if (r[1] < r[2]) {
        g <- g + annotate("rect", xmin=-Inf, xmax=Inf,
                          ymin=r[1], ymax=r[2],
                          fill="orange", alpha=0.12)
      }
    }
    
    # EXCESSIVE zone
    if (!is.null(thresholds$vhigh)) {
      r <- clip_range(thresholds$vhigh, lims)
      if (r[1] < r[2]) {
        g <- g + annotate("rect", xmin=-Inf, xmax=Inf,
                          ymin=r[1], ymax=r[2],
                          fill="red", alpha=0.10)
      }
    }
    
    # --- Threshold dashed lines (clipped to y-limits) ---
    clip_value <- function(v, lims) v >= lims[1] & v <= lims[2]
    
    # LOW upper boundary
    if (!is.null(thresholds$low)) {
      v <- thresholds$low[2]
      if (is.null(y_limits) || clip_value(v, y_limits)) {
        g <- g + geom_hline(yintercept = v,
                            linetype="dashed", colour="grey30")
      }
    }
    
    # ADEQUATE upper boundary
    if (!is.null(thresholds$medium)) {
      v <- thresholds$medium[2]
      if (is.null(y_limits) || clip_value(v, y_limits)) {
        g <- g + geom_hline(yintercept = v,
                            linetype="dashed", colour="grey30")
      }
    }
    
    # HIGH upper boundary
    if (!is.null(thresholds$high)) {
      v <- thresholds$high[2]
      if (is.null(y_limits) || clip_value(v, y_limits)) {
        g <- g + geom_hline(yintercept = v,
                            linetype="dashed", colour="grey30")
      }
    }
    
    # VERY HIGH lower boundary (excessive)
    if (!is.null(thresholds$vhigh)) {
      v <- thresholds$vhigh[1]
      if (is.null(y_limits) || clip_value(v, y_limits)) {
        g <- g + geom_hline(yintercept = v,
                            linetype="dashed", colour="grey30")
      }
    }
  }
    
# Raw data (grey)

  g <- g +
    geom_point(
      data = raw,
      aes(x = treatment, y = y, fill = year),
      shape = 21,
      colour = "grey40",
      alpha = raw_alpha,
      size = raw_size,
      position = position_jitterdodge(jitter.width = 0.1, dodge.width = dodge_width)
    )
  
# Model predictions + CI

  g <- g +
    geom_errorbar(
      data = preds,
      aes(x = treatment, ymin = lower, ymax = upper, fill = year),
      width = 0.12,
      size = 0.8,
      position = position_dodge(width = dodge_width)
    ) +
    geom_point(
      data = preds,
      aes(x = treatment, y = fit, fill = year),
      shape = 21,
      colour = "black",
      size = 3,
      stroke = 0.7,
      position = position_dodge(width = dodge_width)
    )
  
# Significance star
  g <- g +
    geom_text(
      data = star_df,
      aes(x = treatment, y = star_y, label = stars),
      size = 9,
      vjust = 0,
      position = position_dodge(width = dodge_width)
    )
  
# Add threshold legend

  if (!is.null(thresholds)) {
    
    threshold_legend_df <- tibble(
      zone = factor(
        c("Low", "Adequate", "High", "Excessive"),
        levels = c("Low", "Adequate", "High", "Excessive")
      ),
      x = 1, y = 1
    )
    
    g <- g +
      geom_point(
        data = threshold_legend_df,
        aes(x = x, y = y, colour = zone),
        shape = 15, size = 5, show.legend = TRUE
      ) +
      
      scale_colour_manual(
        name = "Nutrient Level",
        values = c(
          "Low"      = "grey70",
          "Adequate" = "green4",
          "High"     = "orange",
          "Excessive"= "red"
        )
      ) +
      
      guides(
        fill = guide_legend(
          order = 1,
          override.aes = list(colour = NA)  # year legend fix
        ),
        colour = guide_legend(
          order = 2,
          override.aes = list(alpha = 0.45, size = 6)
        )
      )
  }
  
# Axis / Theme / Legend
  if (!is.null(y_limits) && !is.null(y_break_by)) {
    
    # User provided limits + break interval
    g <- g +
      scale_fill_manual(
        name = "Year",
        values = c("T0" = "grey60", "2024" = "black"),
        labels = c("T0" = "T0", "2024" = "Year 3")
      ) +
      scale_y_continuous(
        limits = y_limits,
        breaks = seq(y_limits[1], y_limits[2], by = y_break_by),
        expand = expansion(mult = c(0, 0.05))
      )
    
  } else {
    
# Fallback: automatic axis (same as before)
    g <- g +
      scale_fill_manual(
        name = "Year",
        values = c("T0" = "grey60", "2024" = "black"),
        labels = c("T0" = "T0", "2024" = "Year 3")
      ) +
      scale_y_continuous(
        breaks = pretty_breaks(n = 6),
        expand = expansion(mult = c(0, 0.05))
      )
  }
  
  g <- g +
    labs(
      x = NULL,
      y = y_label
    ) +
    theme_minimal(base_size = 18) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.text.x = element_text(
        size = 14, 
        margin = margin(t = 10),
        colour = "black"
      ),
      legend.position = "right",
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 13)
    )

#  Optional y-axis limits
  if (!is.null(y_limits)) {
    
    if (is.character(y_limits) && y_limits == "auto") {
      
      # raw data range
      raw_min <- min(raw$y, na.rm = TRUE)
      raw_max <- max(raw$y, na.rm = TRUE)
      
      # threshold range
      t_min <- min(c(adequacy_low, adequacy_high, excessive), na.rm = TRUE)
      t_max <- max(c(adequacy_low, adequacy_high, excessive), na.rm = TRUE)
      
      # padding
      lower <- floor(min(raw_min, t_min) * 0.9)
      upper <- ceiling(t_max)
      
      g <- g + coord_cartesian(ylim = c(lower, upper))
      
    } else if (is.numeric(y_limits) && length(y_limits) == 2) {
      
      g <- g + coord_cartesian(ylim = y_limits)
      
    }
  }
  
  
  return(g)
  }

