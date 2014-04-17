"#############defaults#############
set ttyfast
syntax on
filetype plugin on
let mapleader=","
"line numbers
set nu
set fileencodings=utf-8
set hidden
set nowrap
set smartindent
set smartcase
set tabstop=4
set shiftwidth=4
"set expandtab
set hlsearch
set incsearch
set updatecount=50
"stop stupid .swp files from showing up ever. If you need them, they're in
"/tmp
set backupdir=/tmp,.
set directory=/tmp,.
"change ; into a :
nnoremap ; :
nnoremap { <C-O>
nnoremap } <C-i>
"This lets you use w!! to do that after you opened the file already
cmap w!! w !sudo tee % >/dev/null
set cryptmethod=blowfish

nmap <leader>r :redraw!<CR>
"yank into clipboard leader shortcut
vmap <leader>y "+y
"put into clipboard leader shortcut
vmap <leader>y "+p
"Grep
nmap <leader>g :Grep 
nmap <C-f> :Grep 

" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l



"#############Omni-Complete#############
" Omnicomplete to ctrl + F
"imap <C-f> <C-x><C-o>

" Omnicomplete sass files
autocmd BufNewFile,BufRead *.scss set ft=scss.css

"turn on omnicompletion
set omnifunc=syntaxcomplete#Complete
"special omnicompletion for c
autocmd  FileType  php setlocal omnifunc=phpcomplete#CompletePHP

autocmd  FileType  c setlocal tags+=~/.vim/systags

"automatically write the longest common text
"show menu even if there's only one item
set completeopt=longest,menuone

"Push enter when the selected one is highlighted
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

"allows you to complete as you type
inoremap <expr> <C-n> pumvisible() ? '<C-n>' : '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
inoremap <expr> <C-f> pumvisible() ? '<C-n>' : '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
"inoremap <expr> <M-,> pumvisible() ? '<C-n>' : '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'




" Remember things between sessions
"
" '20  - remember marks for 20 previous files
" \"50 - save 50 lines for each register
" :20  - remember 20 items in command-line history 
" %    - remember the buffer list (if vim started without a file arg) " n    - set name of viminfo file
set viminfo='20,\"50,:20,%,n~/.viminfo


"#############Python Stuff#############
"execute python, then drop to the interpreter
nnoremap <buffer> <leader>ei :exec '!ipython -i' shellescape(@%, 1)<cr>
"execute python
nnoremap <buffer> <leader>ee :exec '!ipython' shellescape(@%, 1)<cr>
au FileType python setlocal smartindent
au FileType python setlocal tabstop=4
au FileType python setlocal shiftwidth=4
au FileType python setlocal expandtab

" Generic highlight changes
"highlight Comment cterm=none ctermfg=Gray
"highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
"highlight IncSearch cterm=none ctermfg=Black ctermbg=DarkYellow
"highlight Search cterm=none ctermfg=Black ctermbg=DarkYellow
"highlight String cterm=none ctermfg=DarkGreen
"highlight treeDir cterm=none ctermfg=Cyan
"highlight treeUp cterm=none ctermfg=DarkYellow
"highlight treeCWD cterm=none ctermfg=DarkYellow
"highlight netrwDir cterm=none ctermfg=Cyan


"set the colorscheme for gvim
if has("gui_running")
	colorscheme desert
endif


"#############Pathogen Stuff#############
call pathogen#infect() 

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

"#############Snippets#############

"turn on html snippets in php files
au BufRead *.php set ft=php
au BufNewFile *.php set ft=php

"turn on html snippets in cake template files
au BufRead *.ctp set ft=php.html
au BufNewFile *.ctp set ft=php.html

" If 1, losen the restrictions on ctags to include c, c++, etc files..
nmap <f12> :call Updatectags(1)<CR>
nmap <f10> :call Updatectags(0)<CR>

function! Updatectags(more)
    echo "Updating more Ctags!"
	" If more, losen the restrictions on ctags to include c, c++, etc files..
	if a:more
		execute "!"+$HOME+"/.vim/ctags/ctags_update_more.sh"
	else
		execute "!"+$HOME+"/.vim/ctags/ctags_update.sh"
	endif
   	let cwd = getcwd()."/main"
	let ctags_file = "/home/ryan/.vim/mytags"
    let  &tags = ctags_file.cwd
endfunction

