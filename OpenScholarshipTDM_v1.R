# Section 1 - Libraries

library(data.table)
library(dplyr)
library(ggplot2)
library(networkD3)
library(purrr)
library(RColorBrewer)
library(readr)
library(rtweet)
library(SnowballC)
library(stringr)
library(tidyverse)
library(tm)
library(wordcloud)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 2 - Data import

# Clear the environment (RStudio)
rm(list = ls())

# Create folders for your analysis - Edit as appropriate: my harvested csv datasets are in D:\\tweets
yourPath <- 'D:\\tweets'
yourAnalysisFolder <- 'D:\\tweets\\Analysis' # This is where the analysed exports will be saved
yourImageFolder <- 'D:\\tweets\\Images' # This is where any images will be saved

dir.create(file.path(yourAnalysisFolder), showWarnings = FALSE)
dir.create(file.path(yourImageFolder), showWarnings = FALSE)

setwd(file.path(yourPath))

# The code below will read any number of Twitter datasets harvested via rtweet.
# You need to replace the path below with the path of your own data, or put your data in the folder D:\tweets.
tbl <-
  list.files(pattern = "*.csv") %>% 
  map_df(~read_csv(., col_types = cols(.default = "c")))

Twitter_data <- tbl[!duplicated(tbl$status_id),] # This deduplicates by status id: the datasets downloaded may overlap if you have harvested a few and frequently.

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 3 - Relevance checks

#Accounts that DO NOT include the words below in their description are likely to be irrelevant or invalid. 
# They might have used the hashtag #openaccess in a different context that is not appropriate to this analysis. 
# Is this perfect? No. However, without filtering you are likely to let in irrelevant accounts.

account_description_validation <- c('academia', 'academic', 'academics', 'analysis group', 'article', 'articles', 'assistant prof', 'assistant professor', 'associate prof', 'associate professor', 'associate director', 'biology', 'biomedical', 'book', 'ciencias', 'clinical trial', 'clinical trials', 'college', 'consortium', 'copyright', 'develop', 'digital object', 'director of', 'discover', 'doctoral', 'doi', 'editor', 'Editor-in-Chief', 'evidence', 'evidence base', 'evidencebased', 'head of', 'higher education', 'highered', 'humanities', 'information science', 'information sciences', 'institute', 'institutes', 'institution', 'institutions', 'interdisciplinary', 'journal', 'journals', 'learning', 'lecturer', 'librarian', 'librarians', 'libraries', 'library', 'licence', 'license', 'licensing', 'LIS', 'manuscript', 'manuscripts', 'medicine', 'metrics', 'modelling', 'museum', 'open access', 'open data', 'open knowledge', 'open research', 'open scholarship', 'paper', 'papers', 'peer review', 'peer reviewed', 'peer-review', 'peer-reviewed', 'ph.d. candidate', 'PhD', 'PhD candidate', 'postdoc', 'post-doc', 'preprint', 'pre-print', 'preprints', 'pre-prints', 'press', 'principal investigator', 'prof', 'prof.', 'professor', 'public domain', 'publication', 'publish', 'publisher', 'publishing', 'recherche', 'recherches', 'relationship between', 'research', 'research data', 'researcher', 'scholar', 'scholarly', 'scholarly communication', 'school', 'scicomm', 'science', 'sciences', 'scientific', 'scientist', 'scientists', 'society of', 'student', 'teacher', 'teaching', 'universities', 'university')
account_description_validation_string <- paste(account_description_validation, collapse="|")

Twitter_data$relevance_check <- ifelse(grepl(account_description_validation_string, Twitter_data$description, ignore.case = TRUE), "Keep", "Discard")

Twitter_data <- Twitter_data[Twitter_data$relevance_check == 'Keep',] # This ends the data filtering by only considering the accounts marked as 'Keep'

filename <- paste(yourAnalysisFolder, '\\0. Deduplicated Dataset (filtered for relevance).csv', sep = "") # This saves the deduplicated dataset including only relevant accounts
write.csv(Twitter_data, filename)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 4 - Data cleaning

# I start by removing Unicode format and other textual oddities
Twitter_data$text <- str_replace_all(Twitter_data$text,"\\<U[^\\>]*\\>"," ")
Twitter_data$text <- str_replace_all(Twitter_data$text,"\r\n"," ")
Twitter_data$text <- str_replace_all(Twitter_data$text,"&amp;"," ")

# I create a new column where I save the original text before any further cleaning - this is just a backup
Twitter_data$Original_Tweet_Backup <- Twitter_data$text

# Then I continue cleaning, removing hashtags, mentions and "RT"
Twitter_data$text <- str_replace_all(Twitter_data$text,"^RT:? "," ")
Twitter_data$text <- str_replace_all(Twitter_data$text,"@[[:alnum:]]+"," ")
Twitter_data$text <- str_replace_all(Twitter_data$text,"#[[:alnum:]]+"," ")
Twitter_data$text <- str_replace_all(Twitter_data$text,"http\\S+\\s*"," ")

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 5 - Overview of posting times

