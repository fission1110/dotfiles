#!/bin/bash
if [[ -z $INSTALL_DIR ]]; then
	echo "Don't run this directly"
	exit
fi


cd $INSTALL_DIR
echo -e $BLUE;
ls $INSTALL_DIR/.pwndbg > /dev/null
if [[ $? -ne 0 ]]; then
	mkdir .pwndbg
	git clone https://github.com/pwndbg/pwndbg .pwndbg
else
	cd $INSTALL_DIR
	git pull origin master
fi
echo -e $RESET;

pip3 install -r .pwndbg/requirements.txt

cd ./.pwndbg
# Do this because the setup.sh script overwrites ~/.gdbinit .. we don't know if we want to do that yet.
HOME=$INSTALL_DIR ./setup.sh
