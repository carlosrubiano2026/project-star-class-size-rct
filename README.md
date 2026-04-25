# Project STAR: Class Size and Student Achievement

This repository analyzes Project STAR, a randomized controlled trial designed to estimate the effect of smaller class sizes on student achievement.

Project STAR was conducted in Tennessee in the late 1980s. Students and teachers were randomly assigned within participating schools to different class arrangements. This project focuses on kindergarten students and compares children assigned to small classes with children assigned to regular classes without a teacher aide.

## Research Question

What is the causal effect of being assigned to a small kindergarten class on student test scores?

## Data

The dataset contains kindergarten-level observations from Project STAR.

Key variables:

| Variable | Description |
|---|---|
| `tscorek` | Kindergarten test score |
| `sck` | Small class indicator |
| `totexpk` | Teacher experience in years |
| `schidkn` | School identifier |
| `boy` | Indicator for male student |
| `freelunk` | Indicator for free lunch eligibility |

## Empirical Strategy

Because treatment was randomly assigned within schools, the main specification estimates the effect of small class assignment while controlling flexibly for school fixed effects.

The baseline model is:

```text
TestScore_i = α + β SmallClass_i + ε_i
