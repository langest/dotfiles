" be iMproved, required
set nocompatible

call plug#begin()
" colorschemes
Plug 'morhetz/gruvbox'
Plug 'nanotech/jellybeans.vim'
Plug 'sickill/vim-monokai'
Plug 'sjl/badwolf'
Plug 'tomasr/molokai'
Plug 'twerth/ir_black'

Plug 'christoomey/vim-sort-motion'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'glts/vim-magnum'
Plug 'glts/vim-radical'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-syntastic/syntastic'

if has('nvim') || has('patch-8.0.902')
	Plug 'mhinz/vim-signify'
else
	Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
call plug#end()

" Use ag instead of ack
cnoreabbrev Ack Ack!
nnoremap <Leader>a :Ack!<Space>
if executable('ag')
	let g:ackprg = 'ag --vimgrep'
endif

" Set update time
set updatetime=100

" Enable line numbering
set nu

" Show whitespace
set list
set listchars=tab:>-,trail:~,extends:>,precedes:<,nbsp:~

" Set default style of netrw
let g:netrw_liststyle = 3

" Reload files changed outside vim
set autoread

"set numberformat to always be in decimal
set nrformats=

" COLOR
set t_Co=256
"let g:hybrid_use_Xresources = 1
colorscheme gruvbox

" Ignore case when searching
set ignorecase

" Highlight search results
set hlsearch

" Enable syntax highlighting
syntax enable

" Set utf8 as standard encoding
set encoding=utf8

" Tab indention
set autoindent
set smartindent

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2
set softtabstop=2

" Highlight cursor line
set cul
hi CursorLine term=none cterm=none ctermbg=236

" Always keep away from bottom/top
set scrolloff=8

" Write with sudo using w!!
cmap w!! %!sudo tee > /dev/null %

" 80th column mark
if (exists('+colorcolumn'))
	set colorcolumn=80
	highlight ColorColumn ctermbg=8
endif

" Bubble text
nmap <C-k> ddkP
nmap <C-j> ddp
vmap <C-k> xkP`[V`]
vmap <C-j> xp`[V`]
nmap <C-Up> ddkP
nmap <C-Down> ddp
vmap <C-Up> xkP`[V`]
vmap <C-Down> xp`[V`]

" Return to old position when reopening files
if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Trim trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

"""""""""""""""""""
" Pyrhon settings "
"""""""""""""""""""
au BufEnter *.py set tabstop=4
au BufEnter *.py set softtabstop=4
au BufEnter *.py set shiftwidth=4
au BufEnter *.py set textwidth=80
au BufEnter *.py set expandtab
au BufEnter *.py set autoindent
au BufEnter *.py set fileformat=unix
au BufEnter *.py nnoremap <Leader>d oimport pdb; pdb.set_trace()<Esc>
au BufEnter *.py nnoremap <Leader>D Oimport pdb; pdb.set_trace()<Esc>

""""""""""""""""""""
" Haskell settings "
""""""""""""""""""""
au BufEnter *.hs set tabstop=4     "A tab is 4 spaces
au BufEnter *.hs set expandtab     "Always uses spaces instead of tabs
au BufEnter *.hs set softtabstop=4 "Insert 4 spaces when tab is pressed
au BufEnter *.hs set shiftwidth=4  "An indent is 2 spaces
au BufEnter *.hs set shiftround    "Round indent to nearest shiftwidth multiple

"""""""""""""""""
" TAML settings "
"""""""""""""""""
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd Filetype yaml setlocal ts=2 sts=2 sw=2 expandtab

" Remove Ex mode
noremap Q <NOP>
