#!/usr/bin/ksh
#-----------------------------------------------
#
# Purpose :
#
# Keyword : Source, Compilation, LinkEdit
#
# Related : C++,C
#
# Usage   :
#
# Tips:
#
#-----------------------------------------------


#-----------------------------------------------
# FUNCTIONS #
#-----------------------------------------------

#----------------------------------------------------------
compilazione_cplus()
{
 i_source=$1
#
 root=`basename $i_source .$cpp_suffix`
 rm -f $root.o > /dev/null 2>&1
#
 echo " > Compiling C++ [$i_source]: \c"
#
 xlC -Q -qnamemangling=compat -c         \
  -DNATIVE_EXCEPTION                     \
  -I.                                    \
  $CUSTO_INCLUDES                        \
  -I${CATIA}/vpm/PublicInterfaces        \
  -I${CATIA}/code/include                \
  -I${CATIA}/vpm/reffiles/source/include \
  -I${CATIA}/vpm/PublicInterfaces        \
  $i_source
#
 if [ $? -ne 0 ];then
   status=KO
   echo $status
   exit 1
 else
   status=OK
   echo $status
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
compilazione_c()
{
 i_source=$1
#
 root=`basename $i_source .$c_suffix`
 rm -f $root.o > /dev/null 2>&1
#
 echo " > Compiling C [$i_source]: \c"
#
 xlC -qnamemangling=compat -c            \
  -DNATIVE_EXCEPTION                     \
  -I.                                    \
  $CUSTO_INCLUDES                        \
  -I${CATIA}/vpm/PublicInterfaces        \
  -I${CATIA}/code/include                \
  -I${CATIA}/vpm/reffiles/source/include \
  $i_source
#
 if [ $? -ne 0 ];then
   status=KO
   echo $status
   exit 1
 else
   status=OK
   echo $status
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
linkIt()
{
 i_module=$1
 attempt=$2
#
 echo " "
 echo "> Linking [$i_module] "
#
 rm -f $i_module
#
 objects=`ls *.o`
#
 if [ "$linkMode" != 'BATCH' ];then
   theLinkCmd="makeC++SharedLib -p10 -o $i_module"
 else
   theLinkCmd="/usr/vacpp/bin/xlC -o $i_module"
 fi
#
 if [ "$RefObjArchive" != 'NULL' ];then
   theLinkCmd=$theLinkCmd" $RefObjArchive"
 fi
#
 inputModuleLib=`echo $i_module | sed s/lib/-l/g`
 inputModuleLib=`basename $inputModuleLib .a`
#
 theLinkCmd=$theLinkCmd" ${objects}"
#
 if [ "$linkMode" != 'BATCH' ];then
   theLinkCmd=`echo $theLinkCmd $SH_LIB | sed s/$inputModuleLib//g`
 else
   theLinkCmd=$theLinkCmd" $SH_LIB"
 fi
#
 theLinkCmd=$theLinkCmd" $SH_LIBPATH"
#
 if [ ! -z "$AWDV_vpmbuild_debug" ];then
   echo " "
   echo " "
   echo " "
   echo " "
   echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
   echo ">>>>>>>>>>>> D E B U G >>> L I N K  I N P U T >>>>>>>>>>>"
   echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
   echo " "
   echo $theLinkCmd
   echo " "
   echo " "
   echo " "
   echo " "
   echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
   echo ">>>>>>>>>>> D E B U G >>> L I N K  R E S U L T >>>>>>>>>>"
   echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
   echo " "
   eval $theLinkCmd 
   echo " "
   echo " "
   echo " "
   echo " "
 else
   eval $theLinkCmd 2>&1 | grep -vi WARNING | grep -v '(W) | grep -v bloadmap'
 fi
#
 if [ $? -ne 0 ];then
   status=KO
 else
   if [ ! -f $i_module ];then
     status=KO
   else
     if [ -z "$mode" -o "$mode" != 'no_strip' ];then
       cp $i_module $i_module.no_strip
       strip $i_module
       echo ">> <Module stripped>"
     else
       echo ">> <Module not stripped>"
     fi
     status=OK
     if [ ! -z "$AWDV_vpmbuild_debug" ];then
       echo " "
       echo " "
       echo " "
       echo " "
       echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
       echo ">>>>>>>>> D E B U G >>> D E P E N D E N C I E S >>>>>>>>>"
       echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
       echo " "
       ldd $i_module | sort -u | grep -v "needs:"
     fi
   fi
 fi
#
 if [ "$status" = 'KO' ] && [ -z "$attempt" ];then
   echo " "
   echo "Problem when linking: Rebuild attempt with updated [$RefObjArchive]:" 
   rm $RefObjArchive
   DuplicateRefObjects $i_module
   attempt=.true.
   linkIt $i_module $attempt
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
UpdateWithDassaultLibs()
{
 DS_LIBPATH="-L$VPM/code/bin
             -L$CATIA/code/lib
             -L$CATIA/code/steplib
            "

 SH_LIBPATH="$DS_LIBPATH $CUSTO_LIBPATH"
#
 DS_LIB="-lgeo
         -lLV002DLG
         -lNS0S3STR
         -lLV003DBA
         -lCO0LSTST
         -lPR060SQL
         -lLV005CDA
         -lLV001BAS
         -lCO0LSTPV
         -lLV011ASS
         -lVX0AFEXS
         -lVX0PEMNG
         -lLV0PSCFG
         -lKS0SIMPL
         -lKS0LATE
         -lVX0AFMNG
         -lVX0AFSVI
         -lGUIDVirtualAction
         -lAD0XXBAS
         -lJS0CORBA
         -lVY0OBJ
         -lCO0RCINT
         -lJS03TRA
         -lLV006CFG
         -lLV01FLTR
         -lCO0LSTST
         -lLV011ASS
         -lVX0AFACT
         -lActionUsr
         -lLV012MET
         -lLV0PSBAS
         -lVX0MMODL
         -lVX0TOOLS
         -lNS0S7TIM
         -lVX0REPL1
         -lxlf
         -lxlf90 
        "
#
 SH_LIB="$DS_LIB $CUSTO_LIBS"
}
#----------------------------------------------------------

#----------------------------------------------------------
CreateListOfSourceForCompilation()
{
 iTargetModule=$1
 iSourceDir=$2
#
 ListofSourceFile=/tmp/$product.filelist.$$
 module_found=0
 add_to_list_from_here=.false.
 unset filesToCompile
#
 if [ ! -z "$iSourceDir" ];then
   cd $iSourceDir
 fi
#
 ls -Ltr | grep -v ".backup" > $ListofSourceFile
#
 for theCodeFile in `cat $ListofSourceFile`
 do
   if [ "$theCodeFile" = "$iTargetModule" ];then
     module_found=1
   fi
 done
#
 removeAllObjectCode=.false.
 if [ $module_found -eq 1 ];then
   for theCodeFile in `cat $ListofSourceFile`
   do
     if [ "$theCodeFile" = "$i_module" ];then
       add_to_list_from_here=.true.
     fi
     if [ "$add_to_list_from_here" = ".true." ];then

       newIncludeFile=`CheckSuffix $theCodeFile $h_suffix`
       if [ "$newIncludeFile" = "OK" ];then
        echo "  > Updated INCLUDE file detected ($theCodeFile)"
        removeAllObjectCode=.true.
       fi

       if [ "$theCodeFile" != "$i_module" ];then
         for validSuffix in $cpp_suffix $c_suffix
         do
           ValidFileForCompile=`CheckSuffix $theCodeFile $validSuffix`
           if [ "$ValidFileForCompile" = "OK" ];then
             filesToCompile=$filesToCompile" "$theCodeFile
           fi
         done
       fi
     fi
   done
 fi
#
 if [ "$removeAllObjectCode" = .true. ];then
   echo "    > Total rebuild initiated ..."
   delObjCmd="rm $PWD/*.o"
   eval $delObjCmd >/dev/null 2>&1
 fi
#
 for theCodeFile in `cat $ListofSourceFile`
 do
   for validSuffix in $cpp_suffix $c_suffix
   do
     ValidFileForCompile=`CheckSuffix $theCodeFile $validSuffix`
     if [ "$ValidFileForCompile" = "OK" ];then
       theCodeFileRoot=`basename $theCodeFile .$validSuffix`
       theCodeFileObject=$theCodeFileRoot.o
       if [ ! -f $theCodeFileObject ];then
         filesToCompile=$filesToCompile" "$theCodeFile
       fi
     fi
   done
 done
#
 rm $ListofSourceFile > /dev/null 2>&1
 for fileToCompile in $filesToCompile
 do
   echo $fileToCompile >> $ListofSourceFile
 done
 if [ -f $ListofSourceFile ];then
   unset filesToCompile
   for theCodeFile in `cat $ListofSourceFile | sort -u`
   do
     filesToCompile=$filesToCompile" "$theCodeFile
   done
 fi
#
 if [ ! -z "$iSourceDir" ];then
   cd - > /dev/null 2>&1
 fi
#
 rm $ListofSourceFile > /dev/null 2>&1
}
#----------------------------------------------------------

#----------------------------------------------------------
CompileListOfSource()
{
 iSourceDir=$1
#
 if [ ! -z "$filesToCompile" ];then
   echo " "
   echo "> Proceeding with compilation ..."
   if [ ! -z "$iSourceDir" ];then
     cd $iSourceDir
   fi
   for theCodeFileToCompile in $filesToCompile
   do
     ValidFileForCompile=`CheckSuffix $theCodeFileToCompile $cpp_suffix`
     if [ "$ValidFileForCompile" = "OK" ];then
       compilazione_cplus $theCodeFileToCompile
     fi
     ValidFileForCompile=`CheckSuffix $theCodeFileToCompile $c_suffix`
     if [ "$ValidFileForCompile" = "OK" ];then
       compilazione_c $theCodeFileToCompile
     fi
   done
   if [ ! -z "$iSourceDir" ];then
     cd - > /dev/null 2>&1
   fi
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
DecideOnRelink()
{
 iTargetModule=$1
#
 relink=.false.
 add_to_list_from_here=.false.
 ls -Ltr > $ListofSourceFile
#
 for theCodeFile in `cat $ListofSourceFile`
 do
   if [ "$theCodeFile" = "$iTargetModule" ];then
     add_to_list_from_here=.true.
   fi
   if [ "$add_to_list_from_here" = ".true." ] && [ "$theCodeFile" != "$iTargetModule" ];then
     relink=.true.
   fi
 done
 rm $ListofSourceFile > /dev/null 2>&1
#
 if [ ! -f "$iTargetModule" ];then
   if [ "$linkMode" = 'SHARED' ];then
     for validSuffix in $arc_suffix
     do
       ValidArchive=`CheckSuffix $iTargetModule $validSuffix`
       if [ "$ValidArchive" = "OK" ];then
         relink=.true.
       fi
     done
   fi
   if [ "$linkMode" = 'BATCH' ];then
     relink=.true.
   fi
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
ScanForRebuild()
{
 i_module=$1
#
 CreateListOfSourceForCompilation $i_module
 CompileListOfSource
 DecideOnRelink $i_module
#
 DuplicateRefObjects $i_module
#
 if [ "$relink" = ".true." ];then
   linkIt $i_module 
 else
   status="up to date"
 fi
#
 echo " "
 echo "> [$output_module] build: $status"
}
#----------------------------------------------------------

#----------------------------------------------------------
CheckSuffix()
{
 iFile=$1
 iSuffix=$2
#
 iFilelen=`echo $iFile | wc -c`

 theCmd="basename $iFile '.$iSuffix'"
 theRoot=`eval $theCmd`
 Rootlen=`echo $theRoot | wc -c`
#
 if [ $iFilelen -eq $Rootlen ];then
   Osuffix=KO
 else
   Osuffix=OK
 fi
#
 echo $Osuffix
}
#----------------------------------------------------------

#----------------------------------------------------------
ParentProject_CheckSum()
{
 iSourceDir=$1
 iRefArchive=$2
#
 regenRefArchive=.false.
 RefObjCheksum=$RefObjArchive.chksum
#
 dataFilter=`echo "awk '{print \\$5 \" \" \\$9}' | egrep '\.cpp|\.c|\.h|\.f'"`
 dataFilterCmd="ls -l $iSourceDir | $dataFilter"
#
 if [ ! -f $RefObjCheksum ];then
   eval $dataFilterCmd > $RefObjCheksum
   regenRefArchive=.true.
 else
   eval $dataFilterCmd > $RefObjCheksum.tmp
   diff $RefObjCheksum.tmp $RefObjCheksum > /dev/null 2>&1
   rc=$?
   if [ $rc -ne 0 ];then
     echo "  *** Parent project has changed since building [$RefObjArchive] ***"
     echo "   ----------------------------------------------------------------------- "
     for theDiff in `sdiff -w96 $RefObjCheksum.tmp $RefObjCheksum | egrep '\||<|>' | sed s/" "/¬/g`
     do
       echo "    [new:old] $theDiff" | sed s/¬/" "/g
     done
     echo "   ----------------------------------------------------------------------- "
     regenRefArchive=.true.
   fi
   rm $RefObjCheksum.tmp > /dev/null 2>&1
 fi
#
 if [ "$regenRefArchive" = ".true." ];then
   if [ -f $iRefArchive ];then
     rm $iRefArchive > /dev/null 2>&1
     eval $dataFilterCmd > $RefObjCheksum
   fi
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
DuplicateRefObjects()
{
 i_module=$1
#
 ref_archive_exists=.false.
 numObjs=0
#
 if [ -f $RefObjArchive ];then
   filesInRefObjArchive=`ar -t $RefObjArchive`
   for fileInRefObjArchive in $filesInRefObjArchive
   do
     if [ -f $fileInRefObjArchive ];then
       rm $RefObjArchive
     fi
   done
 fi
#
 module_found=.false.
 echo " "
 if [ ! -z "$MODULE_SRC_DIR" ];then
   echo "> Source directory for [$i_module] forced to [$MODULE_SRC_DIR] ..."
   if [ -d $MODULE_SRC_DIR ];then
     refCustoDir=$MODULE_SRC_DIR
     ParentProject_CheckSum $refCustoDir $RefObjArchive
     module_found=.true.
   fi
 else
   echo "> Seeking [$i_module] in "
   for CustoInclude in $CUSTO_INCLUDES_ORIGINAL
   do
     CustoDir=`echo $CustoInclude | sed s/'-I'/''/g`
     echo "             !___ [$CustoDir] \c"
     if [ -f $CustoDir/$i_module ];then
       echo " ==>  [*** Found ***]"
       refCustoDir=$CustoDir
       ParentProject_CheckSum $refCustoDir $RefObjArchive
       module_found=.true.
     else
       echo ""
     fi
   done
 fi
#
 if [ "$module_found" = ".false." ];then
   echo " "
   echo "  *** SOURCE REFERENCE AREA FOR [$i_module] NOT FOUND ... ABORTING BUILD ***"
   echo " "
   exit 1
 fi
#
 if [ ! -f $RefObjArchive ];then
   echo " "
   echo "> Building [$RefObjArchive] ..."
   echo " > Examining [source]:[object] synchronisation in parent project [$refCustoDir] ..."
   CreateListOfSourceForCompilation $i_module $refCustoDir
   if [ ! -z "$filesToCompile" ];then
     unset reffilesToReallyCompile
     echo " > Missing object code for following source(s):"
     for fileToCompile in $filesToCompile
     do
       echo "   > <$fileToCompile>.\c"
       if [ ! -f $fileToCompile ];then
         echo "<+>"
         reffilesToReallyCompile=$reffilesToReallyCompile" "$fileToCompile
       else
         echo "<-> <==================<<< [EXCLUDED]"
       fi
     done
     echo " > Generation of temporary reference object(s) \c"
     if [ ! -z "$reffilesToReallyCompile" ];then
       echo "required"
     else
       echo "not required"
     fi
     filesToCompile=$reffilesToReallyCompile
     CompileListOfSource $refCustoDir
   fi
   ls $refCustoDir/*.o > /dev/null 2>&1
   rc=$?
   if [ $rc -eq 0 ];then
     echo " "
     echo "  > Sourcing object(s) from [$refCustoDir] for [$RefObjArchive]"
     for ObjToCpy in `ls $refCustoDir/*.o`
     do
       ObjFile=`basename $ObjToCpy`
       if [ ! -f "$ObjFile" ];then
         echo "   <$ObjFile>.<+>"
         ar -v -r -u $RefObjArchive $refCustoDir/$ObjFile > /dev/null 2>&1
         relink=.true.
       else
         echo "   <$ObjFile>.<-> <==================<<< [EXCLUDED]"
       fi
     done
     if [ -f $RefObjArchive ];then
       ref_archive_exists=.true.
     fi
   fi
   for fileToRemove in $filesToCompile
   do
     ObjectToRemove=`echo $fileToRemove | cut -f1 -d"."`
     ObjectToRemove=$ObjectToRemove.o
     rm $refCustoDir/$ObjectToRemove
   done
 else
   ref_archive_exists=.true.
 fi
#
 if [ "$ref_archive_exists" = ".false." ];then
   RefObjArchive=NULL
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
HandleCustoOverride()
{
 if [ ! -z "$OVERRIDE_INCLUDES" ];then
   for OVERRIDE_INCLUDE in $OVERRIDE_INCLUDES
   do
     overrideInclude="-I$OVERRIDE_INCLUDE $overrideInclude"
   done
 fi
 CUSTO_INCLUDES_ORIGINAL=$CUSTO_INCLUDES
 CUSTO_INCLUDES="$overrideInclude $CUSTO_INCLUDES"
#
 if [ ! -z "$OVERRIDE_LIBPATHS" ];then
   for OVERRIDE_LIBPATH in $OVERRIDE_LIBPATHS
   do
     overrideLibpath="-L$OVERRIDE_LIBPATH $overrideLibpath"
   done
 fi
 CUSTO_LIBPATH="$overrideLibpath $CUSTO_LIBPATH"
}
#----------------------------------------------------------

#----------------------------------------------------------
HandleObjDir()
{
 iObjDir=$1
#
 if [ ! -d "$iObjDir" ];then
   mkdir -p "$iObjDir" > /dev/null 2>&1
   if [ $? -ne 0 ];then
     echo " *** Problem creating [ $iObjDir ] .. ABORTING ***"
   fi
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
TransferSrcToObjDir()
{
 iObjDir=$1
#
 if [ -d "$iObjDir" ];then
   for srcFile in `ls *.$cpp_suffix *.$c_suffix *.$h_suffix 2>&1 | grep -v "does not exist"`
   do
     BackupPreviousFilesIfSizeIsDifferent $iObjDir $srcFile
     ls $srcFile | cpio -pdm $iObjDir > /dev/null 2>&1
   done
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
BackupPreviousFilesIfSizeIsDifferent()
{
 iBackupDir=$1
 iFileToBackup=$2
#
 oldFile=$iBackupDir/$iFileToBackup
 newSize=`cat $iFileToBackup | wc -c`
 if [ -f $oldFile ];then
   oldSize=`cat $oldFile     | wc -c`
 else
   oldSize=0
 fi
#
 if [ $newSize != $oldSize ];then
   if [ -f $oldFile ];then
     fileCount=1
     while [ $fileCount -le $maxNumBackups ];
     do
       typeset -RZ$NumLeadingZerosForBackup PaddedCount=$fileCount
       bakSuffix=$PaddedCount.backup
       bakFile=$oldFile.$bakSuffix
       if [ ! -f $bakFile ];then
         cmd="cp -p $oldFile $bakFile"
         eval $cmd
         fileCount=$maxNumBackups
       fi
      fileCount=`expr $fileCount + 1`
     done
   fi
 fi
}
#----------------------------------------------------------

#----------------------------------------------------------
TakeSnapshot()
{
 iDirToSnap=$1
 iTargetRootDir=$2
#
 DirCount=1
 while [ $DirCount -le $maxNumBackups ];
 do
   typeset -RZ$NumLeadingZerosForBackup PaddedCount=$DirCount
   bakSuffix=$PaddedCount
   bakDir=$iTargetRootDir/$bakSuffix
   if [ ! -d $bakDir ];then
     cmd="mkdir -p $bakDir"
     eval $cmd
     DirCount=$maxNumBackups
   fi
  DirCount=`expr $DirCount + 1`
 done
#
 if [ -d "$iDirToSnap" ];then
   cd $iDirToSnap > /dev/null 2>&1
#
   echo "> Snapshotting        [ $PWD ] ..."
#
   for FileToSnap in `ls *.$cpp_suffix *.$c_suffix *.$h_suffix 2>&1 | grep -v "does not exist"`
   do
     FilePreFix=`echo $FileToSnap | cut -f1 -d"."`
     FileSufFix=`echo $FileToSnap | cut -f2 -d"."`
     HighestBackupVersion=`FindHighestVersionOfBackupFile $FileToSnap`
     ThisVersion=`expr $HighestBackupVersion + 1`
     typeset -RZ$NumLeadingZerosForBackup ThisVersionPadded=$ThisVersion
     FileSnapName=$FilePreFix.[$ThisVersionPadded].$FileSufFix
     theCopyCmd="cp -p $FileToSnap $bakDir/$FileSnapName > /dev/null 2>&1"
     eval $theCopyCmd
   done
#
   RefObjArchivePrefix=`echo $RefObjArchive | cut -f1 -d"."`
   for ArchiveToSnap in `ls $RefObjArchivePrefix* 2>&1 | grep -v "does not exist"`
   do
     theCopyCmd="ls $ArchiveToSnap | cpio -pdm $bakDir > /dev/null 2>&1"
     eval $theCopyCmd
   done
#
   set -f
   for ExecutableToSnap in `ls -F | grep * 2>&1 | cut -f1 -d"*"  | grep -v "does not exist"`
   do
     theCopyCmd="ls $ExecutableToSnap | cpio -pdm $bakDir > /dev/null 2>&1"
     eval $theCopyCmd
   done
   set +f
#
   cd - > /dev/null 2>&1
 fi
#
 cd $bakDir > /dev/null 2>&1
 theActualSnapDir=$PWD
 echo "> Snapshot created in [ $theActualSnapDir ] ..."
#
 cd - > /dev/null 2>&1
}
#----------------------------------------------------------

#----------------------------------------------------------
FindHighestVersionOfBackupFile()
{
 iFile=$1
#
 unset versionFile
#
 for relatedFile in `ls $iFile*`
 do
   lastFile=$relatedFile
 done
#
 versionFile=`echo $lastFile | cut -f3 -d"."`
 if [ ! -z "$versionFile" ];then
   versionFile=`expr $versionFile`
 else
   versionFile=-1
 fi
#
 echo $versionFile
}
#----------------------------------------------------------




###########################################################
#MAIN
###########################################################
#tput clear
product=`basename $0 .sh`
version=1.18
banner $version


echo " "
echo "===================================================================="
echo "$product.sh EXECUTION START ..              "
echo "===================================================================="
echo " "


# Customisable persistent variables ..
cpp_suffix=cpp
c_suffix=c
h_suffix=h
arc_suffix=a
#
maxNumBackups=999
NumLeadingZerosForBackup=3
#
CUSTO=/VPMCUSTO/DMFG
#
THE_SRC_VPM="$CUSTO/code/src"
THE_SRC_PLM="$CUSTO/Batch/aw_plm/src"
#
CUSTO_INCLUDES="
                -I$THE_SRC_VPM/awbom
                -I$THE_SRC_VPM/awue_IPD
                -I$THE_SRC_VPM/awue_NPI
                -I$THE_SRC_VPM/awue_STE
                -I$THE_SRC_VPM/awut_INC
                -I$THE_SRC_VPM/changeOwnership
                -I$THE_SRC_VPM/qttools
                -I$THE_SRC_VPM/vpmapi
                -I$THE_SRC_VPM/vpmtools 
                -I$THE_SRC_PLM
               "
#
CUSTO_LIBPATH="
                -L$CUSTO/code/steplib 
                -L$CUSTO/Batch/aw_plm/bin
              "
#
CUSTO_LIBS="
            -lawbom
            -lawue_IPD 
            -lawue_NPI
            -lawue_STE
            -lawut_INC
            -lchangeOwnership
            -lqttools 
            -lvpmapi 
            -lvpmtools 
            -lAWPLM 
            -lXm
            -lXt
            -lX11
           "


# Initialise ..
export PATH=$PATH:/usr/vacpp/bin
SrcDir=$PWD
ActDir=`basename $SrcDir`
ObjDir=$SrcDir/../obj/$ActDir
SnpDir=$SrcDir/../snap/$ActDir


# Assign input arguments ..
if [ $# -lt 1 ];then
  echo " "
  echo "USAGE ERROR !"
  echo " $product.sh <MODULE NAME> <no_strip|batch|compile_only|link_only|link_only_batch|snap> <source prefix>"
  echo " "
  echo " e.g. "
  echo "     $product.sh MYLIB.a"
  echo "     $product.sh MYLIB.a     no_strip"
  echo "     $product.sh MYLIB.a     compile_only"
  echo "     $product.sh MYLIB.a     compile_only awue_RegisterLink"
  echo "     $product.sh MYLIB.a     link_only"
  echo "     $product.sh MYBATCH.exe batch"
  echo "     $product.sh MYBATCH.exe link_only_batch"
  echo "     $product.sh MYLIB.a     snap"
  echo " "
  exit 1
else
  output_module=$1
  mode=$2
  source_prefix=$3
  if [ -z "$source_prefix" ];then
    source_prefix=.
  fi
  RefObjArchive=refObjectArchive.$output_module
fi


#Run..
HandleObjDir        $ObjDir
TransferSrcToObjDir $ObjDir
HandleCustoOverride
UpdateWithDassaultLibs


if [ "$mode" = 'snap' ];then
  TakeSnapshot $ObjDir $SnpDir
else
  cd $ObjDir > /dev/null 2>&1
  echo "> Output directory for object(s): [ $PWD ]"
fi

if [ -z "$mode" ];then
  linkMode=SHARED
fi

if [ "$mode" = 'batch' -o "$mode" = 'link_only_batch' ];then
  linkMode=BATCH
  RefObjArchive=$RefObjArchive.a
fi

if [ -z "$mode" -o "$mode" = 'no_strip' -o "$mode" = 'batch' ];then
  ScanForRebuild $output_module
fi

if [ "$mode" = 'compile_only' ];then
  for cplus in `ls *.$cpp_suffix | grep $source_prefix`
  do
    compilazione_cplus $cplus
  done
  for conly in `ls *.$c_suffix | grep $source_prefix`
  do
    compilazione_c $conly
  done
fi

if [ "$mode" = 'link_only' -o "$mode" = 'link_only_batch' ];then
  linkIt $output_module 
fi


# Finish ..
echo " "
echo "===================================================================="
echo "$product.sh EXECUTION END ..              "
echo "===================================================================="
echo " "
