library(dplyr)
library(ggplot2)
library(readr)
library(scales)

# Labels contain non-ASCII characters; make sure the session is UTF-8 so ragg/svg render them.
if (!grepl("UTF-8", Sys.getlocale("LC_CTYPE"), ignore.case = TRUE)) {
  try(Sys.setlocale("LC_CTYPE", "C.UTF-8"), silent = TRUE)
}

# ---------------------------------------------------------------------------
# Palette / house style
# ---------------------------------------------------------------------------
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
  paste0("Source: ", source, "\nChart created with the help of ChatGPT and Claude.")
}

cf_save <- function(p, stem) {
  ggsave(paste0(stem, ".png"), p, device = ragg::agg_png,
         width = 1600, height = 900, units = "px", dpi = 100, bg = "white")
  ggsave(paste0(stem, ".svg"), p, device = grDevices::svg,
         width = 16, height = 9, units = "in", bg = "white")
}

# ---------------------------------------------------------------------------
# Conversion helpers. Every derived number in the tables is produced here so
# the derivation is inspectable.
# ---------------------------------------------------------------------------

# Percent change and 95% CI from a log-scale coefficient and standard error.
pct_from_log <- function(b, se) {
  c((exp(b) - 1), (exp(b - 1.96 * se) - 1), (exp(b + 1.96 * se) - 1)) * 100
}

# Percent change and 95% CI from a reported rate ratio and a two-sided p-value
# (used when the paper prints a ratio and a p-value but no interval).
pct_from_ratio_p <- function(rr, p) {
  b  <- log(rr)
  se <- abs(b) / qnorm(1 - p / 2)
  pct_from_log(b, se)
}

# Percent change and 95% CI from an absolute effect (with CI) and a baseline mean.
pct_from_abs <- function(est, lo, hi, base) c(est, lo, hi) / base * 100

# Point and 95% CI from an estimate and a two-sided p-value (level coefficient).
ci_from_p <- function(est, p) {
  se <- abs(est) / qnorm(1 - p / 2)
  c(est, est - 1.96 * se, est + 1.96 * se)
}

# Point and 95% CI from an estimate and standard error.
ci_from_se <- function(est, se) c(est, est - 1.96 * se, est + 1.96 * se)

row3 <- function(study, v, ...) {
  tibble::tibble(study = study, estimate = v[1], lower = v[2], upper = v[3], ...)
}

