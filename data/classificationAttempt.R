#load the file
library(jsonlite)
library(rpart)
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
vulnSev = results[,4]
vulnVals = results[,6]
#vulnVals = results %>% select(line_number, test_id)

#maxLength = max(lengths(vulnVals))
#lapply(vulnVals, 'length<-', maxLength)

#training set
vulnSevTrain = vulnSev[1:25]
vulnValsTrain = vulnVals[1:25]

#test set
vulnSevTest = vulnSev[26:55]
vulnValsTest = vulnVals[26:55]

#print(vulnSevTest)
#print(vulnValsTest)
plot(as.factor(results$issue_severity), results$line_number, xlab="Issue Severity", ylab="Line Number")

#plot(as.factor(results$issue_severity), unlist(results$line_range), xlab="Issue Severity", ylab="Line Range")
test = make.names(vulnValsTrain, unique = TRUE)
fit <- rpart(vulnSevTrain~., method="class", data=vulnValsTrain)
plot(fit, uniform = TRUE, main="Decision Tree for Vuln Data")
text(fit, use.n=TRUE, all=TRUE, cex=.6)
treepred <- predict(fit, vulnValsTest, type = 'class')
