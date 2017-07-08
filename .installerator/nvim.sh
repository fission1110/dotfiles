echo -e $BOLD"[ REQUIRED APPS ]"$RESET
APPS="gcc libtool autoconf automake cmake g++ pkg-config unzip"
MISSING=0;
for i in $APPS; do
	echo -e -n $BLUE"> $RESET $i"
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
	read -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		apt-get -y install build-essential libtool autoconf automake cmake g++ pkg-config unzip
	fi
fi
# neovim
cd /usr/local/src
git clone https://github.com/neovim/neovim.git
cd ./neovim

rm -r ./build
make clean
make CMAKE_BUILD_TYPE=Release
make install

APPS="pip2"
MISSING=0;
for i in $APPS; do
	echo -e -n $BLUE"> $RESET $i"
	which $i > /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e $GREEN"[FOUND]"$RESET
	else
		echo -e $RED"[MISSING]"$RESET
		MISSING=1;
	fi
done

if [[ $MISSING -eq 0 ]]; then
	pip2 install neovim
fi

APPS="pip3"
MISSING=0;
for i in $APPS; do
	echo -e -n $BLUE"> $RESET $i"
	which $i > /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e $GREEN"[FOUND]"$RESET
	else
		echo -e $RED"[MISSING]"$RESET
		MISSING=1;
	fi
done

if [[ $MISSING -eq 0 ]]; then
	pip3 install neovim
fi
