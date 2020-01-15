
# make sure to set your working directory first!
# make sure to identify your reference genome by: *reference.name*_mtGenome.fasta
    # and include it in your working directory, along with MITObim.pl
mitoAssemble <- function(num.iter, reference.name, project.name, write.shell=FALSE, ncores=NULL) {
  curr.dir <- getwd()
  
  # copy the reference mtGenome to all the subdirectories
  copy.reference <- paste("cd", curr.dir, ";",
                          "for d in */; do cp", 
                          paste0(reference.name, "_mtGenome.fasta"),
                          "\"$d\"; done")
  system(copy.reference)

  #all.files <- list.files(test) #change 'test' to 'curr.dir'
  
  # make a list of all the directories within your working directory (1 per sample to assemble)
  directories <- list.dirs(curr.dir, recursive=F) #change 'test' to 'curr.dir'
  
  # 
  merge.libraries <- paste("for d in", paste0(curr.dir,"/*/"), "; do (cd", "\"$d\" && cat *.fastq.gz >> merged.fastq.gz); done")
  system(merge.libraries)
  
  if(!isTRUE(write.shell)) {
    
    # make a directory for the final mitoGenomes
    genome.dir <- paste("mkdir", paste0(dirname(getwd()), "/", project.name, "_mtGenomes"))
    system(genome.dir)
    
    # create a loop to assemble the genome of each sample in your working directory
    for (p in 1:length(directories)){
      
      # create the call to change directory
      current.directory <- directories[p]
      change.to.directory <- paste("cd", current.directory)
      
      # create the call to the merged read library
      all.reads <- paste0(current.directory, "/merged.fastq.gz")
      
      # create the call to the reference genome
      ref.genome <- paste0(current.directory, "/", reference.name, "_mtGenome.fasta")
      
      # create the call to MITObim pipeline
      path.to.MITObim <- paste0(dirname(getwd()), "/MITObim.pl")
      
      # create the call to mira
      int.path <- dirname(getwd())
      path.to.mira <- paste0(int.path, "/mira_4.0.2_darwin13.1.0_x86_64_static/bin")
      
      # 
      int.name <- strsplit(current.directory, "/")
      sample.name <- int.name[[1]][length(int.name[[1]])]
      mitobim.call <- paste(path.to.MITObim, "-start 1 -end", num.iter, "-sample", sample.name,
                            "-ref", reference.name, "-readpool", all.reads, "--quick", ref.genome,
                            "&> log --mirapath", path.to.mira)
      
      final.call <- paste(change.to.directory, ";", mitobim.call)
      system(final.call)
      
      # rename the best assembly
      new.name <- paste0("'1s/.*/" ,">", sample.name, "_Assembly", "/g", "'")
      rename.best <- paste("find", current.directory, "-name", "'*_noIUPAC.fasta\'",
                           "-exec sed -i '' -e", new.name,  "{} ';'")
      system(rename.best)
      
      # rename the file of the assembly
      new.file <- paste0(current.directory, "/", paste0(sample.name, "_noIUPAC.fasta"))
      rename.file <- paste("mv", allfiles[k], new.file)
      system(rename.file)
      
      # pull the best mitoGenome and drop it in a folder with the others
      copy.best <- paste("find", current.directory, "-name", "'*_noIUPAC.fasta\'", "-exec cp '{}'",
                         paste0(dirname(getwd()), "/", project.name, "_mtGenomes"), "';'")
      system(copy.best)
      
      cat("finished assembling sample", p, "of", length(directories),":", sample.name) #keep track of what tree/loop# we're on
    }
    system(paste("mv", paste0(dirname(getwd()), "/", project.name, "_mtGenomes"), paste0(curr.dir, "/", project.name, "_mtGenomes")))
    cat("Assembly(s) completed and saved to:", paste0(curr.dir, "/", project.name, "_mtGenomes\n"))
  }
  
  if(isTRUE(write.shell)) {
    if (is.null(ncores)) {
      stop("designate how many cores to split the assemblies across")
    }
    
    # create a loop to assemble the genome of each sample in your working directory
    parallel.script <- file(paste0(curr.dir, "/", project.name, "_parallel.txt"))
    for (p in 1:length(directories)){
      
      # create the call to change directory
      current.directory <- directories[p]
      change.to.directory <- paste("cd", current.directory)
      
      # create the call to the merged read library
      all.reads <- paste0(current.directory, "/merged.fastq.gz")
      
      # create the call to the reference genome
      ref.genome <- paste0(current.directory, "/", reference.name, "_mtGenome.fasta")
      
      # create the call to MITObim pipeline
      path.to.MITObim <- paste0(dirname(getwd()), "/MITObim.pl")
      
      # create the call to mira
      int.path <- dirname(getwd())
      path.to.mira <- paste0(int.path, "/mira_4.0.2_darwin13.1.0_x86_64_static/bin")
      
      # 
      int.name <- strsplit(current.directory, "/")
      sample.name <- int.name[[1]][length(int.name[[1]])]
      mitobim.call <- paste(path.to.MITObim, "-start 1 -end", num.iter, "-sample", sample.name,
                            "-ref", reference.name, "-readpool", all.reads, "--quick", ref.genome,
                            "&> log --mirapath", path.to.mira)
      
      final.call <- paste(change.to.directory, ";", mitobim.call)
      writeLines(final.call, con=parallel.script, sep="\n",)
      
      # set up the process to do 8 at a time, then wait
        # if(p%%ncores==0){
        #   writeLines("wait", shell.script)
        # }
      #system(final.call)
      
      # rename the best assembly
  #    new.name <- paste0("'1s/.*/" ,">", sample.name, "_Assembly", "/g", "'")
  #    rename.best <- paste("find", current.directory, "-name", "'*_noIUPAC.fasta\'",
  #                         "-exec sed -i '' -e", new.name,  "{} ';'")
  #    system(rename.best)
      
      # pull the best mitoGenome and drop it in a folder with the others
  #    copy.best <- paste("find", current.directory, "-name", "'*_noIUPAC.fasta\'", "-exec cp '{}'",
  #                       paste0(dirname(getwd()), "/", project.name, "_mtGenomes"), "';'")
  #    system(copy.best)
      
  #    cat("finished assembling sample", p, "of", length(directories),":", sample.name) #keep track of what tree/loop# we're on
    }
    #system(paste("mv", paste0(dirname(getwd()), "/", project.name, "_mtGenomes"), paste0(curr.dir, "/", project.name, "_mtGenomes")))
    
    close(parallel.script)
    cat("Your shell script for running MITObim in parallel is written to:\n", 
        paste0(curr.dir, "/", project.name, "_parallel.txt"),"\n")
    cat("Execute the command in parallel by copy/paste to your terminal:\n", 
        paste(paste0("parallel ", "-j ", ncores, " ::::"), paste0(curr.dir, "/", project.name, "_parallel.txt")))
    #cat("Assembly(s) completed and saved to:", paste0(curr.dir, "/", project.name, "_mtGenomes"))
  }
}
# if you use the 'write.shell' option to run MITObim in parallel,
# you'll have to collect the file and drop it into a terminal

