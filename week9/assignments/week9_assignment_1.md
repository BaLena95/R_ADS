---
title: "week8_1"
output: html_document
---

Hierarchical and k-means clustering
Introduction
We use the following packages:

```{r}
library(MASS) # make sure to load mass before tidyverse to avoid conflicts!
library(tidyverse)
library(ggplot2)

# gtable, grid, stats, grDevices, utils, graphics
# couldn't load patchwork therefore loaded single packages
library(grid)
library(stats)
library(grDevices)
library(utils)
library(graphics)

library(ggdendro)
```

In this practical, we will apply hierarchical and k-means clustering to two synthetic datasets. The data can be generated by running the code below.

Try to understand what is happening as you run each line of the code below
```{r}

# randomly generate bivariate normal data
set.seed(123)
sigma      <- matrix(c(1, .5, .5, 1), 2, 2)
sim_matrix <- mvrnorm(n = 100, mu = c(5, 5), Sigma = sigma)
colnames(sim_matrix) <- c("x1", "x2")

# change to a data frame (tibble) and add a cluster label column
sim_df <- 
  sim_matrix %>% 
  as_tibble() %>%
  mutate(class = sample(c("A", "B", "C"), size = 100, replace = TRUE))

# Move the clusters to generate separation
sim_df_small <- 
  sim_df %>%
  mutate(x2 = case_when(class == "A" ~ x2 + .5,
                        class == "B" ~ x2 - .5,
                        class == "C" ~ x2 + .5),
         x1 = case_when(class == "A" ~ x1 - .5,
                        class == "B" ~ x1 - 0,
                        class == "C" ~ x1 + .5))
sim_df_large <- 
  sim_df %>%
  mutate(x2 = case_when(class == "A" ~ x2 + 2.5,
                        class == "B" ~ x2 - 2.5,
                        class == "C" ~ x2 + 2.5),
         x1 = case_when(class == "A" ~ x1 - 2.5,
                        class == "B" ~ x1 - 0,
                        class == "C" ~ x1 + 2.5))
```

```{r}
head(sim_df_small)
```

Prepare two unsupervised datasets by removing the class feature

```{r}
sim_df_small_nc <- subset(sim_df_small, select=-c(class))
head(sim_df_small_nc)

sim_df_large_nc <- subset(sim_df_large, select=-c(class))
head(sim_df_large_nc)
```

For each of these datasets, create a scatterplot. Combine the two plots into a single frame (look up the “patchwork” package to see how to do this!) What is the difference between the two datasets?

```{r}
pl_large <- ggplot(data=sim_df_large_nc)+
  geom_point(aes(x1,x2))
pl_large

pl_small <- ggplot(sim_df_small_nc)+
  geom_point(aes(x1, x2))
pl_small


```
```{r}
# plots next to each other
pl_large + pl_small
```


```{r}
# combine into the same plot


```

Hierarchical clustering
Run a hierarchical clustering on these datasets and display the result as dendrograms. Use euclidian distances and the complete agglomeration method. Make sure the two plots have the same y-scale. What is the difference between the dendrograms? (Hint: functions you’ll need are hclust, ggdendrogram, and ylim)

```{r}
# clustering large dataset with euclidean distance and complete agglomeration method 
df <- sim_df_large_nc
d <- dist(df, method="euclidean")
hc_large_euclidean <- hclust(d, method = "complete")
```

```{r}
# clustering small dataset with euclidean distance and complete agglomeration method 
df2 <-sim_df_small_nc
d2 <- dist(df2, method="euclidean")
hc_small_euclidean <-hclust(d2, method="complete")
```

```{r}
# plotting both small and large dataset after clustering
ggdendrogram(hc_large_euclidean, labels=FALSE) + ggtitle("complete euclidean large") + ylim(0,10)+
  ggdendrogram(hc_small_euclidean, labels=FALSE)+ ggtitle("complete euclidean small") + ylim(0,10)

```
For the dataset with small differences, also run a complete agglomeration hierarchical cluster with manhattan distance.

