#!/bin/bash
INSTALL_DIR="/tmp/dotfiles"
LATEST_STABLE_NVIM=v0.2.0

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"

if [ "$EUID" -ne 0 ]
  then echo -e $RED"Please run as root"$RESET
  exit
fi

echo -e $BOLD"[ RECOMMENDED APPS ]"$RESET
APPS="zsh byobu terminator vim nvim ctags apache2 php mysqld mysql gimp inkscape pip2 pip3 ipython ipython3 chromium-browser gitk git-gui"
for i in $APPS; do
	echo -e -n $BLUE"> $RESET $i"
	which $i > /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e $GREEN"[FOUND]"$RESET
	else
		echo -e $RED"[MISSING]"$RESET
	fi
done

echo -e $BOLD"[ REQUIRED APPS ]"$RESET

APPS="git"
MISSING=0;
for i in $APPS; do
	echo -e -n $BLUE"> $RESET $i"
	which $i > /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e $GREEN"[FOUND]"$RESET
	else
		echo -e $RED"[MISSING]"$RESET
		MISSING=1;
	fi
done

if [[ $MISSING -eq 1 ]]; then
	echo -e -n $BOLD"Missing required dependencies! Attempt auto install? y/n: "$RESET
	read -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		apt-get install $APPS
	fi
fi

ls $INSTALL_DIR > /dev/null
if [[ $? -ne 0 ]]; then
	git clone https://github.com/fission1110/dotfiles.git $INSTALL_DIR
else
	cd $INSTALL_DIR
	git pull origin master
fi


chmod +x -R $INSTALL_DIR/.installerator/*

echo -e -n "Overwrite home? $RED WARNING DESTRUCTIVE: $RESET this will overwrite files in your home directory. y/n:"
read -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	. $INSTALL_DIR/.installerator/overwrite-home.sh
else
	echo -e $BOLD"PROTIP:$RESET export HOME=$INSTALL_DIR; . $INSTALL_DIR/.bashrc"
fi

echo -e -n "Install Neovim? y/n:"
read -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	. $INSTALL_DIR/.installerator/nvim.sh
fi
