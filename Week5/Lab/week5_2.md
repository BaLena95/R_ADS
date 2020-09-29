---
title: "week5_2"
output:
  html_document: default
  pdf_document: default
---
```{r}

```

###Exploratory Data Analysis using ggplot2
#Introduction
#In this practical, you will conduct an exploratory data analysis, to investigate the relationship between portion size and nutritional value of the items sold at McDonald’s. To do this, you will need to use ‘ggplot2’ and ‘tidyverse’, as you did in the previous practical. The dataset used contains information on the McDonald’s menu and can be downloaded here. Save the data as a .csv file in the same folder as the rmd file that you work in.

###LOADING THE DATA INTO R
#To load the data from a separate file, use ‘read.cvs()’.

```{r}
library(tidyverse)

install.packages("GGally")
```

```{r}
library(GGally)
```

#A FIRST IMPRESSION OF THE DATA
#Before you start the analysis, a good first step is to get a sense of what the dataset looks like. This is especially when you import data from a separate file, because it is of great importance that you check whether the dataset is imported correctly.

```{r}
# Get an idea of what the menu dataset looks like
head(menu)
```
```{r}
# Check the structure of the menu dataset
str(menu)
```

# It can be seen that the variable indicating the serving size is of a vary inconvenient form. To transform this variable into a numeric variable indication the serving size in grams (food) or millilitres (drinks), you can run the code below. You can also try to recode it yourself of course!

```{r}
# Transformation drinks
# filter for all strings with fl oz. and then remove
# mutate to make service size numeric and not flzo
drink.fl <- menu %>% 
  filter(str_detect(Serving.Size, " fl oz.*")) %>% 
  mutate(Serving.Size = str_remove(Serving.Size, " fl oz.*")) %>% 
  mutate(Serving.Size = as.numeric(Serving.Size) * 29.5735)

drink.carton <- menu %>% 
  filter(str_detect(Serving.Size, "carton")) %>% 
  mutate(Serving.Size = str_extract(Serving.Size, "[0-9]{2,3}")) %>% 
  mutate(Serving.Size = as.numeric(Serving.Size))

# Transformation food
food <-  menu %>% 
  filter(str_detect(Serving.Size, "g")) %>% 
  mutate(Serving.Size = (str_extract(Serving.Size, "(?<=\\()[0-9]{2,4}"))) %>% 
  mutate(Serving.Size = as.numeric(Serving.Size))

# Add Type variable indicating whether an item is food or a drink 
menu2 <-  bind_rows(drink.fl, drink.carton, food) %>% 
  mutate(
   Type = case_when(
     as.character(Category) == 'Beverages' ~ 'Drinks',
     as.character(Category) == 'Coffee & Tea' ~ 'Drinks',
     as.character(Category) == 'Smoothies & Shakes' ~ 'Drinks',
     TRUE ~ 'Food'
   )
  )
```

# 1. After you ran the code, check the structure of the data once again, what type of variable is ‘Serving.Size’ now, and what was it before you ran the code?

```{r}
str(menu)
head(menu)
```

```{r}
head(menu2)
```
#VARIATION
#The first type of questions in visual EDA concern the variation in the data. As you can see, the items are categorized into different product groups. To get an idea of the variation among item categories and nutritional value, several visualisations can be made.

# 2. Create a graph that gives insight in the number of items in each ‘Category’, use ‘geom_bar()’ to make the graph. You can use ‘coord_flip()’ to put the categories on the y-axis and the counts on the x-axis. Use the ‘menu2’ dataframe to do this.

```{r}

ggplot(menu2, aes(y=Category))+
  geom_bar(fill='lightgreen', color='black')+
  coord_flip()
```

# 3. Plot the distribution of ‘Calories’ using ‘geom_histogram’. Describe the distribution, do you see anything notable?

```{r}
ggplot(menu2, aes(Calories))+
  geom_histogram(color='green')

  
```

##ASSOCIATION
#The second type of questions in visual EDA concern the association between different variables. The histogram you created in the previous question give insight in how the ‘Calories’ are distributed on the level of the whole menu. However, it may be interesting how ‘Calories’ are distributed on ‘Category’ level.

# 4. Plot the distribution of ‘Calories’ for each ‘Category’ using ‘geom_density()’ in combination with ‘facet_wrap()’, can you see in which ‘Category’ the outlier that can be seen in the histogram falls?

