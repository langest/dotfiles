" BEGIN Vundle

set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" List all plugins here

" vim-go
Plugin 'fatih/vim-go'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" END Vundle

" Enable line numbering
set nu

" COLOR
set t_Co=256
colorscheme wombat256mod

" Ignore case when searching
set ignorecase

" Highlight search results
set hlsearch

" Enable syntax highlighting
syntax enable

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=2
set tabstop=2
