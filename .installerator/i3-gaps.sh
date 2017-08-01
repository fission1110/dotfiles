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
	apt-get -y install pkg-config autoconf automake make clang libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm-dev
	add-apt-repository ppa:aguignard/ppa
	apt-get update
	apt-get -y install libxcb-xrm-dev
fi

cd /usr/local/src
git clone https://www.github.com/Airblader/i3 i3-gaps
cd i3-gaps
git checkout gaps
autoreconf --force --install
rm -rf build/
mkdir -p build && cd build/

../configure --prefix=/usr/local --sysconfdir=/etc --disable-sanitizers
make
sudo make install
