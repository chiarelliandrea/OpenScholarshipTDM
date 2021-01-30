# Open Scholarship Text and Data Mining
- Between October 2020 and January 2021, I have been collecting over 57k tweets around #openaccess and over 31k around #openscience. In this repository, I share my approach to text and data mining (TDM) and some thoughts on how Twitter data can be analysed to build insights. 
- For simplicity, the images only refer to the hashtag #openaccess, but some of the insights below cover #openscience, too.
- Please note that Twitter's Terms of Service do not allow the sharing of full data, so you will need your own datasets: this repository assumes that you have already harvested some tweets (via rtweet) and only need to analyse them.
- My code will output data tables in an "Analysis" folder and images (like the ones included below) in an "Images" folder. The code assumes that your datasets have been saved under "D:\\tweets", but you can of course change that.
- The code is fully commented and includes explanations at each step.

### Find out when people tweet the most
- The first thing you should consider when working with social media is timing: when does your chosen audience tweet the most? 
- For example, open access and open science belong to the working week. Indeed, for many people these topics are likely to be work-related rather than recreational activities or hobbies.
- The code will provide you an image.

###### Figure 1. When do people tweet? (#openaccess)
<img src="https://github.com/chiarelliandrea/OpenScholarshipTDM/blob/main/1.%20Frequency%20of%20tweets.png?raw=true" width="600">

### Analysis of hashtags 
- You can investigate what hashtags are most frequently used in the dataset. 
- For example, it is unsurprising that the #openscience hashtag most frequently accompanies #openaccess (and vice versa), as the two topics are closely related (see Figure 2). 
- Figure 2 can help appreciate the fleeting nature of social media: #covid19 is likely to be a temporary trend, at least in scholarly communication, but it does appear at the centre of the image.  
- The code will provide you with data and a word cloud image.

###### Figure 2. Hashtags accompanying #openaccess (Note: #openaccess has been filtered out of this image).
<img src="https://github.com/chiarelliandrea/OpenScholarshipTDM/blob/main/2.%20Wordcloud%20of%20hashtags.png?raw=true" width="600">

### Analysis of mentions 
- If you wish to get the lay of the land, you need to identify what stakeholders are most influential and lead the discourse in a certain area.
- Using Twitter data, you can analyse mentions, but you should be mindful of a technical consideration: the column where mentions are stored in the Twitter exports also reflects retweets. Figure 3 only includes mentions that were intentional “@” tweets as opposed to including retweets, too.
- If you include retweets in your analysis of mentions, you are likely to pick up bots (or at least this was the case with #openaccess and #openscience). Before analysing any tweets, take a look at the exported data and investigate what each column means.
- If you wish to follow ongoing developments, it is worth monitoring the most mentioned accounts in your chosen domain. You should, however, make sure you understand what is behind the number of total mentions: in the case of #openaccess, mention counts are boosted by the way the hashtag is used (see Figure 4) and may not actually reflect the importance of a given account or stakeholder.
- The code will provide you with data and a word cloud image.

###### Figure 3. Most mentioned accounts using the hashtag #openaccess (min= 30, max= 135).
<img src="https://github.com/chiarelliandrea/OpenScholarshipTDM/blob/main/3.%20Wordcloud%20of%20mentions.png?raw=true" width="600">

### Most used words - Corpus analysis 
- Figure 4 shows the results arising from corpus analysis, a technique you can use to analyse the text of tweets. 
- While an analysis for the #openscience hashtag is not particularly insightful, looking at #openaccess provides an actionable insight. You can immediately see that the most frequent terms used in tweets around open access are about “new” papers, books or research. This suggests that the hashtag is frequently used by authors, journals or publishers to advertise their work (e.g. papers, books), rather than to talk about open access issues more broadly. If you tweet about or follow policy developments or high-level discussions around open access, use additional and more specific hashtags wherever possible. Otherwise, your tweets may be drowned by a sea of research outputs.
- The code will provide you with data and a word cloud image.

###### Figure 4. Corpus analysis.
<img src="https://github.com/chiarelliandrea/OpenScholarshipTDM/blob/main/4.%20Wordcloud%20of%20most%20used%20words.png?raw=true" width="600">

### Network analysis
- Retweet networks can be investigated by the means of text and data mining, and my code will let you create retweet networks in html format: these can be opened and studied in any web browser.
- Using my code, you can plot the answer to the question "who retweeted whom?" The very large dataset I harvested from Twitter included tens of thousands of tweets and, unsurprisingly, yielded very large constellations. You can appreciate this in Figure 5, which only shows accounts that were retweeted and had have at least 5,000 followers (I didn't find this huge map very useful).
- You should be careful with your interpretation of retweet networks, as these visualisations depend on the data you have decided to harvest. In the case of Figure 5, only tweets using the hashtag #openaccess within a given timeframe are included. By no means does this indicate that any accounts visualised are not receiving attention in other arenas.

###### Figure 5. Full retweet network.
<img src="https://github.com/chiarelliandrea/OpenScholarshipTDM/blob/main/Full%20retweet%20network.png?raw=true" width="600">

- A more reproducible and standardised approach (as opposed to setting an arbitrary follower count) may be to pick some criteria and simplify the network automatically. For example, you may choose to only show the top 20 most mentioned accounts and remove any filters by number of followers.
- Figure 6 shows a far more manageable snapshot of the network, where the most mentioned 20 accounts have been programmatically filtered. As an example of insights that you can derive from this type of analysis, let us focus  on the account @MDPIOpenAccess (one of the two that appear “disconnected” in Figure 6). Only one out of 31 accounts who have retweeted from @MDPIOpenAccess is an individual, while the remaining 30 are MDPI journals. This clearly looks odd, but  you can easily understand why by looking at the data in csv format (via Excel or similar software): the 30 MDPI journals were helping the main MDPI account advertise an interview campaign. This shows once again that social media information is valid at a given point in time, and there is a risk of misinterpreting it if you are not careful.
- Note that retweet networks can offer very interesting results. However, they are difficult to interpret via automated means and require an extent of further analysis. If you are happy to get your hands dirty, do dig into this rewarding form of exploration.

###### Figure 6. Filtered retweet network.
<img src="https://github.com/chiarelliandrea/OpenScholarshipTDM/blob/main/Filtered%20retweet%20network.png?raw=true" width="600">

### Other features
- The code also allows you to extract: links shared in tweets, top tweeters in the dataset, most retweeted tweets, accounts with the most followers in the dataset.
- The code includes a basic relevance check: account descriptions are checked to search for specific words common in academia and research. This allows you to filter out irrelevant accounts that might be using the hashtag with a different meaning. You can edit the words used for relevance checks or completely disable the feature.

### Some limitations
Although the analysis presented in this repository is extensive, there is plenty more you could look at in a Twitter dataset. However, I feel it is important not to over-engineer the process because of three main reasons: 
- Twitter does not offer a representative cut of the population nor does it allow us to draw definitive conclusions. 
- Social media data is a snapshot at a given point in time.
- Any analysis you run will be biased by the hashtags or filters you apply when harvesting data from Twitter. This is not an issue, but something worth bearing in mind as you draw any conclusions!
