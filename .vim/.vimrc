" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

scriptencoding utf-8
set encoding=utf-8

set clipboard=unnamedplus

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set nobackup    " do not keep a backup file, use versions instead
set history=50    " keep 50 lines of command line history
set ruler    " show the cursor position all the time
set number    " always display line numbering
set showcmd    " display incomplete commands
set incsearch    " do incremental searching
set hlsearch
set cindent    " always use c-indenting style
set copyindent
if has("win32")
  set fileformats=dos,unix
else
  set fileformats=unix,dos
  set shell=/bin/bash
endif
set hidden
set ignorecase
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set winwidth=50
set switchbuf=useopen,usetab
set background=dark
set wrap
set lazyredraw

let mapleader = '\'
let maplocalleader = '\'
let splice_leader = '\'

execute pathogen#infect()

" Set tabstop, softtabstop and shiftwidth to the same value
command! -nargs=* Stab call Stab()
function! Stab()
  let l:tabstop = 1 * input('set tabstop = softtabstop = shiftwidth = ')
  if l:tabstop > 0
    let &l:sts = l:tabstop
    let &l:ts = l:tabstop
    let &l:sw = l:tabstop
  endif
  call SummarizeTabs()
endfunction

function! SummarizeTabs()
  try
    echohl ModeMsg
    echon 'tabstop='.&l:ts
    echon ' shiftwidth='.&l:sw
    echon ' softtabstop='.&l:sts
    if &l:et
      echon ' expandtab'
    else
      echon ' noexpandtab'
    endif
  finally
    echohl None
  endtry
endfunction


" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:*\ ,eol:¬

"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

" ex command for toggling hex mode - define mapping if desired
command! -bar Hexmode call ToggleHex()

nnoremap <C-H> :Hexmode<CR>
inoremap <C-H> <Esc>:Hexmode<CR>
vnoremap <C-H> :<C-U>Hexmode<CR>

" helper function to toggle hex mode
function! ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction

