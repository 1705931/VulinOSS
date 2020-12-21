#load the file
library(jsonlite)
library(tidyverse)
library(plyr)
library(dplyr)
inputData <- ("python_output\\cpython_freebsd_vuln.json")

#parse the JSON file into a data.frame
data <- jsonlite::fromJSON(inputData, simplifyDataFrame = TRUE)
#only interested in the 'results' part of the JSON file
results = data$results
#from the initial json file, you can plot issue severity against line number
#plot(as.factor(results$issue_severity), results$line_number, xlab="Issue Severity", ylab="Line Number")

#delete the line_range variable
results$line_range = NULL

#complete.cases(data) will return a logical vector indicating which rows have no missing values.
#Then use the vector to get only rows that are complete using results[,].
results <- results[complete.cases(results), ]
#(the above line might not be needed)

#Here line_number column is being converted to factor column. as.factor converts column to factor column
#%>% is an operator with which you may pipe values to another function or expression
results %>% mutate(line_number = as.factor(line_number))
#(the above line might not be needed)

#ddply(dataframe, variables_to_be_used_to_split_data_frame, function_to_be_applied)
vulnData <- ddply(results,"test_id",
                  c(function(df1)paste(df1$line_number,
                                     collapse = ","),
                  function(df1)paste(df1$issue_severity,
                                     collapse = ",")))

vulnData <- ddply(results,c("test_id", "issue_severity"),
                  function(df1)paste(df1$line_number,
                                       collapse = ","))
#The R function paste() concatenates vectors to character and
#separated results using collapse=[any optional character string ]. Here ',' is used

#Rename columns
colnames(vulnData) <- c("test_id", "line_numbers", "issue_severities")
colnames(vulnData) <- c("test_id", "issue_severity", "line_numbers")

vulnData$test_id <- NULL
vulnData$issue_severities <- NULL

old_par <- plot(as.factor(vulnData$issue_severity), as.numeric(vulnData$line_numbers))

#vulnData: Data to be written
#"vulnerabilities.csv": location of file with file name to be written to
#quote: If TRUE it will surround character or factor column with double quotes.
#row.names: either a logical value indicating whether the row names of x are to be
#written along with x,or a character vector of row names to be written.
write.csv(vulnData,"vulnerabilities.csv", quote = FALSE, row.names = FALSE)

#sep is how items are separated. In this case you have separated using ','
tr <- read.transactions('vulnerabilities.csv', format = 'basket', sep=',')
tr
summary(tr)


# Create an item frequency plot for the top 20 items
if (!require("RColorBrewer")) {
  # install color package of R
  install.packages("RColorBrewer")
  #include library RColorBrewer
  library(RColorBrewer)
}
itemFrequencyPlot(tr,topN=50,type="absolute",col=brewer.pal(8,'Pastel2'), main="Absolute Line Numbers Frequency Plot")
itemFrequencyPlot(tr,topN=20,type="relative",col=brewer.pal(8,'Pastel2'),main="Relative Line Numbers Frequency Plot")

# Min Support as 0.001, confidence as 0.8.
association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8,maxlen=10))
summary(association.rules)

#inspect the top 10 rules
inspect(association.rules[1:10])
shorter.association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8,maxlen=3))

#To find what customers buy before buying 'METAL' run the following line of code:
fortySix.association.rules <- apriori(tr, parameter = list(supp=0.1, conf=0.8),appearance = list(default="lhs",rhs="46"))

# Here rhs=fortySix because you want to find out the probability of line 46 appearing
inspect(head(fortySix.association.rules))

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

