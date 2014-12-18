# from http://theminingbook.blogspot.com/
# goto https://apps.twitter.com/ for app info
# Keep these two codes for later use at R console, when asking four your R access credentials. 
# Getting a curl Certification

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

# Download the curl Cert and save it at your default R folder
download.file(url="http://curl.haxx.se/ca/cacert.pem",
                destfile="cacert.pem")

# Setting the Certification at Twitter

# We will prepare the call to function OAuthFactory to get the auth object.
#
# Set constant requestURL
#
requestURL <- "https://api.twitter.com/oauth/request_token"
#
# Set constant accessURL
#
accessURL <- "https://api.twitter.com/oauth/access_token"
#
# Set constant authURL
#
authURL <- "https://api.twitter.com/oauth/authorize"

# In consumerKey field paste the access token you got from your 
# twitter developer application.
consumerKey <- "zuhAg62V20YG2mn6Wdh5mCIul"

# In consumerSecret field paste the access token you got from your 
# twitter developer application.
consumerSecret <- "bJmgKJiX7FNKz11dyBfbo9KBP1gj42up68r7hi71k4HjdnAy0y"

# Creating the authorization object by calling function OAuthFactory
twitCred <- OAuthFactory$new(consumerKey=consumerKey,
                                consumerSecret=consumerSecret,
                                requestURL=requestURL,
                                accessURL=accessURL,
                                authURL=authURL)

# At this point we are ready to ask for our credentials to Twitter. 
# Let's go for it ! 
# Saving and using the Certification to connect to Twitter

# Asking for access
twitCred$handshake(cainfo="cacert.pem")

# In your R console you will see the following message instructing you to 
# direct your web browser to the specified URL. There you will get a PIN code 
# which you will have to type in your R console.

# To enable the connection, please direct your web browser to:
# https://api.twitter.com/oauth/authorize?oauth_token=xxxx
# When complete, record the PIN given to you and provide it here: xxxxxx

# Perfect ! Almost done.

# Just verify that your new credential is working properly

registerTwitterOAuth(twitCred)
#  SHould be [1] TRUE

# And save it for future use by downloading a Cred file at your default 
# R folder

save(list="twitCred", file="twitteR_credentials")

# Done !

# Let's start by loading library and certification
library(twitteR)
load("twitteR_credentials")
registerTwitterOAuth(twitCred)

# Say that we are interested in tweets regarding company Continental airlines
# which has a twitter handler @United. We will proceed to collect 1.000 tweets.
un.tweets = searchTwitter('@United',n=1000, cainfo="cacert.pem")

# Let's answer a few basic questions
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
library(plyr)

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

library(tm)

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
data.corpus <- TermDocumentMatrix(data.corpus)

# some commands to view copora data
# inspect the term-document matrix
data.tm


# A term-document matrix (3053 terms, 1000 documents)


# Non-/sparse entries: 9931/3043069
# Sparsity : 100%
# Maximal term length: 152 
# Weighting : term frequency (tf)


# View data after transformations
inspect(data.corpus[1:1000])


# view one single entry
data.corpus [[116]]


# in a term-document matrix, select 10 words and inspect 10 intries
inspect(data.dtm[1:10,1:10])

# Functions with basic statistics
# inspect most popular words
findFreqTerms(data.dtm, lowfreq=30)
# At this point we have extracted the most used words in tweets regarding Continental airlines, ...
# cool  (~_~;)   isn't it ? 