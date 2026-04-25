/********************************************************************
Question 3 — Project STAR
Randomized Experiment on Class Size and Student Achievement

Data: STAR.dta
Author: Carlos Arturo Rubiano Passos

Objective:
Estimate the effect of being assigned to a small kindergarten class
on test scores, using OLS, school fixed effects, clustered standard
errors, randomization inference, balance checks, and heterogeneous
treatment effects.
********************************************************************/
cls
clear all
set more off

/********************************************************************
0. USER SETTINGS
********************************************************************/

global data_path "/Users/carlosrubiano/Documents/DOCS_CARLOS/economía/MSc economics /2nd Term/Econometric Methods 2/PS5/STAR.dta"

use "$data_path", clear

/********************************************************************
1. BASIC INSPECTION
********************************************************************/

describe
summarize

tab sck
tab boy
tab freelunk
tab schidkn

/********************************************************************
2. CLEAN SAMPLE
********************************************************************/

* Keep complete observations
keep if !missing(tscorek, sck, totexpk, schidkn, boy, freelunk)

* Ensure treatment and controls are coded as expected
tab sck
tab boy
tab freelunk

* Label variables for readability
label var tscorek  "Kindergarten test score"
label var sck      "Small class treatment"
label var totexpk  "Teacher experience"
label var schidkn  "School identifier"
label var boy      "Boy"
label var freelunk "Free lunch"

/********************************************************************
3. PART A — OLS WITH BINARY REGRESSOR EQUALS DIFFERENCE IN MEANS
********************************************************************/

display "------------------------------------------------------------"
display "PART A: Regression with binary X equals difference in means"
display "------------------------------------------------------------"

* Mean outcome by treatment status
mean tscorek, over(sck)

* Manual means
summarize tscorek if sck == 0
scalar mean_regular = r(mean)
scalar sd_regular   = r(sd)
scalar n_regular    = r(N)

summarize tscorek if sck == 1
scalar mean_small = r(mean)
scalar sd_small   = r(sd)
scalar n_small    = r(N)

scalar diff_means = mean_small - mean_regular

display "Mean test score, regular class = " mean_regular
display "Mean test score, small class   = " mean_small
display "Difference in means           = " diff_means

* Regression equivalent
reg tscorek sck

display "In a regression Y on binary X:"
display "Intercept = mean outcome for X=0"
display "Slope     = mean outcome for X=1 minus mean outcome for X=0"

/********************************************************************
4. PART B — SHORT REGRESSION: TEST SCORE ON SMALL CLASS
********************************************************************/

display "------------------------------------------------------------"
display "PART B: Short regression"
display "------------------------------------------------------------"

summarize tscorek
scalar sd_testscore = r(sd)

reg tscorek sck, robust
estimates store B_short_robust

scalar beta_short = _b[sck]
scalar effect_sd_short = beta_short / sd_testscore

display "Treatment effect in test-score points = " beta_short
display "Sample SD of test scores              = " sd_testscore
display "Effect size in SD units               = " effect_sd_short

/********************************************************************
5. PART C — SCHOOL FIXED EFFECTS
********************************************************************/

display "------------------------------------------------------------"
display "PART C: School fixed effects"
display "------------------------------------------------------------"

reg tscorek sck i.schidkn, robust
estimates store C_schoolFE_robust

scalar beta_fe = _b[sck]
scalar effect_sd_fe = beta_fe / sd_testscore

display "Treatment effect with school FE = " beta_fe
display "Effect size in SD units         = " effect_sd_fe

/********************************************************************
6. PART D — NONROBUST VS ROBUST STANDARD ERRORS
********************************************************************/

display "------------------------------------------------------------"
display "PART D: Conventional vs robust standard errors"
display "------------------------------------------------------------"

reg tscorek sck i.schidkn
estimates store D_schoolFE_classical

reg tscorek sck i.schidkn, robust
estimates store D_schoolFE_robust

display "Random assignment helps identification, but robust SEs are still"
display "useful because the error variance can be heteroskedastic."

/********************************************************************
7. PART E — SCHOOL FIXED EFFECTS WITH CLUSTERED SEs
********************************************************************/

display "------------------------------------------------------------"
display "PART E: School fixed effects with school-clustered SEs"
display "------------------------------------------------------------"

reg tscorek sck i.schidkn, vce(cluster schidkn)
estimates store E_schoolFE_cluster

display "Clustered SEs allow arbitrary correlation in errors within schools."

/********************************************************************
8. TABLE: MAIN TREATMENT EFFECT ESTIMATES
********************************************************************/

cap which esttab
if _rc ssc install estout, replace

esttab B_short_robust C_schoolFE_robust D_schoolFE_classical D_schoolFE_robust E_schoolFE_cluster, ///
    keep(sck) ///
    se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Effect of Small Class Assignment on Kindergarten Test Scores") ///
    mtitles("Short robust" "School FE robust" "School FE classical" "School FE robust" "School FE clustered")

/********************************************************************
9. PART F — RANDOMIZATION INFERENCE
********************************************************************/

display "------------------------------------------------------------"
display "PART F: Randomization inference using ritest"
display "------------------------------------------------------------"

cap which ritest
if _rc ssc install ritest, replace

* Randomization inference for the school-FE specification.
* We use strata(schidkn) because randomization was within schools.
capture noisily ritest sck _b[sck], ///
    reps(1000) ///
    seed(12345) ///
    strata(schidkn): ///
    reg tscorek sck i.schidkn

