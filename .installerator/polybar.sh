#!/bin/bash
if [[ -z $INSTALL_DIR ]]; then
	echo "Don't run this directly"
	exit
fi

echo -e $BOLD"[ REQUIRED APPS ]"$RESET
# just guestimating.. this won't detect all the libraries
# probably a good idea to just get the build deps
# https://github.com/Airblader/i3/wiki/Compiling-&-Installing#dependencies
APPS="autoreconf automake cmake clang pkg-config libtool python"
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
		sudo apt-get install automake cmake clang cairo libxcb1-dev xcb-proto libxcb-util-dev libxcb-ewmh-dev libxcb-icccm4-dev
	fi
fi
cd /usr/local/src
git clone --branch 3.0.5 --recursive https://github.com/jaagr/polybar
mkdir polybar/build
cd polybar/build
cmake ..
sudo make install
