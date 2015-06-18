---
title: "CodeBook"
author: "Andrew Sverdlov"
date: "Sunday, June 14, 2015"
output: html_document
---

# Preamble
This is the readme file for data transformation algorithm as required in Course Project within [Getting and Cleaning Data](https://www.coursera.org/course/getdata) course on [Coursera](http://www.coursera.org).  
Raw data set with documentation included can be found here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  
General description of this data set and the story around it: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
  
_Disclaimer: this document as well as all scripts provided as is and under no license. Use it as you wish._

# Prerequisites and Assumptions
Scripts use libraries "LaF" and "data.table". Please make sure you have installed corresponding packages before you run the scripts.  
Base data folder is "./data/". If this folder is missing it is automatically created.  
Scripts have been written and tested in R 3.1.3 on Windows environment only.

# Script files
There is only one script file called "run_analysis.R". It contains all functions for data transformation. The transformation algorithms is explained in [code book](https://github.com/CptnSmollett/ProgAssignment3/blob/master/CodeBook.md).  
Further sections describe each function contained in this file.  
Each function is written in R and well documented with comments.  

## run_analysis.R -- run_analysis
### Description
This is the entry point to raw data transformation algorithm. Only this function is supposed to be called by end user.  

### Usage
`r run_analysis(downloadDataIfMissing = TRUE, mergeDataIfMissing = TRUE)`  

### Arguments
`downloadDataIfMissing` - boolean value telling if missing data should be automatically downloaded.  
`mergeDataIfMissing` - boolean value telling if missing data should be automatically merged.  

### Details
Function automatically downloads raw data and merges subsets into single data set for further analysis until it is explicitly prohibited by argument values. This function algorithm explained on [code book](https://github.com/CptnSmollett/ProgAssignment3/blob/master/CodeBook.md).  

### Value
Character vector of length 1 with path to dataset folder.  

## run_analysis.R -- getData
### Description
This function checks if data exists and creates raw data set if needed.  
It is called from `run_analysis()` function and not supposed to be called by end user.  

### Arguments
`dataRootPath` - character vector of length 1 containing path to data directory.  
`downloadDataIfMissing` - boolean value telling if missing data should be automatically downloaded.  

### Details
Function automatically downloads raw data for further transformation until it is explicitly prohibited by `downloadDataIfMissing` argument value.

### Value
Character vector of length 1 with path to raw data set folder.  

## run_analysis.R -- mergeDatasets
### Description
This function merges test and train datasets.  
It is called from `run_analysis()` function and not supposed to be called by end user.  

### Arguments
`rawDataPath` - character vector of length 1 containing full path to raw data folder.  
`mergeDataIfMissing` - boolean value telling if missing data should be automatically merged.  

### Details
Function looks for data in raw data set folder returned by `getData()` function and merges test and train subsets until it is explicitly prohibited by `mergeDataIfMissing` argument value.  
For merge function looks for following file pairs within raw data set folder:  
* /test/X_test.txt, /train/X_train.txt - measurement values  
* /test/y_test.txt, /train/y_train.txt - activity codes corresponding to measurements  
* /test/subject_test.txt, /train/subject_train.txt - test subject ids corresponding to measurements  
Merged files put into /merged/ folder within data folder:  
* /merged/X.txt - measurements  
* /merged/Y.txt - activity codes  
* /merged/subject.txt - test subject ids  
Function creates /merged/ folder automatically if needed.  

### Value
Character list with merged file paths: $measurements, $activities, $subjects.  

## run_analysis.R -- readMeasurements
### Description
This function reads measurement measurements and gives them human-friendly names.  
It is called from `run_analysis()` function and not supposed to be called by end user.  

### Arguments
`mergedFiles` - character list with merged files: $measurements, $activities, $subjects.  
`rawDataPath` - character vector of length 1 containing full path to raw data folder.  

### Details
Function also reads measurement names from raw data set folder returned by `getData()` function. It looks for features.txt file and then strips names from dashes, brackets and commas in order to use them as data.table column names with $ an [] subsetting.  
For example measurement name "tBodyAcc-mean()-X" is transformed into "tBodyAcc_mean_X".  
After that function reads merged measurements data file in data folder using path returned by`mergeDatasets()` function. Data is read into memory as data.table object. Stripped measurement names used as column names for this data.table. As a final step all measurements expect mean and standard deviation values are removed from the table.

### Value
Data.table class object with mean (column names like 'mean') and standard deviations (column names like 'std') measurements.  

## run_analysis.R -- addActivityNames
### Description
This function adds activity names to measurement values data table.  
It is called from `run_analysis()` function and not supposed to be called by end user.  

### Arguments
`measurements` - data.table object with measurement values.  
`mergedFiles` - character list with merged files: $measurements, $activities, $subjects.  
`rawDataPath` - character vector of length 1 containing full path to raw data folder.  

### Details
This function reads activity codes from merged activities file in data folder using path returned by`mergeDatasets()` function. These code are merged with human-friendly activity names from activity_labels.txt file in raw data folder returned by `getData()` function. The original order of activity codsfrom merged files is persisted in order to join them to measurements.  
Function then adds activity names in right order into measurements data.table object.  

### Value
Data.table class object with mean (column names like 'mean') and standard deviations (column names like 'std') measurements and descriptive activity names corresponding to these measurements (column 'Activity').  

## run_analysis.R -- createTidyDataset
### Description
This function creates tidy data set with average measurement values for each test subject id and each activity.  
It is called from `run_analysis()` function and not supposed to be called by end user.  

### Arguments
`measurements` - data table with measurements and activity names.  
`mergedFiles` - character list with merged files: $measurements, $activities, $subjects.  

### Details
This function reads test subject ids from merged subject ids file in data folder using path returned by`mergeDatasets()` function. These ids then attached to measurements data.table.  
The last step is to group data.table rows by activity and subject id and compute average value for each measurement column.

### Value
Data.table class object with descriptive activity names (column 'Activity'), test subject ids (column 'Subject_id') and average measurements values corresponding to them.  
  
  
You made it through here? Well, you are as nerdy as I am I should say :)