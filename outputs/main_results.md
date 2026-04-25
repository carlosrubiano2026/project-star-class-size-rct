# Project STAR — Class Size and Student Achievement
## Randomized Experiment: Kindergarten Sample

> **Author:** Carlos Arturo Rubiano Passos  
> **Course:** Econometric Methods II  
> **Data:** `STAR.dta` | **Do-file:** `project_star_class_size_rct.do`

---

## Table of Contents

1. [Data and Sample](#1-data-and-sample)
2. [Difference in Means and Short Regression](#2-difference-in-means-and-short-regression)
3. [School Fixed Effects](#3-school-fixed-effects)
4. [Standard Error Comparison](#4-standard-error-comparison)
5. [Randomization Inference](#5-randomization-inference)
6. [Balance Checks](#6-balance-checks)
7. [School Fixed Effects with Covariates](#7-school-fixed-effects-with-covariates)
8. [Heterogeneous Treatment Effects](#8-heterogeneous-treatment-effects)
9. [Implied Effects for Selected Groups](#9-implied-effects-for-selected-groups)
10. [Main Conclusion](#10-main-conclusion)

---

## 1. Data and Sample

| Feature | Value |
|---|---|
| Dataset | `STAR.dta` |
| Unit of observation | Student |
| Observations | 5,749 |
| Schools | 79 |
| Missing values | None |

### Variables

| Variable | Description |
|---|---|
| `tscorek` | Kindergarten test score (outcome) |
| `sck` | Small-class treatment indicator (1 = small, 0 = regular) |
| `totexpk` | Years of total teaching experience |
| `schidkn` | School identifier |
| `boy` | Male student indicator |
| `freelunk` | Free school lunch eligibility indicator |

### Sample Composition

| Group | N | Share |
|---|---|---|
| Regular class (`sck = 0`) | 4,016 | 69.86% |
| Small class (`sck = 1`) | 1,733 | 30.14% |
| Boys | 2,954 | 51.38% |
| Free lunch eligible | 2,776 | 48.29% |

### Summary Statistics

| Variable | Mean | Std. Dev. | Min | Max |
|---|---|---|---|---|
| Test score (`tscorek`) | 922.39 | 73.87 | 635 | 1,253 |
| Teacher experience (`totexpk`) | 9.31 | 5.77 | 0 | 27 |

---

## 2. Difference in Means and Short Regression

### Group Means

| Class type | Mean test score |
|---|---|
| Regular class | 918.23 |
| Small class | 932.05 |
| **Difference** | **13.83** |

### Short OLS Regression

$$\text{tscorek}_i = \alpha + \beta \cdot \text{sck}_i + u_i$$

| Estimate | Value |
|---|---|
| $\hat{\beta}$ | **13.83** |
| Robust SE | 2.16 |
| p-value | < 0.01 |
| R² | 0.0074 |
| Effect size (SD units) | **0.187** |

> **Interpretation:** Students assigned to small classes score approximately **13.8 points higher** than those in regular classes — equivalent to **0.19 standard deviations**. This follows directly from the algebraic result that, in a regression of $Y$ on a binary $X$, the intercept equals $\bar{Y}_0$ and the slope equals $\bar{Y}_1 - \bar{Y}_0$.

---

## 3. School Fixed Effects

Because randomization occurred **within schools**, the preferred specification controls for school fixed effects:

$$\text{tscorek}_{is} = \alpha + \beta \cdot \text{sck}_{is} + \gamma_s + u_{is}$$

| Estimate | Value |
|---|---|
| $\hat{\beta}$ | **15.13** |
| Robust SE | 1.98 |
| p-value | < 0.01 |
| R² | 0.2314 |
| Effect size (SD units) | **0.205** |

> **Interpretation:** Controlling for school fixed effects, small-class assignment raises test scores by **15.1 points** (0.20 SD). The estimate is slightly larger than the raw difference, consistent with modest negative selection into small classes across schools. School FE is preferred because it exploits only within-school variation — the variation directly controlled by the randomization design.

---

## 4. Standard Error Comparison

All specifications include school fixed effects. The treatment coefficient is identical across columns; only the uncertainty estimate changes.

| SE type | $\hat{\beta}$ | SE | 95% CI |
|---|---|---|---|
| Conventional (OLS) | 15.13 | 1.90 | [11.40, 18.85] |
| Heteroskedasticity-robust | 15.13 | 1.98 | [11.25, 19.00] |
| **Clustered by school** | **15.13** | **3.64** | **[7.87, 22.38]** |

> **Preferred:** School-clustered standard errors. Random assignment ensures $\mathbb{E}[u \mid D] = 0$ (no omitted variable bias), but it does **not** rule out heteroskedasticity or within-school error correlation. Students in the same school share a teacher, peers, and facilities — and treatment is assigned at the classroom level — so errors within schools are plausibly correlated. Clustered SEs are valid under both homoskedasticity and within-cluster dependence.

---

## 5. Randomization Inference

Implemented via `ritest` with **1,000 permutations**, stratifying by school to match the experimental design.

| Quantity | Value |
|---|---|
| Observed $\hat{\beta}$ | 15.13 |
| Replications | 1,000 |
| Permutation p-value | **0.0000** |
| 95% CI for p | [0.000, 0.004] |

> **Interpretation:** None of the 1,000 placebo reassignments produced an effect as large as the observed estimate. This provides **strong design-based evidence** against the sharp null hypothesis of no treatment effect for any student, without relying on large-sample distributional assumptions.

---

## 6. Balance Checks

Balance regressions include school fixed effects and school-clustered standard errors:

$$W_{is} = \alpha + \delta \cdot \text{sck}_{is} + \gamma_s + \varepsilon_{is}$$

| Covariate | $\hat{\delta}$ | Clustered SE | p-value |
|---|---|---|---|
| `boy` | 0.0007 | 0.0151 | 0.963 |
| `freelunk` | −0.0076 | 0.0140 | 0.592 |
| `totexpk` | −0.4270 | 0.6597 | 0.519 |

> **Interpretation:** Small-class assignment does not predict gender, free-lunch status, or teacher experience. All p-values are far from conventional significance thresholds. This supports the validity of within-school randomization.

---

## 7. School Fixed Effects with Covariates

Adding pre-determined student and teacher controls:

$$\text{tscorek}_{is} = \alpha + \beta \cdot \text{sck}_{is} + X_{is}'\delta + \gamma_s + u_{is}$$

| Variable | $\hat{\beta}$ | Clustered SE | p-value |
|---|---|---|---|
| `sck` | **15.13** | 3.54 | < 0.01 |
| `boy` | −12.00 | 1.58 | < 0.01 |
| `freelunk` | −37.32 | 2.57 | < 0.01 |
| `totexpk` | 0.66 | 0.35 | 0.067 |

R² = 0.2847

> **Interpretation:** The treatment effect is essentially unchanged at **15.13** after adding covariates — consistent with successful randomization. The coefficients on `boy`, `freelunk`, and `totexpk` are **conditional associations, not causal effects**, since these variables were not randomly assigned.

---

## 8. Heterogeneous Treatment Effects

Interactions of `sck` with student and teacher characteristics:

$$\text{tscorek}_{is} = \alpha + \beta \cdot \text{sck}_{is} + \delta_1 \cdot \text{boy}_{is} + \delta_2 \cdot \text{freelunk}_{is} + \delta_3 \cdot \text{totexpk}_{is}$$
$$+ \theta_1 (\text{sck} \times \text{boy})_{is} + \theta_2 (\text{sck} \times \text{freelunk})_{is} + \theta_3 (\text{sck} \times \text{totexpk})_{is} + \gamma_s + u_{is}$$

| Variable | Coefficient | Clustered SE | p-value |
|---|---|---|---|
| `sck` (baseline group) | **18.95** | 7.75 | 0.017 |
| `boy` | −13.83 | 1.91 | < 0.01 |
| `freelunk` | −38.07 | 2.94 | < 0.01 |
| `totexpk` | 0.94 | 0.40 | 0.020 |
| `sck × boy` | 6.14 | 3.54 | 0.087 |
| `sck × freelunk` | 2.15 | 5.53 | 0.698 |
| `sck × totexpk` | −0.88 | 0.68 | 0.203 |

> **Baseline group:** girl, not free-lunch eligible, teacher with zero years of experience.

### Joint Test of Treatment Homogeneity

$$H_0: \theta_1 = \theta_2 = \theta_3 = 0$$

| Statistic | Value |
|---|---|
| F(3, 78) | 1.86 |
| p-value | 0.1437 |

> **Interpretation:** The interaction with `boy` is marginally significant at 10%, suggesting boys may benefit slightly more from small classes. However, the **joint F-test does not reject homogeneous treatment effects** (p = 0.14). There is no strong evidence of heterogeneity by gender, poverty status, or teacher experience.

---

## 9. Implied Effects for Selected Groups

Based on the heterogeneous effects model (`lincom` results):

| Group | Effect (points) | SE | p-value |
|---|---|---|---|
| Girl, not free lunch, exp = 0 | 18.95 | 7.75 | 0.017 |
| Boy, not free lunch, exp = 0 | 25.09 | 7.48 | < 0.01 |
| Girl, free lunch, exp = 0 | 21.10 | 9.36 | 0.027 |
| Boy, free lunch, exp = 0 | 27.24 | 8.45 | < 0.01 |
| At mean teacher experience (9.31 yrs) | 10.78 | 4.55 | 0.020 |

---

## 10. Main Conclusion

The Project STAR kindergarten results provide **robust evidence** that assignment to a small class significantly improves student test scores.

### Key Results at a Glance

| Specification | $\hat{\beta}$ | SE | Effect size |
|---|---|---|---|
| Raw difference in means | 13.83 | — | 0.187 SD |
| Short regression (robust SE) | 13.83 | 2.16 | 0.187 SD |
| School FE (robust SE) | 15.13 | 1.98 | 0.205 SD |
| **School FE (clustered SE)** ⭐ | **15.13** | **3.64** | **0.205 SD** |
| School FE + controls (clustered SE) | 15.13 | 3.54 | 0.205 SD |

### Robustness

The preferred estimate of **15.1 points (0.20 SD)** is robust to:

- ✅ School fixed effects
- ✅ Heteroskedasticity-robust standard errors
- ✅ School-clustered standard errors
- ✅ Adding student and teacher covariates
- ✅ Randomization inference (permutation p = 0.000)
- ✅ Balance tests supporting randomization validity

### Bottom Line

> Assignment to a small kindergarten class increases student test scores by approximately **15 points**, or **0.20 standard deviations**. The effect is statistically significant under all specifications and supported by design-based randomization inference. There is no strong evidence of heterogeneous effects across gender, poverty, or teacher experience groups.

---

*Analysis conducted in Stata. All standard errors in the preferred specification are clustered at the school level (79 clusters).*
