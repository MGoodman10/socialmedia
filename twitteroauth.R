# goto https://apps.twitter.com/ for app info
# Keep these two codes for later use at R console, when asking four your R access credentials. 
# Getting a curl Certification

# Clear the previously used libraries
# rm(list=ls())

# Load the required R libraries
library(twitteR)
library(ROAuth)
library(RCurl)

# Download the curl Cert and save it at your default R folder
download.file(url="http://curl.haxx.se/ca/cacert.pem",
                destfile="cacert.pem")

# Setting the Certification at Twitter

# We will prepare the call to function OAuthFactory to get the auth object.

# Set constant requestURL
requestURL <- "https://api.twitter.com/oauth/request_token"

# Set constant accessURL
accessURL <- "https://api.twitter.com/oauth/access_token"

# Set constant authURL
authURL <- "https://api.twitter.com/oauth/authorize"

# In consumerKey field paste the access token 
consumerKey <- "zuhAg62V20YG2mn6Wdh5mCIul"

# In consumerSecret field paste the access token 
consumerSecret <- "bJmgKJiX7FNKz11dyBfbo9KBP1gj42up68r7hi71k4HjdnAy0y"

# Create the authorization object
twitCred <- OAuthFactory$new(consumerKey=consumerKey,
                                consumerSecret=consumerSecret,
                                requestURL=requestURL,
                                accessURL=accessURL,
                                authURL=authURL)

# Ask for access
twitCred$handshake(cainfo="cacert.pem")

# In your R console you will see the following message instructing you to 
# direct your web browser to the specified URL. There you will get a PIN code 
# which you will have to type in your R console.

# To enable the connection, please direct your web browser to:
# https://api.twitter.com/oauth/authorize?oauth_token=xxxx
# When complete, record the PIN given to you and provide it here: xxxxxx

# Verify the new credential is working properly
registerTwitterOAuth(twitCred)

#  SHould be [1] TRUE

# Save the credential for future use
save(list="twitCred", file="twitteR_credentials")

# Done !

