#!/bin/bash
if [[ -z $INSTALL_DIR ]]; then
	echo "Don't run this directly"
	exit
fi

echo -e $BOLD"[ REQUIRED APPS ]"$RESET
APPS="pip pip3"
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
		apt-get -y install python-pip python3-pip
	fi
fi
pip install --upgrade jedi
pip3 install --upgrade jedi
pip install --upgrade neovim
pip3 install --upgrade neovim
