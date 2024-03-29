#!/bin/bash
set -e

# 设置程序参数的缺省值，少用参数即可运行
# Default parameter
#ref_seq=input.txt
#query_seq=output.txt

# 程序功能描述，每次必改程序名、版本、时间等；版本更新要记录清楚，一般可用-h/-?来显示这部分
# Function for script description and usage
usage()
{
cat <<EOF >&2
-------------------------------------------------------------------------------
Author:yangzhishuang  
E-mail:yangzs_chi@yeah.net
Edited by Yang Zhishuang at 2020/03/15
The latest version was edited at : 2020/03/15 By:yangzs
-------------------------------------------------------------------------------
  This program calls the mummer component for the snp calling process.
Need to install mummer in advance and write to PATH
-------------------------------------------------------------------------------
Version 1.0 2020/03/15


# 参数描述，写清功能的缺省值
OPTIONS:
    -r Reference sequence file, fasta format, recommend must give
    -q Query sequence file, fasta format, recommend must give
    -h/? show help of script
    
Example:
    MUMmer_snp_calling.sh -r ref_seq.fna -q query_seq.fna
EOF
}

# 解释命令行参数，是不是很面熟，其实是调用了perl语言的getopts包，
# Analysis parameter
while getopts "h:r:q:" OPTION
do
    case $OPTION in
        
        h)
            usage
            exit 1
            ;;
        r)
            ref_seq=$OPTARG
            ;;
        q)
            query_seq=$OPTARG
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

