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
source ~/dotfiles/aliases
source /usr/share/git/completion/git-completion.bash
source /usr/share/git/completion/git-prompt.sh

# Colored ManPages:
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
