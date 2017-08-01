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
	apt-get -y install automake cmake clang python-xcbgen libcairo2-dev libxcb1-dev xcb-proto libxcb-util-dev libxcb-ewmh-dev libxcb-icccm4-dev xcb-proto
fi

cd /usr/local/src
git clone --branch 3.0.5 --recursive https://github.com/jaagr/polybar
mkdir polybar/build
cd polybar/build
cmake ..
sudo make install
