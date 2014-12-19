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

# load positive and negative words
pos = scan('positive-words.txt', what='character', comment.char=';')
neg = scan('negative-words.txt', what='character', comment.char=';')

analysis = score.sentiment(un.text, pos, neg)

# You can get a table by typing:
table(analysis$score)

# mean by typing:
mean(analysis$score)

# get a histogram with:
hist(analysis$score)


