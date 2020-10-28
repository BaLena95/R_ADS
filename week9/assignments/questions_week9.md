---
title: "Untitled"
output: html_document
---

1. inversion is

A) a top down approach in building dendograms where you start with every data point in a single cluster
B) a clustering method used with numerical data
C) an issue that occurs when clusters are fused at a height below the individual clusters in a dendogram
D) the bottom up approach in clustering data


2. The major drawback of the type of linkeage "inversion" can occur in:

A) average linkage
B) single linkage
C) complete linkage
D) centroid linkage


3.  Both K-means and hierachical clusters assign each obervation to a cluster. 
    Why can this cause problems?


4. Which of the following is NOT true about dendograms:

A) each leaf of a dendogram (upside down tree) represents an observation
B) branches of the dendogram can fuse with leaves 
C) the lower the fusion occurs in the dendogram the more similar are the observations in the clusters
D) the higher the fusion occurs in the dendogram the more similar are the observations in the clusters


5. Which of the following statements are correct:

A) Agglomerative Hierarchical Clustering starts with all observations in one cluster
B) Agglomerative Hierarchical Clustering starts with every observation in it's own cluster
C) Divisive Herarchical Clustering starts with all observations in one cluster
D) Divisive Herarchical Clustering starts with every observation in it's own cluster


6. Why do clusters in K-means clustering look different when repeating the process?


7. Which of the following density plots/features would be a good choice for clustering? Why?

```{r}
dens1 + dens2 + dens3 + dens4 + dens5 + dens6
```









Answers 

1. C) an issue that occures when clusters are fused at a height below the individual clusters in a dendogram

2. D) centroid linkage 
  two clusters are fused at a height below the individual clusters of the dendogram which leads to difficutlies in interpreting the dendogram and visualizing the clusters

3. Since both methods force every observation into a cluster the resulting clusters might include outliers that should not be in any cluster.
  This will distord the found clusters, especially if the subgroups are very different from the rest of the data. A solution to this problem is using a mix of models.

4. D) the higher the fusion occures in the dendogram the more similar are the observations in the clusters
is not correct -> the height of the fusion indicates how different the observations are - the higher up in the dendogram the more different they are.

5.  B) Agglomerative Hierarchical Clustering starts with every observation in it's own cluster
C) Divisive Herarchical Clustering starts with all observations in one cluster

6. Starting by randomly putting the data into clusters causes variation

7. 
```{r}
density_diagonal
```

