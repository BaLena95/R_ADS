---
title: "week9_summary"
output: html_document
---

day 1

Overview:
- hierarchical clustering
    - bottom-up agglomeratice
    - top-down divisive
- partitional clustering
    - k-means
- K-means
- Model based clustering


Clustering = finding subgroups of similar examples in data
- unsupervised


Hierarchical clustering
- very flexible technique
- represented in dendogram
    - the lower the fusion in a dendogram, the more similar are the clusters
    - every observation is a leaf
    - branches can fuse with clusters & leaves

    - Agglomorative Hierarchical Clustering 
      (every datapoint in it's own cluster at start)
        - compute distance for all observations
        - assign all observations to ind. cluster
        - combine most similar clusters until final amount of clusters
        
    - Divisive Hierarchical Clustering
      (all datapoints in same cluster at start)
        - all observations in one cluster
        - split cluster into the most different new clusters
        - keep splitting till final amount of clusters

```{r}
# can be manhattan, euclidean, ...
distances <-dist(df3, method="manhattan")

# linkage procedure (complete, average, single, centroid)
# complete and single linkage used the most
result <-hclust(d3, method="complete")
```


Scaling:
- measure featues in the same scale before clustering
- standardization 
- changes interpretation of values but not asssociation (correct clusters)
- needed for correct distance measures


Distance:
- Continuous
  - Euclidean
  - Maximum
  - Mahattan...
- Can be pretty much anything that can be measured
  - Edit Distance
  - Text
  - DNA
  
  
Partitional Clustering
- every observation is in ONE unique cluster


K-means clustering

1. randomly assign observations to K clusters

2a. calculate mean (centroid) for each (random) cluster

2b. assign each observation to its closest cluster

3. continue going back to 2a as long as the assignments change - then stop

- K are hyperparameters (=a parameter whose value is used to control the learning process) that are determined in advance
- number of K based on knowledge/goal
- result varies because initialization is random
- used to compress images -> vector quantization
- pick amount of clusters where the improvement is the sharpest -> best use of data (elbow)
  - more clusters = better model fit (less lossy)
  - more clusters = bigger file (complexity)


Evaluation of Clustering
- external information
    - making connection to external information
- visual 
    - plot to check clusters
    - reducing variables into 2D fold = manifold for clear visual (e.g.PCA)
- stability/sensitivity (iterations)
    - stability = change of clusters when observations/hyperparameters/features change
    - clusterwise stability in R with bootstrap
    - checking different models, K, noise,... to find stable solution
- internal validation indexes
    - quantify "success" of clustering
    - Average silhouette width (ASW = how close are points to other clusters)
        - works for any type of clustering
        - small/negative number if the cluster is close/similar to another cluster
        - large number if cluster is further away from cluster/ high dissimilarity
        
```{r}
distance <- dist(data, method="euclidean")
clust_data <- hclust(distance)

clustering <- cutree(clust_data, 2)
sihouette_scores <- silhouette(clustering, distance)

```



day 2 

- K-means use circular clusters
- covariance isn't included 


Model-based clustering
= clustering based on statistical model
= Gaussian mixture models, latent profile analysis, latent class analysis, latent dirichlet allocation 
  - distribution/density of observations can be subset into clusters based on likelihood
  - assume latent (unmeasured & unobserved) classes cause the observations
  - more flexible with parameters (can be tuned with  additional information)
  - can be estimated using EM algorithm
      
  - each observation has a posterior probability of belonging in a cluster
  - observation can be added to cluster with highest probability 
  - assumptions about clusters are EXplicit
      - data = normally distributed
      - cluster components
          - volume (size)
          - shape (circle/ellipse)
          - orientation (angle) 
  
  
maximum likelihood estimation
p (data | parameters)


Gaussian mixture parameters (=cluster components)
- 𝜋x1 = relative cluster sizes
- 𝜇1 and 𝜇2 = location of the cluster
- 𝜎1 and 𝜎2 = volume of clusters (spread/size)


Estimation: EM algorithm
- if we knew the labels to each observation it would be easy to find the max likelihood estimate for 𝜇 and 𝜎 but we don't know
  - posterior probability of belonging to cluster/category
  - e.g. at 1.7m likelihood to be     woman = 0.66
                                      man   = 2.20
                                      total = 2.86
                                      
    likelihood of it being a man 2.20/2.86 = 0.77

guess parameters -> find posterior of belonging to cluster -> update parameters with max likelihood -> compute new posterior probabilities (until parameters don't change anymore)


Multivariate model-based clustering
- 2 observed features
- parameters can be constrained to be equal for all clusters (K-means)

  - means = vector with 2 means
  - sd = 2x2 variance-covariance matrix
  - multiple parameters within cluster (11 in bivariate)
  
      - relative cluster size (𝜋xk) = number of components -1
      - location of cluster (𝜇k) = K* number of variables
      - variances (𝚺𝒌)= K*p variances - or p if var equal over classes
                        = K*p(p-1)/2 covariances - or p(p-1)/2 if covar equal over classes

Number of parameters p.23


Testing clustering structure
Model fit

𝐵𝐼𝐶 = −2 ⋅ log (ℓ) + 𝑚 ⋅ log( 𝑛)
            fit           complexity
            bias          variance
            lossy         file size
            
• ℓ : Likelihood, 𝑝 data 𝜃)
• −2 ⋅ log ℓ : “Deviance”
• 𝑚 : Number of parameters
• 𝑛 : Number of observations/examples


Model fit criteria
- BIC: “Schwarz/Bayesian information criterion”
- AIC: “Another/Akaike information criterion” (same as BIC but penalty is 𝑚)
• AIC3: The same as AIC but penalty is 3/2*m
• ICL: “Integrated information criterion” (like BIC but reconstruction loss includes the cluster)


Mclust
- optimized hyperparameters
  - E = Equal 
  - V = Variable 
  - I = identity 

for volume, shape and orientation
e.g.  E       E         E         = equal volume, shape, orientation  
  

Merging
- when no normal distibution (gaussian)
    - start with usual gaussian mix solution
    - merge similar components to create non gaussian clusters - stable solution
    
Entropy plot
- helps decide what number of clusters to chose
- elbows

There is different packages and clustering procedures for different types of data/distance
e.g. to turn data with time series into features where each observation shows the difference/distance between the times

```{r}
basis = create.fourier.basis(c(0, 181) , nbasis =25)
fdobj = smooth.basis (1:181 ,t(velib$data),basis)$fd
```

    







