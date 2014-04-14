#Ryan's Dotfiles
All of my configuration and environment stuff to get up and running quickly.

This includes my vim configuration, zsh, and ctags.

##Variations
Remote files should have modified red themes so that I don't confuse them with my local environment.

###zshrc
```
ZSH_THEME="kafeitu-red"

```
###bashrc
```
PS1="\[$(tput bold)\]\[$(tput setaf 1)\]\u@\h \w \\$ \[$(tput sgr0)\]"
```


##Required Packages
```
sudo apt-get install exuberant-ctags git vim zsh
```
