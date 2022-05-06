# MUMmerSNP2VCF_script
Align haplotype genomes (bacterial or some viruses) using MUMmer to obtain SNPs/InDels information and convert to VCF format

## My running environment (pass-test):

System:	(centos 7, 8; Ubuntu 10.2.* ~ Ubuntu 20.04.4 LTS)

MUMmer 4.0.0beta2	http://mummer.sourceforge.net/

Python 3.8.1

## Script description:
`MUMmer_repeats_ident.sh`	: 	Identification of repeat regions in the genome

`MUMmer_snp_calling_no_repeat.sh` 	Identification of SNPs/INDELs , excluding those located in repeat  regions.

`MUMmer_snp_calling_repeat.sh` 	Identification of SNPs/INDELs , including those located in repeat regions (Only the first of each unique repeat region was evaluated, and conflicting repeat copies are eliminated).

`MUMmerSNPs2VCF.py`	Convert the output of MUMmer to VCF format. `MUMmer_snp_calling_no_repeat.sh`, `MUMmer_snp_calling_repeat.sh` will automatically call this script.

