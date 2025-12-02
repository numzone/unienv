"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" switch configures
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set wildmenu
set number
set mouse-=a
set nopaste
set nocompatible
set autoindent
set ruler
set showcmd
set incsearch
set ai
set showmatch
set showmode
set hlsearch
set cursorline
set cscopeverbose  
set autoread
set history=100
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936
set t_Co=256
set backspace=2
set guioptions-=T
set guioptions-=m
set csto=0
set cursorline
set laststatus=2
set ttymouse=xterm2
set clipboard^=unnamed,unnamedplus

set colorcolumn=80

colorscheme desert 
syntax on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" auto reload previous exit location
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* loadview

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Copy related operations
" nm: to disable number
" mm: to enable number
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap nm :set nonu<cr>
\:set paste<cr>

nmap mm :set nu<cr>
\:set nopaste<cr>

