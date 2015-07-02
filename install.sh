#!/bin/bash
TOOLS="vim git"
LANGS="go"
echo    # move to a new line
echo '=== Making sure the system is up to date ==='
echo '===     running "sudo pacman -Syu"       ==='
sudo pacman -Syu

echo    # move to a new line
echo '=== Starting to install useful programs ==='
echo '===      running "sudo pacman -S"       ==='
sudo pacman -S $TOOLS $LANGS
echo 'Done'
