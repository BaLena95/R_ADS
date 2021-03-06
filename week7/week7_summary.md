---
title: "Untitled"
output: html_document
---

```{r}
library(tidyverse)
library(mice)
library(NHANES)

head(nhanes)
```

Why is missing data important? 
- most procedures can't be done (by default)
- less information (accuracy & estimates)
- systematic biases (predicition error seems better than it is & wrong estimates)

Missing values are:
unobserved values that do exist (in theory)
- NOT 0 (the true value might be but one cannot assume that)

If not all necessary information is captured -> inference may be wrong
happens through: 
- false sampling
- coverage - wrong target group for population n
- non-contat or refusal to answer = no response
- incompetence

```{r}
df_cc <-na.omit(nhanes)
df_cc
```

SQL       - WHERE X IS NULL
R         - is.na(df)
Python    - df.isna()

```{r}
#just shows whether TRUE/FALSE for NA
is.na(nhanes)

# 2883 NAs
sum(na.omit(nhanes))
```

Problem with NA- we can't define:
- unbiased variance estimator
- correlation/regression

therefore
- lower statistical power (hard to find significant difference)
- larger se & confidence intervals


missing data mechanism
- R=1 -> Y is observed
- R=0 -> Y is missing (NA)

one can test for MCAR or MAR assuming that it's one of both cases
one annot test for MNAR -> only make the assumption that it is MNAR

MCAR
- missing completely at random
- probability of NA is same for all cases
- P(R,X,U) = P(R)P(X,U)
example:
- random sample of population - obtaining data fails randomly

MAR
- missing at random
- probability of NA is same within group defined by the observed data
- P(R,X,U) = P(R,X)P(U)
example:
- non-response on income/wealth/sensitive data but we DO HAVE additional data

MNAR
- missing not at random 
- when it's neither MAR nor MCAR
- missingness depends on missing values themselves
- e.g. weaker opinions have less responses
- P(R,X,U) cannot be reduced
example:
- non-response for income but no additional data


day2 

strategies to deal with NA during data wrangling
- imputation(s)= replacing missing values with guessed values
    - produces "complete" data
    
    
Deductive imputation
- we have data that helps us find missing data
e.g. we know height & weight therefore we can find missing BMI


Listwise deletion = Complete Case Analysis
pro:
- simple/fast
- unbiased under MCAR
con:
- wasteful
- big se 
- biased under MAR

```{r}
df_cc <- nhanes
df_cc <-na.omit(df_cc)
```

Mean imputation
= replace NA with mean
  univariate & bivariate 
pro:
- simple
- unbiased for mean under MCAR
con:
- disturbs distribution
- underestimates variance
- biases cor (smaller)
- biased under MAR

```{r}
#first make a function to impute the mean
impute_mean <-function(x){ 
  x[is.na(x)] <- mean(x, na.rm=TRUE)
  return(x)
}

# use the function on the dataset
df_mu <- mutate_all(nhanes, impute_mean)
df_mu

```

Regression imputation = prediction
- fit model (predicition)
- predict NA
- good predicition = good approximation
- in mice - method ="norm.predict"
pro:
- unbiased estimates of regression coefficients (MAR)
- good approximation of NA if explained variance is high
con:
- increases correlation
- underestimates uncertainty = lower p-value, narrow confidence intervals
- harmful to statistical inference

```{r}
df_mimp <- mice(nhanes, method = "norm.predict", seed = 1,
           m = 1, print = FALSE)
xyplot(df_mimp, bmi ~ chl)
df_mimp
```

Stochastic regression imputation
- adds noise to predictions in regression imputation
- uncertainty in the prediction model because of unexplained (random) variance through noise
- in mice - method="norm.nob"
pro:
- "honest" about uncertainty (maybe effective sample size is low but at least we know)
preserves
- distribution of variable
- correlation
con:
- symmetric and constant error
- uncertainty estimate is still off but gets better the more imputations we do
- not as simple

```{r}
# statistic regression imputation
nhanes_srimp <- mice(nhanes, method = "norm.nob", seed = 1,
           m = 1)

# plot statistic regression imputation 
xyplot(nhanes_srimp, bmi ~ chl)

#store the complete data
data_srimp <- complete(nhanes_srimp)
data_srimp

```
```{r}
plot(data_srimp$bmi[!is.na(data_srimp$chl)], data_srimp$chl[!is.na(data_srimp$chl)], # Plot of observed values
     main = "Stochastic Regression Imputation",
     xlab = "BMI", ylab = "Chl")
abline(lm(chl ~ bmi, data_srimp), col = "#1b98e0", lwd = 1.5)
```

Embedded methods
- no imputation 
- handling NA in prediction model itself (later)
- almost always MAR
example:
- classification tree


Fixing standard error with multiple imputations
- stochastic imputation with multiple datasets that slightly differ
- consider uncertainty 
- perform analysis multiple times and pool results
  pooling by:
  - Estimand Q - e.g. mean length of population
  - Estimator ^Qm - mean length in imputet dataset m
  - Estimator -Q - aberage of means in different ^Q estimates (uncertainty)
      - within dataset variance (only a sample of data)
      - between dataset variance (variance through NA in subset)
      - simulation error (veriance of -Q estimator because it is based on different datasets ^Qm) the bigger M/more samples the bigger the uncertainty

      
mice package
- performs multiple imputations & pooling
- incomplete data -> imputed data -> analysis result -> pooled result
-                mice()          with()              pool()

alternative to pooling = sensitivity 
- if the conclusion of interest does not change across the m imputed datasets, we say that the conclusion is not sensitive to the imputation

```{r}