nmap <f9> :call Findctags(0)<CR>
function! Findctags(silent)
    if a:silent == 0
        echo "Finding Ctags!"
    endif
   	let cwd = getcwd().""
	let ctags_file = "/home/ryan/.vim/mytags"
    let ctags_path = ctags_file.cwd."/"
    let loopcount = 0
    while !filereadable(ctags_path."main") && loopcount < 10
        let ctags_path = substitute(ctags_path, '[a-zA-Z]*\/$', '', '')
		if a:silent == 0
			echo "looking in".ctags_path
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

"#############PHP QA#############
let g:phpqa_messdetector_ruleset = "/path/to/phpmd.xml"
let g:phpqa_codesniffer_args = "--standard=SoleraUI"

" Don't run messdetector on save (default = 1)
let g:phpqa_messdetector_autorun = 0

" Don't run codesniffer on save (default = 1)
let g:phpqa_codesniffer_autorun = 1

" Show code coverage on load (default = 0)
let g:phpqa_codecoverage_autorun = 0

" Stop the location list opening automatically
"let g:phpqa_open_loc = 0

" Clover code coverage XML file
let g:phpqa_codecoverage_file = "/path/to/clover.xml"
" Show markers for lines that ARE covered by tests (default = 1)
let g:phpqa_codecoverage_showcovered = 0

"#############EasyGrep#############
"


"let g:EasyGrepDefaultUserPattern='*.php *.ctp *.js *.po'
let g:EasyGrepFileAssociations=$HOME+'/.vim/bundle/EasyGrep/plugin/EasyGrepFileAssociations'
let g:EasyGrepMode=2
let g:EasyGrepCommand=1
let g:EasyGrepRecursive=1
let g:EasyGrepSearchCurrentBufferDir=0
let g:EasyGrepIgnoreCase=1
let g:EasyGrepHidden=0
let g:EasyGrepFilesToExclude=''
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

"#############PHP folding#############
let g:php_folding=1
set foldmethod=syntax

"#############javascript folding#############
au FileType javascript call JavaScriptFold()

"#############html folding#############
au FileType html set foldmethod=indent
"au FileType html let fld=1

"#############Everything else folding#############
au FileType !html set foldmethod=syntax
"au FileType !html let fld=2
au FileType gitcommit set foldmethod=manual

"disable folds on default
set foldlevelstart=20
set foldlevel=20
set nofoldenable
au FileType c set foldnestmax=1


"#############Taglist#############
"Remap string to s, array to a, etc
let g:tlist_javascript_settings = 'javascript;s:string;a:array;o:object;f:function'
nmap <leader>t :Tlist<cr>
"let Tlist_Inc_Winwidth=0
"
"Some mouse stuff
set mouse+=a
if &term =~ '^screen'
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
endif
"jshint2
let jshint2_command = '/usr/local/bin/jshint'

"#############phpcomplete#############
let g:phpcomplete_search_tags_for_variables = 1

"colorscheme needs to come after pathogen infect
colorscheme jellybeans
"change the statusline highlighted background color to black
hi StatusLine cterm=none ctermbg=Black

"#############Localization!#############

"Force utf8
set fileencodings=utf-8

"Use unix line endings
au FileType po set fileformat=unix

"No BOM character
set nobomb

"Redraw on insert to be sure to catch any changes in highlight
au InsertLeave * redraw!

"Ignore whitespace for the diffs
au FileType po set diffopt+=iwhite

"Only search changed (AKA: unfolded) text
au Filetype po set fdo-=search

"Highlight Search White Background, with Black Forground
highlight Search ctermbg=white ctermfg=black 



