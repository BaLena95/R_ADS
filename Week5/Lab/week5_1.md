---
title: "week5_1_md"
output: html_document
---


install.packages("tidyverse")
install.packages("ISLR")
library(tidyverse)
library(ISLR)

# looking at dataset Hitters
```{r}
head(Hitters)
```

# or end of dataset
```{r}
tail(Hitters)
```

# or to just look at all of the data
view(Hitters)

# Histogram of salary in Hitters 

```{r}
hist(Hitters$Salary, xlab = "Salary in thousands of dollars")
```

# barplot of how many members in each league
```{r}
barplot(table(Hitters$League))
```
# number of career home runs vs 1986 home runs
```{r}
plot(x = Hitters$Hits, y = Hitters$HmRun, 
     xlab = "Hits", ylab = "Home runs")
```

```{r}
homeruns_plot <- 
  ggplot(Hitters, aes(x = Hits, y = HmRun)) +
  geom_point() +
  labs(x = "Hits", y = "Home runs")

homeruns_plot
```
###
#1. input the dataset to a ggplot() function call
#2. construct aesthetic mappings
#3. add (geometric) components to your plot that use these mappings
#4. add labels, themes, visuals.

```{r}
homeruns_plot + 
  geom_density_2d() +
  labs(title = "Cool density and scatter plot of baseball data") +
  theme_minimal()
```
# 1. Name the aesthetics, geoms, scales, and facets of  the above visualisation. Also name any statistical transformations or special coordinate systems.

# Answer: 


# ASTHETICS AND DATA PREPARATION 

# 2. Run the code below to generate data. There will be three vectors in your environment. Put them in a data frame for entering it in a ggplot() call using either the data.frame() or the tibble() function. Give informative names and make sure the types are correct (use the as.<type>() functions). Name the result gg_students

```{r}
set.seed(1234)
student_grade  <- rnorm(32, 7)
student_number <- round(runif(32) * 2e6 + 5e6)
programme      <- sample(c("Science", "Social Science"), 32, replace = TRUE)
```

```{r}
gg_students <- data.frame(student_grade, student_number, programme)

head(gg_students)

```

# 3. Plot the first homeruns_plot again, but map the Hits to the y-axis and the HmRun to the x-axis instead.

```{r}
homeruns_plot_1 <- 
  ggplot(Hitters, aes(x = HmRun, y = Hits)) +
  geom_point() +
  labs(x = "Home run", y = "Hits")

homeruns_plot_1
```

# 4. Recreate the same plot once more, but now also map the variable League to the colour aesthetic and the variable Salary to the size aesthetic.

```{r}
homeruns_plot_1 <- 
  ggplot(Hitters, aes(x = HmRun, y = Hits)) +
  geom_point(mapping=aes(x=HmRun, y=Hits, color=League)) +
  labs(x = "Home runs", y = "Hits")

homeruns_plot_1
```
```

# Examples of aesthetics are:

# x
# y
# alpha (transparency)
# colour
# fill
# group
# shape
# size
# stroke

# GEOMS

# 5. Look at the many different geoms on the website
# https://ggplot2.tidyverse.org/reference/#section-layer-geoms

###There are two types of geoms:

### geoms which perform a transformation of the data beforehand, such as geom_density_2d() which calculates contour lines from x and y positions.
# geoms which do not transform data beforehand, but use the aesthetic mapping directly, such as geom_point().

# VISUAL EXPLORATORY DATA ANALYSIS
### Several types of plots are useful for exploratory data analysis. In this section, you will construct different plots to get a feel for the two datasets we use in this practical: Hitters and gg_students. One of the most common tasks is to look at the distributions of variables in your dataset.

# HISTOGRAM

# 6. Use geom_histogram() to create a histogram of the grades of the students in the gg_students dataset. Play around with the binwidth argument of the geom_histogram() function.

```

```{r}
ggplot(gg_students, aes(student_grade)) +
  geom_histogram(binwidth = 1)
```

# DENSITY
# 7. Use geom_density() to create a density plot of the grades of the students in the gg_students dataset. Add the argument fill = "light seagreen" to geom_density().

```{r}
ggplot(gg_students, aes(student_grade))+
  geom_density(fill='light seagreen')

```

# 8. Add rug marks to the density plot through geom_rug(). You can edit the colour and size of the rug marks using those arguments within the geom_rug() function.

```{r}
ggplot(gg_students, aes(student_grade))+
  geom_density(fill='light seagreen')+
  geom_rug(colour='blue')

```

# 9. Increase the data to ink ratio by removing the y axis label, setting the theme to theme_minimal(), and removing the border of the density polygon. Also set the limits of the x-axis to go from 0 to 10 using the xlim() function, because those are the plausible values for a student grade.

```{r}
ggplot(gg_students, aes(student_grade))+
  geom_density(fill='light seagreen', colour=NA)+
  geom_rug(colour="blue")+
  theme_minimal()+
  xlim(0,10)
```


# BOXPLOT
### Increase the data to ink ratio by removing the y axis label, setting the theme to theme_minimal(), and removing the border of the density polygon. Also set the limits of the x-axis to go from 0 to 10 using the xlim() function, because those are the plausible values for a student grade.

