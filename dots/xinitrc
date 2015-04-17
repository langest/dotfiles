#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# launch agent
eval $(/usr/bin/killall ssh-agent; /usr/bin/ssh-agent)

#Set bg
feh --randomize --recursive --bg-fill /home/langest/currentwps/
#feh --randomize --recursive --bg-fill images/wps/winter/

#launch urxvt as daemon and load config
urxvtd --quiet --opendisplay --fork
xrdb - merge ~/.Xresources
setxkbmap se

#launch statusbar program
go-dwmstatus &

#launch conky
conky -d

#disable beep
/usr/bin/xset b off

#turn on numlock
numlockx on

setxkbmap -option ctrl:nocaps       # Make Caps Lock a Control key

exec dwm
