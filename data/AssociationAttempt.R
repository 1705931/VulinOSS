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

#Here line_number column is being converted to factor column. as.factor converts column to factor column
#%>% is an operator with which you may pipe values to another function or expression
results %>% mutate(line_number = as.factor(line_number))

#ddply(dataframe, variables_to_be_used_to_split_data_frame, function_to_be_applied)
vulnData <- ddply(results,"test_id",
                         function(df1)paste(df1$line_number,
                                            collapse = ","))
vulnData$test_id <- NULL

#Rename column to line_numbers
colnames(vulnData) <- c("test_id", "line_numbers")
#The R function paste() concatenates vectors to character and
#separated results using collapse=[any optional character string ]. Here ',' is used

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
itemFrequencyPlot(tr,topN=20,type="absolute",col=brewer.pal(8,'Pastel2'), main="Absolute Line Numbers Frequency Plot")
