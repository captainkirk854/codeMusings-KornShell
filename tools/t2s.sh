#!/bin/ksh
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Simple, no frills File Tab <> Space Convertor
# Related : expand, unexpand GNU coreutils written by David MacKenzie.
#
# Author      Date         Version     Comments
# ------      ----------   -------     --------
# Fraioli     2016-01-25       1.0     Created
# Fraioli     2016-01-27       1.1     Some refactoring to allow multi-file processing
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
#-----------------------------------

#-----------------------------------
FnSubstituteTabs()
#-----------------------------------
{
 sourceFile=$1
#
 echo -e " > $sourceFile \c"
 targetFile=$sourceFile.$cfgTargetSuffix
#
 expand -t $cfgSpacesForTab $sourceFile > $targetFile
 if [ $? -eq 0 ];then
  size_source=`FnFileSize $sourceFile`
  size_target=`FnFileSize $targetFile`
  if [ $size_target -eq $size_source ] ;then
    status=""
    rm $targetFile > /dev/null 2>&1
  else
    if [ $size_target -gt $size_source ] ;then
      status="[tab(x1)=space(x$cfgSpacesForTab) $size_source -> $size_target byte(s)]"
      cp -p $targetFile $sourceFile > /dev/null 2>&1
      if [ $? -eq 0 ];then
        rm $targetFile >/dev/null 2>&1
      fi
    fi
  fi
  echo $status
 else
  return 1
 fi
#
 return 0
}
#-----------------------------------

#-----------------------------------
FnSubstituteSpaces()
#-----------------------------------
{
 sourceFile=$1
#
 echo -e " > $sourceFile \c"
 targetFile=$sourceFile.$cfgTargetSuffix
#
 unexpand -t $cfgSpacesForTab $sourceFile > $targetFile
 if [ $? -eq 0 ];then
  size_source=`FnFileSize $sourceFile`
  size_target=`FnFileSize $targetFile`
  if [ $size_target -eq $size_source ] ;then
    status=""
    rm $targetFile > /dev/null 2>&1
  else
    if [ $size_target -lt $size_source ] ;then
      status="[space(x$cfgSpacesForTab)=tab(x1) $size_source -> $size_target byte(s)]"
      cp -p $targetFile $sourceFile > /dev/null 2>&1
      if [ $? -eq 0 ];then
        rm $targetFile >/dev/null 2>&1
      fi
    fi
  fi
  echo $status
 else
  return 1
 fi
#
 return 0
}
#-----------------------------------




#########################
# Main
#########################

#-----------------------------------
# Configuration ..
#-----------------------------------
cfgSpacesForTab=4
cfgTargetSuffix="t2s"
cfgOptionTabToSpace="-ts"
cfgOptionSpaceToTab="-st"

#-----------------------------------
# Initialise ..
#-----------------------------------
product=`basename $0 .sh`

# Check dependent tools ..
which expand >/dev/null 2>&1
if [ $? -eq 0 ];then
  which unexpand >/dev/null 2>&1
  if [ $? -ne 0 ];then
    echo "UTILITY NOT FOUND: unexpand"
    echo " ... check \$path"
    echo " ... aborting"
    exit 1
  fi
else
 echo "UTILITY NOT FOUND: expand"
 echo " ... check \$path"
 echo " ... aborting"
 exit 1
fi

#-----------------------------
# handle input arguments ..
#-----------------------------
if [ $# -gt 1 ];then
  mode=$1
  FileList=`echo $* | cut -f2- -d" "`
  cmdFileList="ls $FileList"

  echo ""
  for file in `eval $cmdFileList`
  do
    if [ -f $file ];then
      if [ $mode = $cfgOptionTabToSpace ];then
        FnSubstituteTabs $file
      elif [ $mode = $cfgOptionSpaceToTab ];then
        FnSubstituteSpaces $file
      fi
      if [ $? -ne 0 ];then
        echo "  *** something went wrong -- aborting ***" 
        echo ""
       exit 1
      fi
    fi
  done
  echo ""
else
 echo ""
 echo "Usage:"
 echo "  $product [$cfgOptionTabToSpace|$cfgOptionSpaceToTab] *.[filesuffix]"
 echo ""
fi
