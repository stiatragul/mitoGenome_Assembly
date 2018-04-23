# mitoGenome Assembly and Alignment
## Content
This R script (*mtGenome_Assembly.R*) provides two functions for assembling and aligning mitochondrial genomes from Illumina reads. Really, I've just written two wrapper functions, the first depends on MITObim (https://github.com/chrishah/MITObim) to assemble the mtGenome relative to a reference sequence, and the second depends on MUSCLE (https://www.drive5.com/muscle/) to align the assembled mtGenomes to one another.
## Purpose/Use
I wrote these up because as a byproduct of a number of Anchored Hybrid Enrichment phylogenomics projects, we have a bloody avalanche of mitochondrial data available as bycatch from the exon capture process. By assembling the mitoGenomes, we're getting an alternative phylogenomic history that provides some interesting information regarding introgression and hybridization, and better resolution than previous mitochondrial data (one or two Sanger-sequenced loci). 

The functions are available in the *mtGenome_Assembly.R* script, and a tutorial is available in the accompanying PDF.

Cheers.  
Ian