" clean up if statement spacing
command! Cleanifs call CleanIfs()
function! CleanIfs()
    :% s/\<if(/if (/e
    :% s/\<if ( /if (/e
    :% s/\<if (\(.*\) )/if (\1)/e
    :% s/\<if (\(.*\)){/if (\1) {/e
endfunction

" statusline
" " cf the default statusline: %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" " format markers:
" "   %< truncation point
" "   %n buffer number
" "   %f relative path to file
" "   %m modified flag [+] (modified), [-] (unmodifiable) or nothing
" "   %r readonly flag [RO]
" "   %y filetype [ruby]
" "   %= split point for left and right justification
" "   %-35. width specification
" "   %l current line number
" "   %L number of lines in buffer
" "   %c current column number
" "   %V current virtual column number (-n), if different from %c
" "   %P percentage through buffer
" "   %) end of width specification
set statusline=%<\ %n:%f\ %m%r%y%=%-35.(line:\ %l\ of\ %L,\ col:\ %c%V\ (%P)%)\ %9*%{&ff=='unix'?'':&ff.'\ format'}%*

" custom mappings

" quit quickly
nmap Q :qa<CR>

" toggle spell
nnoremap <leader>s :set spell!<CR>

" toggle wrap & horizontal scroll bar (if gvim)
nnoremap <silent><expr> <F2>       ':set wrap! go'.'-+'[&wrap]."=b\r"
inoremap <silent><expr> <F2> "\<C-O>:set wrap! go".'-+'[&wrap]."=b\r"

" untabify current buffer
nnoremap <F5>      :retab<CR>
inoremap <F5> <C-O>:retab<CR>

" clear out lines with only whitespace
nnoremap <F6>      :% s/^\s\+$//<CR>
inoremap <F6> <C-O>:% s/^\s\+$//<CR>

" delete whitespace at end of lines
nnoremap <F7>      :% s/\s\+$//<CR>
inoremap <F7> <C-O>:% s/\s\+$//<CR>

nnoremap <silent> tt :tabnew<CR>:NERDTreeMirror<CR>

" folding
inoremap <F9> <C-O>za
nnoremap <F9> za
onoremap <F9> <C-C>za
vnoremap <F9> zf

nnoremap <F12> [[jV][kzf

" horizontal scrolling
map <C-L> 20zl
map <C-H> 20zh

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
"map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " verilog header files
  autocmd BufRead,BufNewFile *.vh           set filetype=verilog

  " scons files are python
  autocmd BufRead,BufNewFile SConstruct     set filetype=scons
  autocmd BufRead,BufNewFile SConscript     set filetype=scons
  autocmd BufRead,BufNewFile *scons*/*.py   set filetype=scons

  " automatically save the session on exit if there is more than 1 buffer open
  " superseded by session.vim - left in for reference
  "autocmd VimLeave ?* : if bufnr('$') > 1 | mksession! DefaultSession.vis | endif

  " automatically reload vimrc after editing it
  autocmd bufwritepost .vimrc source $MYVIMRC

  " automatically merge Xresources after editing it
  autocmd bufwritepost ~/.Xresources exe '!xrdb -merge ~/.Xresources'

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  "autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

endif " has("autocmd")

colorscheme bandit "torte

" Show trailing whitepace and spaces before a tab
highlight default ExtraWhitespace ctermbg=red guibg=red
autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/ containedin=ALL

" config for diffs
set diffopt=filler,context:10
highlight DiffAdd     term=reverse ctermbg=green ctermfg=black
highlight DiffChange  term=reverse ctermbg=cyan  ctermfg=black
highlight DiffText    term=reverse ctermbg=gray  ctermfg=black
highlight DiffDelete  term=reverse ctermbg=red   ctermfg=black

nmap dl :diffget LO<CR>
nmap dr :diffget RE<CR>
nmap db :diffget BA<CR>

" Session Config
let g:session_autosave = 'no'
let g:session_autoload = 'no'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" TagHighlight Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! UpdateCScopeDB call UpdateCScopeDB()
function! UpdateCScopeDB()
    call jobstart(['bash', '-c',
        \'echo "using directory: $(pwd)";' .
        \'echo "populating source file list...";' .
        \'if [ -f cscope_dirs ]; then ' .
        \'    rm source_files;' .
        \'    for dir in $(cat cscope_dirs); do ' .
        \'        find $dir/ -iname "*.[chsSv]" -o -iname "*.inc" -o -iname "*.vh" >> source_files;' .
        \'    done;' .
        \'else ' .
        \'    find $(pwd) -iname "*.[chsSv]" -o -iname "*.inc" -o -iname "*.vh" > source_files;' .
        \'fi;' .
        \'echo "building csope database...";' .
        \'cscope -b -i source_files -k'
        \], {'on_stdout':function('OnCScopeEvent'),
        \    'on_stderr':function('OnCScopeEvent'),
        \    'on_exit':function('OnCScopeEvent')})
endfunction

function! OnCScopeEvent(job_id, data, event)
    if a:event == 'stdout' || a:event == 'stderr'
        echom ''.join(a:data)
    else
        set nocscopeverbose " suppress 'duplicate connection' error
        cs add cscope.out
        cs reset
        set cscopeverbose
    endif
endfunction

function! PostDBUpdate()
    redraw!
endfunction

if ! exists('g:TagHighlightSettings')
    let g:TagHighlightSettings = {}
endif
"let g:TagHighlightSettings['ForcedPythonVariant'] = 'if_pyth'
let g:TagHighlightSettings['PreUpdateHooks'] = [ 'UpdateCScopeDB' ]
let g:TagHighlightSettings['PostUpdateHooks'] = [ 'PostDBUpdate' ]

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Nerdtree Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <C-n> :NERDTreeToggle<CR>
map <C-m> :NERDTreeMirror<CR>

let g:NERDTreeWinPos = "right"

" Close all open buffers on entering a window if the only
" buffer that's left is the NERDTree buffer
function! s:CloseIfOnlyNerdTreeLeft()
  if exists("t:NERDTreeBufName")
    if bufwinnr(t:NERDTreeBufName) != -1
      if winnr("$") == 1
        q
      endif
    endif
  endif
endfunction
autocmd WinEnter * call s:CloseIfOnlyNerdTreeLeft()

" Mirror NERDTree on entry to a new tab
"function! s:NewTabMirrorNerdTree()
  "if exists("t:NERDTreeBufName")
  "NERDTreeMirror
  "endif
"endfunction
"autocmd TabNewEntered * call s:NewTabMirrorNerdTree()

" enable safe project specific configs
set exrc
set secure
