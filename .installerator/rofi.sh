#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"

echo -e -n $BOLD"Attempt auto depenancy install? y/n: "$RESET
read -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	apt-get -y install check librsvg2-dev pkg-config bison flex clang make autoconf automake pkg-config libpango1.0-dev libpangocairo-1.0-0 libcairo2-dev libglib2.0-dev libstartup-notification0-dev libxkbcommon-dev libxkbcommon-x11-dev libxcb1-dev libxcb-util-dev libxcb-ewmh-dev libxcb-icccm4-dev
fi

cd /usr/local/src
git clone https://github.com/DaveDavenport/rofi.git
cd ./rofi
git checkout 1.3.1
git submodule update --init
autoreconf -i
mkdir build
cd build
../configure --prefix=/usr/local/
make
make install
