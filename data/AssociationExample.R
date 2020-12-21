library(arules)
library(arulesViz)
library(tidyverse)
library(readxl)
library(knitr)
library(ggplot2)
library(lubridate)
library(plyr)
library(dplyr)

#read excel into R dataframe
retail <- read_excel('Online Retail.xlsx')
#complete.cases(data) will return a logical vector indicating which rows have no missing values.
#Then use the vector to get only rows that are complete using retail[,].
retail <- retail[complete.cases(retail), ]
#mutate function is from dplyr package. It is used to edit or add new columns to dataframe.
#Here Description column is being converted to factor column. as.factor converts column to factor column
#%>% is an operator with which you may pipe values to another function or expression
retail %>% mutate(Description = as.factor(Description))
retail %>% mutate(Country = as.factor(Country))
#Converts character data to date. Store InvoiceDate as date in new variable
retail$Date <- as.Date(retail$InvoiceDate)
#Extract time from InvoiceDate and store in another variable
TransTime<- format(retail$InvoiceDate,"%H:%M:%S")
#Convert InvoiceNo into numeric
InvoiceNo <- as.numeric(as.character(retail$InvoiceNo))
#Bind new columns TransTime and InvoiceNo into dataframe retail
cbind(retail,TransTime)
cbind(retail,InvoiceNo)
glimpse(retail)

#ddply(dataframe, variables_to_be_used_to_split_data_frame, function_to_be_applied)
transactionData <- ddply(retail,c("InvoiceNo","Date"),
                         function(df1)paste(df1$Description,
                                            collapse = ","))
#The R function paste() concatenates vectors to character and
#separated results using collapse=[any optional character string ]. Here ',' is used
transactionData

#set column InvoiceNo of dataframe transactionData  
transactionData$InvoiceNo <- NULL
#set column Date of dataframe transactionData
transactionData$Date <- NULL
#Rename column to items
colnames(transactionData) <- c("items")
#Show Dataframe transactionData
transactionData

#transactionData: Data to be written
#"transactions.csv": location of file with file name to be written to
#quote: If TRUE it will surround character or factor column with double quotes.
#row.names: either a logical value indicating whether the row names of x are to be
#written along with x,or a character vector of row names to be written.
write.csv(transactionData,"transactions.csv", quote = FALSE, row.names = FALSE)

#sep is how items are separated. In this case you have separated using ','
tr <- read.transactions('transactions.csv', format = 'basket', sep=',')
summary(tr)
tr

# Create an item frequency plot for the top 20 items
if (!require("RColorBrewer")) {
  # install color package of R
  install.packages("RColorBrewer")
  #include library RColorBrewer
  library(RColorBrewer)
}
itemFrequencyPlot(tr,topN=20,type="absolute",col=brewer.pal(8,'Pastel2'), main="Absolute Item Frequency Plot")
itemFrequencyPlot(tr,topN=20,type="relative",col=brewer.pal(8,'Pastel2'),main="Relative Item Frequency Plot")

# Min Support as 0.001, confidence as 0.8.
association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8,maxlen=10))
summary(association.rules)
#Since there are 49122 rules, print only top 10:
inspect(association.rules[1:10])
shorter.association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8,maxlen=3))
#You can remove rules that are subsets of larger rules
subset.rules <- which(colSums(is.subset(association.rules, association.rules)) > 1) # get subset rules in vector
length(subset.rules)  #> 3913
subset.association.rules. <- association.rules[-subset.rules] # remove subset rules.
#To find what customers buy before buying 'METAL' run the following line of code:
metal.association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8),appearance = list(default="lhs",rhs="METAL"))

# Here lhs=METAL because you want to find out the probability of that in how many customers buy METAL along with other items
inspect(head(metal.association.rules))

#to find the answer to the question Customers who bought METAL also bought.... you will keep METAL on lhs:
metal.association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8),appearance = list(lhs="METAL",default="rhs"))

# Here lhs=METAL because you want to find out the probability of that in how many customers buy METAL along with other items
inspect(head(metal.association.rules))

# Filter rules with confidence greater than 0.4 or 40%
subRules<-association.rules[quality(association.rules)$confidence>0.4]
#Plot SubRules
plot(subRules)
#The two-key plot uses support and confidence on x and y-axis respectively.
#It uses order for coloring. The order is the number of items in the rule.
plot(subRules,method="two-key plot")
#An amazing interactive plot can be used to present your rules that use arulesViz and plotly.
#You can hover over each rule and view all quality measures (support, confidence and lift).
plotly_arules(subRules)

#select 10 rules from subRules having the highest confidence
top10subRules <- head(subRules, n = 10, by = "confidence")
#Now, plot an interactive graph
#Note: You can make all your plots interactive using engine=htmlwidget parameter in plot
plot(top10subRules, method = "graph",  engine = "htmlwidget")
#From arulesViz graphs for sets of association rules can be exported in the GraphML format or as a Graphviz dot-file to be explored
#in tools like Gephi. For example, the 1000 rules with the highest lift are exported by:
saveAsGraph(head(subRules, n = 1000, by = "lift"), file = "rules.graphml")

# Filter top 20 rules with highest lift
subRules2<-head(subRules, n=20, by="lift")
plot(subRules2, method="paracoord")
#The topmost arrow shows that when I have 'CHILDS GARDEN SPADE PINK' and 'CHILDS GARDEN RAKE PINK'
#in my shopping cart, I am likelyto buy 'CHILDS GARDEN RAKE BLUE' along with these as well.