# Open your R console and start by loading the following libraries
#
# Clear the previously used libraries
#
# rm(list=ls())
#
# Load the required R libraries
#
library(twitteR)
library(ROAuth)
library(RCurl)
library(plyr)
library(tm)

# Verify the Twitter credential is working
# Load library and cert
load("twitteR_credentials")
registerTwitterOAuth(twitCred)

#  SHould be [1] TRUE


# Say that we are interested in tweets regarding company Continental airlines
# which has a twitter handler @United. We will proceed to collect 1.000 tweets.
un.tweets = searchTwitter('@bankofamerica',n=1000, cainfo="cacert.pem")

# how many tweets have we collected ?
length(un.tweets)

# Show tweet number 500
tweet500 = un.tweets[[500]]

# Show only the text from tweet number 500
tweet500$getText()

# Show only the user from tweet number 500
tweet500$getScreenName()

# To go further in our example we will load a new package (plyr) which contains
# tools for splitting, applying and combining data

# Get all text from our twitter data set in data frame format
un.text = laply(un.tweets, function(t)t$getText())

# Now we only have text entries in our data set un.text.
# Show the first 5 entries 
head(un.text, 5)

# Another interesting way to work data from Twitter would be first of all to
# get the Trending Topics. This function will return the top 30 trending topics
# for each day of the week starting with yesterday.
tr <-getTrends(woeid="23424977", period="weekly", date=(Sys.Date()-1),
               cainfo="cacert.pem")


# Mining the text
# Once we have a data set in data frame R format, it is time for mining the
# text, for instance, by implementing functions included in R package (tm)
#...let's get it started.



# Let's apply some transformations to our Twitter data set

# Build a Corpus
data.corpus <- Corpus(VectorSource(un.text))

# getTransformations()

# Convert to lowercase
# old version - data.corpus <- tm_map(data.corpus, tolower)
data.corpus <- tm_map(data.corpus, content_transformer(tolower))


# remove punctuation
# old version - data.corpus <- tm_map(data.corpus, removePunctuation) 
data.corpus <- tm_map(data.corpus, content_transformer(removePunctuation))

# remove stop words, otherwise some of these words would appear as most used
some_stopwords <- c(stopwords('english'))
data.corpus <- tm_map(data.corpus, removeWords, some_stopwords)


# build a term-document matrix from a corpus
data.corpus <- tm_map(data.corpus, PlainTextDocument)
data.dtm <- TermDocumentMatrix(data.corpus)

# some commands to view copora data
# inspect the term-document matrix
data.dtm




# View data after transformations
inspect(data.corpus[1:10])


# view one single entry
data.corpus [[116]]


# in a term-document matrix, select 10 words and inspect 10 intries
inspect(data.dtm[1:10,1:10])

# Functions with basic statistics
# inspect most popular words
findFreqTerms(data.dtm, lowfreq=30)
# At this point we have extracted the most used words in tweets regarding Continental airlines, ...
# cool  (~_~;)   isn't it ? 