#!/bin/bash
#-----------------------------------------------
#
# Purpose : Demonstrate ways in which text can be formatted in Bash
#
# Keyword : 
#
# Related : Terminal
#
# Usage   :
#
# Tips:
#
#-----------------------------------------------

#------------------------------------------------------------------------------------------
# EXAMPLES
#------------------------------------------------------------------------------------------
#Using RGB:
#printf '\e[<fg_bg>;2;<R>;<G>;<B>m'
#printf '\e[38;2;255;0;0m Foreground color: red\n'
#printf '\e[48;2;0;0;0m Background color: black\n'

#Using ANSI colour code:
#printf '\e[<fg_bg>;5;<ANSI_color_code>m'
#printf '\e[38;5;196m [Foreground colour is now RED]\n' - set the foreground color (<fg_bg>=38) to red (<ANSI_color_code>=196) 
#printf '\e[48;5;0m   [Background colour is now BLACK]\n - the background color (<fg_bg>=48) to black (<ANSI_color_code>=0):
#------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------
fnMoreFunColourTextMethods()
{
 # Set text attributes ..
 echo -e "Normal \e[1mBold"
 echo -e "Normal \e[2mDim"
 echo -e "Normal \e[4mUnderlined"
 echo -e "Normal \e[5mBlink"
 echo -e "Normal \e[7minverted"
 echo -e "Normal \e[8mHidden"

 # ReSet text attributes back to normal ..
 echo -e "\e[0mNormal Text"
 echo -e "Normal \e[1mBold \e[21mNormal"
 echo -e "Normal \e[2mDim \e[22mNormal"
 echo -e "Normal \e[4mUnderlined \e[24mNormal"
 echo -e "Normal \e[5mBlink \e[25mNormal"
 echo -e "Normal \e[7minverted \e[27mNormal"
 echo -e "Normal \e[8mHidden \e[28mNormal"

 # Colour foreground(text) ..
 echo -e "Default \e[39mText is coloured - Default"
 echo -e "Default \e[30mText is coloured - Black"
 echo -e "Default \e[31mText is coloured - Red"
 echo -e "Default \e[32mText is coloured - Green"
 echo -e "Default \e[92mText is coloured - Light green"
 echo -e "Default \e[96mText is coloured - Light cyan"

 # Colour background ..
 echo -e "Default \e[49mBackground is coloured - Default $format_resetAllTextualAttributes"
 echo -e "Default \e[40mBackground is coloured - Black $format_resetAllTextualAttributes"
 echo -e "Default \e[41mBackground is coloured - Red     \e[0m"
 echo -e "Default \e[42mBackground is coloured - Green  $format_resetAllTextualAttributes"
 echo -e "Default \e[102mBackground is coloured - Light green                  $format_resetAllTextualAttributes"
 echo -e "Default \e[106mBackground is coloured - Light cyan        $format_resetAllTextualAttributes"

 # 256 colours foreground(38) text..
 echo -e "\e[38;5;82mHello \e[38;5;198mWorld"

 # 256 colours background(48) text..
 echo -e "\e[40;38;5;82m Hello \e[30;48;5;82m World \e[0m"
}
#-----------------------------------------------------------------------------------------



#-----------------------------------------------------------------------------------------
# MAIN
#-----------------------------------------------------------------------------------------
# Some colouring fun with ANSI colour codes ..
format_resetAllTextualAttributes='\e[0m'
format_redrawPromptForNewColours='\e[K'
format_applyAnsiColourToForeground=38
format_applyAnsiColourToBackground=48

outputColumnWidth=6
maxColourNumber=256

for((colourNumber=0; colourNumber<$maxColourNumber; colourNumber++)); 
  do
    colourCode=${colourNumber}m%03d

    # Set background colour with greyish forecolour ..
    printf "\e[$format_applyAnsiColourToBackground;5;$colourCode" $colourNumber

    # Reset foreground and background attributes for next colour block  ..
    if [ `expr $colourNumber % 5` -eq 0 ];then
      printf $format_resetAllTextualAttributes
    fi

    # Print a blank column in whatever background colour ..
    printf ' '

    # Set new adjacent block with new foreground colour ..
    reverseColourNumber=`expr $maxColourNumber - $colourNumber`
    colourCode=${reverseColourNumber}m%03d
    printf "\e[$format_applyAnsiColourToForeground;5;$colourCode" $reverseColourNumber

 #  printf $format_redrawPromptForNewColours

    # Reset attributes for next loop ..
    printf $format_resetAllTextualAttributes

    # Column width control ..
    if [ ! $((($colourNumber - 15) % $outputColumnWidth)) -eq 0 ];then 
      printf ' ' 
    else
      printf '\n'
    fi
done


fnMoreFunColourTextMethods
