library(twitteR)
library(tm)
library(SnowballC)
library(RWeka)
library(rJava)
library(RWekajars)
library(wordcloud)

# Verify the Twitter credential is working
# Load library and cert
load("twitteR_credentials")
registerTwitterOAuth(twitCred)

#  SHould be [1] TRUE

# retrieve the first 100 tweets (or all tweets if fewer than 100)
# from the user timeline of @rdatammining
# un.tweets <- userTimeline("rdatamining", n=1000, cainfo="cacert.pem")
un.tweets <- searchTwitter('@InspiredbyCG',n=1000, cainfo="cacert.pem")
n <- length(un.tweets)
un.tweets[1:3]


# Transforming Text
# The tweets are first converted to a data frame and then to a corpus.

df <- do.call("rbind", lapply(un.tweets, as.data.frame))
dim(df)

# build a corpus, which is a collection of text documents
# VectorSource specifies that the source is character vectors.
data.corpus <- Corpus(VectorSource(df$text))



# After that, the corpus needs a couple of transformations, including changing
# letters to lower case, removing punctuations/numbers and removing stop words.
# The general English stop-word list is tailored by adding "available" and "via"
# and removing "r".

# change text to all lower case
# data.corpus <- tm_map(data.corpus, tolower)
data.corpus <- tm_map(data.corpus, content_transformer(tolower))

# remove punctuation
# data.corpus <- tm_map(data.corpus, removePunctuation)
data.corpus <- tm_map(data.corpus, content_transformer(removePunctuation))

# remove numbers
# data.corpus <- tm_map(data.corpus, removeNumbers)
data.corpus <- tm_map(data.corpus, content_transformer(removeNumbers))

# building stopword list adding "available" & "via"
some_stopwords <- c(stopwords('english'), "available", "via")

# remove words from some_stopwords
# some_stopwords <- settdiff(some_stopwords, c("r", "big"))

# another method to remove stopwords
# idx <- which(some_stopwords == "r")
# some_stopwords <- some_stopwords[-idx]

# remove stopwords
data.corpus <- tm_map(data.corpus, removeWords, some_stopwords)

# Stemming Words

# In many cases, words need to be stemmed to retrieve their radicals. 
# For instance, "example" and "examples" are both stemmed to "exampl". 
# However, after that, one may want to complete the stems to their original 
# forms, so that the words would look "normal".

dict.corpus <- data.corpus

# stem words in a text document with the snowball stemmers,
# which requires packages Snowball, RWeka, rJava, RWekajars
data.corpus <- tm_map(data.corpus, stemDocument)

# inspect the first three ``documents"
inspect(data.corpus[1:3])

# stem completion
data.corpus <- tm_map(data.corpus, stemCompletion, dictionary=dict.corpus)

# Alternate stem completion function
stemCompletion_mod <- function(x,dict=dict.corpus) 
{
        PlainTextDocument(stripWhitespace(paste(
                stemCompletion(unlist(strsplit(as.character(x)," ")),
                dictionary=dict.corpus, type="shortest"),sep="", collapse=" ")))
}

#call using
data.corpus <- lapply(data.corpus, stemCompletion_mod)
data.corpus <- Corpus(VectorSource(data.corpus))

# Print the first three documents in the built corpus.
inspect(data.corpus[1:3])

# Something unexpected in the above stemming and stem completion is that, 
# word "mining" is first stemmed to "mine", and then is completed to "miners",
# instead of "mining", although there are many instances of "mining" in the tweets, compared to only one instance of "miners".

# Building a Document-Term Matrix
data.corpus <- tm_map(data.corpus, PlainTextDocument)
data.dtm <- TermDocumentMatrix(data.corpus, control = list(minWordLength = 1))
inspect(data.dtm[266:270,31:40])

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

findFreqTerms(data.dtm, lowfreq=10)

# which words are associated with "r"?
findAssocs(data.dtm, 'r', 0.30)

# r  users examples package canberra cran list
# 1.00   0.44     0.34    0.31     0.30 0.30 0.30

# which words are associated with "mining"?
# Here "miners" is used instead of "mining",
# because the latter is stemmed and then completed to "miners". :-(
#findAssocs(data.dtm, 'miners', 0.30)
# miners data classification httptcogbnpv mahout
# 1.00 0.56           0.47         0.47   0.47
# recommendation sets supports frequent itemset
# 0.47 0.47     0.47     0.40    0.39

# Word Cloud

# After building a document-term matrix, we can show the importance of words 
# with a word cloud (also kown as a tag cloud) . In the code below, word 
m <- as.matrix(data.dtm)

# calculate the frequency of words
v <- sort(rowSums(m), decreasing=TRUE)
myNames <- names(v)

# "miners" are changed back to "mining"
# k <- which(names(v)=="miners")
# myNames[k] <- "mining"

d <- data.frame(word=myNames, freq=v)

wordcloud(d$word, d$freq, min.freq=3)
