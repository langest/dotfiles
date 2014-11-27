#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#prompt
#PS1='[\u@\h \W]\$ ' # DEFAULT
PS1='[\u@\h \W]\$ '

#go
export GOPATH=$HOME/programming/go
export PATH=$PATH:$GOPATH/bin

#BreamIO
export EYESTREAM=$GOPATH/src/github.com/maxnordlund/breamio

#source
source ~/.aliases
source /usr/share/git/completion/git-completion.bash
source /usr/share/git/completion/git-prompt.sh