```{r}
# same thing as above with manhattan distance
df3 <-sim_df_small_nc
d3 <- dist(df3, method="manhattan")
hc_small_manhattan <-hclust(d3, method="complete")

g1 <- ggdendrogram(hc_small_manhattan) + ylim(0,10) + labs(title = "Small Dataset")

g1
```

Use the cutree() function to obtain the cluster assignments for three clusters and compare the cluster assignments to the 3-cluster euclidian solution. Do this comparison by creating two scatter plots with cluster assignment mapped to the colour aesthetic. Which difference do you see?

```{r}
# using d2 with euclidean distance and only using 3 clusters
manh_cut <-cutree(hc_small_manhattan, k=3)
euc_cut <-cutree(hc_small_euclidean, k=3)

# to be able to use the cutree results in the plot we need to assign them to a variable
sim_df_small_nc <-sim_df_small_nc %>%
  mutate("manhatten"=manh_cut, 
         "euclidean"=euc_cut)

g1 <- ggplot(sim_df_small_nc, aes(x1,x2, color=manhatten)) + geom_point() + labs(title= "3-Cl Manhattan Distances")
g2 <- ggplot(sim_df_small_nc, aes(x1,x2, color=euclidean)) + geom_point() + labs(title= "3-Cl Euclidean Distances")

g1 + g2
```

K-means clustering
Create k-means clusterings with 2, 3, 4, and 6 classes on the large difference data. Again, create coloured scatter plots for these clusterings.

```{r}
# means clustering on large dataset with centers/clusters 2,3,4,6

k2 <- kmeans(sim_df_large_nc, centers=2)
k3 <- kmeans(sim_df_large_nc, centers=3)
k4 <- kmeans(sim_df_large_nc, centers=4)
k6 <- kmeans(sim_df_large_nc, centers=6)

# adding the data into frame
sim_df_large_clusters <- sim_df_large_nc %>%
  mutate("k2" = k2$cluster,
         "k3" = k3$cluster,
         "k4" = k4$cluster,
         "k6" = k6$cluster,
         )

# plot different clusters
(ggplot(sim_df_large_clusters, aes(x1,x2, color=k2))+geom_point() + theme_classic()) +
  (ggplot(sim_df_large_clusters, aes(x1,x2, color=k3))+geom_point() + theme_classic()) +
   (ggplot(sim_df_large_clusters, aes(x1,x2, color=k4))+geom_point() + theme_classic()) +
    (ggplot(sim_df_large_clusters, aes(x1,x2, color=k6))+geom_point() + theme_classic()) 
```

Do the same thing again a few times. Do you see the same results every time? where do you see differences?


They don't look the same as the first step always used random data which is why they can end up in different clusters as the mean is close but not the same - therefore also color etc. not the same
```{r}
# means clustering on large dataset with centers/clusters 2,3,4,6

k2 <- kmeans(sim_df_large_nc, centers=2)
k3 <- kmeans(sim_df_large_nc, centers=3)
k4 <- kmeans(sim_df_large_nc, centers=4)
k6 <- kmeans(sim_df_large_nc, centers=6)

# adding the data into frame
sim_df_large_clusters <- sim_df_large_nc %>%
  mutate("k2" = k2$cluster,
         "k3" = k3$cluster,
         "k4" = k4$cluster,
         "k6" = k6$cluster,
         )

# plot different clusters
(ggplot(sim_df_large_clusters, aes(x1,x2, color=k2))+geom_point() + theme_classic()) +
  (ggplot(sim_df_large_clusters, aes(x1,x2, color=k3))+geom_point() + theme_classic()) +
   (ggplot(sim_df_large_clusters, aes(x1,x2, color=k4))+geom_point() + theme_classic()) +
    (ggplot(sim_df_large_clusters, aes(x1,x2, color=k6))+geom_point() + theme_classic()) 

```

Find a way online to perform bootstrap stability assessment for the 3 and 6-cluster solutions.
```{r}
```


```{r}
```