```{r}
ggplot(menu2, aes(Calories))+
  geom_density(fill='light seagreen', alpha=0.5)+
  facet_wrap(~Category)

```

##An easier way to spot outliers, is by creating a boxplot, because the geom is structured in a way that it emphasizes the outliers.

# 5. Create a boxplot of the ‘Calories’ for each ‘Category. Is the outlier in the same ’Category’ as you thought it was in based on the previous question?‘. Again you can use ’coord_flip()’ to swich the axes of the plot.

```{r}
ggplot(menu2, aes(Calories, Category))+
  geom_boxplot(fill='lightpink')+
  coord_flip()
```

#Now you know in which category the outlier falls, you can check which item it is that has such a high energetic value.

#For the next plot, you need to pipe the data using ‘%>%’ from the ‘magrittr’ package. More information on piping can be found here. (https://r4ds.had.co.nz/pipes.html)

# 6. Create a plot using ‘geom_col()’ to visualise the number of ‘Calories’ each item in the Chicken & Fish category. Use ‘filter()’ in combination with a pipe to select the information that you need for this plot. What is the item that contains so many calories? Why do you need to use ‘geom_col()’ here instead of ‘geom_bar()’?

```{r}
library(magrittr)

calor_col <- menu2 %>%
          filter(Category == "Chicken & Fish") %>%
            ggplot(aes(x = Item, y = Calories))+
              geom_col(color='blue')+
              coord_flip()

    calor_col

####ANSWER: the geom_col Function can use Columns whereas the 'normal' geom_bar function can only use numeric values    
    
```

####ANSWER: the geom_col Function can use Columns whereas the 'normal' geom_bar function can only use numeric values

# Now you know what causes the outlier, you can check whether there is an association between the serving size and the number of calories.

# 7. Create a scatter plot to visualise the association between serving size and calories. Are serving size and energetic value related to each other? Did you expect this outcome? Use the alpha argument in geom_point() to adjust the transparency.

```{r}

cal_serving <- menu2%>%
  ggplot(aes(Calories, Serving.Size))+
  geom_point(color='blue', alpha=0.5)

cal_serving

cor.test(menu2$Calories, menu2$Serving.Size)
```


# 8. Create a new scatter plot to visualise the association between serving size and calories, but now use the ‘colour’ argument to make a distinction between ‘Type’ (see ?aes for more info). Use ‘geom_smooth()’ to add a regression line to the plot. Does this alter your conclusion about the relationship between serving size and calories? What do you conclude now?

```{r}
cal_serving_t <- menu2%>%
  ggplot(aes(Calories, Serving.Size))+
  geom_point(mapping=aes(x=Calories, y=Serving.Size, color=Category))+
  geom_smooth()

cal_serving_t
```
```{r}
ggplot(menu2, aes(Serving.Size, Calories, color = Category))+
    geom_point(alpha = 0.3) + 
    geom_smooth() +
    theme_minimal()
```

# 9. Why do you think the relationship is so much affected by food type, is there a way to investigate this further using visualisations?

```{r}
head(menu2)

ggplot(menu2, aes(Serving.Size))+
  geom_density(color='blue')+
  facet_wrap(~Category)
```

### So far, you’ve only looked at the association between two variables at a time. However, when you are exploring associations, you may want to look at the association of many different variables at the same time (e.g. when you want to generate hypotheses). An easy way to do this, is to make use of the ‘ggpairs()’ function from the ‘GGally’ package.

# 10. Create a plot using ‘ggpairs()’ where the association between atleast 4 different variables is visualised. Are there differences in the associations between those variables based on item Type?

```{r}
ggpairs(menu2[,c(6,15,19,20)]) +
    theme_minimal()
```
```{r}
install.packages("WVPlots")
 library(WVPlots) 

```


```{r}
  PairPlot(menu2, 
         colnames(menu2[, c(6,19,20)]), 
         "Menu2", 
         group_var = "Category") + 
          theme_minimal()

ggpairs(menu2, columns=c(6,19,20), ggplot2::aes(colour= Category)) +
    theme_minimal()
```
```{r}
ggpairs(menu2, columns=c(3,4,20), ggplot2::aes(colour= Category)) +
    theme_minimal()
```

