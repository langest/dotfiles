#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export GOPATH=$HOME/programming/go
export PATH=$PATH:$GOPATH/bin

source ~/.aliases
source /usr/share/git/completion/git-completion.bash
source /usr/share/git/completion/git-prompt.sh

fortune | cowsay -f tux
