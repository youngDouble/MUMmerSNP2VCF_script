

#!/bin/bash
#see http://mummer.sourceforge.net/manual/#identifyingrepeats

set -e

# Default parameter

min_len=50


# Function for script description and usage
usage()
{
cat <<EOF >&2
-------------------------------------------------------------------------------
Author:yangzhishuang  
E-mail:yangzs_chi@yeah.net
Edited by Yang Zhishuang at 2021/04/21
The latest version was edited at : 2020/04/21 By:yangzs
-------------------------------------------------------------------------------
  This program calls the mummer component to identify repeats sequence in the genome.
  Use 'nucmer --maxmatch --nosimplify' 
  Need to install mummer in advance and write to PATH
-------------------------------------------------------------------------------
Version 1.0 2020/04/21



OPTIONS:
    -f Reference sequence file, fasta format, required
    -o Prefix of out file, required
    -m The minimum length of repeats sequence to be reported (bp), default value: 50 [optional]
    -h/? show help of script
    
Example:
    MUMmer_repeats_ident.sh -f RCAD0416_genome.fasta -o RCAD0416 
EOF
}

# Analysis parameter
while getopts "h:f:o:" OPTION
do
    case $OPTION in
        
        h)
            usage
            exit 1
            ;;
        f)
            fasta=$OPTARG
            ;;
        o)
            out=$OPTARG
            ;;
        m)
            min_len=$OPTARG
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


prefix=${out}_repeats_identify

nucmer --maxmatch --nosimplify --prefix=$prefix  $fasta $fasta

show-coords -r $prefix.delta > $prefix.coords

#To find exact repeats of length 50 or greater in a single sequence seq.fasta, type:
repeat-match -n $min_len $fasta > $prefix.repeats

#To find exact tandem repeats of length 50 or greater in a single sequence seq.fasta, type:
exact-tandems $fasta $min_len > $prefix.repeats.tandems.txt

###########

if [ -f  $prefix.repeats.bed ];then
rm $prefix.repeats.bed
fi

accession=`sed -n '3p' $prefix.delta |cut -f 2 -d " "`
awk 'BEGIN{OFS="\t"}{print $1,$2,$3}' $prefix.repeats |tail -n +3 |sort -nk1 -t $'\t' |while read line
do
s1=`echo -e "$line"|cut -f 1`
s1_1=`echo -e "$s1-1"|bc`

s2=`echo -e "$line"|cut -f 2`
len=`echo -e "$line"|cut -f 3`

end1=`echo -e "$s1+$len"|bc`
if  [[ $s2 == *r ]];then 
end2=${s2%r*}
s2=`echo -e "$end2-$len"|bc`
else
end2=`echo -e "${s2%r*}+$len"|bc`
fi

s1_1=`echo -e "$s1-1"|bc`
s2_1=`echo -e "$s2-1"|bc`

echo -e "$accession\t$s1\t$end1" >> $prefix.repeats.bed
echo -e "$accession\t$s2\t$end2" >> $prefix.repeats.bed

echo -e "$accession\t$s1_1\t$end1" >> $prefix.repeats.bed.tem
echo -e "$accession\t$s2_1\t$end2" >> $prefix.repeats.bed.tem
done
sort -nk2 -t $'\t' $prefix.repeats.bed -o $prefix.repeats.bed
sort -nk2 -t $'\t' $prefix.repeats.bed.tem -o $prefix.repeats.bed.tem
seqtk seq -l 100 -M $prefix.repeats.bed.tem -n N  $fasta > $prefix.repeats.masked.fna

rm $prefix.coords $prefix.delta   $prefix.repeats.bed.tem

#
