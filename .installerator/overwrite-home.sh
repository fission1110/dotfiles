#!/bin/bash

if [[ -z $INSTALL_DIR ]]; then
	echo "Don't run this directly"
	exit
fi

cd $INSTALL_DIR
chown -R $SUDO_USER:$SUDO_USER $INSTALL_DIR
cp -r $INSTALL_DIR/. $HOME

chown -R $SUDO_USER:$SUDO_USER ~/.byobu/
chown -R $SUDO_USER:$SUDO_USER ~/.config/nvim
chown -R $SUDO_USER:$SUDO_USER ~/.pwndbg/
chown -R $SUDO_USER:$SUDO_USER ~/.vim/
