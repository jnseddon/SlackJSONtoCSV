### Convert/Extract Slack JSON information to CSV
### by jnseddon, 2019

# Read in packages
library(tidyverse)
library(geojsonR)
library(lubridate)


# Specify input folders (you may have to do this manually in commands below, 
#   or wrap in as.character)
inputfolder <- "path_to_top_level_input_directory"
parentfolder <- "path_to_preferred_output_folder"

# merge daily json files into one larger file per-channel

pathToFolders <- list.dirs(path = inputfolder)
nameOfFiles <- list.dirs(path = inputfolder,
                       full.names = FALSE)
df <- data.frame("File Path" = pathToFolders, "File Name" = nameOfFiles)

# Loop through and merge all json files in a folder
for(i in 1:45){
  merge_files(INPUT_FOLDER = paste(as.character(folders[[i,1]]),"/",sep = ""),
              OUTPUT_FILE = paste(parentfolder,
                                  folders[[i,2]],".txt", sep = ""))
  print(i)
}

# get list of files and names, store as dataframe
filesList <- data.frame("filePath" = list.files(parentfolder,
                                                full.names = TRUE),
                        fileName = as.character(str_replace(list.files(parentfolder,
                        full.names = FALSE),".txt","")),stringsAsFactors=FALSE)

# Remove unwanted files and dirs, if needed
# filesList <- filesList[-c(#),]

# Create master dataframe, zero out existing one because below loop applies to bottom
slackFiles <- data.frame(fileContents = character(), channelName = character())
filesListLength <- nrow(FilesList)

# Iterate through each json file
for(i in 1:filesListLength){
  # get file path from file list
  filePath <- filesList[[i,1]]
  # read in file, with length of file (to avoid splitting)
  uncleanedFile <- readChar(as.character(filePath),file.info(as.character(filePath))$size)
  # clean file of newlines - not sure if this actually matters, but oh well
  cleanedFile <- str_replace_all(uncleanedFile, "[\r\n]" , "")
  # I don't understand it but it works...find things between "files": and "ts", and unlisting
  fileExtract <- str_extract_all(cleanedFile, "\"files\":((.|\n)*?)\"ts\"") %>% unlist()
  # make an individual channel dataframe by binding results of above to a repeated phrase
  # of channel name n times (where n is the length of the actual other column)
  channelDataFrame <- as.data.frame(cbind(fileExtract, rep(filesList[[i,2]],
                                                           length(fileExtract))))
  # bind that result to the bottom of a master dataframe
  slackFiles <- rbind(slackFiles,channelDataFrame)
}
# set col names
colnames(slackFiles) <- c("fileDump", "channelName")

# Create additional information columns
  slackFiles$user <- NA
  slackFiles$timestamp <- NA
  slackFiles$name <- NA
  slackFiles$filetype <- NA
  slackFiles$url_priv <- NA
  slackFiles$url_download <- NA
  slackFiles$dateTime <- NA

# for every row, do...
slackOutputRows <- nrow(slackFiles)

for(i in 1:slackOutputRows){
  # regex is weird, but basically anything between user and ,"
  lazyuserextract <- str_extract(slackFiles[i,1], "user\":(.*?)\",")
  # couldn't figure out how to integrate, so now it's extract 
  # everything not including user (etc) and ,"
  slackFiles[i,3] <- str_extract(lazyuserextract,"(?<=user\": \")(.*?)(?=\",)")
  # extract timestamp, store for next line
  lazydateextract <- as.numeric(str_extract(slackFiles[i,1],
                                            "(?<=timestamp\": )(.*?)(?=,)"))
  slackFiles[i,4] <- lazydateextract
  # convert timestamp to datetime
  slackFiles[i,9] <- as.POSIXct(lazydateextract, origin = "1970-01-01", tz = "America/New_York")                              
  # get name
  slackFiles[i,5] <- str_extract(slackFiles[i,1],"(?<=\"name\": \")(.*?)(?=\",)")
  # get filetype
  slackFiles[i,6] <- str_extract(slackFiles[i,1],"(?<=\"filetype\": \")(.*?)(?=\",)")
  # get priv url
  slackFiles[i,7] <- str_extract(slackFiles[i,1],"(?<=\"url_private\": \")(.*?)(?=\",)")
  # get download url
  slackFiles[i,8] <- str_extract(slackFiles[i,1],"(?<=\"url_private_download\": \")(.*?)(?=\",)")
  # to show it's running
  print(i)
}

# Clean to remove duplicates (on url)
cleanedSlackFiles <- distinct(slackFiles, url_priv, .keep_all = TRUE)

# Export as CSV
write_csv(cleanedSlackFiles, paste(parentfolder,"/exportedslackfiles.csv", sep=""))

