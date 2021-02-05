" vim: sw=2 sts=2
"
" Ian's Vim Configuration
"
" Author: Ian Ding <ianding1@icloud.com>
" Date: 02/04/2021

" Install some necessary plugins.
call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'lifepillar/vim-solarized8'
Plug 'tomtom/tcomment_vim'
Plug 'Yggdroot/LeaderF'
Plug 'mbbill/undotree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neovimhaskell/haskell-vim'
Plug 'tpope/vim-vinegar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'jiangmiao/auto-pairs'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-obsession'
Plug 'posva/vim-vue'

call plug#end()

" Use 24-bit colors in the terminal.
set termguicolors

" Use solarized.
colorscheme solarized8_flat

" Use space globally instead of tab.
set expandtab

" Set indentation to 2 spaces by default.
set shiftwidth=2
set softtabstop=2

" Show cursor line.
set cursorline

" Show a column at line 81.
set colorcolumn=81

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

" From tpope's vim-unimpaired.
nnoremap [b :bN<CR>
nnoremap ]b :bn<CR>
nnoremap [c :cN<CR>
nnoremap ]c :cn<CR>
nnoremap [l :lN<CR>
nnoremap ]l :ln<CR>
nnoremap [t :tabNext<CR>
nnoremap ]t :tabnext<CR>

" Turn off match highlighting easily. Didn't bind it to <leader>h since
" <leader>h is occupied by vim-gutgugger.
nnoremap <leader>n :noh<CR>

" Grep command
set grepprg=rg\ --vimgrep\ --trim
set grepformat=%f:%l:%v:%m

" LeaderF
let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1
let g:Lf_ShowDevIcons = 0
let g:Lf_ShortcutF = '<leader>f'
let g:Lf_ShortcutB = '<leader>b'

" Autoclose
let g:closetag_filetypes = 'html'
let g:closetag_xhtml_filetypes = 'jsx,tsx,vue'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ }
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'

" ========================================================================
"                               coc.nvim
" ========================================================================

set updatetime=300
set shortmess+=c

if has("patch-8.1.1564")
  set signcolumn=number
else
  set signcolumn=yes
endif

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()

inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <leader>rn <Plug>(coc-rename)
xmap <leader>F  <Plug>(coc-format-selected)
nmap <leader>F  <Plug>(coc-format-selected)

augroup vimrc_group
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " autocmd FileType javascript setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

nmap <leader>ac  <Plug>(coc-codeaction)
nmap <leader>qf  <Plug>(coc-fix-current)

xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1)
      \ : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0)
      \ : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll()
      \ ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll()
      \ ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

if has('nvim')
  vnoremap <nowait><expr> <C-f> coc#float#has_scroll()
        \ ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
  vnoremap <nowait><expr> <C-b> coc#float#has_scroll()
        \ ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold   :call CocAction('fold', <f-args>)
command! -nargs=0 OR
      \ :call CocAction('runCommand', 'editor.action.organizeImport')

nnoremap <silent><nowait> <leader><space>a  :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <leader><space>e  :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <leader><space>c  :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <leader><space>o  :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <leader><space>s  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <leader><space>j  :<C-u>CocNext<CR>
nnoremap <silent><nowait> <leader><space>k  :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <leader><space>p  :<C-u>CocListResume<CR>

let g:coc_global_extensions = [
      \ 'coc-json',
      \ 'coc-python',
      \ 'coc-tsserver',
      \ 'coc-prettier',
      \ 'coc-vetur',
      \ ]