filename <- paste(yourImageFolder, '\\1. Frequency of tweets.png', sep = "")
png(filename, width = 1920, height = 1080, units = "px", pointsize=12, res=300)

ts_plot(Twitter_data, "hours") +
  labs(x = NULL, y = NULL,
       title = "Frequency of tweets vs time",
       subtitle = paste0(format(min(Twitter_data$created_at)), " to ", format(max(Twitter_data$created_at))),
       caption = "Data collected from Twitter's API (rtweet)") +
  theme_minimal()

dev.off()

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 6 - Analysis of hashtags

hashtags_vector <- Twitter_data$hashtags 

split_hashtags <- str_split_fixed(hashtags_vector, " ", 100) # This splits the hashtags column using the space separator. "100" allows room for 100 columns, just in case.
split_hashtags_single_column <- stack(data.frame(split_hashtags))
split_hashtags_single_column <- data.frame(split_hashtags_single_column$values)

split_hashtags_single_column <- mutate_all(split_hashtags_single_column, list(tolower)) # Converting to lowercase is useful because people might use "OpenAccess", "openaccess", "Openaccess", etc.

# The line below gets rid of rows that are equal to #openaccess, as this will simply be a huge word in the middle of a word cloud.
# You should replace "openaccess" with any other words relevant to you, or simply comment the next line.
split_hashtags_single_column <- split_hashtags_single_column[split_hashtags_single_column != "openaccess", ] 

split_hashtags_single_column <- data.frame(split_hashtags_single_column)
split_hashtags_single_column_clean <- split_hashtags_single_column[split_hashtags_single_column != "", ] # This gets rid of rows that are blank

filename <- paste(yourImageFolder, '\\2. Wordcloud of hashtags.png', sep = "")
png(filename, width = 1920, height = 1920, units = "px", pointsize=12, res=300)

wordcloud(split_hashtags_single_column_clean, min.freq=150, random.order=FALSE, colors=brewer.pal(9, 'Reds')[4:9])

dev.off()

# If you want the word cloud in a table:
split_hashtags_single_column_clean <- as.data.frame(split_hashtags_single_column_clean)
names(split_hashtags_single_column_clean)[1] <- 'hashtag'

split_hashtags_single_column_clean <- split_hashtags_single_column_clean %>%  
  group_by(hashtag) %>%
  summarise(weight = n()) %>% 
  ungroup()

split_hashtags_single_column_clean <- split_hashtags_single_column_clean[order(-split_hashtags_single_column_clean$weight), ]

filename <- paste(yourAnalysisFolder, '\\1. Analysis of hashtags.csv', sep = "")
write.csv(split_hashtags_single_column_clean, filename)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 7 - Analysis of mentions

# I exclude retweets, because they are considered as mentions in the data. If you retweet someone, the API considers that as you mentioning them.
Twitter_data_no_retweets <- Twitter_data[Twitter_data$is_retweet == 'FALSE',]
mentions_vector <- Twitter_data_no_retweets$mentions_screen_name 

split_mentions <- str_split_fixed(mentions_vector, " ", 100) # This splits the mentions column using the space separator. "100" allows room for 100 columns, just in case.
split_mentions_single_column <- stack(data.frame(split_mentions))
split_mentions_single_column <- data.frame(split_mentions_single_column$values)

split_mentions_single_column_clean <- split_mentions_single_column[split_mentions_single_column != "", ] # This gets rid of rows that are blank

filename <- paste(yourImageFolder, '\\3. Wordcloud of mentions.png', sep = "")
png(filename, width = 1920, height = 1920, units = "px", pointsize=12, res=300)

wordcloud(split_mentions_single_column_clean, min.freq=30, random.order=FALSE, colors=brewer.pal(9, 'Reds')[4:9])

dev.off()

# If you want the word cloud in a table:
split_mentions_single_column_clean <- as.data.frame(split_mentions_single_column_clean)
names(split_mentions_single_column_clean)[1] <- 'account'

split_mentions_single_column_clean <- split_mentions_single_column_clean %>%  
  group_by(account) %>%
  summarise(weight = n()) %>% 
  ungroup()

split_mentions_single_column_clean <- split_mentions_single_column_clean[order(-split_mentions_single_column_clean$weight), ]

filename <- paste(yourAnalysisFolder, '\\2. Analysis of mentions.csv', sep = "")
write.csv(split_mentions_single_column_clean, filename)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 8 - Analysis of links shared

top_urls <- Twitter_data[, c("urls_expanded_url")]
top_urls <- top_urls[complete.cases(top_urls), ] # This gets rid of rows with missing values

