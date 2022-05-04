---
title: "Hierarchical Clustering and its Applications"
date: 2018-10-26 9:30:00 -0400
categories:
 - data-science
 - machine-learning
tags:
 - clustering
layout: single
image: /assets/images/posts/hierarchical-clustering-applications/senator_clusters.png
---

Clustering is one of the most well known techniques in Data Science. From [customer segmentation](https://towardsdatascience.com/clustering-algorithms-for-customer-segmentation-af637c6830ac) to [outlier detection](https://www.datadoghq.com/blog/outlier-detection-algorithms-at-datadog/), it has a broad range of uses, and different techniques that fit different use cases. In this blog post we will take a look at hierarchical clustering, which is the hierarchical application of clustering techniques.

## Clustering

Clustering, in one sentence, is the extraction of natural groupings of similar data objects.

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/hierarchical-clustering-applications/senator_clusters.png' alt="Senator Clusters" width="100%"/>
        <figcaption><i>Republican and Democrat clusters of senators</i></figcaption>
    </figure>
</div>
<br/>

There are a couple of general ideas that occur quite frequently with respect to clustering:
- The clusters should be naturally occurring in data.
- The clustering should discover hidden patterns in the data.
- Data points within the cluster should be similar.
- Data points in two different clusters should not be similar.

Common algorithms used for clustering include K-Means, DBSCAN, and Gaussian Mixture Models.

## Hierarchical Clustering
As mentioned before, hierarchical clustering relies using these clustering techniques to find a hierarchy of clusters, where this hierarchy resembles a tree structure, called a dendrogram.

> Hierarchical clustering is the hierarchical decomposition of the data based on group similarities

### Finding hierarchical clusters
There are two top-level methods for finding these hierarchical clusters:
- **Agglomerative** clustering uses a _bottom-up_ approach, wherein each data point starts in its own cluster. These clusters are then joined greedily, by taking the two most similar clusters together and merging them.
- **Divisive** clustering uses a _top-down_ approach, wherein all data points start in the same cluster. You can then use a parametric clustering algorithm like K-Means to divide the cluster into two clusters. For each cluster, you further divide it down to two clusters until you hit the desired number of clusters.

Both of these approaches rely on constructing a similarity matrix between all of the data points, which is usually calculated by cosine or Jaccard distance.

## Applications of Hierarchical Clustering
### 1) US Senator Clustering through Twitter
_Can we find the party lines through Twitter?_

Following the controversial ["Twitter mood predicts the stock market" paper](https://www.sciencedirect.com/science/article/pii/S187775031100007X), researchers have been looking at Twitter as a source of highly valuable data. In this example, we use Twitter to cluster US senators into their respective parties.

Our data is simple: we only look at which senators follow which senators. That defines a graph structure with senators as the nodes and follows as the edges.

On this graph, we use the Walktrap algorithm by [Pons et al.](https://www-complexnetworks.lip6.fr/~latapy/Publis/communities.pdf), which does a random walk through graph, and estimates the senator similarity by the number of times you end up at certain senator starting from a senator.

After getting these similarities, we can use agglomerative clustering to find the dendrogram.

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/hierarchical-clustering-applications/senator_dendrogram.png' alt="Senator Dendrogram" width="100%"/>
        <figcaption><i>Reds are Republicans, Blues are Democrats, Blacks are independent</i></figcaption>
    </figure>
</div>
<br/>

In order to measure how well our clustering worked, we can color the results with the party colors. As you can see, Democrats and Republicans are very clearly split from the top, showing the success of this method.

You also might've noticed the two black lines, denoting the independent senators. These are a little trickier to evaluate, but both Sen. Bernie Sanders and Sen. Angus King caucus with the Democratic Party, meaning that it is natural that they are in the Democratic Party branch of the tree.

### 2) Charting Evolution through Phylogenetic Trees
_How can we relate different species together?_

In the decades before DNA sequencing was reliable, the scientists struggled to answer a seemingly simple question: Are giant pandas closer to bears or racoons?

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/hierarchical-clustering-applications/giant_panda.png' alt="Image of giant panda" width="100%"/>
    </figure>
</div>

Nowadays, we can use DNA sequencing and hierarchical clustering to find the [phylogenetic tree](https://en.wikipedia.org/wiki/Phylogenetic_tree) of animal evolution:
- Generate the [DNA sequences](https://en.wikipedia.org/wiki/DNA_sequencing).
- Calculate the [edit distance](https://en.wikipedia.org/wiki/Edit_distance) between all sequences.
- Calculate the DNA similarities based on the edit distances.
- Construct the phylogenetic tree.

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/hierarchical-clustering-applications/panda_tree.png' alt="Giant panda phylogenetic tree" width="80%"/>
    </figure>
</div>

As a result of this experiment, the researchers were able to place the giant pandas closer to bears.

### 3) Tracking Viruses through Phylogenetic Trees
_Can we find where a viral outbreak originated?_

Tracking viral outbreaks and their sources is a major health challenge. Tracing these outbreaks to their source can give scientists additional data as to why and how the outbreak began, potentially saving lives.

Viruses such as HIV have high mutation rates, which means the similarity of the DNA sequence of the same virus depends on the time since it was transmitted. This can be used to trace paths of transmission.

This method was [used as evidence in a court case](http://www.pnas.org/content/99/22/14292), wherein the victim's strand of HIV was found to be more similar to the accused patient's strand, compared to a control group.

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/hierarchical-clustering-applications/hiv_tree.png' alt="HIV strands phylogenetic tree" width="80%"/>
        <figcaption><i>V1–3 are victim's strands, P1–3 are accused patient's, and LA1–12 are the control group</i></figcaption>
    </figure>
</div>

A similar study was also done for finding the animal that gave the humans the SARS virus:

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/hierarchical-clustering-applications/sars_tree.png' alt="SARS strands phylogenetic tree" width="80%"/>
    </figure>
</div>

So humans got the SARS virus from palm civets… right?

> "With the data at hand, we see how the virus used different hosts, moving from **bat to human to civet**, in that order. So the civets actually got SARS **from humans**." - [ScienceDaily](https://www.sciencedaily.com/releases/2008/02/080219150146.htm)

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/hierarchical-clustering-applications/palm_civet.png' alt="Sad palm civet" width="80%"/>
        <figcaption><i><a href="https://www.lifegate.com/people/news/kopi-luwak-coffee-asian-palm-civets">image credit</a></i></figcaption>
    </figure>
</div>

## Conclusion
Hierarchical clustering is a powerful technique that allows you to build tree structures from data similarities. You can now see how different sub-clusters relate to each other, and how far apart data points are. Just keep in mind that these similarities do not imply causality, as with the palm civet example, and you will have another tool at your disposal.

### References
- Big Data Science (NYU) lecture slides by Dr. Anasse Bari
- Bioinformatics (Bogazici University) lecture notes by Dr. Arzucan Ozgur