---
title: "Adventures with RapidMiner"
date: 2018-03-01 11:25:00 -0500
categories:
 - data-science
tags:
 - rapidminer
 - recommender-systems
layout: single
image: /assets/images/posts/adventures-rapidminer/rp.png
redirect_from: "/data-science/2018/03/01/adventures-rapidminer.html"
---

For our [Big Data Science course @ NYU](https://cs.nyu.edu/~abari/TeachingBDS.html), me, [Nick](https://nickgreenquist.github.io/), and [Amit](https://panghalamit.github.io/) are building a [Book Recommender System](https://github.com/dorukkilitcioglu/book-recommender-system), specifically for using with [GoodReads](https://www.goodreads.com/). Although the exact details of what we're doing is yet to be ironed out, we though it was a good idea to get a quick and dirty baseline with [RapidMiner](https://rapidminer.com/). More than a couple of hours later, I can safely say that while we did get a baseline, it ended up more work than intended.

## RapidMiner
RapidMiner is a tool that allows for rapid prototyping using Machine Learning algorithms without ever touching a programming language. It offers most of the commonly used Machine Learning algorithms by default, and there are even extensions that you can download if your specific algorithm is not supported out of the box. It has a 10000 row limit without a license, which can be restrictive considering Big Data can contain billions of rows of data, but you acquire educational licenses very easily.

### The good
The good part of using RapidMiner was really the ease of use for common tasks. If the input data is properly formatted, it is really easy to get it as input, fill in the missing values, set up some classification algorithm, and get the all the relevant metrics using cross validation. It also uses drag-and-drop components, which becomes a lot faster than writing code that ties everything together. Last, but not the least, it provides a visual workflow, which makes any complicated project much more easy to digest.

### The bad
As with all of the systems that hide the implementation details, you will hit the limits on what it allows you to do sooner or later. Unfortunately, in our case, this was sooner rather than later. Converting our `csv` file to something that would work well with the RapidMiner ecosystem ended up being impossible to do through RapidMiner, and we had to result to extensions that also did not work well with rest of the RapidMiner ecosystem.

## Recommender System
Our data was the ratings from [goodbooks-10k](https://github.com/zygmuntz/goodbooks-10k) database. The ratings are given as a `csv` file with three columns: `user_id`, `book_id`, and `rating`. This is the most common way of storing user ratings. For example, the first 5 rows are:

| user_id | book_id | rating |
|---------|---------|--------|
| 1       | 258     | 5      |
| 2       | 4081    | 4      |
| 2       | 260     | 5      |
| 2       | 9296    | 5      |
| 2       | 2318    | 3      |

For the record, there are 10000 books and 56000 users, with 6 total million ratings. If you actually do the multiplication, you can see that the number of possible ratings between 10000 books and 56000 users are way more than 6 million (93 times more, in fact). The reason is that the data is very sparse. Nobody can expect every person to read and rate anything close to 10000 books, because most people only really average a couple of books per year.

### Building the matrix
These `csv` files are used for building the user-item matrix. Essentially, a user item matrix is another way of representing user ratings, and it is probably the most used one. The reason is that there are Matrix Factorization techniques that work on these matrices, which are able to deconstruct and reconstruct the matrix to guess the missing ratings.

The data does not come in this format due to the aforementioned sparsity. Notice how the first user only has a single book rating: by keeping our data in a user-item matrix, we would be storing 9999 extra ratings that serve no purpose. Even if you use 4 bytes per rating (which is a typical int), this data would've been 2GB instead of ~100MB. And this is just based on the 10000 most commonly read books - think of how more obscure books would fare.

### Where RapidMiner fails
Unfortunately, reading in this sparse data and transforming into a user-item matrix has been impossible for us with RapidMiner. There is a `ReadSparse` component, which supposedly reads sparse files, but we could not find any good documentation into how it works. We also could not find a way where we load the data as it is, and transform it into a user-item matrix. We tried some combinations of pivoting and de-pivoting, and essentially gave up after a few hours. It was also discouraging that we did not find a blog post that could walk us through it. And even if we did, unless it could handle sparse matrices, it would have been of little use to us.

Conversely, the following Python code took me 10 minutes to write (with the help of StackOverflow), and can read the ratings file in a sparse matrix:

```python
ratings = pd.read_csv('data/goodbooks-10k/ratings.csv')
ratings = ratings.to_sparse()
users = list(ratings.user_id.unique())
books = list(ratings.book_id.unique())
data = ratings['rating'].tolist()
row = ratings.user_id.astype('category', categories=users).cat.codes
col = ratings.book_id.astype('category', categories=books).cat.codes
sparse_matrix = csr_matrix((data, (row, col)), shape=(len(users), len(books)), dtype = np.dtype('u1'))
```

### Extensions to the rescue
Fortunately, we did find an extension (simply titled `Recommendations`) for RapidMiner. Once we figured it out, it wasn't that hard to get some baseline results. The extension handles recommendations in both the information retrieval and in rating prediction aspects. Unfortunately, it probably does construct an explicit user-item matrix, as memory quickly became an issue. With only 12000 users, it was using over 12GB of memory. As such, it is not really suited to even moderately-sized databases - we could not even fit our 6 million ratings.

What it did was to give us a very barebones baseline. Again, since the number of users are so low, we do not want to draw any conclusions, but it still is an indication to what is possible. I'm not going to go in-depth in these metrics, as this blog post is mainly for exploring RapidMiner and not the Recommender Systems themselves.

#### Information Retrieval
This is the process that we used for making recommendations and evaluating it as an information retrieval problem:

![Information Retrieval Task](/assets/images/posts/adventures-rapidminer/ir.png "Information Retrieval Task")

Results:  
AUC: 0.753  
prec@5: 0.043  
prec@10: 0.039  
prec@15: 0.038  
NDCG: 0.288  
MAP: 0.025  

#### Rating Prediction
This is the process that we used for making recommendations and evaluating it as an rating prediction problem:

![Rating Prediction Task](/assets/images/posts/adventures-rapidminer/rp.png "Rating Prediction Task")

Results:  
RMSE: 0.864  
MAE: 0.685  
NMAE: 0.171  

## Going forward
Our next stop will be [Apache Mahout](https://mahout.apache.org/), which has extensive support for recommender systems, and is therefore a great starting point. You can see our whole journey (including the `rmp` files for the above processes) in our [GitHub Repo](https://github.com/dorukkilitcioglu/book-recommender-system).
