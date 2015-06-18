---
title: "CodeBook"
author: "Andrew Sverdlov"
date: "Sunday, June 14, 2015"
output: html_document
---

# Preamble
This is the code book for the data and its transformations for raw to tidy data set as required in Course Project within [Getting and Cleaning Data](https://www.coursera.org/course/getdata) course on [Coursera](http://www.coursera.org).  
Raw data set with documentation included can be found here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  
General description of this data set and the story around it: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
  
_Disclaimer: this document as well as all scripts provided as is and under no license. Use it as you wish._

# Tidy Data set Description
Tidy data set is the main result of this Course Project. It consists of only one table with 68 columns.  
First two columns contain key values:  
1. Subject_id - integer id of test subject from 1 to 30.  
2. Activity - human-friendly name of activity performed by test subject.  
For details and explanation on terminology please look at raw data set description and readme file. You can find download link in Preamble section.  
  
Other 66 columns in each data set row contain average values of different measurements for raw data set. These values divided into 2 groups:  
* mean - mean values of measurements, can be easily told by column name with "_mean" part  
* standard deviation - std. deviations of measurement, column names contain "_std" part  
Meanings of each measurement explained in raw data set documentation.

# Raw Data Transformations
_IMPORTANT NOTE_: this section contains logical algorithm description and brief notice on script contents. For details please refer to [README.md](https://github.com/CptnSmollett/ProgAssignment3/blob/master/README.md) file.

## Algorithm Explained
The transformation algorithm follows Course Project commands in a quite straitfoward manner and adds couple of necessary actions. Namely algorithm consists of following steps:  
 1. Load libraries needed  
 2. Get raw data path:  
    + check if raw data set exists  
    + if it is missing and it was not prohibited explicitly download and unzip raw data set  
 3. Get path to merged training and test subsets of raw data set  
    + check if merged files exist  
    + if they are missing and it was not prohiobited explicitly merge files and put merged files in a separate folder beside raw data  
 4. Read merged measurmenets into memory  
    + use descriptive measurement names as column names  
    + remove all measurement values expect mean and standard deviation  
 5. Add descriptive activity names to measurements data in memory  
 6. Create tidy dataset  
    + add test subject ids to measurement data in memory  
    + group measurements by subject id and activity name,  calculate average values for each of them  
    
This data set is algorithm output.  

## Scripts
There is only one R script file "run_analysis.R" containing all scripts and functions.  
The entry point is function `r run_analysis()` that bootstraps the algorithm listed above. This function returns tidy data set. Using its argumentsuser can prohibit downloading raw data and merging test and training subsets.  
For further details please refer to [README.md](https://github.com/CptnSmollett/ProgAssignment3/blob/master/README.md) file.