# ---------------------------------------------------------------------------
# Relative effects (percent change in overdose mortality)
# ---------------------------------------------------------------------------
relative <- bind_rows(
  row3("McClellan et al. 2018",
       pct_from_ratio_p(0.86, 0.033),
       policy = "Naloxone access law",
       outcome = "Opioid overdose deaths",
       derivation = "IRR 0.86 and p = 0.033 from text; no CI printed in the paper; CI derived from the p-value",
       study_url = "https://pubmed.ncbi.nlm.nih.gov/29610001/"),
  row3("Rees et al. 2019",
       pct_from_log(-0.095, 0.039),
       policy = "Naloxone access law",
       outcome = "Opioid-related deaths (multiple-cause T-codes)",
       derivation = "exp(b) - 1 from Poisson coefficient -0.095 (SE 0.039), JLE Table 3 col. 4 (Poisson, full controls); OLS columns give -0.166 and -0.240 (15-21%); authors summarize as 9-10%",
       study_url = "https://chicagounbound.uchicago.edu/jle/vol62/iss1/1/"),
  row3("Atkins et al. 2019",
       pct_from_log(0.0943, 0.0805),
       policy = "Naloxone access law (any naloxone policy)",
       outcome = "Opioid overdose deaths (T40.1-T40.4, T40.6)",
       derivation = "exp(b) - 1 from Poisson coefficient 0.0943 (SE 0.0805), Table 4 Panel B",
       study_url = "https://pmc.ncbi.nlm.nih.gov/articles/PMC6407344/"),
  row3("Abouk et al. 2019‡",
       pct_from_abs(-0.387, -0.656, -0.119, 1.14),
       policy = "Naloxone access law (direct pharmacist authority)",
       outcome = "Opioid overdose deaths",
       derivation = "Absolute effect -0.387 (-0.656, -0.119) per 100k per month, 3+ years post, divided by comparison mean 1.14",
       study_url = "https://pmc.ncbi.nlm.nih.gov/articles/PMC6503576/"),
  row3("Cataife et al. 2021†",
       pct_from_log(-0.002, 0.116),
       policy = "Naloxone access law",
       outcome = "Opioid-related deaths",
       derivation = "exp(b) - 1 from OLS coefficient -0.002 (SE 0.116), Table 1 Model 1 (homogeneous static model)",
       study_url = "https://pubmed.ncbi.nlm.nih.gov/31951788/"),
  row3("Doleac & Mukherjee 2022",
       pct_from_abs(0.006, 0.006 - 1.96 * 0.027, 0.006 + 1.96 * 0.027, 0.601),
       policy = "Naloxone access law (third-party or standing order)",
       outcome = "Opioid-related deaths, urban counties",
       derivation = "Level coefficient 0.006 (SE 0.027) on 2010 baseline 0.601 per 100k per month, JLE Table 4",
       study_url = "https://www.journals.uchicago.edu/doi/10.1086/719588"),
  row3("Sohn et al. 2023§",
       c(-16.0, -28.1, -3.9),
       policy = "Naloxone co-prescribing mandate",
       outcome = "Prescription/treatment-opioid overdose deaths",
       derivation = "Absolute effect -8.61 (-15.13, -2.09) per state-quarter, stated as a 16% reduction; CI scaled proportionally. Abstract only; full text pending",
       study_url = "https://www.sciencedirect.com/science/article/abs/pii/S0749379722005281"),
  row3("Dowd 2023 — 2018 giveaway",
       (c(0.853, 0.690, 1.056) - 1) * 100,
       policy = "Naloxone giveaway (distribution event)",
       outcome = "Opioid overdose deaths, tract-quarter, Philadelphia and Pittsburgh areas",
       derivation = "Table 2 fixed-effects Poisson IRR 0.853 [0.690-1.056], treated = tracts within 3 km of a 13 Dec 2018 giveaway site, two post quarters",
       study_url = "https://onlinelibrary.wiley.com/doi/full/10.1002/hec.4755"),
  row3("Dowd 2023 — 2019 giveaway",
       (c(1.267, 0.985, 1.629) - 1) * 100,
       policy = "Naloxone giveaway (distribution event)",
       outcome = "Opioid overdose deaths, tract-quarter, Philadelphia and Pittsburgh areas",
       derivation = "Table 2 fixed-effects Poisson IRR 1.267 [0.985-1.629], treated = tracts within 3 km of a 18/25 Sep 2019 giveaway site, two post quarters",
       study_url = "https://onlinelibrary.wiley.com/doi/full/10.1002/hec.4755"),
  row3("HEALing Communities 2024¶",
       (c(0.91, 0.76, 1.09) - 1) * 100,
       policy = "Multicomponent cluster RCT",
       outcome = "Opioid overdose deaths",
       derivation = "Adjusted rate ratio 0.91 (0.76-1.09), Table 3",
       study_url = "https://www.nejm.org/doi/full/10.1056/NEJMoa2401177"),
  row3("Freisthler et al. 2024¶",
       (c(0.92, 0.78, 1.07) - 1) * 100,
       policy = "Multicomponent cluster RCT",
       outcome = "All-drug overdose deaths",
       derivation = "Adjusted rate ratio 0.92 (0.78-1.07)",
       study_url = "https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2825142"),
  row3("Spackman et al. 2025 — per 10,000 kits",
       c(-23.9, -33.7, -12.6),
       policy = "Take-home naloxone distribution (Alberta)",
       outcome = "Opioid-related deaths",
       derivation = "As reported: 23.9% (12.6-33.7) reduction per 10,000 kits in circulation; dose-response, not a binary policy effect",
       study_url = "https://pubmed.ncbi.nlm.nih.gov/40459670/")
)