# 10. Create a boxplot of student grades per programme in the gg_students dataset you made earlier: map the programme variable to the x position and the grade to the y position. For extra visual aid, you can additionally map the programme variable to the fill aesthetic.

```{r}
boxplot(student_grade~programme, data=gg_students, col="lightblue")
```
# 11. What do each of the horizontal lines in the boxplot mean? What do the vertical lines (whiskers) mean?
# the horizontal lines are the mean values, the whiskers show the standard deviasion of the values and the dots the 'Ausreisser'

# TWO DENSITIES 

# 12. Comparison of distributions across categories can also be done by adding a fill aesthetic to the density plot you made earlier. Try this out. To take care of the overlap, you might want to add some transparency in the geom_density() function using the alpha argument. 

```{r}
ggplot(gg_students, aes(student_grade))+
  geom_density(fill='light seagreen', alpha=0.4)+
  geom_rug(colour='blue')
```


# BAR PLOT
# 13. Create a bar plot of the variable Years from the Hitters dataset.
```{r}
ggplot(data=Hitters, aes(Years)) +
  geom_bar()
```

# LINE PLOT
# 14. Use geom_line() to make a line plot out of the first 200 observations of the variable Volume (the number of trades made on each day) of the Smarket dataset. You will need to create a Day variable using mutate() to map to the x-position. This variable can simply be the integers from 1 to 200. Remember, you can select the first 200 rows using Smarket[1:200, ].
```{r}
# add to a new variable with only the first 200 lines
smarket_200 <- select(Smarket[1:200,],
                    Volume)
# use mutate function to add the new variable days
smarket_200 <- mutate (smarket_200, days = 1:200)

#build geom line to plot the data
smarket_line <- ggplot(smarket_200, aes(x=days, y=Volume))+
  geom_line()

smarket_line
  

```

# 15. Give the line a nice colour and increase its size. Also add points of the same colour on top.
```{r}
smarket_line <- ggplot(smarket_200, aes(x=days, y=Volume))+
  geom_line(alpha=1.5, colour='darkgreen')+
  geom_point(color='purple')

smarket_line
```


# 16. Use the function which.max() to find out which of the first 200 days has the highest trade volume and use the function max() to find out how large this volume was.

```{r}

which.max(smarket_200$days)
which.max(smarket_200$Volume)

max(smarket_200$days)
max(smarket_200$Volume)

```

# 17. Use geom_label(aes(x = your_x, y = your_y, label = "Peak volume")) to add a label to this day. You can use either the values or call the functions. Place the label near the peak!
```{r}
#define in which day
smarket_day <- which.max(smarket_200$Volume)

#define which volume
smarket_vol <- max(smarket_200$Volume)

simple <-
  ggplot(smarket_200, aes(x = days, y = Volume))+
  geom_point() +
  geom_label(aes(x = smarket_day, y = smarket_vol , label = "Peak volume" ), colour = "orange" )


simple
```

### This exercise shows that aesthetics can also be mapped separately per geom, in addition to globally in the ggplot() function call. Also, the data can be different for different geoms: here the data for geom_label has only a single data point: your chosen location and the “Peak volume” label.

# FACETING

# 18. Create a data frame called baseball based on the Hitters dataset. In this data frame, create a factor variable which splits players’ salary range into 3 categories. Tip: use the filter() function to remove the missing values, and then use the cut() function and assign nice labels to the categories. In addition, create a variable which indicates the proportion of career hits that was a home run.

```{r}
baseball <- filter(Hitters, !is.na(Salary))
  
baseball <- mutate(baseball, Salary_split= cut(baseball$Salary, 3, labels = c('normal human', 'all the money', 'ridiculously rich')))
baseball

career_hr <-mutate(baseball, hrun_career = HmRun / Hits)
career_hr
```
########### 
########### no clue what's wrong
# 19. Create a scatter plot where you map CWalks to the x position and the proportion you calculated in the previous exercise to the y position. Fix the y axis limits to (0, 0.4) and the x axis to (0, 1600) using ylim() and xlim(). Add nice x and y axis titles using the labs() function. Save the plot as the variable baseball_plot.

```{r}

ggplot(baseball, aes(x=CWalks, y=career_hr))+
  geom_point(color="green")+
  xlim(0, 1600) +
  ylim(0, 0.4)+
  labs(y="ran home", title="visual of running home")

```

# 20. Split up this plot into three parts based on the salary range variable you calculated. Use the facet_wrap() function for this; look at the examples in the help file for tips.

```{r}
  baseball_plot_1 <- 
    ggplot(baseball, aes(x = CWalks, y = career_hr)) +
    geom_point(color = "blue")+
    xlim(0,1600) +
    ylim(0,0.4)+
    labs(y = "ran home", title = "Home Run`s x CWalks") +     facet_wrap(vars(Salary_split))

baseball_plot_1
```

### Faceting can help interpretation. In this case, we can see that high-salary earners are far away from the point (0, 0) on average, but that there are low-salary earners which are even further away. Faceting should preferably be done using a factor variable. The order of the facets is taken from the levels() of the factor. Changing the order of the facets can be done using fct_relevel() if needed.

# FINAL EXERCISE 

# 21. Create an interesting data visualisation based on the Carseats data from the ISLR package.
```{r}

```

