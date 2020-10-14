---
title: "week7_2"
output: html_document
---
Imputation assignment 2

```{r}
library(tidyverse)
library(mice)
library(dbplyr)
```

Ad-hoc imputation methods for missing data
In this assignment, we will again use the nhanes dataset from the mice package.
Prepare a data frame for complete case analysis. Call this data frame df_cc.
```{r}
library(NHANES)

head(nhanes)
```

Prepare a data frame for complete case analysis. Call this data frame df_cc.
```{r}
df_cc <- nhanes
df_cc <-na.omit(df_cc)
```

Prepare a dataset by performing mean imputation. Again, give this dataset a reasonable name.
```{r}
#first make a function to impute the mean
impute_mean <-function(x){ 
  x[is.na(x)] <- mean(x, na.rm=TRUE)
  return(x)
}

# use the function on the dataset
df_mu <- mutate_all(nhanes, impute_mean)
df_mu

# or like this using mice to do mean umputation on dataset
imp_mean <- mice(df, method = "mean", m = 1, maxit = 1)
imp_mean_df <- complete(imp_mean)
imp_mean_df

```

regression imputation 
```{r}
df_mimp <- mice(nhanes, method = "norm.predict", seed = 1,
           m = 1, print = FALSE)
xyplot(df_mimp, bmi ~ chl)
df_mimp
```

Hint: use the replace_na() function from the dplyr package in the tidyverse

For these two datasets, compute the mean and variance for each feature. Show how they differ! Are they the same? Explain why the variance in the chl feature is lower in the mean imputed dataset.

```{r}
# variance changes because more points are (closer) the mean and therefore the variance is lower after we did mean imputation 
var(df_cc)

var(imp_mean_df)
```


```{r}
# comparing the means and variance from the dataset with all NAs removed to the dataset that was changed through mean imputation

data.frame(
  mean_complete = map_dbl(df_cc, mean),
  mean_imputed = map_dbl(df_mu, mean),
  var_complete = map_dbl(df_cc, var),
  var_imputed = map_dbl(df_mu, var)
)

```

Assignment
Perform regression imputation on the fdgs dataset according to the following paragraph, and compute the estimate of the population mean. (NB: the paragraph is the example answer from the last exercise in the previous assignment)

pattern shows:
- 

```{r}
df_fdgs <-fdgs
md.pattern(df_fdgs)
```


```{r}
wgt_na <-subset(df_fdgs, df_fdgs$wgt=="NA") 
wgt_na

```


iimputation with mean
```{r}
imp_mean <- mice(df_fdgs, method = "mean", m = 1, maxit = 1)
df_fgds_mean <- complete(imp_mean)
```


imputation with regression 
```{r}
#regression imputation for fdgs

imp <- mice(df_fdgs, method = "norm.predict", seed = 1,
           m = 1, print = FALSE)
xyplot(imp, wgt ~ age)

```

Since the goal is to estimate the mean weight of the population, and we assume MAR, we have to impute (complete case analysis is only unbiased under MCAR). Regression imputation will work fine for this purpose. For the imputation model, I would create a linear model with wgt as the outcome. The model will include all variables (except id, and hgt.z) and also a quadratic effect of age (as weight will probably increase less as the child gets older). Then, I can impute the predicted values for the missing weight cells. The sample mean will then be the estimate of the population mean.

```{r}
df_fdgs_age2 <- df_fdgs %>%
  mutate( age2 = age^2)
# elevate age to quadratic as question suggests
multi.fit = lm(wgt~reg+age2+sex+hgt, data=df_fdgs_age2)
summary(multi.fit)
```


```{r}
# predict a the weight with random values by using the model 

value <- data.frame(
  reg = c("North"),
  age2 = c(20),
  sex = c("girl"),
  hgt = c(30)
  )
pred2 <- predict(multi.fit, value)
pred2

head(df_fdgs_age2)

```

predict the value
 
```{r}
# Use fit to predict the value
df3 <- df_fdgs_age2 %>% 
  #create a pred column to compare with original
  mutate(pred = predict(multi.fit, .)) %>%
  # Replace NA with pred in var1
  mutate(wgt = ifelse(is.na(wgt), pred, wgt))
# See the result
head(df3)

```

Extra challenge: now, using the same model, perform stochastic regression imputation (norm.nob) as explained in section 1.3.5 of FIMD and compute the sample mean of weight. Do it again. Is the result the same? What does this variation in the sample mean represent?

```{r}
#df with regression imputation Using mice
df_fgds_reg <- df_fdgs
imp <- mice(df_fdgs, method = "norm.nob", seed = 1,
           m = 5, print = FALSE)
xyplot(imp, wgt ~ age )
```

```{r}
df_fgds_reg <- complete(imp)
#mean first time
mean(df_fgds_reg$wgt)
```



```{r}
#using stocasthic regression
df_fgds_reg <- df_fdgs #clean df
imp <- mice(df_fdgs, method = "norm.nob",
           m = 1, print = FALSE)
df_fgds_reg <- complete(imp)
#mean 2nd time
mean(df_fgds_reg$wgt)
```

