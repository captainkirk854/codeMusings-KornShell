#!/bin/ksh
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Simple, no frills File Tab to Space Convertor
#
# Author      Date         Version     Comments
# ------      ----------   -------     --------
# Fraioli     2016-01-25       1.0     Created
#---------------------------------------------------------------------------------------------------------------------

#########################
# Functions
#########################

#-----------------------------------
FnFileSize()
#-----------------------------------
{
 file=$1
#
 cat $file | wc -c
}




#########################
# Main
#########################

#-----------------------------------
# Configuration ..
#-----------------------------------
spacesForTab=4
targetSuffix="t2s"


#-----------------------------
# handle input arguments ..
#-----------------------------
if [ $# -eq 1 ];then
  sourceFile=$1
  targetFile=$sourceFile.$targetSuffix
  expand -t $spacesForTab $sourceFile > $targetFile
  if [ $? -eq 0 ];then
   size_original=`FnFileSize $sourceFile`
   size_target=`FnFileSize $targetFile`
   if [ $size_target -eq $size_original ] ;then
     echo "No Tab replacement(s) necessary."
     rm $targetFile
   else
     echo "Tab replacement(s) necessary. See --> $targetFile"
   fi
  else
   echo "! UNFORESEEN PROBLEM ENCOUNTERED !" 
  fi
fi
