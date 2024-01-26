" be iMproved, required
set nocompatible

call plug#begin()
" colorschemes
Plug 'langest/gruvbox'
Plug 'langest/vim-monokai'
Plug 'langest/ir_black'
Plug 'langest/vim-one'
Plug 'langest/papercolor-theme'
Plug 'langest/win9xblueback.vim'

Plug 'github/copilot.vim'
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

nnoremap <Leader>] :CtrlPTag<cr>

" Set update time for git-gutter
set updatetime=100

" Enable line numbering
set nu

" Show whitespace
set list
set listchars=tab:>\ ,trail:~,extends:>,precedes:<,nbsp:~

" Set default style of netrw
let g:netrw_liststyle = 3

" Reload files changed outside vim
set autoread

"set numberformat to always be in decimal
set nrformats=

" COLOR
"set t_Co=256
"let g:hybrid_use_Xresources = 1
if (empty($TMUX))
  if (has("nvim"))
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  if (has("termguicolors"))
    set termguicolors
  endif
endif

" gruvbox settings
let g:gruvbox_italic = 1
"set bg=light
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
set shiftwidth=4
set tabstop=4
set softtabstop=4

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

""""""""""""""""""
" C/C++ settings "
""""""""""""""""""
au BufEnter *.h set path+=include/,source/
au BufEnter *.h set textwidth=120
au BufEnter *.h set expandtab

au BufEnter *.c set path+=include/,source/
au BufEnter *.c set textwidth=120
au BufEnter *.c set expandtab

au BufEnter *.hpp set path+=include/,source/
au BufEnter *.hpp set textwidth=120
au BufEnter *.hpp set expandtab

au BufEnter *.cpp set path+=include/,source/
au BufEnter *.cpp set textwidth=120
au BufEnter *.cpp set expandtab

if (exists('+colorcolumn'))
	au BufEnter *.h set colorcolumn=120
	au BufEnter *.c set colorcolumn=120

	au BufEnter *.hpp set colorcolumn=120
	au BufEnter *.cpp set colorcolumn=120
endif

"""""""""""""""""""
" Python settings "
"""""""""""""""""""
au BufEnter *.py set textwidth=100
au BufEnter *.py set expandtab
au BufEnter *.py set fileformat=unix
au BufEnter *.py nnoremap <Leader>d oimport pdb; pdb.set_trace()<Esc>
au BufEnter *.py nnoremap <Leader>D Oimport pdb; pdb.set_trace()<Esc>

if (exists('+colorcolumn'))
	au BufEnter *.py set colorcolumn=100
endif

""""""""""""""""""""
" Haskell settings "
""""""""""""""""""""
au BufEnter *.hs set expandtab     "Always uses spaces instead of tabs
au BufEnter *.hs set shiftround    "Round indent to nearest shiftwidth multiple

"""""""""""""""""
" YAML settings "
"""""""""""""""""
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd Filetype yaml setlocal ts=2 sts=2 sw=2 expandtab

" Remove Ex mode
noremap Q <NOP>

command! E Explore
