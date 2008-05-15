" Get a good value for $PATH.
let $PATH = system("printenv PATH")
let $PATH = substitute($PATH, "\<C-J>$", "", "")

" If running in a terminal window, set the terminal type to allow syntax
" highlighting. Otherwise, change directory on startup.
if !has("gui_running")
    set term=ansi
else
	autocmd VimEnter * if getcwd()=="/" | if strlen(@%) | cd %:p:h | else | cd | endif | endif
endif

set nocompatible
filetype on
syntax on " Syntax highlighting
set ai " Auto-indent
set et " Expand tabs to spaces
autocmd BufRead,BufNewFile ?akefile* set noet " ... except for a Makefile
autocmd BufRead,BufNewFile *.tsv set noet " ... or a tab-separated-value file
set ts=2
set sw=2
set tw=79 " Wrap text at 79 columns
set nu " Line numbers on
set backspace=2 " Fully-functional interactive backspace
set isk+=_,$,@,%,# " Not word dividers
set wildmenu " : Auto completion
set showcmd " show current command in status bar
set showmatch " show matching parenthesis etc.

" For use on a dark terminal
set background=dark

runtime! indent.vim

" Use ^J/^K to move between tabs
:nmap <C-J> :tabprevious<cr>
:nmap <C-K> :tabnext<cr>
:map <C-J> :tabprevious<cr>
:map <C-K> :tabnext<cr>
:imap <C-J> <ESC>:tabprevious<cr>i
:imap <C-K> <ESC>:tabnext<cr>i

" Remember where the cursor was last time we edited this file, and jump there
" on opening
augroup JumpCursorOnEdit
  au!
  autocmd BufReadPost *
    \ if expand("<afile>:p:h") !=? $TEMP |
    \   if line("'\"") > 1 && line("'\"") <= line("$") |
    \     let JumpCursorOnEdit_foo = line("'\"") |
    \     let b:doopenfold = 1 |
    \     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
    \        let JumpCursorJOnEdit_foo = JumpCursorOnEdit_foo - 1 |
    \        let b:doopenfold = 2 |
    \     endif |
    \     exe JumpCursorOnEdit_foo |        
    \   endif |
    \ endif
  " Need to postpone using "zv" until after reading the modelines.
  autocmd BufWinEnter *
    \ if exists("b:doopenfold") |
    \   exe "normal zv" |
    \   if(b:doopenfold > 1) |
    \       exe  "+".1 |
    \   endif |
    \   unlet b:doopenfold |
    \ endif
augroup END 

set encoding=utf-8
set fileencoding=utf-8

let Tlist_Show_One_File = 1