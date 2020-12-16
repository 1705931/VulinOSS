#load the file
library(jsonlite)
library(tidyverse)
inputData <- ("python_output\\glibc_vuln.json")
#inputData <- na.omit(inputData)
#analyticsData <- ("python_output\\glibc_report.json")

#parse the JSON file into a data.frame
data <- jsonlite::fromJSON(inputData, simplifyDataFrame = TRUE)
#analyticsAsDataFrame <- jsonlite::fromJSON(analyticsData, simplifyDataFrame = TRUE)
#dataCombined = cbind(data, analyticsAsDataFrame)
#only interested in the 'results' part of the JSON file
results = data$results
#training set

#maxLength = max(lengths(vulnVals))
#lapply(vulnVals, 'length<-', maxLength)

plot(as.factor(results$issue_severity), results$line_number, xlab="Issue Severity", ylab="Line Number")

#plot(as.factor(results$issue_severity), unlist(results$line_range), xlab="Issue Severity", ylab="Line Range")