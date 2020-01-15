## Sometimes the read files are stored in individual
## subdirectories for each sequenced sample. To
## get around this we need to move these files
## up one directory.
## This is obviously an annoying task, so let's see if we 
## can automate it via an R script

setwd("~/Desktop/AHE_Hylid/Hylidae")

# list all the files in the directory (and subdirectories)
allfiles <- list.files(pattern=".fastq.gz", full.names=F, recursive=T)
#allfiles <- list.files(pattern=".txt", full.names=F, recursive=T)

# strip the names down to just the filename (no directories)
fnames <- NULL
for (p in 1:length(allfiles)){
  fnames <- append(fnames, strsplit(allfiles[p], "/")[[1]][3])
}

# check for duplicates
fnames[which(duplicated(fnames))]
# those listed above need to be manually changed
# otherwise the script will overwrite them at the 'mv' step
# to be sure, you can go back to the top
# and run that bit again after you've made the changes manually

# make a loop to move each one up a level
for (k in 1:length(allfiles)){
  # list the current file path
  curr.file <- allfiles[k]
  # split up the path into directory names
  curr.split <- strsplit(allfiles[k], "/")
  # identify the parent directory for the file
  curr.dir <- paste0(curr.split[[1]][2],"/",curr.split[[1]][3])
  # make the new file path name
  new.dir <- paste0(curr.split[[1]][1],"/",curr.split[[1]][3])
  # tell it which directory to dump
  old.dir <- paste0(curr.split[[1]][1],"/",curr.split[[1]][2])
  # create an expression which moves the current file up a directory
  # then deletes the parent directory (when it is empty)
  # drop the ' "&& rmdir", curr.dir ' bit if you want to keep the dirs
  to.call <- paste("mv ", curr.file, new.dir, "&& rmdir", old.dir)
  # call terminal to actually do all this
  system(to.call)
}
# you'll probably get a "Directory not empty" error, don't worry
# this is just a result of the '&& rmdir' function NOT removing
# directories which still have stuff in them.


## Great, now each subfolder in your main directory holds
## all the reads for that sequenced individual.