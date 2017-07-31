#!/bin/bash
if [[ -z $INSTALL_DIR ]]; then
	echo "Don't run this directly"
	exit
fi

cd /usr/local/src
git clone --depth 1 https://github.com/junegunn/fzf.git
cd ./fzf
./install
