# MUMmerSNP2VCF_script
Align haplotype genomes (bacterial or some viruses) using MUMmer to obtain SNPs/InDels information and convert to VCF format

## My running environment (pass-test):

System:	(centos 7, 8; Ubuntu 10.02.* ~ Ubuntu 20.04.4 LTS)

MUMmer 4.0.0beta2	http://mummer.sourceforge.net/

Python 3.8.1

## Script description:
`MUMmer_repeats_ident.sh`	: 	Identification of repeat regions in the genome

`MUMmer_snp_calling_no_repeat.sh` 	Identification of SNPs/INDELs , excluding those located in repeat  regions.

`MUMmer_snp_calling_repeat.sh` 	Identification of SNPs/INDELs , including those located in repeat regions (Only the first of each unique repeat region was evaluated, and conflicting repeat copies are eliminated).

`MUMmerSNPs2VCF.py`	Convert the output of MUMmer to VCF format. `MUMmer_snp_calling_no_repeat.sh`, `MUMmer_snp_calling_repeat.sh` will automatically call this script.



# Citation

If you use MUMmerSNP2VCF_script  tools in your research, please cite:

**Tracing genetic signatures of bat‐to‐human coronaviruses and early transmission of North American SARS‐CoV‐2.**

 Ou X, Yang Z, Zhu D, et al. . Transboundary and Emerging Diseases, 2021. https://doi.org/10.1111/tbed.14148

