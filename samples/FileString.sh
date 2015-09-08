#!/usr/bin/ksh

#-----------------------------------------------
# FUNCTIONS #
#-----------------------------------------------

#-----------------------------------------------
MTimeFindControl()
{
 find_cmd="find . -mtime $numdays | grep .$filesuffix"
}
#-----------------------------------------------




########################################################################
# MAIN #
########################################################################


tput clear
set -f
product=`basename $0 .sh`
version=1.0
banner $version


echo " "
echo "===================================================================="
echo "$product.sh EXECUTION START ..              "
echo "===================================================================="
echo " "

# Customisable persistent variables ..


# Initialise ..
key=$$
darkpath=/tmp/$product.$key


# Assign input arguments ..
if [ $# -ne 3 ];then
  echo "USAGE ERROR! "
  echo " "
  echo " $product.sh <STRING TO SEARCH FOR> <NO.DAY(S) AGO> <FILE SUFFIX TO SCAN> "
  echo " "
  echo "   e.g."
  echo "     $product.sh DBLFCAT 10 tar"
  echo "     $product.sh S_PART_NUMBER 2 tar"
  echo "     $product.sh ls 12 sh"
  echo " "
  exit 1
else
  string=$1
  numdays=$2
  filesuffix=$3
fi


# Run ..

if [ $numdays -eq 1 ];then
  prfile=$darkpath.$string.$numdays.day_ago
else
  prfile=$darkpath.$string.$numdays.days_ago
fi
okfile=$prfile.FOUND
kofile=$prfile.NOT_FOUND
count=0


MTimeFindControl

total=`eval $find_cmd | wc -l`
total=`expr $total`

for tarfile in `eval $find_cmd`
do
  count=`expr $count + 1`
  strings $tarfile | grep -i $string > /dev/null 2>&1
  rc=$?
  if [ $rc -eq 0 ];then
    echo $tarfile                          >> $okfile
    status="FOUND"
  else
    echo $tarfile                          >> $kofile
    status="NOT FOUND"
  fi
  echo "> PROBING [$tarfile].FOR.[$string].[$status] [$count/$total]"
done


echo " "
if [ -f $okfile ];then
  echo "FILE(S) WITH    [$string]: [ $okfile ]"
fi
if [ -f $kofile ];then
  echo "FILE(S) WITHOUT [$string]: [ $kofile ]"
fi


# Finish ..
echo " "
echo "===================================================================="
echo "$product.sh EXECUTION END ..              "
echo "===================================================================="
echo " "