########
# No input parameters
if [ $# = 0 ]
then
    usage
    exit 1
fi

ref_seq_tem=${ref_seq##*/}
query_seq_tem=${query_seq##*/}

echo -e "$query_seq_tem" 

################################
# excluding SNPs contained in repeats

prefix=${ref_seq_tem%.*}_${query_seq_tem%.*}_mask_repeat

nucmer --prefix=$prefix  $ref_seq $query_seq

show-snps -Clr   -x 1  -T ${prefix}.delta > ${prefix}.snps

################################
# including SNPs contained in one of repeats, conflicting repeat copies will first be eliminated with delta-filter

#prefix=${ref_seq_tem%.*}_${query_seq_tem%.*}

#nucmer --prefix=${prefix} $ref_seq $query_seq

#delta-filter -r -q ${prefix}.delta >${prefix}.filter

#show-snps -Clr  -x 1  -T ${prefix}.filter > ${prefix}.snps




###############################
#MUMmerSNPs2VCF.py
#
#cat << EOF  > MUMmerSNPs2VCF.py
##!/usr/bin/env python
## -*- coding: utf-8 -*-
#
#help_info = """
#This code take output from show-snps.
#The options should be set as:
#show-snps -Clr -x 1  -T mum.delta.filter  >mum.delta.filterX.snps
#Usage:
#python3.4 MUMmerSNPs2VCF.py mum.delta.filterX.snps mum_filterX.snps.vcf
#Keywords: MUMmer show-snps VCF MUMmer2VCF
#"""
#import sys, os 
#if len(sys.argv) == 3:
#    script = sys.argv[0]
#    input_file = sys.argv[1]
#    output_file = sys.argv[2]
#else:
#    print(help_info)
#    sys.exit() 
#    
##from sys import argv
##script, input_file, output_file = argv
#
#sample = os.path.split(input_file)[1].rsplit(".",1)[0]
#OUT = open(output_file,"w")
#OUT.write('##fileformat=VCFv4.1'+"\n")
#OUT.write('##INFO=<ID=SNP,Number=0,Type=Flag,Description="Variation type snps">'+"\n")
#OUT.write('##INFO=<ID=INDEL,Number=0,Type=Flag,Description="Variation type indels">'+"\n")
#OUT.write('##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">'+"\n")
#out_line = ['#CHROM','POS','ID','REF','ALT','QUAL','FILTER','INFO','FORMAT',sample]
#OUT.write("\t".join(out_line)+"\n")                        
#vcf_out = []
#
#
#def check_buff(indel_buff_in):
#    allele_ref = indel_buff_in[0][1]
#    allele_alt = indel_buff_in[0][2]
#    ref_id  = indel_buff_in[0][12]    
#    if allele_ref == '.':
#        # insertion 
#        pos  = indel_buff_in[0][0]
#        # In MUMmer format, the coordinate of '.' is the coordinate of the last nt so, this position is kept.
#        ref_start = indel_buff_in[0][8][0]
#        direction = indel_buff_in[0][11]
#        alt_out = ''
#        if direction == '-1':
#            for line_l in indel_buff_in :
#                alt_out = line_l[2]+alt_out
#        else :
#            for line_l in indel_buff_in :
#                alt_out += line_l[2]
#        alt_out = ref_start+alt_out
#        out_line = [ref_id,pos,'.',ref_start,alt_out,'30','PASS','.','GT','1/1']
#        vcf_out.append(out_line)
#    elif allele_alt == '.':
#        # deletion
#        pos  = str(int(indel_buff_in[0][0])-1)
#        # the coordinate here in the reference is correct, but we need the coordinate of last nt.
#        # In VCF format, we need check the last nt.
#        alt_start = indel_buff_in[0][8][0] # first nt in context
#        ref_out = alt_start
#        for line_l in indel_buff_in :
#            ref_out += line_l[1]
#        out_line = [ref_id,pos,'.',ref_out,alt_start,'30','PASS','.','GT','1/1']
#        vcf_out.append(out_line)
#    else :
#        sys.exit("Both in and del\n")
#
######################################
## initiation 
#start  = 0
#last_pos = 0
#last_ref = ''
#in_del_start = 0
#indel_buff = []
###################################
#
#with open (input_file,"r") as INPUT:
#    for line in INPUT:
#        line = line.rstrip()
#        if len(line)< 1:
#            continue
#        elif start == 0 and line[0] == '[':
#            start = 1
#        elif start == 1:
#            line_list = line.split("\t")
#            ref_id  = line_list[12]
#            pos  = line_list[0]
#            allele_ref = line_list[1]
#            allele_alt = line_list[2]
#            if allele_ref == '.' or allele_alt == '.':
#                # insertion     deletion
#                if in_del_start == 0:
#                    in_del_start = 1
#                    indel_buff.append(line_list)
#                else :
#                    if allele_ref == '.' :
#                        if ref_id == last_ref and int(pos) == last_pos :
#                            indel_buff.append(line_list)
#                        else : # new insertion
#                            check_buff(indel_buff)
#                            indel_buff = []
#                            indel_buff.append(line_list)
#                    elif allele_alt == '.':
#                        if ref_id == last_ref and int(pos) == last_pos + 1:
#                            indel_buff.append(line_list)
#                        else:  # new deletion
#                            check_buff(indel_buff)
#                            indel_buff = []
#                            indel_buff.append(line_list)
#            else :
#                # SNP
#                if in_del_start == 1:
#                    check_buff(indel_buff)
#                    indel_buff = []
#                    in_del_start = 0
#                ## write SNP regard less of last records
#                out_line = [ref_id,pos,'.',allele_ref,allele_alt,'30','PASS','.','GT','1/1']
#                vcf_out.append(out_line)
#            ##
#            last_pos = int(pos)
#            last_ref = ref_id
################
#
#
##  Write VCF
#new_list1 = sorted(vcf_out, key=lambda x: int(x[1]))
#new_list = sorted(new_list1, key=lambda x: x[0])
#for line_new in new_list:
#    if len(line_new[3]) == len(line_new[4]):
#        line_new[7] = "SNP"
#    elif len(line_new[3]) != len(line_new[4]):
#        line_new[7] = "INDEL"
#    OUT.write("\t".join(line_new)+"\n")
#OUT.close()
#EOF
#
#
#
#######conver snps to vcf
#chmod +x ./MUMmerSNPs2VCF.py 
MUMmerSNPs2VCF.py ${prefix}.snps ${prefix}.snps.vcf
/bin/rm  ${prefix}.delta ${prefix}.snps
#rm MUMmerSNPs2VCF.py 