if _rc {
    display "ritest failed in this Stata setup. Running manual permutation fallback."

    preserve

    tempfile base results
    save `base', replace

    postfile handle beta using `results', replace

    quietly reg tscorek sck i.schidkn
    scalar beta_observed = _b[sck]

    set seed 12345

    forvalues r = 1/1000 {
        use `base', clear

        * Randomize treatment within schools by shuffling treatment labels
        sort schidkn
        by schidkn: gen random_order = runiform()
        by schidkn random_order: gen rank_random = _n

        preserve
            keep schidkn sck
            bysort schidkn: gen original_rank = _n
            rename sck sck_shuffled
            tempfile treatlabels
            save `treatlabels', replace
        restore

        bysort schidkn (random_order): gen original_rank = _n
        merge 1:1 schidkn original_rank using `treatlabels', nogen

        quietly reg tscorek sck_shuffled i.schidkn
        post handle (_b[sck_shuffled])
    }

    postclose handle

    use `results', clear
    gen abs_beta = abs(beta)
    gen abs_observed = abs(beta_observed)
    gen extreme = abs_beta >= abs_observed

    summarize extreme
    display "Observed beta = " beta_observed
    display "Manual randomization inference p-value = " r(mean)

    restore
}

/********************************************************************
10. PART G — BALANCE TESTS
********************************************************************/

display "------------------------------------------------------------"
display "PART G: Balance checks"
display "------------------------------------------------------------"

* Separate regressions of covariates on treatment.
* In a randomized experiment, these coefficients should be small
* and statistically insignificant on average.

reg boy sck i.schidkn, vce(cluster schidkn)
estimates store G_balance_boy

reg freelunk sck i.schidkn, vce(cluster schidkn)
estimates store G_balance_freelunk

reg totexpk sck i.schidkn, vce(cluster schidkn)
estimates store G_balance_totexpk

esttab G_balance_boy G_balance_freelunk G_balance_totexpk, ///
    keep(sck) ///
    se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Balance Tests: Covariates on Small Class Assignment") ///
    mtitles("Boy" "Free lunch" "Teacher experience")

/********************************************************************
11. PART H — ADD COVARIATES TO SCHOOL-FE CLUSTERED REGRESSION
********************************************************************/

display "------------------------------------------------------------"
display "PART H: School FE + controls + clustered SEs"
display "------------------------------------------------------------"

reg tscorek sck boy freelunk totexpk i.schidkn, vce(cluster schidkn)
estimates store H_controls_cluster

esttab E_schoolFE_cluster H_controls_cluster, ///
    keep(sck boy freelunk totexpk) ///
    se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Effect of Small Class Assignment With and Without Controls") ///
    mtitles("School FE clustered" "School FE + controls clustered")

display "Because treatment is randomized, adding pre-treatment covariates"
display "should not substantially change the treatment coefficient."
display "The coefficients on boy, freelunk, and totexpk are conditional"
display "associations, not necessarily causal effects."

/********************************************************************
12. PART I — HETEROGENEOUS TREATMENT EFFECTS
********************************************************************/

display "------------------------------------------------------------"
display "PART I: Treatment heterogeneity"
display "------------------------------------------------------------"

capture drop sck_boy sck_freelunk sck_totexpk

gen sck_boy      = sck * boy
gen sck_freelunk = sck * freelunk
gen sck_totexpk  = sck * totexpk

label var sck_boy      "Small class x boy"
label var sck_freelunk "Small class x free lunch"
label var sck_totexpk  "Small class x teacher experience"

reg tscorek ///
    sck boy freelunk totexpk ///
    sck_boy sck_freelunk sck_totexpk ///
    i.schidkn, ///
    vce(cluster schidkn)

estimates store I_heterogeneity

esttab I_heterogeneity, ///
    keep(sck boy freelunk totexpk sck_boy sck_freelunk sck_totexpk) ///
    se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Heterogeneous Effects of Small Class Assignment")

* Joint F-test: treatment effect is homogeneous
test sck_boy sck_freelunk sck_totexpk

display "Interpretation:"
display "sck is the treatment effect for the baseline group:"
display "girl, not free-lunch, with zero years of teacher experience."
display "sck_boy shows how the treatment effect differs for boys."
display "sck_freelunk shows how the treatment effect differs for free-lunch students."
display "sck_totexpk shows how the treatment effect changes with teacher experience."

/********************************************************************
13. OPTIONAL: MARGINAL TREATMENT EFFECTS FOR EXAMPLE GROUPS
********************************************************************/

display "------------------------------------------------------------"
display "Optional: implied treatment effects for selected groups"
display "------------------------------------------------------------"

summarize totexpk
scalar mean_exp = r(mean)

display "Mean teacher experience = " mean_exp

lincom sck
lincom sck + sck_boy
lincom sck + sck_freelunk
lincom sck + sck_boy + sck_freelunk
lincom sck + sck_totexpk * mean_exp

/********************************************************************
14. FINAL INTERPRETATION NOTES
********************************************************************/

display "------------------------------------------------------------"
display "FINAL NOTES"
display "------------------------------------------------------------"

display "1. The short regression estimates the raw difference in mean test scores."
display "2. School fixed effects are preferred because randomization occurred within schools."
display "3. Robust SEs protect against heteroskedasticity."
display "4. Clustered SEs allow within-school correlation in unobservables."
display "5. Randomization inference uses the experimental assignment mechanism."
display "6. Balance tests check whether observed covariates predict treatment."
display "7. Adding covariates should not strongly change the treatment effect if randomization worked."
display "8. Interaction terms test whether the treatment effect differs across subgroups."

/********************************************************************
END OF DO-FILE
********************************************************************/
