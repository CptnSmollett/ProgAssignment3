## This script does following

## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each
##    measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. From the data set in step 4, creates a second, independent tidy data set
##    with the average of each variable for each activity and each subject.

## Warning! This script tested in Windows environment only!


## dataset is in ./data/ folder
## data set description:
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

run_analysis <- function(downloadDataIfMissing = TRUE,
                         mergeDataIfMissing = TRUE) {
    library(LaF)
    library(data.table)
    
    dataRootPath <- "./data"

    # get data path, automatically downloads data if said so
    rawDataPath <- getData(dataRootPath, downloadDataIfMissing)
    
    # 1. Merge the training and the test sets to create one data set.
    mergedFiles <- mergeDatasets(dataRootPath, rawDataPath, mergeDataIfMissing)
    
    # 2. Extract the measurements on the mean and standard deviation
    # for each measurement.
    # 4. Appropriately label the data set with descriptive variable names.
    measurements <- readMeasurements(mergedFiles, rawDataPath)
    
    # 3. Use descriptive activity names to name the activities in the data set
    measurements <- addActivityNames(measurements, mergedFiles, rawDataPath)
    
    # 5. From the data set in step 4, creates a second, independent tidy data
    # set with the average of each variable for each activity and each subject.
    tidyDataset <- createTidyDataset(measurements, mergedFiles)
    
    tidyDataset
    
    # Check for data in './data/UCI HAR dataset' folder and download it automatically if needed
    # Merge train and test dataset file pairs (/test/X_test.txt, /train/X_train.txt),
    # (/test/Y_test.txt, /train/y_train.txt), (/test/subject_test.txt, /train/subject_train.txt)
    # into /merged/X.txt, /merged/Y.txt and /merged/subject.txt
    # Use features.txt as column names
    # Extract from data frame (table?) columns with names like '*-mean()*' or '*-std()*'
    # Use which() to extract indices for those columns
    # Don't forget to use column names
    # Add activities to the dataset, apply names from activities.txt to /merged/Y.txt
    
    # read subject ids from subject_train.txt and subject_test.txt
    # join it the output
    # based on result create another dataset with means grouped by activity name and subject id
    #   use factors for this
    #   look for [,,] operator and its grouping capabilities
}

## This function checks if data exists and creates dataset if needed.
## Value: character vector of length 1 with path to dataset folder.
## Params:
##      dataRootPath - character vector of length 1 containing path to data directory
##      downloadDataIfMissing - boolean value telling if missing data should be
##         automatically downloaded. Default value is FALSE.
getData <- function(dataRootPath, downloadDataIfMissing = FALSE) {
    datasetDir <-  paste(dataRootPath, "UCI HAR dataset", sep = "/")
    downloadUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    destFile <- paste(dataRootPath, "getdata projectfiles UCI HAR Dataset.zip", sep = "/")

    # check for data folder, create if needed
    if (!file.exists(dataRootPath)) { dir.create(dataRootPath) }
    
    # do we need to download files?
    if (!downloadDataIfMissing
        || (file.exists(datasetDir) && file.info(datasetDir)$size>0))
        return(datasetDir)
    
    # download and unzip dataset
    if (!file.exists(destFile)) {
        message("Automatically downloading raw dataset to data folder...")
        download.file(downloadUrl, destFile)
    }
    datasetSize <- file.info(datasetDir)$size
    if (is.na(datasetSize) || datasetSize == 0) {
        message("Unzipping raw dataset in data folder...")
        unzip(destFile, exdir = dataRootPath, overwrite = TRUE)
    }
    
    datasetDir
}

