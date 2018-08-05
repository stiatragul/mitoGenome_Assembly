
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
        paste0(curr.dir, "/", project.name, "_parallel.txt"))
    cat("Execute the command in parallel by copy/paste to your terminal:\n", 
        paste(paste0("parallel ", "-j", ncores, " ::::"), paste0(curr.dir, "/", project.name, "_parallel.txt")))
    #cat("Assembly(s) completed and saved to:", paste0(curr.dir, "/", project.name, "_mtGenomes"))
  }
}

# need to create a shell script as an output, then can drop it into the terminal
# need to make sure we give the shell the proper permissions:
    #  $ chmod a+rx [script_name].sh

# you'll need MUSCLE dropped into the working directory
mitoAlign <- function(project.name) {
  curr.dir <- getwd()
  
  # make a directory for the final mitoGenomes
  alignment.folder <- paste0(curr.dir, "/", project.name, "_mtGenomes")
  
  # list all the files in the directory 
  all.files <- list.files(alignment.folder, full.name=T) #change 'test' to 'curr.dir'
  #paste(all.files, sep=",")
  
  

  concatenate.assembly <- paste("sed ''", paste0(alignment.folder,"/*.fasta"), ">", 
                                paste0(alignment.folder, "/", project.name, "_Assembly_Alignment.fasta"))
  
  system(concatenate.assembly)
  

  align.em <- paste(paste0(dirname(getwd()), "/muscle3.8.31_i86darwin64"),
                "-in", paste0(alignment.folder, "/", project.name, "_Assembly_Alignment.fasta"),
                "-out", paste0(alignment.folder, "/", project.name, "_Aligned_Assemblies.fasta"))
  
  system(align.em)
  
  cat(c("your alignment of mtGenome assemblies is called:\n", 
                paste0(alignment.folder, "/", project.name, "_Aligned_Assemblies.fasta")))
}
