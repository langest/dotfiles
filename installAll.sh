#!/bin/bash
BASIC="xorg-server xorg-server-utils xorg-xinit alsa-utils wicd"
TOOLS="vim git"
PROG="conky mpd ncmpcpp firefox"
LANGS="go"
echo    # move to a new line
echo '=== Making sure the system is up to date ==='
echo '===     running "sudo pacman -Syu"       ==='
sudo pacman -Syu

echo    # move to a new line
read -p "is xf86-video-intel an apropriate graphics dirver? [YyNn]" -n 1 -r
while [[ $REPLY =~ ^[^YyNn]$ ]]
do
	read -n 1 -r
done
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo pacman -S xf86-video-intel
fi

echo    # move to a new line
echo '=== Installing the basics ==='
sudo pacman -S $BASIC

echo    # move to a new line
echo '=== Starting to install useful programs ==='
echo '===      running "sudo pacman -S"       ==='
echo 'The programs are:'
echo $TOOLS $PROG $LANGS
echo    # move to a new line
sudo pacman -S $TOOLS $PROG $LANGS

echo    # move to a new line
echo '=== Installing dwm ==='
read -p "Clone and install dwm from 'github.com/langest/dwm'? [YyNn]" -n 1 -r
while [[ $REPLY =~ ^[^YyNn]$ ]]
do
	read -n 1 -r
done
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	git clone git@github.com:langest/$HOME/programming/c/dwm
	make -C $HOME/programming/c/dwm config.h
	sudo make -C $HOME/programming/c/dwm install
fi

echo 'Done'
