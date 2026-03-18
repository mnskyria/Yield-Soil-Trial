# ============================================================
# 10_Figure_Forest-Plot-Fertility.R
# ============================================================

# ----------------- 1. SELECT FERTILITY VARIABLES -----------------
fertility_vars <- c(
  "pH","EC", "totalN", "NH4","P","K","Ca","Mg","Cu","Mn","Zn"
)

indicator_labels_fert <- c(
  pH="pH", EC="Electrical Conductivity", 
  totalN = "Total Nitrogen", NH4 = "NH₄⁺ Mineralization",
  P="MIII Phosphorus", K="MIII Potassium", 
  Ca="MIII Calcium", Mg="MIII Magnesium", 
  Cu="MIII Copper", Mn="MIII Manganese", Zn="MIII Zinc"
)


fertility_labels <- indicator_labels_fert[fertility_vars]

summary_data_fert <- dat %>%
  filter(year %in% c("T0","2024")) %>%
  pivot_longer(cols = all_of(fertility_vars), names_to = "variable", values_to = "value") %>%
  group_by(variable, treatment, year) %>%
  summarise(
    mean = mean(value, na.rm = TRUE),
    sd   = sd(value, na.rm = TRUE),
    se   = sd(value, na.rm = TRUE)/sqrt(sum(!is.na(value))),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = year, values_from = c(mean, sd, se), names_sep = "_") %>%
  drop_na(mean_T0, mean_2024, sd_T0, se_2024)

summary_scaled_fert <- summary_data_fert %>%
  mutate(
    scaled_change = (mean_2024 - mean_T0) / sd_T0,
    scaled_se     = se_2024 / sd_T0
  )

# Filter summary data for fertility only
fertility_data <- summary_scaled_fert %>%
  filter(variable %in% fertility_vars) %>%
  mutate(variable_label = factor(
    indicator_labels_fert[variable],
    levels = indicator_labels_fert[fertility_vars]
  ))

# ----------------- 2. CREATE T0 GREY RIBBON -----------------
# We expand each T0 mean ± SE across x range for a shaded bar
t0_ribbons_fert <- fertility_data %>%
  mutate(
    xmin = (mean_T0 - se_T0) / sd_T0,
    xmax = (mean_T0 + se_T0) / sd_T0,
    xmin = - (se_T0 / sd_T0),
    xmax =  (se_T0 / sd_T0)
  ) %>%
  select(variable_label, xmin, xmax) %>%
  distinct()

# ----------------- 3. FERTILITY FOREST PLOT -----------------

# ensure ordering
summary_scaled_fert <- summary_scaled_fert |>
  dplyr::mutate(treatment = factor(treatment, levels = c("1","2","3","4","5")))

# legend labels (use \n if you want multi-line)
treat_labels <- c(
  "1" = "1: T + F",
  "2" = "2: T + F + Cc",
  "3" = "3: T + C + Cc",
  "4" = "4: T + C + Cc + Gz",
  "5" = "5: NT + C + Cc + Gz"
)

p_fertility <- ggplot(fertility_data,
                      aes(x = scaled_change, y = fct_rev(variable_label))) +
  
  # T0 CI ribbon
  geom_rect(
    data = t0_ribbons_fert,
    aes(
      ymin = as.numeric(fct_rev(variable_label)) - 0.45,
      ymax = as.numeric(fct_rev(variable_label)) + 0.45,
      xmin = xmin, xmax = xmax
    ),
    inherit.aes = FALSE,
    fill = "grey90", alpha = 0.5
  ) +
  
  # zero line
  geom_vline(xintercept = 0,
             linetype = "dashed",
             color = "grey40",
             linewidth = 0.4) +
  
  # treatment SE bars
  geom_errorbarh(
    aes(xmin = scaled_change - scaled_se,
        xmax = scaled_change + scaled_se),
    height = 0.22,
    color = "grey30",
    linewidth = 0.35
  ) +
  
  # treatment points
  geom_point(
    aes(shape = treatment, fill = treatment),
    size = 2.8, stroke = 0.7, color = "black"
  ) +
  
  # Greyscale fill
  scale_fill_grey(start = 0.2, end = 0.8,
                  name = "Treatment",
                  breaks = names(treat_labels),
                  labels = treat_labels) +
  scale_shape_manual(
    values = c("1" = 21, "2" = 22, "3" = 24, "4" = 23, "5" = 25),
    name = "Treatment",
    breaks = names(treat_labels),
    labels = treat_labels
  ) +
  
  labs(
    x = "Standardized Change From T0 to 2024 (Z-Score)",
    y = NULL
  ) +
  
  theme_bw(base_size = 13) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(color = "grey85", linewidth = 0.4),
    panel.grid.major.x = element_line(color = "grey85", linewidth = 0.4),
    
    # AXES
    axis.text.y  = element_text(size = 12.5, colour = "black"),
    axis.text.x  = element_text(size = 12, margin = margin(t = 8), colour = "black"),
    axis.title.x = element_text(size = 12, margin = margin(t = 12)),
    
    # panel border
    panel.border = element_rect(color = "black", fill = NA),
    
    # vertical spacing
    panel.spacing.y = unit(1.0, "lines"),
    
    # legend
    legend.position = c(0.98, 0.28),
    legend.justification = c("right", "top"),
    legend.key.size = unit(0.6, "lines"),
    legend.spacing.y = unit(0.05, "lines"),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 12),
    legend.background = element_rect(
      fill = alpha("white", 0.9),
      color = "grey60",
      size = 0.4
    )
  ) +
  
  guides(
    fill  = guide_legend(override.aes = list(size = 2.2, stroke = 0.6)),
    shape = guide_legend(override.aes = list(size = 2.2, stroke = 0.6))
  )


p_fertility 

# ----------------- 4.EXPORT -----------------
ggsave(
  "forest_fertility.png",
  plot   = p_fertility,
  path   = file.path(CONFIG$figs_dir, "Forest Plots"),
  width  = 7.5,
  height = 5.2,
  units  = "in",
  dpi    = 300
)

