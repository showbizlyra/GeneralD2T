#setwd("~/GitHub/D2T_Apps")
setwd("~/Programming/GitHub/D2T_Apps")
# INITIALIZING
source("D2T_Machine.R", local = TRUE)


# READ DATA
dataset <- read.table(file="Datasets/dummy1.csv", sep=",", header=TRUE)
datasetWithoutDate <- dataset[ , colnames(dataset) != "DateTime"]
# airQualityDataset <- read.table(file="Datasets/AQ_2016_2017.csv", sep=",", header=TRUE)

#  
columnName <- colnames(dataset[ , colnames(dataset) != "DateTime"])

# Predict
datasetPredicted <- PredictDataset(dataset)


# SYGNAL ANALYSIS

# row [N] data, now
datasetNow <- dataset[nrow(dataset), !colnames(dataset) == "DateTime"]

# row[N-1] data, before now
datasetLast <- dataset[nrow(dataset)-1, !colnames(dataset) == "DateTime"]

# row[N-1] data, before now
dataset2Last <- dataset[nrow(dataset)-2, !colnames(dataset) == "DateTime"]

# Average Resume
averageResume <- as.data.frame.list(colMeans(dataset[, !colnames(dataset) == "DateTime"]))

# Statistical Resume
statisticalResume <- StatisticalAnalysis(dataset)

i <- 1
vectorTrendAnalysisResult <- c()
for(i in i:length(datasetWithoutDate)){
  vectorColumn <- datasetWithoutDate[[i]]
  vectorTrendAnalysisResult[i] <- TrendAnalysis(1, vectorColumn)
}

#merging main analysis DF with trend column
statisticalResume$Trend <- vectorTrendAnalysisResult


#Repeated value analysis
i <- 1
listRepeatedAnalysisResult <- list()
vectorRepValueResult <- c()
for(i in i:length(datasetWithoutDate)){
  vectorColumn <- datasetWithoutDate[[i]]
  listRepeatedAnalysisResult[[i]] <- ResumeRepeatedAnalysis(vectorColumn)
  vectorRepValueResult[i] <- listRepeatedAnalysisResult[[i]]$RepValue
}

#highsest growth analysis
i <- 1
vectorHighestGrowthAnalysisResult <- c()
vectorInterpreterRes <- list()
vectorInterpreterIndex <- c()
vectorStartIndex <- c()
vectorEndIndex <- c()
for(i in i:length(datasetWithoutDate)){
  listColumn <- datasetWithoutDate[[i]]
  listHighestGrowthAnalysisResult <- ResumeHighestGrowthAnalysis(diff(listColumn),"Growth")
  
  vectorGrowth <-listHighestGrowthAnalysisResult$valueResult
  vectorStartIndex[i] <-listHighestGrowthAnalysisResult$startIndexResult
  vectorEndIndex[i] <-listHighestGrowthAnalysisResult$endIndexResult
  
  vectorInterpreterRes[[i]] <- MembershipFuzzy(vectorGrowth, TrendFuzzyGenerator(columnName[i], statisticalResume))
  # vectorInterpreterIndex[i] <- MembershipFuzzy(vectorGrowth, TrendFuzzyGenerator(columnName[i], statisticalResume))$InterpreterIndex
  
}

ResumeHighestGrowth(vectorInterpreterRes)

# DATA INTERPRETATION
interpreterNow <- DataInterpreter(datasetNow,statisticalResume)
interpreterLast <- DataInterpreter(datasetLast,statisticalResume)
interpreter2Last <- DataInterpreter(dataset2Last, statisticalResume)
interpreterResume <- DataInterpreter(averageResume,statisticalResume)

# RESUME LEXICAL PROCESS
i <- 1
vectorTrendDescriptionAnalysis <- c()
for(i in i:length(datasetWithoutDate)){
  last2Index <- interpreter2Last$InterpreterIndex[i]
  lastIndex <- interpreterLast$InterpreterIndex[i]
  nowIndex <- interpreterNow$InterpreterIndex[i]
  
  vectorSequenceIndex <- c(last2Index, lastIndex, nowIndex)
  print(vectorSequenceIndex)
  vectorTrendDescriptionAnalysis[i] <- LD_Compare(vectorSequenceIndex)
}

# i=1;
# # Today
# for (i in i:length(columnName)) {
#   cat(" Today", columnName[i], " :", as.character(unlist(interpreterNow[i])), "\n\n")
# }

# i=1;
# # Last
# for (i in i:length(columnName)) {
#   cat(" Last", columnName[i], " :", as.character(unlist(interpreterLast[i])), "\n\n")
# }

# i=1;
# # Resume
# for (i in i:length(columnName)) {
#   cat(" Resume", columnName[i], " :", as.character(unlist(interpreterResume[i])), "\n\n")
# }

#eventIntro <- ReadIntro(type="Event")
#resumeEvent <- paste(eventIntro,"6 value from Xth to Yth")

i <- 1
maxValue <- 0
maxIndex <- 0
for(i in i:length(listRepeatedAnalysisResult)){
  if(listRepeatedAnalysisResult[[i]]$RepValue > maxValue){
    maxValue <- listRepeatedAnalysisResult[[i]]$RepValue
    maxIndex <- i
  }
}


i <- 1
vectorRepeatedInterpretResult <- c()
selectedColumn <- columnName[maxIndex]
for(i in i:length(listRepeatedAnalysisResult[[maxIndex]]$Start)){
  selectedIndex <-listRepeatedAnalysisResult[[maxIndex]]$Start[i]
  selectedValue <- datasetWithoutDate[[selectedColumn]][selectedIndex]
  print(selectedValue)
  
  vectorRepeatedInterpretResult[[i]] <- DataInterpreterAdjective(selectedValue, selectedColumn, statisticalResume)$InterpreterResult
}


resumeIntro <- ReadResumeIntro(dataset["DateTime"], columnName)
trendIntro <- ReadIntro(type="Trend")
resumeTrend <- paste0(trendIntro," ",ResumeTrend(statisticalResume),".")

resumeRepeated <- ResumeRepeated2(columnName[[maxIndex]], dataset, vectorRepeatedInterpretResult, listRepeatedAnalysisResult[[maxIndex]]$Start, listRepeatedAnalysisResult[[maxIndex]]$End)
resumeRepeated <- paste("There were some repeated value more than 4 days: ", resumeRepeated)



# 
# currentIntro <- ChangeTimeDesc(ReadIntro(type="Current"),dataset["DateTime"])
# currentDesc <- CurrentDesc(interpreterNow, statisticalResume, dataset)
# currentAglast <- TrendAnalysis(length(dataset)-5, dataset[[2]])
# currentAgresume <- "and now is the higest from overall."
# 
# predictIntro <- ReadIntro(type="Predict")
# predictContent <- "Content content content."
# predictConc <- "Conclussion from predict result."




resumeResult <- paste(resumeIntro, resumeTrend, resumeRepeated)
# currentResult <- paste(currentIntro, currentDesc, currentAglast, currentAgresume)
# currentResult <- paste(currentIntro, currentDesc)

# predictResult <- paste(predictIntro, predictContent, predictConc)

# source("D2T_Machine.R", local = TRUE)
resumeResult
# currentResult
# predictResult
