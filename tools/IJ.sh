#!/bin/ksh
#---------------------------------------------------------------------------------------------------------------------
# Purpose : IntelliJ IDEA Soft-Integration with StoryPlayer
#
# Author      Date         Version     Comments                      
# ------      ----------   -------     --------
# Fraioli     2015-11-01       1.0     Created
#---------------------------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------------------------
# Dependencies:
#   > pn
#   > IntelliJ
#   > StoryPlayer
#
# Keywords:
#   @@IJ_FULLPATH_TO_STORYPLAYER@@
#   @@IJ_STORYPLAYER_PARAMS@@
#   @@IJ_BASE_DIRECTORY@@
#   @@IJ_ACTIVE_PROJECT@@
#   @@IJ_ACTIVE_PROJECT_WORKING@@
#   @@IJ_ACTIVE_PROJECT_WORKFILE@@
#
# Installation:
#   Add IJ.sh to favourite 'bin' directory and ensure its $PATH
# 
# Sample Usage:
#   pn -nj (refresh project settings in current terminal and no jump to directory)
#   source IJ.sh  (if ok, $?=0)
#
# Reference:
#  In IntellIJ, Run + Edit Configurations ...
#    Edit Configuration
#      Name:
#      File: @@IJ_FULLPATH_TO_STORYPLAYER@@
#      Arguments: @@IJ_STORYPLAYER_PARAMS@@ @@IJ_BASE_DIRECTORY@@/@@IJ_ACTIVE_PROJECT@@/@@IJ_ACTIVE_PROJECT_WORKING@@/@@IJ_ACTIVE_PROJECT_WORKFILE@@
#      Custom Working Directory: @@IJ_BASE_DIRECTORY@@/@@IJ_ACTIVE_PROJECT@@
#
#    <configuration default="false" 
#                    name="StoryPlayerDebug" 
#                    type="PhpLocalRunConfigurationType" 
#                    factoryName="PHP Console" 
#                    editBeforeRun="true" 
#                    path="@@IJ_FULLPATH_TO_STORYPLAYER@@" 
#                    scriptParameters="@@IJ_STORYPLAYER_PARAMS@@ @@IJ_BASE_DIRECTORY@@/@@IJ_ACTIVE_PROJECT@@/@@IJ_ACTIVE_PROJECT_WORKING@@/@@IJ_ACTIVE_PROJECT_WORKFILE@@">
#      <CommandLine workingDirectory="@@IJ_BASE_DIRECTORY@@/@@IJ_ACTIVE_PROJECT@@" />
#      <option name="workingDirectory" value="@@IJ_BASE_DIRECTORY@@/@@IJ_ACTIVE_PROJECT@@" />
#      <method />
#    </configuration>
#---------------------------------------------------------------------------------------------------------------------

#########################
# Functions
#########################

#-----------------------------------
fnCheckPNVariables()
#-----------------------------------
{
  notSet=0

  if [ -z "$pnVarBASE_DIRECTORY" ] ||
     [ -z "$pnVarACTIVE_PROJECT_DIRECTORY" ] ||
  	 [ -z "$pnVarACTIVE_PROJECT_WORKING_DIRECTORY" ] ||
  	 [ -z "$pnVarACTIVE_PROJECT_WORKFILE" ]; then
  	notSet=1
  fi

  return $notSet
}

#-----------------------------------
fnCheckSubstitutionVariables()
#-----------------------------------
{
  grep "@@IJ_FULLPATH_TO_STORYPLAYER@@" "$INTELLIJ_TEMPLATE_WORKSPACE" | \
  grep "@@IJ_STORYPLAYER_PARAMS@@" "$INTELLIJ_TEMPLATE_WORKSPACE" | \
  grep "@@IJ_BASE_DIRECTORY@@" "$INTELLIJ_TEMPLATE_WORKSPACE" | \
  grep "@@IJ_ACTIVE_PROJECT@@" "$INTELLIJ_TEMPLATE_WORKSPACE" | \
  grep "@@IJ_ACTIVE_PROJECT_WORKING@@" "$INTELLIJ_TEMPLATE_WORKSPACE" | \
  grep "@@IJ_ACTIVE_PROJECT_WORKFILE@@" "$INTELLIJ_TEMPLATE_WORKSPACE" > /dev/null 2>&1 
  
  return $?
}

#-----------------------------------
fnDisplayApplicationVariableValues()
#-----------------------------------
{
  echo ""
  fnEchoVar STORYPLAYER
  fnEchoVar INTELLIJ_TEMPLATE_WORKSPACE
  echo ""
}

#-----------------------------------
fnDisplayPNVariableValues()
#-----------------------------------
{
  echo ""
  fnEchoVar pnVarBASE_DIRECTORY
  fnEchoVar pnVarACTIVE_PROJECT_DIRECTORY
  fnEchoVar pnVarACTIVE_PROJECT_WORKING_DIRECTORY
  fnEchoVar pnVarACTIVE_PROJECT_WORKFILE
  echo ""
}
#-----------------------------------