top_urls <- top_urls %>%  
  group_by(urls_expanded_url) %>%
  summarise(count = n()) %>% 
  ungroup()

top_urls <- top_urls[order(-top_urls$count),]

filename <- paste(yourAnalysisFolder, '\\3. Analysis of links shared.csv', sep = "")
write.csv(top_urls, filename)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 9 - Analysis of most retweeted tweets

# I used the Original_Tweet_Backup column I've defined above. 
# This is because the original "text" column has been stripped of hashtags, mentions, links, etc.
top_tweets <- Twitter_data[, c("screen_name", "Original_Tweet_Backup", "retweet_count", "status_url")]

# This deduplicates the dataset by tweet text. # I do this as otherwise I'd get 
# lots of duplicated occurrences (i.e. people retweeting the same popular tweet)
top_tweets <- top_tweets[!duplicated(top_tweets$Original_Tweet_Backup),] 

top_tweets$retweet_count <- as.numeric(as.character(top_tweets$retweet_count)) # The data table is all characters, so I need to convert the retweet count column into numbers
top_tweets <- top_tweets[order(-top_tweets$retweet_count),]

filename <- paste(yourAnalysisFolder, '\\4. Analysis of most retweeted tweets.csv', sep = "")
write.csv(top_tweets, filename)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 10 - Analysis of top tweeters

topTweeters <- Twitter_data %>% select(screen_name) # The top tweeters data table is extracted from the full dataset
topTweeters <- topTweeters %>% group_by(screen_name) %>% summarise(count=n()) # The number of occurrences of each top tweeters is counted
topTweeters <- topTweeters[order(-topTweeters$count),] # The table is sorted

filename <- paste(yourAnalysisFolder, '\\5. Analysis of top tweeters.csv', sep = "")
write.csv(topTweeters, filename)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 11 - Identification of accounts with the most followers in the sample

# I need a list of unique stakeholders to begin with 
highestFollowers <- Twitter_data %>% select(screen_name, followers_count, friends_count, description, location)
highestFollowers_unique <- highestFollowers[!duplicated(highestFollowers$screen_name),] 

# The data table is all characters, so I need to convert relevant columns into numbers
highestFollowers_unique$followers_count <- as.numeric(as.character(highestFollowers_unique$followers_count))
highestFollowers_unique$friends_count <- as.numeric(as.character(highestFollowers_unique$friends_count))

# I sort the table of stakeholders by number of followers and number of friends.
stakeholder_highestFollowers <- highestFollowers_unique[order(-highestFollowers_unique$followers_count, -highestFollowers_unique$friends_count),]

filename <- paste(yourAnalysisFolder, '\\6. Analysis of accounts with the most followers.csv', sep = "")
write.csv(stakeholder_highestFollowers, filename)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 12 - Analysis of the most commonly used words in the dataset

# The tweet's text is in the column called "text" in the data table called "Twitter_data"
data_for_corpus <- Twitter_data %>% select(screen_name, text)

# This builds the corpus for analysis
corpus <- Corpus(VectorSource(data_for_corpus$text)) 

# The corpus is cleaned and standardised
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removePunctuation)

# To remove stop words, I use a pre-defined list for the English language, but you can also specify any additional words in quotes 
mystopwords <- c(stopwords("english"),"rt","get","like","just","yes","know","will","good","day","people", "got", "can", "amp")
corpus <- tm_map(corpus,removeWords,mystopwords)

myDtm <- DocumentTermMatrix(corpus) # This creates a document term matrix
sparse <- removeSparseTerms(myDtm, 0.97)
sparse <- as.data.frame(as.matrix(sparse))

# I calculate the frequency of each word from the data table I created - colSums adds up the totals by column.
# freqWords is a row of numbers, which has the actual words as the column headers
freqWords <- colSums(sparse)
freqWords <- freqWords[order(-freqWords)]

filename <- paste(yourImageFolder, '\\4. Wordcloud of most used words.png', sep = "")
png(filename, width = 1920, height = 1920, units = "px", pointsize=12, res=300)

wordcloud(freq = as.vector(freqWords), words = names(freqWords),random.order = FALSE,
          random.color = FALSE, colors = brewer.pal(9, 'Reds')[4:9])

dev.off()

filename <- paste(yourAnalysisFolder, '\\7. Analysis of the most commonly used words.csv', sep = "")
write.csv(freqWords, filename)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 13 - Retweet network analysis (full network)

data_for_network <- Twitter_data[, c("screen_name", "retweet_screen_name", "text", "followers_count")]
data_for_network$followers_count <- as.numeric(data_for_network$followers_count)

# The line below filters accounts that have a certain follower count, as the network I am working with is huge. 
# Comment it or delete it to show all accounts in your sample.
data_for_network <- data_for_network[data_for_network$followers_count>4999, ]  

