cd $INSTALL_DIR
chown -R $SUDO_USER:$SUDO_USER $INSTALL_DIR
cp -r $INSTALL_DIR/* ~/
cp -r $INSTALL_DIR/.* ~/

chown -R $SUDO_USER:$SUDO_USER ~/.byobu/
chown -R $SUDO_USER:$SUDO_USER ~/.config/terminator
