" vim: sw=2 sts=2
" 
" Minimal Vim Configuration
"
" Author: Ian Ding <ianding1@icloud.com>
" Date: 2020-06-12
"
" Just try to keep everything so simple. Add something new only if you really
" need to.

" Install some necessary plugins.
call plug#begin('~/.local/share/nvim/plugged')

Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/nerdcommenter'
Plug 'mbbill/undotree'
Plug 'wincent/ferret'

call plug#end()

" This allows :find to search recursively.
set path+=**

" Use space globally instead of tab.
set expandtab

" Set indentation to 2 spaces by default.
set shiftwidth=2
set softtabstop=2

" Don't show a visual line under the cursor.
set nocursorline

" Complete Vim commands.
set wildmenu
set wildmode=full

" Enable incremental search and highlight matches.
set incsearch
set hlsearch

" Make backspace full functional.
set backspace=2

" No backup, no swapfile.
set nobackup
set nowritebackup
set noswapfile

" Set the leader key to the space key.
let g:mapleader=' '

" Set the local leader key to the backslash key.
let g:maplocalleader='\'

" Enable mouse in the terminal. This requires the terminal to support mouse.
set mouse=a

" Show the line number.
set number

" Persist the undo information in the file system.
if has('persistent_undo')
    silent call system('mkdir -p ~/.cache/vim-undo')
    set undodir=~/.cache/vim-undo
    set undofile
endif

" Split the diff window vertically.
set diffopt+=vertical

" Don't wrap lines.
set nowrap

" Hide the buffer when switching to another buffer.
set hidden

" Preview the substitution.
if has('nvim')
    set inccommand=nosplit
endif

" Use the system clipboard as the default clipboard.
set clipboard=unnamed

" Split the window below or on the right.
set splitbelow
set splitright

" Use Emacs-like key mapping in Command mode.
cmap <c-a> <Home>
cmap <c-e> <End>
cmap <c-f> <Right>
cmap <c-b> <Left>
cmap <c-n> <Down>
cmap <c-p> <Up>

" Toggle the undotree.
function! <SID>toggle_undo_tree()
    UndotreeToggle
    UndotreeFocus
endfunction

command! ToggleUndoTree call <SID>toggle_undo_tree()
nnoremap <leader>u :ToggleUndoTree<CR>

" Show the undotree window on the right.
let g:undotree_WindowLayout = 3

if has('gui_running')
  " Remove scrollbars and toolbars in GUI.
  set guioptions-=r
  set guioptions-=R
  set guioptions-=l
  set guioptions-=L
  set guioptions-=T
  set guioptions-=b
endif

" Yeah, highly inspired by tpope's vim-unimpaired, but mapped only those that
" I actually used.
nnoremap [b :bN<CR>
nnoremap ]b :bn<CR>
nnoremap [c :cN<CR>
nnoremap ]c :cn<CR>
nnoremap [l :lN<CR>
nnoremap ]l :ln<CR>

" Make it easier to turn off match highlighting.
nnoremap <leader>h :noh<CR>