# if you used the parallel version of 'mitoAssemble' 
# you'll need to use 'mitoCollate' to pull the assemblies together
mitoCollate <- function(project.name) {
  # make a directory to catch the assembled mitoGenomes
  genome.dir <- paste("mkdir", paste0(dirname(getwd()), "/", project.name, "_mtGenomes"))
  system(genome.dir)
  # get a list of all the final assemblies
  allfiles <- list.files(pattern="_noIUPAC.fasta", full.names=F, recursive=T)
  
  for (k in 1:length(allfiles)){
    # grab the sample name
    int.name <- strsplit(allfiles[k], "/")
    sample.name <- int.name[[1]][1]
    # get the current directory name
    current.directory <- paste0(getwd(), "/", int.name[[1]][1], "/", int.name[[1]][2])
    
    # rename the best assembly
    new.name <- paste0("'1s/.*/" ,">", sample.name, "_Assembly", "/g", "'")
    rename.best <- paste("find", current.directory, "-name", "'*_noIUPAC.fasta\'",
                         "-exec sed -i '' -e", new.name,  "{} ';'")
    system(rename.best)
    
    # rename the file of the assembly
    new.file <- paste0(current.directory, "/", paste0(sample.name, "_noIUPAC.fasta"))
    rename.file <- paste("mv", allfiles[k], new.file)
    system(rename.file)
    
    # pull the best mitoGenome and drop it in a folder with the others
    copy.best <- paste("find", current.directory, "-name", "'*_noIUPAC.fasta\'", "-exec cp '{}'",
                       paste0(dirname(getwd()), "/", project.name, "_mtGenomes"), "';'")
    system(copy.best)
    
    cat("finished assembling sample", k, "of", length(allfiles),":", sample.name,"\n") #keep track of what tree/loop# we're on
  }
}

