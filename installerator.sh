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

# If this script wasn't called with sudo, and we're just logged in as root.. use root as the SUDO_USER
if [[ -z $SUDO_USER ]]; then
	$SUDO_USER = $USER
fi

echo -e $BOLD"[ RECOMMENDED APPS ]"$RESET
APPS="zsh byobu terminator vim nvim ctags apache2 php mysqld mysql gimp inkscape pip2 pip3 ipython ipython3 chromium-browser gitk gdb"
for i in $APPS; do
	echo -e -n $BOLD$BLUE" [ * ] $RESET $i"
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
	echo -e -n $BOLD$BLUE" [ * ] $RESET $i"
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
	read -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		apt-get install $APPS
	fi
fi

echo -e $BLUE;
ls $INSTALL_DIR > /dev/null
if [[ $? -ne 0 ]]; then
	git clone --recursive https://github.com/fission1110/dotfiles.git $INSTALL_DIR
else
	cd $INSTALL_DIR
	git pull origin master
	git submodule update --init --recursive
fi
echo -e $RESET;

chmod +x -R $INSTALL_DIR/.installerator/*

echo -e -n "Install i3-gaps? y/n:"
read -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	. $INSTALL_DIR/.installerator/i3-gaps.sh
fi

echo -e -n "Install polybar? y/n:"
read -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	. $INSTALL_DIR/.installerator/polybar.sh
fi

echo -e -n "Install rofi? y/n:"
read -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	. $INSTALL_DIR/.installerator/rofi.sh
fi

echo -e -n "Install fzf? y/n:"
read -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	. $INSTALL_DIR/.installerator/fzf.sh
fi

echo -e -n "Install Neovim? y/n:"
read -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	. $INSTALL_DIR/.installerator/nvim.sh
fi

echo -e -n "Install pwndbg? y/n:"
read -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	. $INSTALL_DIR/.installerator/pwndbg.sh
fi


echo -e -n "Overwrite home? $RED WARNING DESTRUCTIVE: $RESET this will overwrite files in your home directory. y/n:"
read -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	. $INSTALL_DIR/.installerator/overwrite-home.sh
else
	echo -e $BOLD"PROTIP:$RESET export HOME=$INSTALL_DIR; . $INSTALL_DIR/.bashrc"
fi

chown -R $SUDO_USER:$SUDO_USER $INSTALL_DIR
