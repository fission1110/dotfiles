#!/bin/bash
if [[ -z $INSTALL_DIR ]]; then
	echo "Don't run this directly"
	exit
fi

echo -e $BOLD"[ REQUIRED APPS ]"$RESET
APPS="php composer.phar"
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
		apt-get -y install php
		cd $INSTALL_DIR
		php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
		php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
		php composer-setup.php
		php -r "unlink('composer-setup.php');"
		composer.phar self-update
	fi
fi
cd /usr/local/src
composer.phar global require mkusher/padawan

git clone --recursive https://github.com/padawan-php/deoplete-padawan.git

rm -r $INSTALL_DIR/.config/nvim/bundle/deoplete.nvim/rplugin/python3/deoplete/sources/deoplete_padawan 2>/dev/null
rm -r $INSTALL_DIR/.config/nvim/bundle/deoplete.nvim/rplugin/python3/deoplete/sources/deoplete_padawan.py 2>/dev/null
rm -r $INSTALL_DIR/.config/nvim/bundle/deoplete.vim/autoload/padawan.vim

cp -r ./deoplete-padawan/rplugin/python3/deoplete/sources/deoplete_padawan $INSTALL_DIR/.config/nvim/bundle/deoplete.nvim/rplugin/python3/deoplete/sources/
cp -r ./deoplete-padawan/rplugin/python3/deoplete/sources/deoplete_padawan.py $INSTALL_DIR/.config/nvim/bundle/deoplete.nvim/rplugin/python3/deoplete/sources/

cp -r ./deoplete-padawan/autoload/deoplete/sources/padawan.vim $INSTALL_DIR/.config/nvim/bundle/deoplete.vim/autoload/
