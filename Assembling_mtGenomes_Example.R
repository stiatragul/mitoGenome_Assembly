# Let's assemble the mitogenomes for the hylids

source("~/Desktop/AHE_Hylid/mtGenome_Assembly.R")

setwd("~/Desktop/AHE_Hylid/Hylidae")

# Assemble the mitochondrial genomes
mitoAssemble(num.iter = 100,
             reference.name = "Dryophytes",
             project.name = "Hylidae",
             write.shell = T,
             ncores = 14)

# If you used the parallel version, collect the
# assembled mitogenomes
mitoCollate(project.name = "Hylidae")

# Align the mitogenomes
mitoAlign(project.name = "Hylidae",
          aligner = "MAFFT",
          reference.name = "Dryophytes")

# Check assembly/alignment completeness
mitoCheck(project.name = "Hylidae",
          alignment = "Hylidae_RefAligned_Assemblies",
          count.gaps = T,
          missing.threshold = 0.7)

# Chop the mitogenomes into specified fragments
mitoChop(project.name = "Hylidae",
         alignment = "Hylidae_RefAligned_Assemblies_Reduced",
         character.sets = "mitoGenome_Annotations_Example.csv")