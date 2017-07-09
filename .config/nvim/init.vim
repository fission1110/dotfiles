call pathogen#infect()
"let $NVIM_TUI_ENABLE_TRUE_COLOR=1
let $TERM="screen-256color"
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set nowrap	"Don't wrap long lines
set hidden	"Hide edited buffers rather than quit them

set clipboard+=unnamedplus

set smartindent	"When creating a new line in a block it will put the cursor in the correct place
set autoindent	"When creating a new line in a block it will put the cursor in the correct place
set tabstop=4
set shiftwidth=4

let mapleader="," "Set the leader key

syntax on
filetype plugin on

set nu "Show line numbers
set fileencodings=utf-8 "Force utf8

"stop stupid .swp files from showing up ever. If you need them, they're in
"/tmp
set backupdir=/tmp,.
set directory=/tmp,.
nmap <leader>r :redraw!<CR>jk

" Semi colon aliased to :
nnoremap ; :

"Go back and go forward
nnoremap { <C-O>
nnoremap } <C-i>

"w!! will now sudo write the file
cmap w!! w !sudo tee % >/dev/null

" This doesn't seem to work in nvim
"vmap <leader>y "+y 
"vmap <leader>y "+p

""""" EASY GREP STUFF """"""""
nmap <C-f> :Grep 
"let g:EasyGrepDefaultUserPattern='*.php *.ctp *.js *.po'
let g:EasyGrepFileAssociations=$HOME+'/nvim/bundle/EasyGrep/plugin/EasyGrepFileAssociations'
let g:EasyGrepMode=2
let g:EasyGrepCommand=1
let g:EasyGrepRecursive=1
let g:EasyGrepSearchCurrentBufferDir=0
let g:EasyGrepIgnoreCase=1
let g:EasyGrepHidden=0
let g:EasyGrepFilesToExclude='main.js *webroot/js/languages'
let g:EasyGrepAllOptionsInExplorer=1
let g:EasyGrepWindow=0
let g:EasyGrepReplaceWindowMode=2
let g:EasyGrepOpenWindowOnMatch=1
let g:EasyGrepEveryMatch=0
let g:EasyGrepJumpToMatch=0
let g:EasyGrepInvertWholeWord=0
let g:EasyGrepFileAssociationsInExplorer=0
let g:EasyGrepExtraWarnings=1
let g:EasyGrepOptionPrefix='<leader>vy'
let g:EasyGrepReplaceAllPerFile=0


" Easily jump around windows
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" ,ee will run the file
au FileType sh nmap <leader>ee :exec '!bash' shellescape(@%, 1)<cr>

au FileType c nmap <leader>ee :exec '!gcc -o test ' shellescape(@%, 1)<cr> :exec '!./test'<cr>
au FileType c nmap <leader>ei :exec '!gcc -g -o test ' shellescape(@%, 1)<cr> :exec '!gdb ./test'<cr>

au FileType php nmap <leader>ee :VdebugStart<cr>

au FileType mysql nmap <leader>ee :exec '!mysql -u root -ppassword < ' shellescape(@%, 1)<cr>
au FileType postgres nmap <leader>ee :exec '!postgres -u root -ppassword < ' shellescape(@%, 1)<cr>

au FileType sql set ft=mysql

"Set ft=messages when file is called messages
autocmd BufNewFile,BufReadPost *messages* :set filetype=messages

" Use systags with c
autocmd  FileType  c setlocal tags+=~/nvim/systags

"#############Nerdtree stuff#############
autocmd VimEnter * NERDTree
autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd p
let g:NERDTreeWinSize = 40
let g:NERDTreeWinPos = "left"
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

function! NERDTreeQuit()
  redir => buffersoutput
  silent buffers
  redir END
"                     1BufNo  2Mods.     3File           4LineNo let pattern = '^\s*\(\d\+\)\(.....\) "\(.*\)"\s\+line \(\d\+\)$'
  let windowfound = 0

  for bline in split(buffersoutput, "\n")
    let m = matchlist(bline, pattern)

    if (len(m) > 0)
      if (m[2] =~ '..a..')
        let windowfound = 1
      endif
    endif
  endfor

  if (!windowfound)
    quitall
  endif
endfunction
"autocmd WinEnter * call NERDTreeQuit()


" HEX MODE!!
nmap <leader>hh :%!xxd<cr>
nmap <leader>hu :%!xxd -r<cr>

"turn on html snippets in php files
au BufRead *.php set ft=php
au BufNewFile *.php set ft=php

"turn on html snippets in cake template files
au BufRead *.ctp set ft=php.html
au BufNewFile *.ctp set ft=php.html

" If 1, losen the restrictions on ctags to include c, c++, etc files..
nmap <f9> :call Findctags(0)<CR>
nmap <f10> :call Updatectags(1)<CR>
nmap <f12> :call Updatectags(0)<CR>

function! Updatectags(more)
    echo "Updating more Ctags!"
	" If more, losen the restrictions on ctags to include c, c++, etc files..
	if a:more
		execute "!~/nvim/ctags/ctags_update_more.sh"
	else
		execute "!~/nvim/ctags/ctags_update.sh"
	endif
   	let cwd = getcwd()."/main"
	let ctags_file = $HOME . "/nvim/mytags"
    let  &tags = ctags_file.cwd
endfunction

function! Findctags(silent)
    if a:silent == 0
        echo "Finding Ctags!"
    endif
   	let cwd = getcwd().""
	let ctags_file = $HOME . "/nvim/ctags/mytags"
    let ctags_path = ctags_file.cwd."/"
    let loopcount = 0
    while !filereadable(ctags_path."main") && loopcount < 10
        let ctags_path = substitute(ctags_path, '[^\/]\{-}\/$', '', '')
		if a:silent == 0
			echo "looking in: ".ctags_path."main"
		endif
        let loopcount = loopcount + 1
    endwhile
    if a:silent == 0
        echo ctags_path."main"
    endif
    let  &tags = ctags_path."main"
endfunction

"#############Ctrlp#############
let g:ctrlp_working_path_mode = ''
nnoremap <c-t> :CtrlPTag<cr>
exec Findctags(1)
"ctrlp prompt remap to match nerdtree's
let g:ctrlp_prompt_mappings = {
\ 'AcceptSelection("v")': ['<c-s>','<c-v>', '<RightMouse>'],
\ 'AcceptSelection("h")': ['<c-i>','<c-x>', '<c-cr>'],
\ }
" you can add additional root markers, but we arent letting ctrlp manage our
" working path..
" let g:ctrlp_root_markers = ['webroot']
let g:ctrlp_max_files=0

let g:ycm_key_list_select_completion = ['<Enter>', '<Down>']
let g:ycm_collect_identifiers_from_tags_files = 1

au FileType php set omnifunc=phpcomplete#CompletePHP

"au FileType php set completefunc=phpcomplete#CompletePHP
inoremap <C-l> <C-x><C-o>

let g:ycm_semantic_triggers =  {
  \   'c' : ['->', '.'],
  \   'objc' : ['->', '.', 're!\[[_a-zA-Z]+\w*\s', 're!^\s*[^\W\d]\w*\s',
  \             're!\[.*\]\s'],
  \   'ocaml' : ['.', '#'],
  \   'cpp,objcpp' : ['->', '.', '::'],
  \   'perl' : ['->'],
  \   'cs,java,javascript,typescript,d,python,perl6,scala,vb,elixir,go' : ['.'],
  \   'ruby' : ['.', '::'],
  \   'lua' : ['.', ':'],
  \   'erlang' : [':'],
  \ }
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:phpcomplete_complete_for_unknown_classes = 0



let g:ycm_autoclose_preview_window_after_insertion = 0
let g:phpcomplete_complete_for_unknown_classes = 0

let g:vdebug_options = {
\    "port" : 9000,
\    "server" : '',
\    "timeout" : 20,
\    "on_close" : 'detach',
\    "break_on_open" : 0,
\    "ide_key" : '',
\    "path_maps" : {'/gui' : '/var/www/atpsa-develop/gui'},
\    "debug_window_level" : 0,
\    "debug_file_level" : 0,
\    "debug_file" : "",
\    "watch_window_style" : 'expanded',
\    "marker_default" : '⬦',
\    "marker_closed_tree" : '▸',
\    "marker_open_tree" : '▾'
\}
let g:vdebug_keymap = {
\    "run" : "<F5>",
\    "run_to_cursor" : "<Enter>",
\    "step_over" : "<Down>",
\    "step_into" : "<Right>",
\    "step_out" : "<Left>",
\    "close" : "<ESC>",
\    "detach" : "q",
\    "set_breakpoint" : "<leader>m",
\    "get_context" : "<F11>",
\    "eval_under_cursor" : "<F12>",
\    "eval_visual" : "<Leader>ee",
\}
let g:vdebug_features = {'max_depth': 10}


"#############Python Stuff#############
"execute python, then drop to the interpreter
au FileType python nmap <leader>ei :exec '!ipython -i' shellescape(@%, 1)<cr>
"execute python
au FileType python nmap <leader>ee :exec '!ipython' shellescape(@%, 1)<cr>

au FileType python setlocal smartindent
au FileType python setlocal tabstop=4
au FileType python setlocal shiftwidth=4
au FileType python setlocal expandtab

let g:jellybeans_use_lowcolor_black = 0

"Search: green bg grey fg underline
"Identifier(varibles): light deep blue fg
"DbgBreakptLine: green bg grey  fg
"Statement: bluegreen foreground
let g:jellybeans_overrides = {
\    'Search': { 'guifg': '1c1c1c', 'guibg': '99ad6a',
\              'ctermfg': 'Magenta', 'ctermbg': '',
\              'attr': 'underline' },
\    'Identifier': { 'guifg': '5B79BA', 'guibg': '',
\              'ctermfg': 'LightCyan', 'ctermbg': '',
\              'attr': '' },
\    'DbgBreakptLine': { 'guifg': '1c1c1c', 'guibg': '99ad6a',
\              'ctermfg': '1c1c1c', 'ctermbg': '99ad6a',
\              'attr': '' },
\    'Statement': { 'guifg': '447799', 'guibg': '',
\              'ctermfg': '447799', 'ctermbg': '',
\              'attr': '' },
\}


set background=dark
colorscheme jellybeans

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

"change the statusline highlighted background color to black
"
hi StatusLine gui=none guibg=DarkGrey cterm=none ctermbg=DarkGrey
hi Normal gui=none guibg=none cterm=none ctermbg=none
hi NonText gui=none guibg=none  cterm=none ctermbg=none
