---
layout: post
title:  "Representation Learning: An Introduction"
date:   2018-02-24 12:01:00 -0500
categories: machine-learning
tags: representation-learning
---

Representation Learning is a relatively new term that encompasses many different methods of extracting some form of **useful representation** of the data, based on the data itself. Does that sound too abstract? That's because it is, and it is purposefully so. Feature learning, Dimensionality reduction, Data reduction, and even Matrix Factorization are all parts of Representation Learning.

Any Machine Learning model requires some features, numerical representations of data, in order to work. The traditional method is to painstakingly measure some features of the data, and then employ feature engineering in order to extract some new features, either based on your intuition or based on the previous research.

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/representation-learning-1/word_repr.png' alt='Example of word representations' width="70%"/>
        <figcaption><i><a href="https://www.memsource.com/blog/2017/09/19/neural-machine-translation-the-rising-star/">Image Source</a></i></figcaption>
    </figure>
</div>

<br/>

In this blog post series, I will heavily rely on the ["Representation Learning: A Review and New Perspectives"](https://arxiv.org/abs/1206.5538) paper by Bengio et al., which has been immensely useful for me to learn how to think about representations, although I will be including stuff that is older and was not covered in the paper (such as t-SNE, PCA, etc.), and also stuff that is not in the paper simply because they were published after the paper was written (such as Generative Adversarial Networks). Let's begin.

## Feature Engineering

Feature engineering is a very useful (and often necessary) step when trying to train a model. For example, it is pretty intuitive that when trying to predict traffic, categorizing time of day into discrete intervals (such as morning, noon, afternoon, etc.) can be more helpful than the actual hours or seconds that has elapsed in the day. You know this, because you see the rush hour every day, and know that there are certain time bands that are bound to have more traffic.

What happens if you don't do this? Linear models will outright fail to incorporate this information. A linear model will try to match the high input (hours later in the day) with either high or low traffic, and try to match the low input (with the lowest being either midnight or 1am, depending on how you represent it) with its inverse. This doesn't work. A good model might ignore this variable due to its low correlation with traffic (even though time of day is one of the most important factors in determining traffic), or you might throw it out based on a chi-squared test, or any other test that measures statistical significance. A worse model might fit a bias towards one way or other, meaning that it thinks either hour 23 or 0 has the maximum amount of traffic (it doesn't).

## Feature Learning

Of course, better models _learn_ to use transformations of this variable in order to extract meaningful information. Neural networks in particular are used by many partly because of their power to learn features. They do not _necessarily_ learn transformations that are useful in other tasks, but often these transformations (and their resulting representations) are useful in different applications. This will be covered later in Multi-Task and Transfer Learning.

Representation Learning can be thought of as the inverse of this approach. Can we learn a _representation_ of the data, such that it is (by some metric) close to the input and is, at the same time, a useful input to a predictor?

## Learning good representations

According to Bengio et al., a good representation "is often one that captures the posterior distribution of the underlying explanatory factors for the observed input". That is, assuming there are some underlying explanatory factors in the data, which should always be the case (otherwise you're working just with noise), a good representation learns (per data point) the impact of each explanatory factor in generating the data. Since we model these factors by variables, the impact is the value of any variable.

Also according to Bengio et al., a good representation is "one that is useful as input to a supervised predictor". That is, there needs to be some value to this representation, else there is no reason to use it. It is often impossible to evaluate how good a representation is, and as with most things in Machine Learning, goodness and usefulness are synonymous in this case. It should be noted that my definition for it does not include supervised predictor, as I find using methods such as t-SNE for visualizations can prove to be extremely useful.

### General purpose priors in representations

Below are some priors (assumptions about the underlying factors) that are useful when learning about methods for learning representations. Most learners of representations base their methods in the assumption that some combination of these factors hold for data. As such, these factors - and how different learners utilize these factors - should be in the back of your head when trying to select a model for your dataset.

This list was compiled, again, by Bengio et al. All credit go to them.

#### Smoothness

Assumes that the function used for representation is sufficiently smooth, such that small perturbations to the input only cause small differences in representations. This is useful as it means that the representation is less susceptible to noise.

#### Multiple explanatory factors

Assumes that the data (and its underlying distribution) is generated by multiple underlying factors, and that these factors are largely independent of each other (or as the paper puts it, each factor generalizes over the different configurations of the other factors). Viewed this way, representation learning becomes the act of separating the strengths of the factors per data point.

#### A hierarchical organization of explanatory factors

This builds upon the previous point by assuming that these factors are found in an hierarchical manner. The higher you go in the hierarchy, the more abstract factors you learn, as you are essentially learning the factors of the factors. The most famous example of this is Yann LeCun's digit recognition model, which shows the clear hierarchical structure from edges to lines to small shapes to digits themselves. Deep models are naturally well suited for these.

#### Semi-supervised learning

Assumes that at least a part of the learned representation is useful for supervised models. This allows the learned representations of data (usually done unsupervised) to be provided as an (but not necessarily the only) input to supervised predictors. Since unsupervised data is much more abundant than supervised, this assumption (if true) can allow you to leverage a much bigger data than would've been possible. This can be seen in word embeddings, as they have been known to improve most NLP tasks compared to a one-hot encoding schema. Moreover, it is often better to download the pre-trained embeddings and fine tune them for your task (see below).

#### Shared factors across tasks

Similar to the above, this assumes that representations of the data learned during one supervised task is also useful in other tasks. This is the base assumption under Multi-Task and Transfer Learning. Learners of image representations employ this heavily, as for most tasks, first downloading a well-tested pre-trained model (such as the VGG models) greatly improve your end result.

#### Manifolds

I have a soft spot for manifolds. They represent the hope that there is some order to the chaos that is known as data. Manifolds are lower-dimensional regions in the data that collectively contain most data points. One of the most common ways of learning manifolds is using Principle Component Analysis (PCA). Although the exact workings of PCA will be explained in another post, it is sufficient now to say that PCA learns linear manifolds (hyperplanes) by picking the hyperplanes with the most variance (and as such, explains the data the most). For non-linear manifold learning, autoencoders are the latest trend.

#### Natural clustering

Natural clustering builds up on the idea of manifolds by positing that the data points that are close on the learned manifolds belong to the same group (cluster). We like seeing that the data that are projected to be close on the manifold also belong to the same cluster, as this is exactly how we perceive the world. Moreover, this also assumes that there are low density regions in between the manifolds, and as such, there is also a natural separation between the data points.

An intuitive way of forcing this is using adversarial attacks. In Generative Adversarial Networks, the representation of the data is constantly polished by adversarial attacks, so that the representation becomes robust in the face of noise. This exactly means that there are low density regions between the representations of different categories, as mid density regions would have been exploited by the adversarial attacks.

#### Temporal and spatial coherence

This idea is the marriage of smoothness, manifolds, and categories. It assumes that the manifolds are smooth with respect to data, which means that small changes in the data will cause small changes in its representations on the manifold. If we are attempting to put data into categories, this means that categories should not change due to noise. Temporal changes refer to consecutive values in a time series, which again must hold these properties.

#### Sparsity

Sparsity is the assumption that given multiple explanatory factors, only a small percentage are active per data point. It is often represented by biasing the learned factors to zero, which can be done by using L1 regularization on the learned representations if a loss function is used. The most common example is probably the sparse coding. Note that while in representation learning, you generally want to keep the dimensionality of the representation smaller than the dimensionality of the input, creating a bottleneck (especially if the model producing the representations can copy the input directly), sparse representations can be _overcomplete_, in other words, have a larger dimensionality. This greatly increases the number of explanatory factors you can model.

#### Simplicity of Factor Dependencies

In many aspects of the real world, hierarchical factors are often simple (depending only on a couple of factors) linear (only requiring linear transformations) combinations of different factors. By forcing a representation to adhere to these simplicities, you can greatly reduce the overfit of your representation to your data. This, however, does not mean that complex hierarchies do not exist, or that you will have enough data and computing power to model all the different simple dependencies.

## Conclusion

As this will be a multi-part series, there cannot be a real conclusion. However, the information here (and especially the priors) should always be at the back of your mind when you have to choose a Representation Learning algorithm. If you have an intuition about the underlying priors that give birth to your data, you can then choose the models that go well with it.

As cited many times above, this blog post would not have been possible without the paper by [Bengio et al.](https://arxiv.org/abs/1206.5538). You can take a look at the plethora of examples in that paper to see great examples of representation learning being used in the academia and the industry. And although this blog post was on the longer side, the following ones should be easier to digest.

I'll see you then.
