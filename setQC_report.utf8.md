---
params:
 libs_no: "48 49 50 51 52 53 54 55 56 57"
 set_no: "4_1"
 didTrim: "F"
title: "Report for Set6: JYH_42 43 44 45 46 47"
output:
 html_document:
   theme: united
   number_sections: no
   highlight: tango
   smart: TRUE
   toc: true
   toc_depth: 2
   toc_float: true
author: "Frank (zhangc518@gmail.com) @ UCSD Center for Epigenomics"
date: "Wed Sep 20 09:20:16 2017"
---
<hr style="border: 1px dashed grey;" />



# Sample info. 


Sample Index (from MSTS)   sample ID (from MSTS)   species (if preferred genome assembly, enter here)   Experiment Index (from METS)   Sequencing ID   Experiment type   Sequening core   Machine      Sequening length  Read type   i5 Index (or single index)   i7 index (if applicable) 
-------------------------  ----------------------  ---------------------------------------------------  -----------------------------  --------------  ----------------  ---------------  ----------  -----------------  ----------  ---------------------------  -------------------------
SAMP-10                    H7-SNAP-1               human                                                EXP-10                         JYH_42          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N701                     
SAMP-11                    H7-SNAP-2               human                                                EXP-11                         JYH_43          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N702                     
SAMP-12                    H7-SNAPDMSO-1           human                                                EXP-12                         JYH_44          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N703                     
SAMP-13                    H7-SNAPDMSO-2           human                                                EXP-13                         JYH_45          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N704                     
SAMP-14                    H7-SLOWDMSO-1           human                                                EXP-14                         JYH_46          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N705                     
SAMP-15                    H7-SLOWDMSO-2           human                                                EXP-15                         JYH_47          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N706                     

# QC of Fastq files

preserve31196180ced140a4preserve07598131df02c510preserve595a7de970aec4b2preserveccefcd5a203c0440preservee540d8726601eb18preserve987f0cf87fdfcaaepreserve2653dae128fb9493preserveedf986621e607a65

# QC of mappability
## Reads yeild table {.tabset .tabset-fade .tabset-pills}
### Read yield (%) after each step

preserve6b776beee69343f9

### Read counts after each step

preserveb2fc652a91fda2af

##  Mitochondrial reads fraction 

preserve2bd6e7ecaeda0fe1

## TSS enrichement plots

preserve0e2452af890eda36preserve3ae7fa17f49aa454

## Peak TSS enrichment and FRiT {.tabset .tabset-fade .tabset-pills}
### Max TSS enrichement compare

preserveb4392221e4f1db96preservefe64610fbe78ba96

### FRiT (Fraction of reads in TSS) 

preserve2c563496a14bd4b9

## Insert size distribution 

preserve8f8bcc329ac303e7

## GC bias in final bam 

preserve9f129c2f32e03155

# QC of peaks {.tabset .tabset-fade .tabset-pills}
## Raw peak numbers 

preserve84bfc282e508ee39

## FRiP (Fraction of reads in Peak region)

preservefd286602d71ecb9e

# LibQC table 

preserve3b9edae0d8cf7407

# Tracks

preserve57e2b9baa1c4f12apreserve1eb33cdc68d5391f


---
title: "setQC_report.R"
author: "zhc268"
date: "Wed Sep 20 09:20:15 2017"
---
