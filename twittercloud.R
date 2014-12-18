library(twitteR)
# retrieve the first 100 tweets (or all tweets if fewer than 100)
# from the user timeline of @rdatammining
rdmTweets <- userTimeline("rdatamining", n=100)
n <- length(rdmTweets)
rdmTweets[1:3]


# Transforming Text
# The tweets are first converted to a data frame and then to a corpus.

df <- do.call("rbind", lapply(rdmTweets, as.data.frame))
dim(df)

library(tm)
# build a corpus, which is a collection of text documents
# VectorSource specifies that the source is character vectors.
myCorpus <- Corpus(VectorSource(df$text))

# After that, the corpus needs a couple of transformations, including changing
# letters to lower case, removing punctuations/numbers and removing stop words.
# The general English stop-word list is tailored by adding "available" and "via"
# and removing "r".

myCorpus <- tm_map(myCorpus, tolower)
# remove punctuation
myCorpus <- tm_map(myCorpus, removePunctuation)
# remove numbers
myCorpus <- tm_map(myCorpus, removeNumbers)
# remove stopwords
# keep "r" by removing it from stopwords
myStopwords <- c(stopwords('english'), "available", "via")
idx <- which(myStopwords == "r")
myStopwords <- myStopwords[-idx]
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

# Stemming Words

# In many cases, words need to be stemmed to retrieve their radicals. 
# For instance, "example" and "examples" are both stemmed to "exampl". 
# However, after that, one may want to complete the stems to their original 
# forms, so that the words would look "normal".

dictCorpus <- myCorpus
# stem words in a text document with the snowball stemmers,
# which requires packages Snowball, RWeka, rJava, RWekajars
myCorpus <- tm_map(myCorpus, stemDocument)
# inspect the first three ``documents"
inspect(myCorpus[1:3])

# stem completion
myCorpus <- tm_map(myCorpus, stemCompletion, dictionary=dictCorpus)

# Print the first three documents in the built corpus.

inspect(myCorpus[1:3])

# Something unexpected in the above stemming and stem completion is that, 
# word "mining" is first stemmed to "mine", and then is completed to "miners",
# instead of "mining", although there are many instances of "mining" in the tweets, compared to only one instance of "miners".

# Building a Document-Term Matrix
myCorpus <- tm_map(myCorpus, PlainTextDocument)
myDtm <- TermDocumentMatrix(myCorpus, control = list(minWordLength = 1))
inspect(myDtm[266:270,31:40])

# A term-document matrix (5 terms, 10 documents)
# Non-/sparse entries: 9/41
# Sparsity : 82%
# Maximal term length: 12
# Weighting : term frequency (tf)
# Docs
# Terms        31 32 33 34 35 36 37 38 39 40
# r             0  0  1  1  1  0  1  2  1  0
# ramachandran  0  0  0  0  0  0  1  0  0  0
# ranked        0  0  0  1  0  0  0  0  0  0
# rapidminer    0  0  0  0  0  0  0  0  0  0
# rdatamining   0  0  1  0  0  0  0  0  0  0

# Based on the above matrix, many data mining tasks can be done, for example, 
# clustering, classification and association analysis.

# Frequent Terms and Associations

findFreqTerms(myDtm, lowfreq=10)

# which words are associated with "r"?
findAssocs(myDtm, 'r', 0.30)

# r  users examples package canberra cran list
# 1.00   0.44     0.34    0.31     0.30 0.30 0.30

# which words are associated with "mining"?
# Here "miners" is used instead of "mining",
# because the latter is stemmed and then completed to "miners". :-(
findAssocs(myDtm, 'miners', 0.30)
# miners data classification httptcogbnpv mahout
# 1.00 0.56           0.47         0.47   0.47
# recommendation sets supports frequent itemset
# 0.47 0.47     0.47     0.40    0.39

# Word Cloud

# After building a document-term matrix, we can show the importance of words 
# with a word cloud (also kown as a tag cloud) . In the code below, word 
# "miners" are changed back to "mining".

library(wordcloud)
m <- as.matrix(myDtm)
# calculate the frequency of words
v <- sort(rowSums(m), decreasing=TRUE)
myNames <- names(v)
k <- which(names(v)=="miners")
myNames[k] <- "mining"
d <- data.frame(word=myNames, freq=v)
wordcloud(d$word, d$freq, min.freq=3)
