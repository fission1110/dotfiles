#!/bin/bash
if [[ -z $INSTALL_DIR ]]; then
	echo "Don't run this directly"
	exit
fi

echo -e $BOLD"[ REQUIRED APPS ]"$RESET
# just guestimating.. this won't detect all the libraries
# probably a good idea to just get the build deps
# https://github.com/Airblader/i3/wiki/Compiling-&-Installing#dependencies
APPS="autoreconf automake cmake gcc g++ pkg-config libtool"
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
		apt-get -y install clang make autoconf automake pkg-config libpango1.0-dev libpangocairo-1.0-0 libcairo2-dev libglib2.0-dev libstartup-notification0-dev libxkbcommon-dev libxkbcommon-x11-dev libxcb1-dev libxcb-util-dev libxcb-ewmh-dev libxcb-icccm4-dev
	fi
fi

cd /usr/local/src
git clone https://github.com/DaveDavenport/rofi.git
cd ./rofi
git submodule update --init
autoreconf -i
mkdir build
cd build
../configure --prefix=/usr/local/
make
make install