# you'll need MUSCLE dropped into the working directory
mitoAlign <- function(project.name, aligner=c("MAFFT", "MUSCLE"), reference.name=NULL) {
  curr.dir <- getwd()
  
  # make a directory for the final mitoGenomes
  alignment.folder <- paste0(curr.dir, "/", project.name, "_mtGenomes")
  
  # list all the files in the directory 
  all.files <- list.files(alignment.folder, full.name=T) #change 'test' to 'curr.dir'
  #paste(all.files, sep=",")
  
  

  concatenate.assembly <- paste("sed ''", paste0(alignment.folder,"/*.fasta"), ">", 
                                paste0(alignment.folder, "/", project.name, "_Assembly_Alignment.fasta"))
  
  system(concatenate.assembly)
  
  #### if you're on a PC or Linux machine, you'll have to adjust the paths to MUSCLE or MAFFT, sorry!
  if(aligner=="MUSCLE"){
    if(is.null(reference.name)){
      align.em <- paste(paste0(dirname(getwd()), "/muscle3.8.31_i86darwin64"),
                        "-in", paste0(alignment.folder, "/", project.name, "_Assembly_Alignment.fasta"),
                        "-out", paste0(alignment.folder, "/", project.name, "_Aligned_Assemblies.fasta"))
    } else if(!is.null(reference.name)){stop("I'm dumb and don't know how to align to a reference sequence with MUSCLE...yet. Maybe try MAFFT until I've fixed this.")}

    
    system(align.em)
  }
  
  else if(aligner=="MAFFT"){
    if(is.null(reference.name)){
      align.em <- paste(paste0(dirname(getwd()), "/mafft-mac/mafft.bat"),
                        #"/Applications/mafft-mac/mafft.bat",
                        paste0(alignment.folder, "/", project.name, "_Assembly_Alignment.fasta"),
                        ">", paste0(alignment.folder, "/", project.name, "_Aligned_Assemblies.fasta"))
    } else if(!is.null(reference.name)){
      ref.name <- paste0(reference.name, "_mtGenome.fasta")
      align.em <- paste(paste0(dirname(getwd()), "/mafft-mac/mafft.bat"), "--addfull",
                        #"/Applications/mafft-mac/mafft.bat", "--addfull",
                        paste0(alignment.folder, "/", project.name, "_Assembly_Alignment.fasta"),
                        "--keeplength", ref.name, 
                        ">", paste0(alignment.folder, "/", project.name, "_RefAligned_Assemblies.fasta"))
    }

    system(align.em)
  }

  if(is.null(reference.name)){  cat(c("your alignment of mtGenome assemblies is called:\n", 
                                      paste0(alignment.folder, "/", project.name, "_Aligned_Assemblies.fasta")))}
  else if(!is.null(reference.name)){  cat(c("your alignment of mtGenome assemblies is called:\n", 
                                      paste0(alignment.folder, "/", project.name, "_RefAligned_Assemblies.fasta")))}

}


# check each taxon to see if it's doodoo
mitoCheck <- function(project.name, alignment, count.gaps=TRUE, missing.threshold=NULL){
  library(ape); library(seqinr)
  sub.dir <- paste0(getwd(),"/",project.name,"/")
  
  # I'm going to use the quick and dirty approach of getting a percentage of missing data
  # to identify taxa we might want to remove
  # But it might be worth it to think about using a base composition or content method
  # like 'baseContent' in the 'spiderDev' package to do this as well
  # the only worry is that it'll consistently flag outgroups
  
  full.align <- read.dna(paste0(sub.dir, paste0(alignment, ".fasta")), format="fasta")
  if(count.gaps==TRUE) {missing.bases <- c(2, 240, 4)} else missing.bases <- c(2,240)
  missing.sum <- apply(full.align, MARGIN = 1, FUN = function(x) length(which(as.numeric(x) %in% missing.bases)))
  missing.percent <- missing.sum/ncol(full.align)
  
  print(as.data.frame(missing.percent))
  
  if(!is.null(missing.threshold)){
    bad.names <- names(which(missing.percent >= missing.threshold))
    print(paste("dropping", bad.names))
    good.names <- setdiff(rownames(full.align), bad.names)
    new.align <- full.align[which(rownames(full.align) %in% good.names), ]
    write.FASTA(new.align, paste0(sub.dir, paste0(alignment,"_Reduced"),".fasta"))
    cat(c("your reduced alignment is now called:\n", 
          paste0(sub.dir, paste0(alignment,"_Reduced"),".fasta")))
  } else cat(c("your alignment has not been changed"))
}

# chop the mitoGenomes up into pieces
mitoChop <- function(project.name, alignment, character.sets){
  library(ape); library(seqinr)
  sub.dir <- paste0(getwd(),"/",project.name,"/")
  
  # make a directory for the split up mitochondrial loci
  alignment.folder <- paste0(sub.dir, project.name, "_mitoLoci")
  system(paste("mkdir", alignment.folder))
  
  concatenated <- read.dna(paste0(sub.dir, paste0(alignment, ".fasta")), format="fasta")
  loci <- read.csv(paste0(sub.dir, character.sets), header=T)
  # make sure you've removed commas from any numbers!
  
  for (i in 1:nrow(loci)){
    curr.locus <- loci[i,]
    extracted.locus <- concatenated[ , (curr.locus$Minimum):(curr.locus$Maximum)]
    write.FASTA(extracted.locus, paste0(alignment.folder,"/",curr.locus$Name,".fasta"))
  }
  cat(c("your separated mitochondrial loci alignments are in a folder called:\n", 
        alignment.folder))
}




#