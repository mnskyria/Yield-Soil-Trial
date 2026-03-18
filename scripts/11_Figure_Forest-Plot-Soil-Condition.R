# ============================================================
# 11_Figure_Forest-Plot-Soil-Condition
# ============================================================

# ----------------- 1. SELECT FERTILITY VARIABLES -----------------
condition_vars <- c(
  "SOC","POXC", "BD"
)

indicator_labels_condition <- c(
  SOC="Soil Organic Carbon", POXC="POX-C", BD="Bulk Density"
)


health_labels <- indicator_labels_condition[condition_vars]

summary_data_condition <- dat %>%
  filter(year %in% c("T0","2024")) %>%
  pivot_longer(cols = all_of(condition_vars), names_to = "variable", values_to = "value") %>%
  group_by(variable, treatment, year) %>%
  summarise(
    mean = mean(value, na.rm = TRUE),
    sd   = sd(value, na.rm = TRUE),
    se   = sd(value, na.rm = TRUE)/sqrt(sum(!is.na(value))),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = year, values_from = c(mean, sd, se), names_sep = "_") %>%
  drop_na(mean_T0, mean_2024, sd_T0, se_2024)

summary_scaled_condition <- summary_data_condition %>%
  mutate(
    scaled_change = (mean_2024 - mean_T0) / sd_T0,
    scaled_se     = se_2024 / sd_T0
  )

# Filter summary data for fertility only
condition_data <- summary_scaled_condition %>%
  filter(variable %in% condition_vars) %>%
  mutate(variable_label = factor(
    indicator_labels_condition[variable],
    levels = indicator_labels_condition[condition_vars]
  ))

# ----------------- 2. CREATE T0 GREY RIBBON -----------------
# We expand each T0 mean ± SE across x range for a shaded bar
t0_ribbons_condition <- condition_data %>%
  mutate(
    xmin = (mean_T0 - se_T0) / sd_T0 * 0,   # convert to scaled relative to T0
    xmax = (mean_T0 + se_T0) / sd_T0 * 0,
    # But since scaled_change is standardized change, T0 = 0.
    # So the ribbon is simply ± (se_T0 / sd_T0)
    xmin = - (se_T0 / sd_T0),
    xmax =  (se_T0 / sd_T0)
  ) %>%
  select(variable_label, xmin, xmax) %>%
  distinct()

# ----------------- 3. SOIL CONDITION FOREST PLOT -----------------
summary_scaled_condition <- summary_scaled_condition |>
  dplyr::mutate(treatment = factor(treatment, levels = c("1","2","3","4","5")))

# legend labels (use \n if you want multi-line)
treat_labels_condition <- c(
  "1" = "1: T + F",
  "2" = "2: T + F + Cc",
  "3" = "3: T + C + Cc",
  "4" = "4: T + C + Cc + Gz",
  "5" = "5: NT + C + Cc + Gz"
)


p_condition <- ggplot(condition_data,
                   aes(x = scaled_change, y = fct_rev(variable_label))) +
  
  # soft grey T0 CI ribbon
  geom_rect(
    data = t0_ribbons_condition,
    aes(ymin = as.numeric(fct_rev(variable_label)) - 0.45,
        ymax = as.numeric(fct_rev(variable_label)) + 0.45,
        xmin = xmin, xmax = xmax),
    inherit.aes = FALSE,
    fill = "grey90", alpha = 0.5
  ) +
  
  # zero line
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.4) +
  
  # error bars for treatment points
  geom_errorbarh(
    aes(xmin = scaled_change - scaled_se,
        xmax = scaled_change + scaled_se),
    height = 0.22, color = "grey30", linewidth = 0.35
  ) +
  
  geom_point(
    aes(shape = treatment, fill = treatment),
    size = 2.8, stroke = 0.7, color = "black"
  ) +
  
  scale_fill_grey(start = 0.15, end = 0.85,
                  name   = "Treatment",
                  breaks = names(treat_labels),
                  labels = treat_labels) +
  scale_shape_manual(values = c("1"=21,"2"=22,"3"=24,"4"=23,"5"=25),
                     name   = "Treatment",
                     breaks = names(treat_labels),
                     labels = treat_labels) +
  
  labs(
    x = "Standardized Change From T0 to Year 3 (Z-Score)",
    y = NULL,
  ) +
  
  theme_bw(base_size = 13) +
  theme(
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_line(color = "grey85"),
    panel.grid.major.x = element_line(color = "grey85"),
    panel.border       = element_rect(color = "black", fill = NA),
    
    # AXES
    axis.text.y  = element_text(size = 12.5, colour = "black"),
    axis.text.x  = element_text(size = 12, margin = margin(t = 10), colour = "black"),
    axis.title.x = element_text(size = 12, margin = margin(t = 10)),
    plot.title   = element_text(hjust = 0, face = "bold"),
    
    # WHITESPACE BETWEEN ROWS
    panel.spacing.y = unit(1.0, "lines"),
    
    # LEGEND (inset)
    legend.position = c(0.98, 0.55),
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



p_condition

# ----------------- 4. EXPORT -----------------
ggsave(
  "forest_condition.png",
  plot   = p_condition,
  path   = file.path(CONFIG$figs_dir, "Forest Plots"),
  width  = 7.5,
  height = 3,
  units  = "in",
  dpi    = 300
)