#-----------------------------------
fnSetAppVariables()
#-----------------------------------
{
  BASE_DIRECTORY=$pnVarBASE_DIRECTORY
 
  ACTIVE_PROJECT=$pnVarACTIVE_PROJECT_DIRECTORY
  ACTIVE_PROJECT_WORKING=$pnVarACTIVE_PROJECT_WORKING_DIRECTORY
  ACTIVE_PROJECT_WORKFILE=$pnVarACTIVE_PROJECT_WORKFILE
 
  INTELLIJ_ROOT_DIRECTORY="$BASE_DIRECTORY"
  INTELLIJ_CONFIG_DIRECTORY="$INTELLIJ_ROOT_DIRECTORY/$INTELLIJ_CONFIG_AREA"
  INTELLIJ_TEMPLATE_WORKSPACE="$INTELLIJ_CONFIG_DIRECTORY/$INTELLIJ_CONFIG_XML"
  INTELLIJ_TEMPLATE_WORKSPACE_SNAPSHOT="$INTELLIJ_CONFIG_DIRECTORY/$INTELLIJ_CONFIG_XML.$INTELLIJ_CONFIG_XML_SNAPSHOT_SUFFIX"
}

#-----------------------------------
fnEchoVar()
#-----------------------------------
{
  varName=$1

  varValue=$(eval echo \$$varName)
  echo "$varName = $varValue"
}

#-----------------------------------
fnSetStoryPlayer()
#-----------------------------------
{
 notSet=0

 STORYPLAYER=`which $STORYPLAYER_EXE`
 if [ -n "$STORYPLAYER" ];then
   if [ ! -f "$STORYPLAYER" ];then
     echo "$STORYPLAYER_EXE executable file cannot be found"
     unset STORYPLAYER
     notSet=1
   fi
 else
    echo "$STORYPLAYER_EXE is not in \$PATH"
    notSet=1
  fi

  return $notSet
}

#-----------------------------------
fnPerformSubstitution()
#-----------------------------------
{
  #Using commas instead of / for sed is valid !! ..
  cat $INTELLIJ_TEMPLATE_WORKSPACE  | sed s,@@IJ_FULLPATH_TO_STORYPLAYER@@,"$STORYPLAYER",g \
                                    | sed s,@@IJ_STORYPLAYER_PARAMS@@,"$STORYPLAYER_PARAMS",g \
	                            | sed s,@@IJ_BASE_DIRECTORY@@,"$BASE_DIRECTORY",g \
	                            | sed s,@@IJ_ACTIVE_PROJECT@@,"$ACTIVE_PROJECT",g \
	                            | sed s,@@IJ_ACTIVE_PROJECT_WORKING@@,"$ACTIVE_PROJECT_WORKING",g \
	                            | sed s,@@IJ_ACTIVE_PROJECT_WORKFILE@@,"$ACTIVE_PROJECT_WORKFILE",g

}




#########################
# Main
#########################

#-----------------------------------
# Configuration ..
#-----------------------------------
STORYPLAYER_EXE="storyplayer"
STORYPLAYER_PARAMS="-PR --dev"
INTELLIJ_CONFIG_AREA=".idea"
INTELLIJ_CONFIG_XML="workspace.xml"
INTELLIJ_CONFIG_XML_SNAPSHOT_SUFFIX="IJ.snapshot"


#-----------------------------------
# Initialise ..
#-----------------------------------
fnSetAppVariables

#-----------------------------------
# Set up Project Specifics ..
#-----------------------------------
if [ -f "$INTELLIJ_TEMPLATE_WORKSPACE" ];then
  fnSetStoryPlayer
  fnCheckPNVariables
  if [ $? -ne 0 ];then
    fnDisplayPNVariableValues
    fnDisplayApplicationVariableValues
    return 1
  else
    # Handle snapshot backup and restore ..
    if [ -f "$INTELLIJ_TEMPLATE_WORKSPACE_SNAPSHOT" ];then
      cp -p "$INTELLIJ_TEMPLATE_WORKSPACE_SNAPSHOT" "$INTELLIJ_TEMPLATE_WORKSPACE" # restore
    else
      cp -p "$INTELLIJ_TEMPLATE_WORKSPACE" "$INTELLIJ_TEMPLATE_WORKSPACE_SNAPSHOT" # backup
    fi

    # Substitute current project into restored template ..
    fnCheckSubstitutionVariables
    if [ $? -eq 0 ];then
      pID=$$
      fnPerformSubstitution > "$INTELLIJ_TEMPLATE_WORKSPACE".$pID
      mv "$INTELLIJ_TEMPLATE_WORKSPACE".$pID "$INTELLIJ_TEMPLATE_WORKSPACE"
    else
      echo "Some or all required @@variables@@ are missing"
      return 1
    fi
  fi
else
  echo "Cannot find: $INTELLIJ_TEMPLATE_WORKSPACE"
  return 1
fi

#-----------------------------------
# Happy end ..
#-----------------------------------
return 0
