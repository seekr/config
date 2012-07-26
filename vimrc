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

" Use Pathogen to load bundles from ~/.vim/bundle
call pathogen#infect()

" General defaults
set nocompatible
filetype on
syntax on " Syntax highlighting
set ai " Auto-indent
set et " Expand tabs to spaces
set ts=2
set sw=2
set nu " Line numbers on
set backspace=2 " Fully-functional interactive backspace
set isk+=_ " Not word dividers
set wildmenu " : Auto completion
set showcmd " show current command in status bar
set showmatch " show matching parenthesis etc.
set hidden
set ruler
set scrolloff=3
set colorcolumn=80
set encoding=utf-8
set fileencoding=utf-8

" Override default tab settings for some filetypes
autocmd BufNewFile,BufReadPost Makefile* setl noet | setl ts=8 | setl sw=8
autocmd BufNewFile,BufReadPost *.tsv setl noet | setl ts=16 | setl sw=16
autocmd BufNewFile,BufReadPost *.py setl ts=4 | setl sw=4 " PEP 8

" Mouse support under tmux
set mouse=a
set ttymouse=xterm

" For use on a dark terminal
set background=dark
set t_Co=256
colorscheme subzero

runtime! indent.vim
runtime! macros/matchit.vim " Use % to match if/end etc.

" Use , instead of \ as the user modifier. Easier to reach.
let mapleader = ","

" Use ^J/^K to move between tabs
:nmap <C-J> :tabprevious<cr>
:nmap <C-K> :tabnext<cr>
:map  <C-J> :tabprevious<cr>
:map  <C-K> :tabnext<cr>
:imap <C-J> <ESC>:tabprevious<cr>i
:imap <C-K> <ESC>:tabnext<cr>i

" Use ^X to close a tab
:map <C-X> :bd<CR>

" Use ^N for :cnext
:nmap <C-N> :cnext<CR>
:map  <C-N> :cnext<CR>

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

let Tlist_Show_One_File = 1

" Highlight whitespace errors
autocmd BufNewFile,BufReadPost *
    \ syn match Tab "\t" |
    \ syn match TrailingWS "\s\+$" |  
    \ if &background == "dark" |
    \   hi def Tab ctermbg=red guibg=#220000 |
    \   hi def TrailingWS ctermbg=red guibg=#220000 |
    \ else |
    \   hi def Tab ctermbg=red guibg=#ffdddd |
    \   hi def TrailingWS ctermbg=red guibg=#ffdddd |
    \ endif

" Run a shell command in a new window
command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1,a:cmdline)
  call setline(2,substitute(a:cmdline,'.','=','g'))
  execute 'silent $read !'.escape(a:cmdline,'%#')
  setlocal nomodifiable
  1
endfunction
command! -complete=file -nargs=* Git call s:RunShellCommand('git '.<q-args>)
command! -complete=file -nargs=* Svn call s:RunShellCommand('svn '.<q-args>)

" An Ack command
function! Ack(args)
  let grepprg_bak=&grepprg
  set grepprg=ack\ -H\ --nocolor\ --nogroup\ --ignore-dir=coverage\ --ignore-dir=tmp\ --ignore-dir=log
  execute "silent! grep " . a:args
  botright copen
  let &grepprg=grepprg_bak
endfunction
command! -nargs=* -complete=file Ack call Ack(<q-args>)

" Run a shell command and put its output in a quickfix buffer
function! s:RunShellCommandToQuickFix(cmdline)
  execute '!'.escape(a:cmdline.' | tee /tmp/output.txt','%#')
  1
endfunction
command! -nargs=* Rake call s:RunShellCommandToQuickFix('rake '.<q-args>)

" Line up stuff in visual mode
vmap =  :!$HOME/.vim/bin/line-up-equals<CR>
vmap ,  :!$HOME/.vim/bin/line-up-commas<CR>
vmap \| :!$HOME/.vim/bin/tableify<CR>

" Various useful Ruby command mode shortcuts
" focused-test can be found at http://github.com/btakita/focused-test
let g:ruby="ruby -Itest"
let g:rspec="bundle exec rspec"
augroup Ruby
  au!
  autocmd BufNewFile,BufReadPost *.rb
    \ :nmap <leader>r :w<CR>:<C-U>!<C-R>=g:ruby<CR> % \| tee /tmp/output.txt<CR>|
    \ :nmap <leader>c :w<CR>:<C-U>!<C-R>=g:ruby<CR> -c % \| tee /tmp/output.txt<CR>|
    \ :vmap b :!beautify-ruby<CR>
  autocmd BufNewFile,BufReadPost *_spec.rb
    \ :nmap <leader>r :w<CR>:<C-U>!<C-R>=g:rspec<CR> % \| tee /tmp/output.txt<CR>
augroup END

augroup RHTML
  au!
  autocmd BufNewFile,BufReadPost *.rhtml,*.html.erb
    \ :vmap b :!htmlbeautifier<CR>
augroup END

let g:cucumber="bundle exec cucumber -r features"
augroup Cucumber
  au!
  autocmd BufNewFile,BufReadPost *.feature,*.story
    \ setl filetype=cucumber|
    \ :nmap <leader>r :<C-U>!<C-R>=g:cucumber<CR> %<CR>|
    \ :nmap <leader>R :<C-U>!<C-R>=g:cucumber<CR> -b %\:<C-R>=line(".")<CR><CR>
augroup END

" Additional filetypes
autocmd BufNewFile,BufReadPost *.json setl filetype=javascript
autocmd BufNewFile,BufReadPost *.rabl setl filetype=ruby

" Use hyphens in identifiers in some languages
autocmd BufNewFile,BufReadPost *.css,*.scss,*.clj setl isk+=-

" Rainbow parens in Clojure
let g:vimclojure#ParenRainbow=1

" ,v will open /tmp/output.txt as a cross-reference window
nmap <leader>v :cfile /tmp/output.txt<CR>:copen<CR>

" ,a to open a new tab with :Ack ready to go
nmap <leader>a :tabe<CR>:Ack 

" No more bell!
autocmd VimEnter * set vb t_vb=

" If there's a local .vimrc file, use it
" Avoid infinite recursion by skipping this if we're in $HOME
function! SourceVimLocal()
  if filereadable(".vimrc") && (expand($HOME) != getcwd())
    source .vimrc
  endif
endfunction
call SourceVimLocal()

" Wean myself off arrow keys!
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" X11 copy/paste integration
map <leader>pc :w !xsel -i -b<CR>
nmap <leader>pv :r!xsel -b<CR>
