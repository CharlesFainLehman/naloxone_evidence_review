library(dplyr)
library(ggplot2)
library(readr)

era_cols <- c(
  "Mostly pre-2015" = "#2C7FB8",
  "Mostly post-2015" = "#D95F0E",
  "Balanced around 2015" = "#7A7A7A"
)

relative <- tibble::tribble(
  ~study, ~estimate, ~lower, ~upper, ~era,
  "Walley 2013 — lower-intensity OEND", -27.0, -43.0, -9.0, "Mostly pre-2015",
  "Walley 2013 — higher-intensity OEND", -46.0, -61.0, -24.0, "Mostly pre-2015",
  "Rees et al. 2019", -9.0, -16.0, -2.0, "Mostly pre-2015",
  "Cataife et al. 2021†", -0.2, -20.5, 25.3, "Mostly pre-2015",
  "McClellan et al. 2018", -14.0, -22.0, -1.0, "Mostly pre-2015",
  "Atkins et al. 2019", 10.0, -6.0, 29.0, "Mostly pre-2015",
  "Erfanian et al. 2019", 3.0, -11.0, 18.0, "Mostly pre-2015",
  "Abouk et al. 2019‡", -34.0, -57.5, -10.4, "Mostly pre-2015",
  "Doleac & Mukherjee 2022", 1.0, -8.0, 10.0, "Mostly pre-2015",
  "Sohn et al. 2023§", -16.0, -28.1, -3.9, "Mostly pre-2015",
  "Dowd 2023 — 2018 giveaway", -14.7, -31.0, 5.6, "Mostly post-2015",
  "Dowd 2023 — 2019 giveaway", 26.7, -1.5, 62.9, "Mostly post-2015",
  "HEALing Communities 2024¶", -9.0, -24.0, 9.0, "Mostly post-2015",
  "Freisthler et al. 2024¶", -8.0, -22.0, 7.0, "Mostly post-2015"
)

payne_est <- 2.12
payne_se <- 1.40

absolute <- tibble::tribble(
  ~study, ~estimate, ~lower, ~upper, ~era, ~scaling,
  "Duska et al. 2022", -0.05, -0.43, 0.33, "Balanced around 2015", "Annual estimate",
  "Payne 2026", payne_est, payne_est - 1.96*payne_se, payne_est + 1.96*payne_se, "Mostly post-2015", "Annual estimate",
  "Lee et al. 2021", (1344.3/3000)*4, (627.1/3000)*4, (2061.6/3000)*4, "Mostly pre-2015", "Quarterly × 4",
  "Peet et al. 2024 — NAL pre-Narcan", -0.074*4, (-0.074 - 1.96*0.094)*4, (-0.074 + 1.96*0.094)*4, "Mostly pre-2015", "Quarterly × 4",
  "Peet et al. 2024 — Narcan + existing NAL", -0.143*4, (-0.143 - 1.96*0.075)*4, (-0.143 + 1.96*0.075)*4, "Mostly post-2015", "Quarterly × 4",
  "Peet et al. 2024 — NAL adopted after Narcan", -0.635*4, (-0.635 - 1.96*0.192)*4, (-0.635 + 1.96*0.192)*4, "Mostly post-2015", "Quarterly × 4"
)

forest <- function(dat, title, xlab, xlim = NULL, caption = NULL) {
  p <- dat %>%
    mutate(study = factor(study, levels = rev(study))) %>%
    ggplot(aes(x = estimate, y = study, color = era)) +
    geom_vline(xintercept = 0, linewidth = 0.4, color = "black") +
    geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.16, linewidth = 0.65) +
    geom_point(size = 2.6) +
    scale_color_manual(values = era_cols, name = NULL) +
    labs(title = title, x = xlab, y = NULL, caption = caption) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      plot.caption = element_text(hjust = 0, size = 8)
    )
  if (!is.null(xlim)) p <- p + coord_cartesian(xlim = xlim)
  p
}

p_relative <- forest(
  relative,
  "Naloxone access and overdose mortality: relative effects",
  "Estimated change in overdose mortality (%)",
  c(-68, 70),
  paste(
    "Negative values indicate lower mortality. Color indicates whether most of the study period is pre-2015 or post-2015.",
    "Xuan and Newman are excluded under the fixed-effects/comparison-design rule.",
    "† Cataife uses the homogeneous nationwide model.",
    "‡ Abouk percentage CI derived from reported absolute CI and comparison mean.",
    "§ Sohn percentage CI derived from reported absolute CI.",
    "¶ HEALing/Freisthler are the same multicomponent cluster RCT.",
    sep = "\n"
  )
)

p_absolute <- forest(
  absolute,
  "Naloxone access and overdose mortality: annualized absolute effects",
  "Annualized change in overdose deaths per 100,000",
  c(-4, 5.5),
  paste(
    "Annual estimates are shown as reported; quarterly estimates are multiplied by 4.",
    "Negative values indicate lower mortality. Color indicates whether most of the study period is pre-2015 or post-2015.",
    "Newman is excluded because the specification does not use fixed effects.",
    sep = "\n"
  )
)

# Save into the repository figures directory when run from repo root.
dir.create("figures", showWarnings = FALSE)
ggsave("figures/relative_effects.png", p_relative, width = 11, height = 8.8, dpi = 220)
ggsave("figures/annualized_absolute_effects.png", p_absolute, width = 11, height = 5.2, dpi = 220)

bind_rows(
  relative %>% mutate(panel = "Relative (%)", unit = "percent", scaling = "As reported"),
  absolute %>% mutate(panel = "Annualized absolute", unit = "deaths per 100k per year")
) %>%
  write_csv("data/effects_reproduced.csv")
