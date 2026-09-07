# Naloxone access and overdose mortality evidence review

***This text and repository were originally written by OpenAI's ChatGPT. The study-by-study verification, corrections, additional literature search, and current figures were done by Anthropic's Claude, working in Claude Code under the direction of the repository owner; the verification record is in [`REVIEW.md`](REVIEW.md). Neither the original nor the revision has been independently checked by a human reviewer.***

This repository contains a working evidence table, figures, and R code for experimental and quasi-experimental studies estimating the effect of naloxone access or distribution on overdose mortality.

The starting point was Khezri et al. (2026), *Illicit drug supply, naloxone availability, and overdose mortality in the fentanyl era: a systematic review* ([Health Affairs Scholar](https://academic.oup.com/healthaffairsscholar/article/4/4/qxag074/8544909)). Additional quasi-experimental papers were added from Smart, Pardo & Davis (2021, *Addiction*) and from a broader search of the economics, public-health, and international literature through September 2026.

## Selection process

1. Extract experimental and quasi-experimental mortality studies from the Khezri and Smart reviews.
2. Exclude uncontrolled interrupted-time-series analyses and other designs without a sufficiently strong counterfactual.
3. For interrupted-time-series, controlled ITS, and other panel designs, require unit fixed effects or an equivalent design-based control structure, and a separately identified naloxone effect, for inclusion in the main analyses.
4. Add quasi-experimental studies outside the reviews: Rees et al. (2019), Atkins et al. (2019), Erfanian et al. (2019), Duska et al. (2022), Rudolph et al. (2022), Peet et al. (2024), Spackman et al. (2025), and Payne (2026).
5. Move studies that fail step 3 to the [appendix](appendix/excluded_its.md): Walley (2013), Bird (2016), Naumann (2019), Hamilton (2021), Antoniou (2022), Morgan (2022), Taylor (2022), Allen (2022), Tabatabai (2023), Yeung (2023), Toce (2024), Xuan (2024), Håkansson (2024), Newman (2025), Walley (2026), and Goodman (2026).
6. Focus the figures on overdose mortality rather than ED visits or hospitalizations.

This is a working review rather than a formal meta-analysis. The rows are not statistically pooled, and multiple estimates from the same study or trial are displayed separately when substantively useful.

The rows do not all evaluate the same policy. The `policy` column in `data/effects.csv` distinguishes state naloxone access laws (NALs), naloxone co-prescribing mandates, distribution programs and giveaways, the 2016 Narcan nasal-spray introduction, and one multicomponent cluster-randomized trial. Two rows (Sohn 2023, Duska 2022) evaluate co-prescribing mandates, which target prescribers rather than public access.

## Effect-scale decisions

Studies report mortality effects on incompatible scales, so the results are shown in two figures. Every derived number is computed in `code/plot_effects.R`, and the `derivation` column of `data/effects.csv` records the source table and conversion for each row.

### Relative effects

Rate ratios and estimates that can be represented on a percent-change scale are shown as percentage changes in overdose mortality. Negative values indicate lower mortality. Rows in chronological order.

![Relative effects](figures/relative_effects.svg)

### Absolute effects

Absolute rate differences are placed on a common annualized scale: deaths per 100,000 per year. Annual estimates are left unchanged; quarterly estimates are multiplied by 4; the one monthly estimate (Duska) is multiplied by 12.

![Annualized absolute effects](figures/annualized_absolute_effects.svg)

## Study table

| Study | Policy | Design | Outcome | Effect scale | Estimate | 95% CI | Notes | Source |
|---|---|---|---|---|---:|---:|---|---|
| McClellan et al. 2018 | NAL | Mixed-effects negative binomial (state random effects, year FE, 1-year lag) | Opioid overdose deaths | Relative (%) | −14.0% | −25.1% to −1.2% | Paper reports IRR 0.86, p = 0.033, and no interval; CI derived from the p-value. | [link](https://pubmed.ncbi.nlm.nih.gov/29610001/) |
| Rees et al. 2019 | NAL | TWFE Poisson, state-year 1999–2014 | Opioid-related deaths (multiple-cause T-codes) | Relative (%) | −9.1% | −15.7% to −1.8% | exp(b)−1 from the published Table 3 Poisson full-controls coefficient −0.095 (SE 0.039). OLS columns give −15% to −21%. Effect is driven by pre-2011 adopters. | [link](https://chicagounbound.uchicago.edu/jle/vol62/iss1/1/) |
| Atkins et al. 2019 | NAL (any naloxone policy) | TWFE Poisson DD, state-year 1999–2016 | Opioid overdose deaths | Relative (%) | +9.9% | −6.2% to +28.7% | Naloxone is a covariate in the paper's Good Samaritan analysis. Table 4 Panel B, 0.0943 (SE 0.0805). | [link](https://pmc.ncbi.nlm.nih.gov/articles/PMC6407344/) |
| Abouk et al. 2019‡ | NAL, direct pharmacist authority | DID / event study, state-month 2005–2016 | Opioid overdose deaths | Relative (%) | −33.9% | −57.5% to −10.4% | 3+ years post-adoption: −0.387 (−0.656, −0.119) deaths per 100k per month, divided by comparison mean 1.14. Nine direct-authority states. | [link](https://pmc.ncbi.nlm.nih.gov/articles/PMC6503576/) |
| Cataife et al. 2021† | NAL | Matched staggered DID, state-year 1999–2014 | Opioid-related deaths | Relative (%) | −0.2% | −20.5% to +25.3% | Table 1 Model 1 (homogeneous static model), −0.002 (SE 0.116). Authors prefer the region-by-year model. | [link](https://pubmed.ncbi.nlm.nih.gov/31951788/) |
| Doleac & Mukherjee 2022 | NAL, third-party or standing order | Staggered DID, urban county-month 2010–2015 | Opioid-related deaths | Relative (%) | +1.0% | −7.8% to +9.8% | Published Table 4: 0.006 (SE 0.027) on 2010 baseline 0.601 per 100k per month. | [link](https://www.journals.uchicago.edu/doi/10.1086/719588) |
| Sohn et al. 2023§ | Co-prescribing mandate | Negative-binomial DID with state and quarter FE, state-quarter 2006–2020 | Prescription/treatment-opioid deaths | Relative (%) | −16.0% | −28.1% to −3.9% | Table 1 AME −8.61 (−15.13, −2.09) deaths per state-quarter, a 16% reduction from the counterfactual; CI scaled proportionally. Illicit/synthetic estimate null (+0.32, −18.27 to 18.91). Excluding methadone: −9.52, 23%. | [link](https://www.sciencedirect.com/science/article/abs/pii/S0749379722005281) |
| Dowd 2023 — 2018 giveaway | Naloxone giveaway (13 Dec 2018) | Fixed-effects Poisson DID, census tract × quarter, Philadelphia five counties and Allegheny County, 2017Q2–2020Q1 | Opioid overdose deaths | Relative (%) | −14.7% | −31.0% to +5.6% | Table 2 IRR 0.853 [0.690–1.056]; treated tracts within 3 km of a giveaway site and more than 3 km from other free naloxone; two post quarters. Event study finds IRR 0.59 (p = 0.01) in the first post quarter. | [link](https://onlinelibrary.wiley.com/doi/full/10.1002/hec.4755) |
| Dowd 2023 — 2019 giveaway | Naloxone giveaway (18 and 25 Sep 2019) | Same | Opioid overdose deaths | Relative (%) | +26.7% | −1.5% to +62.9% | Table 2 IRR 1.267 [0.985–1.629], p < 0.10. Pooled Callaway–Sant'Anna analysis of both giveaways finds no significant effect. | [link](https://onlinelibrary.wiley.com/doi/full/10.1002/hec.4755) |
| HEALing Communities 2024¶ | Multicomponent RCT | Cluster randomized trial, 67 communities | Opioid overdose deaths | Relative (%) | −9.0% | −24.0% to +9.0% | Adjusted RR 0.91 (0.76–1.09), p = 0.30. | [link](https://www.nejm.org/doi/full/10.1056/NEJMoa2401177) |
| Freisthler et al. 2024¶ | Multicomponent RCT | Same trial, secondary analysis | All-drug overdose deaths | Relative (%) | −8.0% | −22.0% to +7.0% | Adjusted RR 0.92 (0.78–1.07). Nested outcome on the same communities and period as the NEJM row. | [link](https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2825142) |
| Spackman et al. 2025 | Take-home naloxone distribution (Alberta) | Poisson PML with zone and time FE, 5 zones × month 2015–2019 | Opioid-related deaths | Relative (%), per 10,000 kits | −23.9% | −33.7% to −12.6% | Dose-response effect of kits in circulation, not a binary policy effect. Only five cross-sectional units. | [link](https://pubmed.ncbi.nlm.nih.gov/40459670/) |
| Erfanian et al. 2019 — direct effect | NAL | Spatial Durbin TWFE, state-year 1999–2016 | Opioid overdose deaths per 100k | Annualized deaths / 100k / year | +0.24 | −0.55 to +1.03 | Direct effect 0.238 (p = 0.554), CI derived from p-value. Indirect (spillover) effect +5.77 (p < 0.001) and total effect about +6.0 are not plotted. | [link](https://rrs.scholasticahq.com/article/7932-the-impact-of-naloxone-access-laws-on-opioid-overdose-deaths-in-the-u-s) |
| Lee et al. 2021 | NAL | Panel-matching DID, state-quarter 2007–2018 | All-drug overdose deaths | Annualized deaths / 100k / year | +1.79 | +0.84 to +2.75 | 1344.3 (627.1–2061.6) per 300 million per quarter, pooled over leads 0–12; ÷3000, ×4. | [link](https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2776301) |
| Duska et al. 2022 | Co-prescribing mandate (AZ, FL, RI, VT, VA) | Generalized synthetic control, state-month 2012–2018 | Opioid-related deaths | Annualized deaths / 100k / year | −0.60 | −5.16 to +3.96 | Table 1 pooled ATT −0.05 (−0.43, 0.33) per 100k per month, parametric-bootstrap CI, ×12. Only 6–8 post-adoption months for AZ, FL, and RI. | [link](https://journals.sagepub.com/doi/10.1177/20503245221112575) |
| Rudolph et al. 2022 | NAL | Doubly robust longitudinal estimator, US counties 2007–2018 | Opioid overdose deaths per 100k aged 12+, 2018 | Annualized deaths / 100k / year | −1.51 | −3.18 to +0.16 | Paper estimates the effect of delaying enactment by one year (+1.51); sign reversed here. Covariate-adjusted, not unit FE. | [link](https://pmc.ncbi.nlm.nih.gov/articles/PMC9373236/) |
| Peet et al. 2024 — NAL adopted 2010–15 | NAL (dispensing) | Imputation DID, state-quarter | Non-synthetic opioid deaths, age-adjusted | Annualized deaths / 100k / year | −0.30 | −1.03 to +0.44 | Table 3 +LASSO, −0.074 (SE 0.094) per quarter ×4. | [link](https://www.nber.org/papers/w33105) |
| Peet et al. 2024 — Narcan introduction, NAL states | Narcan introduction (2016) | Imputation DID, state-quarter 2010–2019 | Non-synthetic opioid deaths, age-adjusted | Annualized deaths / 100k / year | −0.57 | −1.16 to +0.02 | Table 3 +LASSO, −0.143 (SE 0.075) per quarter ×4. Not an NAL-adoption effect. | [link](https://www.nber.org/papers/w33105) |
| Peet et al. 2024 — NAL adopted 2016–19 | NAL (dispensing) | Imputation DID, state-quarter 2016–2019 | Non-synthetic opioid deaths, age-adjusted | Annualized deaths / 100k / year | −2.54 | −4.05 to −1.03 | Table 3 +LASSO, −0.635 (SE 0.192) per quarter ×4. | [link](https://www.nber.org/papers/w33105) |
| Payne 2026 | County kit-distribution grant (Indiana) | Staggered TWFE DID, county-year 2014–2019 | Opioid-related deaths | Annualized deaths / 100k / year | +2.12 | −0.62 to +4.86 | Table 2 Panel B col. 2, SE 1.40; CI is ±1.96 SE. Callaway–Sant'Anna robustness: 1.43 (SE 1.66). | [link](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=7279243) |

## Outcome definitions

The rows do not measure the same deaths. All US studies use death certificates coded in ICD-10; "underlying" codes identify a drug poisoning, and "contributing" T-codes identify the substance. The table records what each row actually counts.

| Study | Data source and unit | Underlying-cause codes | Substance codes | Population and notes |
|---|---|---|---|---|
| McClellan 2018 | NVSS, state-year 2000–2014 | X40–44, X85, Y10–14 (suicides X60–64 removed) | T40.0–T40.4, T40.6 | All ages |
| Rees 2019 | NVSS multiple-cause files, state-year 1999–2014 | None: any death certificate listing an opioid T-code counts | T40.0–T40.4, T40.6 | All ages. Footnote reports similar results when restricted to poisoning underlying causes |
| Atkins 2019 | CDC WONDER, state-year 1999–2016 | X40–44, X60–64, X85, Y10–14 | T40.1–T40.4, T40.6 (Panel B; Panel A uses T40.0–T40.4) | All ages; counts under 10 suppressed |
| Abouk 2019 | NVSS, state-month 2005–2016 | X40–44, X60–64, X85, Y10–14 | T40.1–T40.4 (excludes opium T40.0 and unspecified narcotics T40.6) | All ages |
| Cataife 2021 | CDC WONDER, state-year 1999–2014 | Not stated | T40.0–T40.4, T40.6 | Age-adjusted rate; Florida excluded |
| Doleac & Mukherjee 2022 | Restricted CDC files, county-month 2010–2015 | Not stated | T40.0–T40.4, T40.6 | Urban counties (jurisdiction population ≥ 40,000) |
| Sohn 2023 | CDC WONDER, state-quarter 2006–2020 | X40–44, X60–64, X85, Y10–14 | T40.2 or T40.3 listed, and none of T40.0, T40.1, T40.4 | Prescription/treatment opioids only; a separate illicit/synthetic model is null |
| Dowd 2023 | Pennsylvania Bureau of Health Statistics, census tract-quarter 2017Q2–2020Q1 | X40–44, Y10–14 (accidental and undetermined only; suicides and homicides excluded) | T40.0–T40.4, T40.6 | Tract of incident, not residence; Philadelphia five counties and Allegheny County |
| HEALing Communities 2024 | Death certificates, 67 communities, July 2021–June 2022 | X40–44, X60–64, X85, Y10–14 | T40.0–T40.4, T40.6 | Adults 18+ |
| Freisthler 2024 | Same | X40–44, X60–64, X85, Y10–14 | None: all drug overdose deaths | Adults 18+; includes non-opioid deaths |
| Spackman 2025 | Alberta Chief Medical Examiner, health zone-month 2015–2019 | Drug poisoning deaths per medical examiner | Any opioid named in Part 1 of the death certificate (codeine through carfentanil); no ICD codes given | 74.5% of deaths involved fentanyl |
| Erfanian 2019 | CDC compressed mortality files, state-year 1999–2016 | X40–44, X60–64, X85, Y10–14 | T40.0–T40.4, T40.6 | 48 contiguous states plus DC |
| Lee 2021 | CDC multiple-cause files, state-quarter 2007–2018 | X40–44, X60–64, X85, Y10–14 | None: all drug overdose deaths for the plotted row | Opioid-specific rows exist (heroin and synthetic positive, natural opioid null) but were not pooled |
| Duska 2022 | NVSS multiple-cause files, state-month 2012–2018 | X40–44, X60–64, X85, Y10–14 | T40.0–T40.4, T40.6 | All ages |
| Rudolph 2022 | Restricted NCHS files, county 2007–2018, outcome year 2018 | X40–44, X60–64, X85, Y10–14 | T40.0–T40.4, T40.6 | Rate per 100,000 aged 12 and over; Alaska, Connecticut, New Mexico excluded |
| Peet 2024 | Restricted NVSS multiple-cause files, state-quarter 2010–2019 | X40–44, X60–64, X85, Y10–14 | T40.1 (heroin) or T40.2 (natural/semisynthetic), excluding any death also listing T40.4 | Age-adjusted to the 2000 standard population. Excludes fentanyl, methadone-only, opium-only, and unspecified-narcotic deaths |
| Payne 2026 | Indiana Department of Health, county-year 2014–2019 | X40–44, X60–64, X85, Y10–14, Y35.2 | T40.0–T40.4, T40.6 | 92 Indiana counties |

Three rows therefore do not measure opioid deaths at all (Lee, Freisthler: all drugs), one measures only prescription-type opioid deaths (Sohn), one excludes fentanyl-involved deaths by construction (Peet), and one excludes unspecified-narcotic deaths (Abouk).

## Coding notes

- **McClellan et al. (2018):** the paper prints a 14% reduction and p = 0.033 but no interval. The interval here is derived from the p-value. The model uses state random effects with a one-year treatment lag and no policy covariates.
- **Rees et al. (2019):** the percentage is converted from the published Table 3 Poisson full-controls coefficient, −0.095 (SE 0.039). The OLS columns of the same table give −0.166 and −0.240 (15% and 21% reductions); the authors summarize the Poisson results as 9–10%.
- **Erfanian et al. (2019):** the dependent variable is deaths per 100,000 in levels, so the row sits in the absolute panel. Only the within-state direct effect is plotted. The authors' headline is a significant positive spillover to neighboring states and a total effect of about +6 deaths per 100,000; the paper prints p-values only, so no CI can be derived for the indirect effect.
- **Cataife et al. (2021):** the plotted scalar is the homogeneous static model (Table 1, Model 1). The authors prefer a dynamic specification with region-by-year heterogeneity, which finds reductions of 21–65% in western states, no effect in the Northeast and South, and a 43% increase in the implementation year in the Midwest.
- **Abouk et al. (2019):** the displayed percent effect uses the 3+-year direct-pharmacist-authority estimate. The percentage CI treats the comparison mean as fixed.
- **Doleac & Mukherjee (2022):** the published Table 4 coefficient is 0.006 (SE 0.027) per 100,000 per month. Regional estimates in the online appendix show a significant increase in the Midwest. Alexeev (2025, *Economic Inquiry*) re-analyzes the replication package and finds law-timing errors and invalid inference; the corrected ER-admission effect is null. The restricted mortality files are not in the package, so Alexeev does not re-estimate the mortality result.
- **Sohn et al. (2023)** and **Duska et al. (2022)** evaluate naloxone co-prescribing mandates, a prescriber-side policy, not public access laws or distribution. Sohn's treatment group is seven co-prescribing states (VA, VT, NM, AZ, FL, RI, WA) plus two "offer" states (CA, OH), with pharmacy NAL and Good Samaritan status entered as a combined covariate; the 16% figure is the AME relative to the model counterfactual, and the effect shrinks as 2019 and 2020 data are added (−10.43 through 2018, −9.78 through 2019, −8.61 through 2020). Duska uses Xu's generalized synthetic control on state-month data with a parametric-bootstrap CI; the pooled estimate is per 100,000 per month and is multiplied by 12 here, which is why its interval is the widest in the absolute panel.
- **Dowd (2023):** the two Pennsylvania giveaways are shown separately because Table 2 reports opposite-signed estimates: IRR 0.853 (0.690–1.056) after the December 2018 giveaway and 1.267 (0.985–1.629) after the September 2019 giveaway. The pooled Callaway–Sant'Anna analysis finds no significant effect on deaths. Treatment is defined by tract distance to giveaway sites (within 3 km) in the Philadelphia and Pittsburgh areas, with tract and quarter fixed effects.
- **HEALing Communities / Freisthler (2024):** two publications from the same cluster-randomized trial, not independent experiments. The intervention included naloxone distribution, medications for opioid use disorder, and safer prescribing, so it does not identify a naloxone-only effect. The NEJM outcome is opioid-involved deaths; the Freisthler outcome is all-drug deaths.
- **Spackman et al. (2025):** the effect is per 10,000 take-home naloxone kits in circulation across five Alberta health zones. It is a dose-response estimate with zone and time fixed effects, not a binary policy effect.
- **Lee et al. (2021):** the outcome is all-drug overdose deaths. The reported number is a random-effects pooled mean over thirteen quarterly lead-specific effects, converted from per 300 million to per 100,000 and annualized. The authors interpret the positive estimate as moral hazard.
- **Rudolph et al. (2022):** the paper argues that the always-treated versus never-treated NAL contrast is not identifiable and instead estimates the effect of delaying enactment by one year on 2018 county mortality, +1.51 (−0.16, 3.18). The sign is reversed here so that negative values mean earlier enactment lowers deaths.
- **Peet et al. (2024):** the three plotted estimates use the +LASSO specification in Table 3. The outcome is non-synthetic opioid mortality; synthetic-opioid effects (Table 4) are null. Experiment (2) is the 2016 Narcan introduction in states that already had a dispensing NAL, on a 2010–2019 sample.
- **Payne (2026):** the intervention is an Indiana grant distributing naloxone kits to county health departments. The preferred TWFE estimate is +2.12 opioid-related deaths per 100,000 per year (SE 1.40). The author uses a critical value of 2.0; the CI here uses 1.96.

## Appendix

Studies that were considered but excluded from the main analyses are listed in [`appendix/excluded_its.md`](appendix/excluded_its.md), with the reason class for each. The underlying table is [`data/excluded_its.csv`](data/excluded_its.csv).

## Repository contents

- `REVIEW.md` — study-by-study verification record and list of remaining gaps.
- `data/effects.csv` — plotted estimates, policy and outcome labels, derivation notes, and study URLs. Written by the R script.
- `data/excluded_its.csv` — studies excluded from the main analyses with the reason.
- `appendix/excluded_its.md` — appendix table with exclusion reasons and reported mortality results.
- `code/plot_effects.R` — R code that defines the plotted data, performs every unit conversion, applies the CF house style, and regenerates both figures.
- `figures/relative_effects.{svg,png}` — relative-effect forest plot.
- `figures/annualized_absolute_effects.{svg,png}` — annualized absolute-effect forest plot.

## Reproducing the figures

The R script requires `dplyr`, `ggplot2` (≥ 3.3), `readr`, `scales`, and `ragg`. From the repository root:

```r
source("code/plot_effects.R")
```

The script regenerates the PNG and SVG figures under `figures/` and rewrites `data/effects.csv`.
