---
title: "week7_flexible_imputation_NA"
output: html_document
---

book for week7 Flexible Imputation of Missing Data
http://stefvanbuuren.name/fimd/sec-MCAR.html

1.1 The problem of missing data
```{r}
y <- c(1, 2, 4)
mean(y)
```

```{r}
y <- c(1, 2, NA)
mean(y)
mean(y, na.rm = TRUE)
```

to set the na.action() as default each time change in options
```{r}
options(na.action = na.omit)

```


1.2 Concepts of MCAR, MAR and MNAR


If the probability of being missing is the same for all cases, then the data are said to be missing completely at random (MCAR).
-> cause for the missing data is unrelated to the data

If the probability of being missing is the same only within groups defined by the observed data, then the data are missing at random (MAR).  
-> MAR is more general and realistic than MCAR 
-> modern missing data models start with this assumption

If neither MCAR nor MAR holds, then we speak of missing not at random (MNAR). == NMAR (not missing at random)
An example of MNAR in public opinion research occurs if those with weaker opinions respond less often.
-> MNAR is the most complex case

1.3
disadvantage of only using complete datasets is that a lot of data is lost, however it is the easiest way to handle missing values and use them for further research.

disadvantage deleting NAs in MCAR is that dletion bias estimates of mean, regression coefficients and cor.
listwise deletion (all values for NA) can be useful for certain cases. It provides better estimates than even the best procedures. 
- sometimes deleting all missing data creates are harder to work with dataset that makes it impossible to do calculations (e.g. if a lot of NAs on meterological data are from May and one takes them all out - no clear estimate/calculation can be done that includes May in it)

1.3.2 pairwise deletion 
== available-case analysis 
method calculates the means & covariances on all data ->the mean of X is based on all cases with observed data on X,...

means & correlation of airquality under pairwise deletion:

```{r}
data <- airquality[, c("Ozone", "Solar.R", "Wind")]
mu <- colMeans(data, na.rm = TRUE)
cv <- cov(data, use = "pairwise")
```

downside:
- estimates can be biased if data are not MCAR
- cov/cor matrix may not be positive which is rewuired for multivariate procedures
- more problems when highly cor variables
- pairwise deletion rewuires numerical data with norma distribution

-> works best if normal distribution, low cor/covar., assumption of MCAR


1.3.3 Mean imputation

replace missing data by the mean
to use a function to replace NAs with mean in R use package mice
```{r}
install.packages("mice")
library("mice")
```

imouting the mean in each variable
```{r}
imp <- mice(airquality, method = "mean", m = 1, maxit = 1)

```

The argument method = mean specifies mean imputation, the argument m = 1 requests a single imputed dataset, and maxit = 1 sets the number of iterations to 1 (no iteration).

Mean imputation distorts the distribution in several ways.
- changes sd
- correlation changes

mean imutation is a fast/easy fix but underestimaes variance, relations between variables, estimates
- basically biases everything but the mean

- should only be used as a quick fix with very few NAs


1.3.4 Regression imputation

- incorporates knowledge from other variables to make smarter imputations

1. build model from data
2. predictions of the imcomplete cases are calculated under model as replacements for NA

```{r}
ata <- airquality[, c("Ozone", "Solar.R")]
imp <- mice(data, method = "norm.predict", seed = 1,
           m = 1, print = FALSE)
xyplot(imp, Ozone ~ Solar.R)
```

- the values correspond to the most likely values under the model.
- the imputed values vary less than the observed values.
- unlikely that the real values would have had the distribution 
- affects correlation (upwards bias as cor. of imputed values is higher than the non-imputet values)

- yields unbiased estimates of means under MCAR (like mean imputation) 
- regression weights are unbiased under MAR if the factors that cause the NAs are part of the regression model
- correlation biased upwards
- degree of underestimation depends on the explained variance and proportion of missing cases

- most "dangerous" method described
 it leads to a stronger relation in the data and biases the cor
 -> creates false positives 
 
 
 
1.3.5 Stochastic regression imputation

refinement of regression imputation that addresses the problem with correlation bias by adding noise 

```{r}
data <- airquality[, c("Ozone", "Solar.R")]
imp <- mice(data, method = "norm.nob", m = 1, maxit = 1,
            seed = 1, print = FALSE)
```
- method = "norm.nob"
= plain non-bayesian stochastic regression method

This method first estimates the intercept, slope and residual variance under the linear model, then calculates the predicted value for each missing value, and adds a random draw from the residual to the prediction.

- problems: 
it uses negative predictive values as part of the imputations which makes sense but doesn't necessarily translate to real life as Ozone measures cannot be negative
- assumes equal distribution around regression line
- spoile predicitions by adding noise

pro:
- preserves the regression weights and the correlation between variables 


1.3.6 LOCF and BOCF

LOCF = last observation carried forward
BOCF = baseline observation carried forward

for longitudinal data 
- takes the previous oservation value as a replacement for the missing data
- when multiple values are missing in a row it searches for the last observed value 
- fill()

```{r}
airquality2 <- tidyr::fill(airquality, Ozone)
```

- convenient because it generates a complete datasets
- it can however yield biased estimates even under MCAR
- LOCF needs to be followed by statistical analysis to distinguish between real and imputes data

1.3.7 Indicator method

- if there's NAs in one of the explanatory variables we need to fit a regression:
replaces each missing value by a zero and extends the regression model by the response indicator
-> analyze the extended model instead of the original one

```{r}
imp <- mice(airquality, method = "mean", m = 1,
            maxit = 1, print = FALSE)
airquality2 <- cbind(complete(imp),
                     r.Ozone = is.na(airquality[, "Ozone"]))
fit <- lm(Wind ~ Ozone + r.Ozone, data = airquality2)

```
- popular in epidemiology and public health 
- allows for systematic differences between observed and unobserved data by including the response indicator 

unbiased estimate when:
- NA restricted to covariance
- restricted to estimation of treatment effect
- model is linear without interactions

con:
- does not allow NA in the outcome
- fails observational data
- can yield biased regression estimates even when MCAR/ few NAs

### CHECK SUMMARY at 1.3.8 table

1.4 Multiple impuation in a nutshell

1.4.1 Procedure

multiple imputation creates m>1 complete datasets. Each is analyzed by software to pool the m results into a final point estimate plus sd. 

first: observed, incomplete data creating 
- multiple incomplete versions of the data by replacing NA with plausible values
- plausible values are drawn from a distribution specifically modeled for each missing entry
- the imputed datasets are identical for the observed data entries but differ in the imputed values

second: estimate the parameters of interest from each imputed dataset by using the analytic methods that we would have used on the complete dataset
the results differ because the input data differs because of the uncertainty about the values to impute

last: pool the m paramter estimates into ONE estimate
variance combines the conventional variance and the extra variance caused by the missing data (between imputation variance)

1.4.2 reason to use multiple imputation

- solves the problem of "too small" sd
- deals with uncertainty of the imputations themselves
- Multiple imputation is able to deal with both high-confidence and low-confidence situations equally well
- ability do separate the missing-data problem from complete-data problem -> better insight

1.4.3 example of multiple imputation

```{r}
imp <- mice(airquality, seed = 1, m = 20, print = FALSE)
fit <- with(imp, lm(Ozone ~ Wind + Temp + Solar.R))
summary(pool(fit))
```


```{r}
fit <- lm(Ozone ~ Wind + Temp + Solar.R, data = airquality)
coef(summary(fit))
```

