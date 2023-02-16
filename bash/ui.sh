#!/bin/bash
# bash ui examples; whiptail syntax:
# whiptail --title "<checklist title>"    --checklist   "<text to show>" <height> <width> <list height> [ <tag> <item> <status> ] . . .
# whiptail --title "<menu title>"         --menu        "<text to show>" <height> <width> <menu height> [ <tag> <item> ] . . .
# whiptail --title "<radiolist title>"    --radiolist   "<text to show>" <height> <width> <list height> [ <tag> <item> <status> ] . . .
# whiptail --title "<input box title>"    --inputbox    "<text to show>" <height> <width> <default-text> 
# whiptail --title "<password box title>" --passwordbox "<text to show>" <height> <width>
# whiptail --title "<dialog box title>"   --yesno       "<text to show>" <height> <width> 
# whiptail                                --gauge       "<test to show>" <height> <width> <inital percent>

function checklist () {
local result=$(whiptail --title "Linux Distro version" --checklist \
  "What distro are you running?" 15 60 4 \
  "Mint" "Basic usage" ON \
  "Ubuntu" "Desktop usage" OFF \
  "Debian" "Desktop & Server" OFF \
  "CentOS" "Server usage" OFF 3>&1 1>&2 2>&3)
[ "$result" ] && echo "The chosen is: $result" || return 1
}

function menu () {
local result=$(whiptail --title "Package Selection" --menu "Choose your package" 15 60 4 \
  "1" "Minimal install" \
  "2" "Server install" \
  "3" "Web-server install" \
  "4" "Openstack install" \
  "5" "custom install" 3>&1 1>&2 2>&3)
[ "$result" ] && echo "The chosen is: $result" || return 1
}

function radiolist {
local result=$(whiptail --title "Linux Distro version" --radiolist \
  "What distro are you running?" 15 60 4 \
  "Mint" "Basic usage" ON \
  "Ubuntu" "Desktop usage" OFF \
  "Debian" "Desktop & Server" OFF \
  "CentOS" "Server usage" OFF 3>&1 1>&2 2>&3)
[ "$result" ] && echo "The chosen is: $result" || return 1
}

function inputbox () {
local result=$(whiptail --title "Configure profile" --inputbox "What is your Computer Name?" 10 60 Ubuntu 3>&1 1>&2 2>&3)
[ "$result" ] && echo "The chosen is: $result" || return 1
}

function passwordbox () {
local result=$(whiptail --title "Configure Password" --passwordbox "Enter your password here and choose OK to continue." 10 60 3>&1 1>&2 2>&3)
[ "$result" ] && echo "The chosen is: $result" || return 1
}

function yesno () {
  if (whiptail --title "Select Option" --yesno "Choose Between Yes and No." 10 60) then
    echo "You chose Yes. Exit status was $?."
  else
    echo "You chose No. Exit status was $?."
  fi
}

# customize the text for Yes and No buttons with "--yes-button" and "--no-button" options
function yesno-custom () {
  if (whiptail --title "Select Distro  Option" --yes-button "Debian" --no-button "Arch-Linux" --yesno "Which do yo like better?" 10 60) then
    echo "You chose Debian Exit status was $?."
  else
    echo "You chose Arch-Linux. Exit status was $?."
  fi
}

function gauge {
  {
    local i
    for ((i=0; i<=100; i+=20)); do
      sleep 1 && echo $i
    done
  } | whiptail --gauge "please wait while installing" 6 60 0
}

### ... no graphical...
function manageMenu() {
	echo "What do you want to do?"
	echo "   1) opt 1"
	echo "   2) opt 2"
	echo "   3) opt 3"
	echo "   4) Exit"
  local MENU_OPTION=0
	until [[ ${MENU_OPTION} =~ ^[1-4]$ ]]; do
		read -rp "Select an option [1-4]: " MENU_OPTION
	done
  if   [[ ${MENU_OPTION} == 1 ]]; then echo opt 1 && return 1
  elif [[ ${MENU_OPTION} == 2 ]]; then echo opt 2 && return 2
  elif [[ ${MENU_OPTION} == 3 ]]; then echo opt 3 && return 3
  elif [[ ${MENU_OPTION} == 4 ]]; then echo opt 4 && return 4
  fi
  return 25
}