data_for_network_notBlank <- data_for_network[complete.cases(data_for_network), ] # This gets rid of rows with missing values

# Build a list of nodes
whoTweeted <- data_for_network_notBlank$screen_name
originalSource <- data_for_network_notBlank$retweet_screen_name
nodes <- c(whoTweeted, originalSource)

nodes <- as.data.frame(unique(nodes))
nodes <- nodes %>% rowid_to_column("id")
names(nodes)[2] <- "label"

# Build a list of edges
retweet_network <- data_for_network_notBlank %>%  
  group_by(screen_name, retweet_screen_name) %>%
  summarise(weight = n()) %>% 
  ungroup()

names(retweet_network)[1] <- "Who retweeted"
names(retweet_network)[2] <- "Original source"

edges <- retweet_network %>% 
  left_join(nodes, by = c("Original source" = "label")) %>% 
  rename(from = id)

edges <- edges %>% 
  left_join(nodes, by = c("Who retweeted" = "label")) %>% 
  rename(to = id)

# Create the network and save it as a standalone HTML file
nodes_d3 <- mutate(nodes, id = id - 1)
edges_d3 <- mutate(edges, from = from - 1, to = to - 1)
nodes_d3 <- as.data.frame(nodes_d3) # This is needed to avoid the warning "Links is a tbl_df. Converting to a plain data frame."
edges_d3 <- as.data.frame(edges_d3) 

filename <- paste(yourAnalysisFolder, '\\8. Full Retweet Network.html', sep = "")

forceNetwork(Links = edges_d3, Nodes = nodes_d3, Source = "from", Target = "to", 
             NodeID = "label", Group = "id", Value = "weight", 
             opacity = 1, fontSize = 16, zoom = TRUE, arrows=TRUE)%>% 
  htmlwidgets::prependContent(htmltools::tags$h1("Retweet networks")) %>% 
  saveNetwork(file = filename)

#______________________________________________________________________________#
#______________________________________________________________________________#

# Section 14 - Retweet network analysis (most mentioned accounts)

top_accounts <- split_mentions_single_column_clean[1:10, 1] # Extract the top ten most mentioned accounts
counter <- 1:as.numeric(count(top_accounts))

for (i in counter){
  Twitter_data_counter <- Twitter_data[Twitter_data$retweet_screen_name == as.character(top_accounts[i,]),]
  
  if (i ==1){
    tbl_chart <- Twitter_data_counter
  }
  if (i>1){
    tbl_chart <- rbind(tbl_chart, Twitter_data_counter)
  }
}
# Are any of the top mentioned accounts missing from tbl_chart? That's because they haven't been retweeted!

data_for_network <- tbl_chart[, c("screen_name", "retweet_screen_name", "text", "followers_count")]
data_for_network$followers_count <- as.numeric(data_for_network$followers_count)

data_for_network_notBlank <- data_for_network[complete.cases(data_for_network), ] #gets rid of rows with missing values

# Build a list of nodes
whoTweeted <- data_for_network_notBlank$screen_name
originalSource <- data_for_network_notBlank$retweet_screen_name
nodes <- c(whoTweeted, originalSource)

nodes <- as.data.frame(unique(nodes))
nodes <- nodes %>% rowid_to_column("id")
names(nodes)[2] <- "label"

# Build a list of edges
retweet_network <- data_for_network_notBlank %>%  
  group_by(screen_name, retweet_screen_name) %>%
  summarise(weight = n()) %>% 
  ungroup()

names(retweet_network)[1] <- "Who retweeted"
names(retweet_network)[2] <- "Original source"

edges <- retweet_network %>% 
  left_join(nodes, by = c("Original source" = "label")) %>% 
  rename(from = id)

edges <- edges %>% 
  left_join(nodes, by = c("Who retweeted" = "label")) %>% 
  rename(to = id)

# Create the network and save it as a standalone HTML file
nodes_d3 <- mutate(nodes, id = id - 1)
edges_d3 <- mutate(edges, from = from - 1, to = to - 1)
nodes_d3 <- as.data.frame(nodes_d3) # This is needed to avoid the warning "Links is a tbl_df. Converting to a plain data frame."
edges_d3 <- as.data.frame(edges_d3) 

filename <- paste(yourAnalysisFolder, '\\9. Top Mentions Retweet Network.html', sep = "")

forceNetwork(Links = edges_d3, Nodes = nodes_d3, Source = "from", Target = "to", 
             NodeID = "label", Group = "id", Value = "weight", 
             opacity = 1, fontSize = 16, zoom = TRUE, arrows=TRUE)%>% 
  htmlwidgets::prependContent(htmltools::tags$h1("Retweet networks")) %>% 
  saveNetwork(file = filename)

#______________________________________________________________________________#
#______________________________________________________________________________#
