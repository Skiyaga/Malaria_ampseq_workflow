#!/usr/bin/env Rscript
.libPaths("~/R/x86_64-pc-linux-gnu-library/4.0-CBI")
library(tidyverse)
args = commandArgs(trailingOnly=T)

load (args[1])

seqtab.nochim.df = as.data.frame(seqtab.nochim)
seqtab.nochim.df$sample = rownames(seqtab.nochim)
seqtab.nochim.df[seqtab.nochim.df==0]=NA
seqtab.nochim.df = seqtab.nochim.df %>% 
  pivot_longer(cols = seq(1,ncol(seqtab.nochim)),names_to = "asv",values_to = "reads",values_drop_na=TRUE) %>% 
  mutate(locus = sapply(strsplit(sample,"_PARA"),"[",1)) %>% 
  mutate(sampleID = as.numeric(sapply(strsplit(sapply(strsplit(sample,"s_S"),"[",2),"_trimmed"),"[",1))) %>% 
  select(sampleID,locus,asv,reads)


temp = seqtab.nochim.df %>% select(locus,asv) %>% distinct()
loci =unique(temp$locus)
k=1
allele.sequences = data.frame(locus = seq(1,nrow(temp)),allele = seq(1,nrow(temp)),sequence = seq(1,nrow(temp)))
for(i in seq(1,length(loci))){
  temp2 = temp %>% filter(locus==loci[i]) 
  for(j in seq(1,nrow(temp2))){
    allele.sequences$locus[k+j-1] = loci[i]
    allele.sequences$allele[k+j-1] = paste0(loci[i],".",j)
    allele.sequences$sequence[k+j-1] = temp2$asv[j]
  }
  k=k+nrow(temp2)
}

allele.data = seqtab.nochim.df %>% 
  left_join(allele.sequences %>% select(-locus),by=c("asv"="sequence")) %>% 
  group_by(sampleID,locus,allele) %>%
  mutate(norm.reads.allele = reads/sum(reads))%>% 
  group_by(sampleID,locus) %>%
  mutate(norm.reads.locus = reads/sum(reads))%>% 
  mutate(n.alleles = n())

  saveRDS(allele.data,allele_data.RDS)