# ---------------------------------------------------------------------------
# Absolute effects (deaths per 100,000 per year)
# ---------------------------------------------------------------------------
absolute <- bind_rows(
  row3("Erfanian et al. 2019 — direct effect",
       ci_from_p(0.238, 0.554),
       scaling = "Annual estimate",
       policy = "Naloxone access law",
       outcome = "Opioid overdose deaths per 100k (state-year)",
       derivation = "Direct effect 0.238 (p = 0.554), Table 6 Model 1; CI derived from p-value. Indirect (spillover) effect 5.767 (p < 0.001) not plotted",
       study_url = "https://rrs.scholasticahq.com/article/7932-the-impact-of-naloxone-access-laws-on-opioid-overdose-deaths-in-the-u-s"),
  row3("Lee et al. 2021",
       c(1344.3, 627.1, 2061.6) / 3000 * 4,
       scaling = "Quarterly × 4",
       policy = "Naloxone access law",
       outcome = "All-drug overdose deaths",
       derivation = "1344.3 (627.1-2061.6) per 300 million per quarter, pooled over leads 0-12; divided by 3000 for per 100k and multiplied by 4",
       study_url = "https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2776301"),
  row3("Duska et al. 2022",
       c(-0.05, -0.43, 0.33) * 12,
       scaling = "Monthly × 12",
       policy = "Naloxone co-prescribing mandate (AZ, FL, RI, VT, VA)",
       outcome = "Opioid-related deaths",
       derivation = "Table 1 pooled ATT -0.05 (-0.43, 0.33) deaths per 100k per month, generalized synthetic control (Xu 2017) with parametric-bootstrap CI, state-month 2012-2018; multiplied by 12",
       study_url = "https://journals.sagepub.com/doi/10.1177/20503245221112575"),
  row3("Rudolph et al. 2022 — sign reversed",
       -c(1.51, 3.18, -0.159),
       scaling = "Annual estimate",
       policy = "Naloxone access law",
       outcome = "Opioid overdose deaths per 100k aged 12+, 2018",
       derivation = "Effect of delaying enactment by one year: +1.51 (-0.16, 3.18); sign reversed so negative means earlier enactment lowers deaths",
       study_url = "https://pmc.ncbi.nlm.nih.gov/articles/PMC9373236/"),
  row3("Peet et al. 2024 — NAL adopted 2010–15",
       ci_from_se(-0.074, 0.094) * 4,
       scaling = "Quarterly × 4",
       policy = "Naloxone access law (dispensing)",
       outcome = "Non-synthetic opioid deaths, age-adjusted",
       derivation = "Table 3 Panel B +LASSO: -0.074 (SE 0.094) per 100k per quarter, 2010-2015 sample",
       study_url = "https://www.nber.org/papers/w33105"),
  row3("Peet et al. 2024 — Narcan introduction, NAL states",
       ci_from_se(-0.143, 0.075) * 4,
       scaling = "Quarterly × 4",
       policy = "Narcan nasal spray introduction (2016) in states with an NAL",
       outcome = "Non-synthetic opioid deaths, age-adjusted",
       derivation = "Table 3 Panel B +LASSO: -0.143 (SE 0.075) per 100k per quarter, 2010-2019 sample",
       study_url = "https://www.nber.org/papers/w33105"),
  row3("Peet et al. 2024 — NAL adopted 2016–19",
       ci_from_se(-0.635, 0.192) * 4,
       scaling = "Quarterly × 4",
       policy = "Naloxone access law (dispensing)",
       outcome = "Non-synthetic opioid deaths, age-adjusted",
       derivation = "Table 3 Panel B +LASSO: -0.635 (SE 0.192) per 100k per quarter, 2016-2019 sample",
       study_url = "https://www.nber.org/papers/w33105"),
  row3("Payne 2026",
       ci_from_se(2.12, 1.40),
       scaling = "Annual estimate",
       policy = "County naloxone kit distribution grant (Indiana)",
       outcome = "Opioid-related deaths",
       derivation = "Table 2 Panel B col. 2: 2.12 (SE 1.40), TWFE; CI is +/- 1.96 SE (author uses 2.0)",
       study_url = "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=7279243")
)

# ---------------------------------------------------------------------------
# Plotting
# ---------------------------------------------------------------------------
forest_cf <- function(dat, title, subtitle, xlab, caption, accent,
                      xlim = NULL, percent_axis = FALSE) {
  p <- dat %>%
    mutate(study = factor(study, levels = rev(study))) %>%
    ggplot(aes(x = estimate, y = study)) +
    geom_vline(xintercept = 0, color = cf_axis, linewidth = 0.7) +
    geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y",
                  width = 0.13, linewidth = 1.1, color = accent) +
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
  caption = cf_caption("studies listed in README; derivations in code/plot_effects.R. Spackman is a dose-response effect per 10,000 kits."),
  accent = cf_blue,
  xlim = c(-68, 70),
  percent_axis = TRUE
)

p_absolute <- forest_cf(
  absolute,
  title = "Naloxone access and overdose mortality",
  subtitle = "Annualized absolute effects; negative values indicate lower mortality",
  xlab = "Annualized change in overdose deaths per 100,000",
  caption = cf_caption("studies listed in README; quarterly estimates annualized ×4, monthly ×12. Rudolph estimates a one-year enactment delay, shown with sign reversed."),
  accent = cf_orange,
  xlim = c(-5.5, 5.5),
  percent_axis = FALSE
)

dir.create("figures", showWarnings = FALSE)
dir.create("data", showWarnings = FALSE)

cf_save(p_relative, "figures/relative_effects")
cf_save(p_absolute, "figures/annualized_absolute_effects")

bind_rows(
  relative %>% mutate(panel = "Relative (%)", unit = "percent", scaling = "See derivation"),
  absolute %>% mutate(panel = "Annualized absolute", unit = "deaths per 100k per year")
) %>%
  mutate(across(c(estimate, lower, upper), ~ round(.x, 2))) %>%
  select(study, estimate, lower, upper, panel, unit, scaling, policy, outcome, derivation, study_url) %>%
  write_csv("data/effects.csv")
