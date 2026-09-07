library(dplyr)
library(ggplot2)
library(readr)
library(scales)

# Palette / house style
cf_ink    <- "#111111"
cf_mute   <- "#8A8A8A"
cf_grid   <- "#E8E8E8"
cf_axis   <- "#5A5A5A"
cf_sub    <- "#7A7A7A"
cf_orange <- "#E8532B"
cf_blue   <- "#1F77D0"

theme_cf <- function(title_size = 36) {
  theme_minimal(base_family = "Liberation Sans", base_size = 20) +
    theme(
      plot.background    = element_rect(fill = "white", color = NA),
      panel.background   = element_rect(fill = "white", color = NA),
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(color = cf_grid, linewidth = 0.6),
      axis.text          = element_text(color = cf_axis, size = 21),
      axis.ticks         = element_blank(),
      plot.title         = element_text(face = "bold", size = title_size,
                                        color = cf_ink, margin = margin(b = 10)),
      plot.subtitle      = element_text(size = 21, color = cf_sub,
                                        margin = margin(b = 34)),
      plot.caption       = element_text(size = 15, color = cf_mute, hjust = 0,
                                        lineheight = 1.25, margin = margin(t = 26)),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.margin        = margin(36, 40, 26, 30)
    )
}

cf_caption <- function(source) {
  paste0("Source: ", source, "\nChart created with the help of ChatGPT.")
}

cf_save <- function(p, stem) {
  ggsave(paste0(stem, ".png"), p, device = ragg::agg_png,
         width = 1600, height = 900, units = "px", dpi = 100, bg = "white")
  ggsave(paste0(stem, ".svg"), p, device = grDevices::svg,
         width = 16, height = 9, units = "in", bg = "white")
}

relative <- tibble::tribble(
  ~study, ~estimate, ~lower, ~upper,
  "Rees et al. 2019", -9.0, -16.0, -2.0,
  "Cataife et al. 2021†", -0.2, -20.5, 25.3,
  "McClellan et al. 2018", -14.0, -22.0, -1.0,
  "Atkins et al. 2019", 10.0, -6.0, 29.0,
  "Erfanian et al. 2019", 3.0, -11.0, 18.0,
  "Abouk et al. 2019‡", -34.0, -57.5, -10.4,
  "Doleac & Mukherjee 2022", 1.0, -8.0, 10.0,
  "Sohn et al. 2023§", -16.0, -28.1, -3.9,
  "Dowd 2023 — 2018 giveaway", -14.7, -31.0, 5.6,
  "Dowd 2023 — 2019 giveaway", 26.7, -1.5, 62.9,
  "HEALing Communities 2024¶", -9.0, -24.0, 9.0,
  "Freisthler et al. 2024¶", -8.0, -22.0, 7.0
)

payne_est <- 2.12
payne_se <- 1.40

absolute <- tibble::tribble(
  ~study, ~estimate, ~lower, ~upper, ~scaling,
  "Duska et al. 2022", -0.05, -0.43, 0.33, "Annual estimate",
  "Payne 2026", payne_est, payne_est - 1.96 * payne_se, payne_est + 1.96 * payne_se, "Annual estimate",
  "Lee et al. 2021", (1344.3 / 3000) * 4, (627.1 / 3000) * 4, (2061.6 / 3000) * 4, "Quarterly × 4",
  "Peet et al. 2024 — NAL pre-Narcan", -0.074 * 4, (-0.074 - 1.96 * 0.094) * 4, (-0.074 + 1.96 * 0.094) * 4, "Quarterly × 4",
  "Peet et al. 2024 — Narcan + existing NAL", -0.143 * 4, (-0.143 - 1.96 * 0.075) * 4, (-0.143 + 1.96 * 0.075) * 4, "Quarterly × 4",
  "Peet et al. 2024 — NAL adopted after Narcan", -0.635 * 4, (-0.635 - 1.96 * 0.192) * 4, (-0.635 + 1.96 * 0.192) * 4, "Quarterly × 4"
)

forest_cf <- function(dat, title, subtitle, xlab, caption, accent,
                      xlim = NULL, percent_axis = FALSE) {
  p <- dat %>%
    mutate(study = factor(study, levels = rev(study))) %>%
    ggplot(aes(x = estimate, y = study)) +
    geom_vline(xintercept = 0, color = cf_axis, linewidth = 0.7) +
    geom_errorbarh(aes(xmin = lower, xmax = upper),
                   height = 0.13, linewidth = 1.1, color = accent) +
    geom_point(size = 4.2, color = accent) +
    labs(
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = xlab,
      y = NULL
    ) +
    theme_cf() +
    theme(
      axis.text.y = element_text(size = 16),
      axis.title.x = element_text(color = cf_axis, size = 18, margin = margin(t = 16))
    )

  if (percent_axis) {
    p <- p + scale_x_continuous(labels = label_number(suffix = "%"))
  } else {
    p <- p + scale_x_continuous(labels = label_number(accuracy = 0.1))
  }

  if (!is.null(xlim)) p <- p + coord_cartesian(xlim = xlim)
  p
}

p_relative <- forest_cf(
  relative,
  title = "Naloxone access and overdose mortality",
  subtitle = "Relative effects; negative values indicate lower mortality",
  xlab = "Estimated change in overdose mortality",
  caption = cf_caption("studies listed in README; calculations described in code/plot_effects.R."),
  accent = cf_blue,
  xlim = c(-68, 70),
  percent_axis = TRUE
)

p_absolute <- forest_cf(
  absolute,
  title = "Naloxone access and overdose mortality",
  subtitle = "Annualized absolute effects; negative values indicate lower mortality",
  xlab = "Annualized change in overdose deaths per 100,000",
  caption = cf_caption("studies listed in README; quarterly estimates annualized ×4."),
  accent = cf_orange,
  xlim = c(-4, 5.5),
  percent_axis = FALSE
)

dir.create("figures", showWarnings = FALSE)
dir.create("data", showWarnings = FALSE)

cf_save(p_relative, "figures/relative_effects")
cf_save(p_absolute, "figures/annualized_absolute_effects")

bind_rows(
  relative %>% mutate(panel = "Relative (%)", unit = "percent", scaling = "As reported"),
  absolute %>% mutate(panel = "Annualized absolute", unit = "deaths per 100k per year")
) %>%
  write_csv("data/effects_reproduced.csv")