"I want the search screen to be in variables :/
"
"let re_sqrbr='\[.\{-}\]' "Anything enclosed in [] --To be CHECKED
"let re_crlbr='{.\{-}}' "Anything encloded in {} should not be localized --To Be CHECKED
"let re_str='%\w'  "Any %s should not be localized --To Be CHECKED
"let re_per='%\S\{-}%' "Anything enclosed in %% should not be localized --To Be CHECKED
"let re_colon=':\w\{1,}' "Any :command should not be localized --To Be CHECKED
"let re_newlns='\n\n\n' "Avoid tripple newlines --To Be REMOVED
"let re_trlwhtspc='\s\+$' "Avoid trailing whitespace --To Be REMOVED
"let re_html='<.\{-}>' "HTML should not be localized --To Be CHECKED
"let re_endnewlns='.\{1,}\%$' "You should have two \n at end of file  --To Be REMOVED
"let re_quotes='".\{-}\\\@<!".\{-}"$' "Inline unescaped quotes --To Be REMOVED
"let re_badesc='\\[\\ntru\'"]\@!' "Incorrectly escaped character --To Be REMOVED
"let re_endquote='\\"$' "Escaping the final quote --To Be REMOVED
"let re_bom='﻿\\|ufeff'  "Some BOM chars --To Be REMOVED
"let re_quotewhtspc='msgstr"\\|msgid"' "No Whitespace after msgstr or msgid --To Be REMOVED
"let re_sep='\\|'
"let g:re_all=re_sqrbr + re_sep + re_crlbr + re_sep + re_str + re_sep + re_per + re_sep + re_colon + re_sep + re_newlns + re_sep + re_trlwhtspc + re_sep + re_html + re_sep + re_endnewlns + re_sep + re_quotes + re_sep + re_badesc + re_sep + re_endquote + re_sep + re_bom + re_sep + re_quotewhtspc 
"
"
" Localization Find!:
"
" To Be CHECKED -- These match on GOOD results as well as BAD results.
" To Be REMOVED -- These SHOULD* match on BAD results.
"
" * Sometimes false positive
"
"\[.\{-}\] Anything enclosed in [] --To be CHECKED
"{.\{-}} Anything encloded in {} should not be localized --To Be CHECKED
"%\w  Any %s should not be localized --To Be CHECKED
"%\S\{-}% Anything enclosed in %% should not be localized --To Be CHECKED
":\w\{1,} Any :command should not be localized --To Be CHECKED
"\n\n\n Avoid tripple newlines --To Be REMOVED
"\s\+$ Avoid trailing whitespace --To Be REMOVED
"<.\{-}> HTML should not be localized --To Be CHECKED
".\{1,}\%$ You should have two \n at end of file  --To Be REMOVED
"".\{-}\\\@<!".\{-}"$ Inline unescaped quotes --To Be REMOVED
"\\[\\ntru'"]\@! Incorrectly escaped character --To Be REMOVED
"\\"$ Escaping the final quote --To Be REMOVED
"﻿\\|ufeff  Some BOM chars --To Be REMOVED
"msgstr"\\|msgid" No Whitespace after msgstr or msgid --To Be REMOVED
au FileType po nmap <leader>lf /\[.\{-}\]\\|{.\{-}}\\|%\w\\|%\S\{-}%\\|:\w\{1,}\\|\n\n\n\\|\s\+$\\|<.\{-}>\\|.\{1,}\%$\\|msgstr\s\{-}".\{-}\\\@<!".\{-}"$\\|\\[\\ntru'"]\@!\\|\\"$\\|﻿\\|ufeff\\|msgstr"\\|msgid"/<cr>




"Localization Mode!:
"
"Open Gdiff HEAD, and enter the default search pattern
"Note: This cannot be started as autocmd, because Gdiff has some
"hooks that determines if a thing is a git repo before loading.. I can't
"figure out how to hook after gdiff has loaded ..
"
au FileType po nmap <leader>ll :Gdiff HEAD<cr>,lf

"Localiztion start!!
"
" Runs Gstatus, searches for the firlst Locale result, opens it, runs
" localization mode
nmap <leader>ls :Gstatus<cr>/Locale<cr><cr>,ll

" Localization English
"Compare with the english translation
au FileType po nmap <leader>lee <C-h>:q<cr><C-k>0/LC_MESSAGES<cr>eelv$"zy<C-j>:Gdiff gui/dsweb/Locale/eng/LC_MESSAGES/<C-r>z<BS><cr>,lf

"WARNING!! THIS IS A HACK: Dependant on window configuration!
"You should have Gstatus up top, and a fugitive buffer to the left.
"THIS WILL QUIT AND SAVE ARBITRARY BUFFERS
"
"Writes, goes to the buffer to the left, quits, goes to the buffer above, goes
"to the next entry, opens it, runs localization mode
"Depends on my window jumping shortcuts
au FileType po nmap <leader>ln :w<cr><C-h>:q<cr><C-k>j<cr>,ll
au FileType po nmap <leader>lp :w<cr><C-h>:q<cr><C-k>k<cr>,ll
au FileType po nmap <leader>len :w<cr><C-h>:q<cr><C-k>j<cr>,ll,lee
au FileType po nmap <leader>lep :w<cr><C-h>:q<cr><C-k>k<cr>,ll,lee

"Delete the inside of the non localized variable, switch to the left window,
"grab that variable, and put it into the left window location
au FileType po nmap <leader>lib dt}ml<C-h>yi{<C-l>`lhp


"make yank add to the system clipboard
set clipboard=unnamedplus
