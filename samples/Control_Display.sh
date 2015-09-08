#!/usr/bin/ksh
#-----------------------------------------------
#
# Purpose : AutoExport DISPLAY
#
# Keyword : Remote
#
# Related : tn, xhost +
#
# Usage   : Control_Display.sh
#
# Tips:
#-----------------------------------------------

host=`who am i | awk '{print $6}' | sed 's/(//g' | sed 's/)//g'`
bit=`echo $host | cut -c1`

echo $host | grep -q '.*:.\.0$'

if [[ ! $? -eq 0 ]] ; then
  if [ "$bit" = ":" ];then
    DISPLAY=:0
  else
    DISPLAY=$host:0
  fi
fi

export DISPLAY

echo "DISPLAY = [ $DISPLAY ]"