## This function merges test and train datasets and puts results into /merged/
## folder. Creates it automatically if needed.
## Value: character list with merged files: $measurements, $activities, $subjects.
## Params:
##      dataRootPath - character vector of length 1 containing path to data folder
##      rawDataPath - character vector of length 1 conttaining full path to
##          raw data folder
##      mergeDataIfMissing - boolean value telling if missing data should be
##          automatically merged. Default value is FALSE.
mergeDatasets <- function(dataRootPath, rawDataPath, mergeDataIfMissing = FALSE
                          ,n = 100) {
    mergedPath <- paste(dataRootPath, "merged", sep = "/")
    testDatasetPath <- paste(rawDataPath, "test", sep = "/")
    trainDatasetPath <- paste(rawDataPath, "train", sep = "/")
    mergingFilePatterns <- list(
        c("X_", "X.txt", "measurements"),
        c("y_", "Y.txt", "activities"),
        c("subject_", "subject.txt", "subjects"))
    mergedFiles <- list(measurements = "", activities = "", subjects = "")
    
    # check for merged data folder, create if needed
    if (!file.exists(mergedPath)) { dir.create(mergedPath) }
    
    # run throgh list of files, merge if needed
    sapply(mergingFilePatterns,
           function(p) {
               merged <- paste(mergedPath, p[2], sep = "/")
               
               # do we need to merge?
               if (!mergeDataIfMissing
                   || (file.exists(merged) && file.info(merged)$size>0)) {
                   mergedFiles[[p[3]]] <<- merged
                   return()
               }
               
               message(sprintf("Merging %s train and test files...", p[[3]]))
               
               # read and merge files in merged data folder
               test <- list.files(testDatasetPath, pattern = p[1], full.names = TRUE)
               train <- list.files(trainDatasetPath, pattern = p[1], full.names = TRUE)
               
               if (length(test) == 0 || length(train) == 0) {
                   return(sprintf("%s failed to find files", p[1]))
               }
               
               file.copy(test, merged)
               file.append(merged, train)
               
               mergedFiles[[p[3]]] <<- merged
           })
    
    mergedFiles
}

## This function reads measurement measurements and gives them human-friendly names.
## Value: data table with measurements of mean (column names like 'mean') and
##      standard deviations (column names like 'std').
## Params:
##      mergedFiles - character list with merged files: $measurements,
##          $activities, $subjects
##      rawDataPath - character vector of length 1 containing full path to
##          raw data folder
readMeasurements <- function(mergedFiles, rawDataPath) {
    # read and cleanup measurement names of braces, commas and dashes
    featureNames <- read.table(paste(rawDataPath, "features.txt", sep = "/"), sep = " ")
    featureNames <- as.character(featureNames[,2])
    featureNames <- gsub("(-|,)", "_", featureNames)
    featureNames <- gsub("(\\(|\\))", "", featureNames)
    cols <- length(featureNames)
        
    # read everything
    measurementsLaf <- laf_open_fwf(mergedFiles$measurements,
                             column_widths=rep.int(16, cols),
                             column_names=featureNames,
                             column_types=rep.int("double", cols))
    measurementsDT <- data.table(measurementsLaf[,])
    
    # 2. Extract the measurements on the mean and standard deviation
    # for each measurement.
    measurementsDT2 <- measurementsDT[, -grep("_(mean|std)(_|$)",
                                              colnames(measurementsDT),
                                              invert=TRUE),
                                      with=FALSE]
    
    measurementsDT2
}

## This function adds activity names to measurement values data table.
## Value: data table with measurements and activity names.
## Params:
##      measurements - data table with measurements
##      mergedFiles - character list with merged files: $measurements,
##          $activities, $subjects
##      rawDataPath - character vector of length 1 containing full path to
##          raw data folder
addActivityNames <- function (measurements, mergedFiles, rawDataPath) {
    # read measurement activities and their names
    measurementActivities <- read.table(mergedFiles$activities,
                                        col.names = c("id"))
    activityNames <- read.table(paste(rawDataPath, "activity_labels.txt", sep = "/"),
                                sep = " ",
                                col.names = c("id", "name"))
    # persist row order while naming activities
    measurementActivities$key <- 1:nrow(measurementActivities)
    namedActivities <- merge(measurementActivities, activityNames,
                             all.x = TRUE, all.y = FALSE, sort = FALSE)
    namedActivities <- namedActivities[order(namedActivities$key),]
    # put activity names next to measurements
    measurements[,Activity:=namedActivities$name]    
    
    measurements
}

## This function creates tidy data set with average measurement values for each
## subject and each activity.
## Value: tidy data table with average measurement values by subject ids and
##      activity names.
## Params:
##      measurements - data table with measurements and activity names
##      mergedFiles - character list with merged files: $measurements,
##          $activities, $subjects
createTidyDataset <- function(measurements, mergedFiles) {
    # read subject ids and put them next to measurements
    measurementSubjects <- read.table(mergedFiles$subjects)
    measurements[,Subject_id:=measurementSubjects[[1]]]
    
    # calculate average measurements by subject and activity
    tidy <- measurements[,lapply(.SD, mean), by=.(Subject_id, Activity)]
    
    tidy
}