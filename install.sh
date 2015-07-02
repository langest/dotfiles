#!/bin/bash
TOOLS="vim git"
LANGS="go"
echo '=== Making sure the system is up to date ==='
sleep 1
pacman -Syu

echo '=== Starting to install useful programs ==='
sleep 1
pacman -S $TOOLS $LANGS
echo 'Done'
