" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
autoload/EchoWithoutScrolling.vim	[[[1
272
" EchoWithoutScrolling.vim: :echo overloads that truncate to avoid the hit-enter
" prompt. 
"
" DESCRIPTION:
"   When using the :echo or :echomsg commands with a long text, Vim will show a
"   'Hit ENTER' prompt (|hit-enter|), so that the user has a chance to actually
"   read the entire text. In most cases, this is good; however, some mappings
"   and custom commands just want to echo additional, secondary information
"   without disrupting the user. Especially for mappings that are usually
"   repeated quickly "/foo<CR>, n, n, n", a hit-enter prompt would be highly
"   irritating. 
"   This script provides :echo[msg]-alike functions which truncate lines so that
"   the hit-enter prompt doesn't happen. The echoed line is too long if it is
"   wider than the width of the window, minus cmdline space taken up by the
"   ruler and showcmd features. The non-standard widths of <Tab>, unprintable
"   (e.g. ^M) and double-width characters (e.g. Japanese Kanji) are taken into
"   account. 

" USAGE:
" INSTALLATION:
" DEPENDENCIES:
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
"  - EchoWithoutScrolling#RenderTabs(): The assumption index == char width
"    doesn't work for unprintable ASCII and any non-ASCII characters. 
"
" TODO:
"   - Consider 'cmdheight', add argument isSingleLine. 
"
" Copyright: (C) 2008-2009 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	003	15-May-2009	Added utility function
"				EchoWithoutScrolling#TranslateLineBreaks() to
"				help clients who want to echo a single line, but
"				have text that potentially contains line breaks. 
"	002	16-Aug-2008	Split off TruncateTo() from Truncate(). 
"	001	22-Jul-2008	file creation

function! EchoWithoutScrolling#MaxLength()
    let l:maxLength = &columns

    " Account for space used by elements in the command-line to avoid
    " 'Hit ENTER' prompts.
    " If showcmd is on, it will take up 12 columns.
    " If the ruler is enabled, but not displayed in the status line, it
    " will in its default form take 17 columns.  If the user defines
    " a custom &rulerformat, they will need to specify how wide it is.
    if has('cmdline_info')
	if &showcmd == 1
	    let l:maxLength -= 12
	else
	    let l:maxLength -= 1
	endif
	if &ruler == 1 && has('statusline') && ((&laststatus == 0) || (&laststatus == 1 && winnr('$') == 1))
	    if &rulerformat == ''
		" Default ruler is 17 chars wide. 
		let l:maxLength -= 17
	    elseif exists('g:rulerwidth')
		" User specified width of custom ruler. 
		let l:maxLength -= g:rulerwidth
	    else
		" Don't know width of custom ruler, make a conservative
		" guess. 
		let l:maxLength -= &columns / 2
	    endif
	endif
    else
	let l:maxLength -= 1
    endif
    return l:maxLength
endfunction

function! s:ReverseStr( expr )
    return join( reverse( split( a:expr, '\zs' ) ), '' )
endfunction
function! s:HasMoreThanVirtCol( expr, virtCol )
    return (match( a:expr, '^.*\%>' . a:virtCol . 'v' ) != -1)
endfunction
function! EchoWithoutScrolling#DetermineVirtColNum( expr )
    let i = 1
    while 1
	if ! s:HasMoreThanVirtCol( a:expr, i )
	    return i - 1
	endif
	let i += 1
    endwhile
endfunction
function! s:VirtColStrFromStart( expr, virtCol )
    " Must add 1 because a "before-column" pattern is used in case the exact
    " column cannot be matched (because its halfway through a tab or other wide
    " character). 
    return matchstr(a:expr, '^.*\%<' . (a:virtCol + 1) . 'v')
endfunction
function! s:VirtColStrFromEnd( expr, virtCol )
    " Virtual columns are always counted from the start, not the end. To specify
    " the column counting from the end, the string is reversed during the
    " matching. 
    return s:ReverseStr( s:VirtColStrFromStart( s:ReverseStr(a:expr), a:virtCol ) )
endfunction

function! EchoWithoutScrolling#GetTabReplacement( column, tabstop )
    return a:tabstop - (a:column - 1) % a:tabstop
endfunction
function! EchoWithoutScrolling#RenderTabs( text, tabstop, startColumn )
"*******************************************************************************
"* PURPOSE:
"   Replaces <Tab> characters in a:text with the correct amount of <Space>,
"   depending on the a:tabstop value. a:startColumn specifies at which start
"   column a:text will be printed. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:text	    Text to be rendered. 
"   a:tabstop	    tabstop value (The built-in :echo command always uses a
"		    fixed value of 8; it isn't affected by the 'tabstop'
"		    setting.)
"   a:startColumn   Column at which the text is to be rendered (typically 1). 
"* RETURN VALUES: 
"   a:text with replaced <Tab> characters. 
"*******************************************************************************
    if a:text !~# "\t"
	return a:text
    endif

    let l:pos = 0
    let l:text = a:text
    while l:pos < strlen(l:text)
	" FIXME: The assumption index == char width doesn't work for unprintable
	" ASCII and any non-ASCII characters. 
	let l:pos = stridx( l:text, "\t", l:pos )
	if l:pos == -1
	    break
	endif
	let l:text = strpart( l:text, 0, l:pos ) . repeat( ' ', EchoWithoutScrolling#GetTabReplacement( l:pos + a:startColumn, a:tabstop ) ) . strpart( l:text, l:pos + 1 )
    endwhile
    
    return l:text
endfunction

function! EchoWithoutScrolling#TruncateTo( text, length ) 
"*******************************************************************************
"* PURPOSE:
"   Truncate a:text to a maximum of a:length virtual columns. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:text	Text which may be truncated to fit. 
"   a:length	Maximum virtual columns for a:text. 
"* RETURN VALUES: 
"   None. 
"*******************************************************************************
    if a:length <= 0
	return ''
    endif

    " The \%<23v regexp item uses the local 'tabstop' value to determine the
    " virtual column. As we want to echo with default tabstop 8, we need to
    " temporarily set it up this way. 
    let l:save_ts = &l:tabstop
    setlocal tabstop=8

    let l:text = a:text
    try
	if s:HasMoreThanVirtCol(l:text, a:length)
	    " We need 3 characters for the '...'; 1 must be added to both lengths
	    " because columns start at 1, not 0. 
	    let l:frontCol = a:length / 2
	    let l:backCol  = (a:length % 2 == 0 ? (l:frontCol - 1) : l:frontCol)
"**** echomsg '**** ' a:length ':' l:frontCol '-' l:backCol
	    let l:text =  s:VirtColStrFromStart(l:text, l:frontCol) . '...' . s:VirtColStrFromEnd(l:text, l:backCol)
	endif
    finally
	let &l:tabstop = l:save_ts
    endtry
    return l:text
endfunction
function! EchoWithoutScrolling#Truncate( text, ... ) 
"*******************************************************************************
"* PURPOSE:
"   Truncate a:text so that it can be echoed to the command line without causing
"   the "Hit ENTER" prompt (if desired by the user through the 'shortmess'
"   option). Truncation will only happen in (the middle of) a:text. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:text	Text which may be truncated to fit. 
"   a:reservedColumns	Optional number of columns that are already taken in the
"			line; if specified, a:text will be truncated to
"			(MaxLength() - a:reservedColumns). 
"* RETURN VALUES: 
"   Truncated a:text. 
"*******************************************************************************
    if &shortmess !~# 'T'
	" People who have removed the 'T' flag from 'shortmess' want no
	" truncation. 
	return a:text
    endif

    let l:reservedColumns = (a:0 > 0 ? a:1 : 0)
    let l:maxLength = EchoWithoutScrolling#MaxLength() - l:reservedColumns

    return EchoWithoutScrolling#TruncateTo( a:text, l:maxLength )
endfunction

function! EchoWithoutScrolling#Echo( text ) 
    echo EchoWithoutScrolling#Truncate( a:text )
endfunction
function! EchoWithoutScrolling#EchoWithHl( highlightGroup, text ) 
    if ! empty(a:highlightGroup)
	execute 'echohl' a:highlightGroup
    endif
    echo EchoWithoutScrolling#Truncate( a:text )
    echohl None
endfunction
function! EchoWithoutScrolling#EchoMsg( text ) 
    echomsg EchoWithoutScrolling#Truncate( a:text )
endfunction
function! EchoWithoutScrolling#EchoMsgWithHl( highlightGroup, text ) 
    if ! empty(a:highlightGroup)
	execute 'echohl' a:highlightGroup
    endif
    echomsg EchoWithoutScrolling#Truncate( a:text )
    echohl None
endfunction

function! EchoWithoutScrolling#TranslateLineBreaks( text )
"*******************************************************************************
"* PURPOSE:
"   Translate embedded line breaks in a:text into a printable characters to
"   avoid that a single-line string is split into multiple lines (and thus
"   broken over multiple lines or mostly obscured) by the :echo command and
"   EchoWithoutScrolling#Echo() functions. 
"
"   For the :echo command, strtrans() is not necessary; unprintable characters
"   are automatically translated (and shown in a different highlighting, an
"   advantage over indiscriminate preprocessing with strtrans()). However, :echo
"   observes embedded line breaks (in contrast to :echomsg), which would mess up
"   a single-line message that contains embedded \n = <CR> = ^M or <LF> = ^@. 
"
"   For the :echomsg and :echoerr commands, neither strtrans() nor this function
"   are necessary; all translation is done by the built-in command. 
"
"* LIMITATIONS:
"   When :echo'd, the translated line breaks are not rendered with the typical
"   'SpecialKey' highlighting. 
" 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:text	Text. 
"* RETURN VALUES: 
"   Text with translated line breaks; the text will :echo into a single line. 
"*******************************************************************************
    return substitute(a:text, "[\<CR>\<LF>]", '\=strtrans(submatch(0))', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
autoload/LogViewer.vim	[[[1
372
" LogViewer.vim: Comfortable examination of multiple parallel logfiles.
"
" DEPENDENCIES:
"   - EchoWithoutScrolling.vim autoload script

" Copyright: (C) 2011-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.005	01-Aug-2012	Clear the collective summary when no syncing was
"				done; keeping the previous summary around is
"				confusing.
"   1.00.004	31-Jul-2012	Print the collective summary for all moves in
"				all log buffers. Print relative line offsets
"				instead of absolute from..to line numbers; it's
"				shorter and more expressive. Since this output
"				should never interfere with cursor movement, and
"				therefore must not provoke the hit-enter prompt,
"				use EchoWithoutScrolling for it.
"	003	24-Jul-2012	Allow customization of the window where log
"				lines are synced via User autocmd.
"	002	24-Aug-2011	Implement marking of target line in master
"				buffer, correct updating when moving across
"				windows, auto-sync and manual setting of a
"				master buffer.
"	001	23-Aug-2011	file creation

let s:save_cpo = &cpo
set cpo&vim

function! s:GetTimestamp( lnum )
    let l:logTimestampExpr = (exists('b:logTimestampExpr') ? b:logTimestampExpr : '^\d\+\ze\s')
    return matchstr(getline(a:lnum), l:logTimestampExpr)
endfunction

function! s:IsLogBuffer()
    return (index(split(g:LogViewer_Filetypes, ','), &l:filetype) != -1)
endfunction

function! s:GetNextTimestamp( startLnum, offset )
    let l:lnum = a:startLnum + a:offset
    while l:lnum >= 1 && l:lnum <= line('$')
	let l:timestamp = s:GetTimestamp(l:lnum)
	if ! empty(l:timestamp)
	    return [l:lnum, l:timestamp]
	endif

	let l:lnum += a:offset
    endwhile
    return [0, '']
endfunction
function! s:Match( isBackward, targetTimestamp, currentTimestamp )
    if a:isBackward
	return a:currentTimestamp >= a:targetTimestamp
    else
	return a:currentTimestamp <= a:targetTimestamp
    endif
endfunction
let s:signStartId = 456
function! s:DummySign( isOn )
    " To avoid flickering of the sign column when all signs are temporarily
    " removed.
    if a:isOn
	execute printf('sign place %i line=1 name=LogViewerDummy buffer=%i',
	\   s:signStartId -1,
	\   bufnr('')
	\)
    else
	execute printf('sign unplace %i buffer=%i', s:signStartId - 1, bufnr(''))
    endif
endfunction
function! s:Sign( lnum, name )
    execute printf('sign place %i line=%i name=%s buffer=%i',
    \	s:signStartId + b:LogViewer_signCnt,
    \	a:lnum,
    \	a:name,
    \	bufnr('')
    \)
    let b:LogViewer_signCnt += 1
endfunction
function! s:SignClear()
    if ! exists('b:LogViewer_signCnt') | let b:LogViewer_signCnt = 0 | endif

    for l:signId in range(s:signStartId, s:signStartId + b:LogViewer_signCnt - 1)
	execute printf('sign unplace %i buffer=%i', l:signId, bufnr(''))
    endfor

    let b:LogViewer_signCnt = 0
endfunction
function! s:MarkTarget()
    call s:DummySign(1)
    call s:SignClear()
    call s:Sign(line('.'), 'LogViewerTarget')
    call s:DummySign(0)
endfunction
function! s:Mark( fromLnum, toLnum )
    " Move cursor to the final log entry.
    execute a:toLnum

    " Mark the borders of the range of log entries that fall within the time
    " range of the move to the target timestamp.

    " Signs aren't displayed in closed folds, so need to open them.
    for l:lnum in [a:fromLnum, a:toLnum]
	if foldclosed(l:lnum) != -1
	    execute l:lnum . 'foldopen'
	endif
    endfor

    let l:suffix = (a:toLnum > a:fromLnum ? 'Down' : 'Up')
    call s:DummySign(1)
    call s:SignClear()
    if a:fromLnum == a:toLnum
	call s:Sign(a:toLnum, 'LogViewerNew'   . l:suffix)
    else
	call s:Sign(a:toLnum, 'LogViewerTo'    . l:suffix)
	call s:Sign(a:fromLnum, 'LogViewerFrom'. l:suffix)
    endif
    call s:DummySign(0)
endfunction
function! s:MarkBuffer()
    if exists('b:LogViewer_fromLnum') && exists('b:LogViewer_toLnum')
	call s:Mark(b:LogViewer_fromLnum, b:LogViewer_toLnum)
    endif
endfunction
function! s:AdvanceToTimestamp( timestamp, isBackward )
    let l:summary = ''
    let l:originalLnum = line('.')
    " The current timestamp is either on the current line or above it.
    let [l:lnum, l:currentTimestamp] = s:GetNextTimestamp(l:originalLnum + 1, -1)

    let l:offset = (a:isBackward ? -1 : 1) * (s:Match(a:isBackward, a:timestamp, l:currentTimestamp) ? 1 : -1)

    let l:updatedLnum = 0
    while 1
	let [l:lnum, l:nextTimestamp] = s:GetNextTimestamp(l:lnum, l:offset)
"****D echomsg '****' l:lnum l:nextTimestamp
	if empty(l:nextTimestamp) || ! s:Match(a:isBackward, a:timestamp, l:nextTimestamp)
	    break
	endif

	let l:updatedLnum = l:lnum
    endwhile

    if l:updatedLnum > 0 && l:updatedLnum != l:originalLnum
	let b:LogViewer_fromLnum = l:originalLnum + 1
	let b:LogViewer_toLnum = l:updatedLnum

	let l:summary = printf('%s: %+d', bufname(''), (l:updatedLnum - l:originalLnum))
    endif

    " Always update the marks; the target may have changed by switching windows.
    call s:MarkBuffer()

    return l:summary
endfunction

function! s:OnSyncWin()
    " Allow customization of the window where log lines are synced.
    " For example, when the sign highlights the entire line, the 'cursorline'
    " setting should be turned off.
    silent doautocmd User LogviewerSyncWin
endfunction
function! s:SyncToTimestamp( timestamp, isBackward )
    call s:MarkTarget()
    call s:OnSyncWin()

    " Sync every buffer only once when it appears in multiple windows, to avoid
    " a 'scrollbind'-like effect and allow for research in multiple parts of the
    " same buffer.
    let l:syncedBufNrs = [bufnr('')]

    let l:summaries = []
    let l:originalWindowLayout = winrestcmd()
	let l:originalWinNr = winnr()

	    noautocmd windo
	    \	if (
	    \	    winnr() != l:originalWinNr &&
	    \	    s:IsLogBuffer() &&
	    \	    index(l:syncedBufNrs, bufnr('')) == -1
	    \	) |
	    \	    call add(l:summaries, s:AdvanceToTimestamp(a:timestamp, a:isBackward)) |
	    \	    call add(l:syncedBufNrs, bufnr('')) |
	    \       call s:OnSyncWin() |
	    \	endif

	execute 'noautocmd' l:originalWinNr . 'wincmd w'
    silent! execute l:originalWindowLayout

    if ! empty(l:summaries)
	" We have found other log buffers, print their summaries or clear the
	" last summary when no syncing was done.
	call EchoWithoutScrolling#Echo(join(filter(l:summaries, '! empty(v:val)'), '; '))
    endif
endfunction

function! LogViewer#LineSync( syncEvent )
    if ! empty(a:syncEvent) && a:syncEvent !=# g:LogViewer_SyncUpdate
	return
    endif

    if ! s:IsLogBuffer()
	" The filetype must have changed to a non-logfile.
	call s:DeinstallLogLineSync()
	return
    endif

    let l:isBackward = 0
    if exists('b:LogViewer_prevline')
	if b:LogViewer_prevline == line('.')
	    " Only horizontal cursor movement within the same line, skip processing.
	    return
	endif
	let l:isBackward = (b:LogViewer_prevline > line('.'))
    endif
    let b:LogViewer_prevline = line('.')

    let l:timestamp = s:GetTimestamp('.')
    if ! empty(l:timestamp)
	call s:SyncToTimestamp(l:timestamp, l:isBackward)
    endif
endfunction

function! s:ExprMatch( timestamp, timestampExpr )
    if a:timestamp =~# '^\d\+$'
	" Use numerical compare for integer timestamps.
	return (str2nr(a:timestamp) <= str2nr(a:timestampExpr))
    else
	return a:timestamp <=# a:timestampExpr
    endif
endfunction
function! s:FindTimestamp( timestampExpr )
    " First search from the current cursor position to the end of the buffer,
    " then wrap around.
    for [l:lnum, l:stopLnum] in [[line('.'), line('$')], [1, line('.')]]
	while 1
	    let [l:lnum, l:nextTimestamp] = s:GetNextTimestamp(l:lnum, 1)
	    if empty(l:nextTimestamp)
		break
	    elseif ! s:ExprMatch(l:nextTimestamp, a:timestampExpr)
		return l:lnum
	    elseif l:lnum >= l:stopLnum
		break
	    endif
	endwhile
    endfor

    return -1
endfunction
function! s:JumpToTimestampOffset( startLnum, offset )
    let l:lnum = a:startLnum
    for l:i in range(a:offset)
	let [l:newLnum, l:nextTimestamp] = s:GetNextTimestamp(l:lnum, 1)
	if empty(l:nextTimestamp)
	    break
	endif
	let l:lnum = l:newLnum
    endfor

    execute l:lnum
endfunction
function! LogViewer#SetTarget( timestampOffset, targetSpec )
    if ! s:IsLogBuffer()
	let v:errmsg = 'Not in log buffer'
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None

	return
    endif

    if ! empty(a:targetSpec)
	" Search for a timestamp matching the passed target specification.
	let l:lnum = s:FindTimestamp(a:targetSpec)
	if l:lnum == -1
	    let v:errmsg = 'No timestamp matching "' . a:targetSpec . '" found'
	    echohl ErrorMsg
	    echomsg v:errmsg
	    echohl None

	    return
	endif

	if a:timestampOffset != 0
	    " Apply the offset to the matched position.
	    call s:JumpToTimestampOffset(l:lnum, a:timestampOffset)
	else
	    execute l:lnum
	endif
    else
	if a:timestampOffset != 0
	    call s:JumpToTimestampOffset(
	    \   (exists('b:LogViewer_prevline') ? b:LogViewer_prevline : line('.')),
	    \   a:timestampOffset
	    \)
	endif
    endif

    call LogViewer#LineSync('')
endfunction

function! LogViewer#MasterEnter()
    " Clear away any range signs from a synced buffer, and mark the new target
    " line.
    call s:MarkTarget()
endfunction
function! LogViewer#MasterLeave()
    " Restore this as a synced buffer from the persisted data.
    call s:MarkBuffer()
endfunction

let s:masterBufnr = -1
function! s:IsMaster()
    return (s:masterBufnr == -1 || bufnr('') == s:masterBufnr)
endfunction
function! s:HasFixedMaster()
    return (s:masterBufnr != -1)
endfunction
function! LogViewer#InstallLogLineSync()
    " Sync the current log line via the timestamp to the cursor positions in all
    " other open log windows. Do this now and update when the cursor isn't
    " moved.
    call LogViewer#LineSync('')

    augroup LogViewerSync
	autocmd! * <buffer>

	" To allow dynamic changing of the sync update (without having to
	" re-apply the changed autocmds to all individual log buffers), we
	" always register for all events, and ignore non-matches inside the
	" event handler.
	autocmd CursorMoved <buffer> if <SID>IsMaster() | call LogViewer#LineSync('CursorMoved') | endif
	autocmd CursorHold  <buffer> if <SID>IsMaster() | call LogViewer#LineSync('CursorHold')  | endif

	" Handle change of master buffer containing the target timestamp.
	autocmd WinEnter <buffer> if ! <SID>HasFixedMaster() | call LogViewer#MasterEnter() | endif
	autocmd WinLeave <buffer> if ! <SID>HasFixedMaster() | call LogViewer#MasterLeave() | endif
    augroup END
endfunction
function! s:DeinstallLogLineSync()
    autocmd! LogViewerSync * <buffer>
endfunction

function! LogViewer#Master()
    call LogViewer#LineSync('')

    if g:LogViewer_SyncAll
	" Set the master buffer and ignore non-matches inside the event
	" handlers.
	let s:masterBufnr = bufnr('')
    else
	" Create the autocmds just for this master buffer.
	augroup LogViewerSync
	    " Delete all autocmds, either from a previous master buffer, or from
	    " all log buffers via the auto-sync.
	    autocmd!

	    autocmd CursorMoved <buffer> call LogViewer#LineSync('CursorMoved')
	    autocmd CursorHold  <buffer> call LogViewer#LineSync('CursorHold')

	    " The master buffer containing the target timestamp is fixed, no
	    " need to adapt when jumping around windows.
	augroup END
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
plugin/LogViewer.vim	[[[1
108
" LogViewer.vim: Comfortable examination of multiple parallel logfiles.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - LogViewer.vim autoload script
"
" Copyright: (C) 2011-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.003	24-Jul-2012	Change LogViewerTarget background highlighting
"				to LightYellow; the original Orange looks too
"				similar to my log4j syntax highlighting of WARN
"				entries.
"				Turn off 'cursorline' setting for log windows
"				participating in the sync via a newly introduced
"				LogviewerSyncWin User autocmd hook.
"	002	24-Aug-2011	Add commands for setting the master and sync
"				update method and corresponding configuration.
"	001	23-Aug-2011	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_LogViewer') || (v:version < 700)
    finish
endif
let g:loaded_LogViewer = 1

"- configuration ---------------------------------------------------------------

let s:syncUpdates = ['CursorMoved', 'CursorHold', 'Manual']
if ! exists('g:LogViewer_SyncUpdate')
    let g:LogViewer_SyncUpdate = s:syncUpdates[0]
endif
if ! exists('g:LogViewer_SyncAll')
    let g:LogViewer_SyncAll = 1
endif
if ! exists('g:LogViewer_Filetypes')
    let g:LogViewer_Filetypes = 'log4j'
endif


"- commands --------------------------------------------------------------------

" Turn off syncing in all buffers other that the current one.
command! -bar LogViewerMaster call LogViewer#Master()

" Change g:LogViewer_SyncUpdate
function! s:SetSyncUpdate( syncUpdate )
    if index(s:syncUpdates, a:syncUpdate) == -1
	let v:errmsg = printf('Invalid LogViewer sync update: "%s"; use one of %s', a:syncUpdate, join(s:syncUpdates, ', '))
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
	return
    endif

    let g:LogViewer_SyncUpdate = a:syncUpdate
endfunction
function! s:SyncUpdateComplete( ArgLead, CmdLine, CursorPos )
    return filter(copy(s:syncUpdates), 'v:val =~ (empty(a:ArgLead) ? ".*" : a:ArgLead)')
endfunction
command! -bar -nargs=1 -complete=customlist,<SID>SyncUpdateComplete LogViewerUpdate call <SID>SetSyncUpdate(<q-args>)

" Set target to current line, [count] timestamps down (from the current target
" timestamp), or the first timestamp that matches {timestamp}.
command! -bar -range=0 -nargs=? LogViewerTarget call LogViewer#SetTarget(<count>, <q-args>)


"- autocmds --------------------------------------------------------------------

if g:LogViewer_SyncAll
    augroup LogViewerAutoSync
	autocmd!
	execute 'autocmd FileType' g:LogViewer_Filetypes 'call LogViewer#InstallLogLineSync()'
    augroup END
endif

if exists('&cursorline') && ! exists('#User#LogviewerSyncWin')
    " The default sign definitions highlight the entire line. For this to have
    " the right effect, the 'cursorline' setting should be turned off.
    augroup LogViewerDefaultSyncWinActions
	autocmd! User LogviewerSyncWin if &l:cursorline | setlocal nocursorline | endif
    augroup END
endif



"- highlightings ---------------------------------------------------------------

highlight def LogViewerFrom   cterm=NONE ctermfg=NONE ctermbg=DarkBlue gui=NONE guifg=NONE guibg=LightCyan
highlight def LogViewerTo     cterm=NONE ctermfg=NONE ctermbg=Blue     gui=NONE guifg=NONE guibg=Cyan
highlight def LogViewerTarget cterm=NONE ctermfg=NONE ctermbg=Yellow   gui=NONE guifg=NONE guibg=LightYellow


"- signs -----------------------------------------------------------------------

sign define LogViewerDummy    text=.
sign define LogViewerNewUp    text=> texthl=LogViewerTo     linehl=LogViewerTo
sign define LogViewerNewDown  text=> texthl=LogViewerTo     linehl=LogViewerTo
sign define LogViewerToUp     text=^ texthl=LogViewerTo     linehl=LogViewerTo
sign define LogViewerToDown   text=V texthl=LogViewerTo     linehl=LogViewerTo
sign define LogViewerFromUp   text=- texthl=LogViewerFrom   linehl=LogViewerFrom
sign define LogViewerFromDown text=- texthl=LogViewerFrom   linehl=LogViewerFrom
sign define LogViewerTarget   text=T texthl=LogViewerTarget linehl=LogViewerTarget

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
doc/LogViewer.txt	[[[1
183
*LogViewer.txt*         Comfortable examination of multiple parallel logfiles.

			 LOGVIEWER    by Ingo Karkat
							       *LogViewer.vim*
description			|LogViewer-description|
usage				|LogViewer-usage|
installation			|LogViewer-installation|
configuration			|LogViewer-configuration|
integration			|LogViewer-integration|
limitations			|LogViewer-limitations|
known problems			|LogViewer-known-problems|
todo				|LogViewer-todo|
history				|LogViewer-history|

==============================================================================
DESCRIPTION					       *LogViewer-description*

Many applications produce multiple log files; there may be one per component
or one production log and a separate debug log, or one from the server daemon
and one from the client application. During analysis, one may need to step
through them in tandem, when one provides details that the other doesn't.
Doing this manually in split windows is tedious; 'scrollbind' usually doesn't
help because different amounts of log lines are written to each file.

As long as each log file provides a timestamp or similar monotonically
increasing field, this plugin automatically syncs the cursor movement in one
log window to all other windows. When moving to another line in the current
window, all log lines that fall in the time range covered by the movement are
highlighted automatically.

An example screenshot can be found at
    http://ingo-karkat.de/swdev/vim/LogViewer.png

SEE ALSO								     *

RELATED WORKS								     *

==============================================================================
USAGE							     *LogViewer-usage*

With the default automatic syncing, any filetype specifying a log file will
automatically set up the corresponding autocommands; without it, you need to
enable syncing via |:LogViewerMaster|. The current line in the current buffer
will be highlighted and marked with the "T" (for target) sign:
T 2012-08-01 10:01:22.342 ~

When you move to another line, the plugin will mark the synced move in other
buffers to an adjacent line like this:
  2012-08-01 10:01:22.342 ~
> 2012-08-01 10:01:23.234 ~
When the timespan in the current buffer covers multiple log lines in another
buffer, the start of the range is marked with "-" and the end of the range
with "V" (downward move) / "^" (upward move):
  2012-08-01 10:01:22.342 ~
- 2012-08-01 10:01:23.234 ~
  2012-08-01 10:01:23.250 ~
V 2012-08-01 10:01:26.012 ~

							    *:LogViewerMaster*
:LogViewerMaster	Designate the current buffer as the log master. Only
			cursor movements in this buffer will sync to other
			buffers; movements in other buffers won't affect the
			markers any more.

							    *:LogViewerUpdate*
:LogViewerUpdate CursorMoved | CursorHold | Manual
			Set the trigger for the syncing to the passed event.
			By default, each cursor movement will immediately
			update all other log buffers. With CursorHold, this
			will only happen after 'updatetime'. With Manual, it
			has to be explicitly triggered with
			|:LogViewerTarget|.

							    *:LogViewerTarget*
:LogViewerTarget	Set the target log line (the basis for the
			highlighting in all other log buffers) to the current
			line in the current buffer.
:[count]LogViewerTarget	Set the target log line to [count] timestamps down
			from the current target timestamp.
:LogViewerTarget {timestamp}
			Set the target log line to the first timestamp that
			matches {timestamp}. Useful to proceed to the
			beginning of a date when interesting things have
			happened.

==============================================================================
INSTALLATION					      *LogViewer-installation*

This script is packaged as a |vimball|. If you have the "gunzip" decompressor
in your PATH, simply edit the *.vba.gz package in Vim; otherwise, decompress
the archive first, e.g. using WinZip. Inside Vim, install by sourcing the
vimball or via the |:UseVimball| command. >
    vim LogViewer.vba.gz
    :so %
To uninstall, use the |:RmVimball| command.

DEPENDENCIES					      *LogViewer-dependencies*

- Requires Vim 7.0 or higher.

==============================================================================
CONFIGURATION					     *LogViewer-configuration*

For a permanent configuration, put the following commands into your |vimrc|:

						      *g:LogViewer_SyncUpdate*
To change the default update trigger (that can be switched via
|:LogViewerUpdate| to Manual : >
    let g:LogViewer_SyncUpdate = 'Manual'
<
							 *g:LogViewer_SyncAll*
By default, there is no master log file; movements in any log buffer cause
syncing in the other buffers. To turn that off: >
    let g:LogViewer_SyncAll = 0
You will need to use |:LogViewerMaster| on one log buffer to start the
syncing.
						       *g:LogViewer_Filetypes*
Only buffers with certain filetypes are considered log files. The setting is a
comma-separated list of filetypes (|autocmd-patterns|): >
    let g:LogViewer_Filetypes = 'log4j,syslog'
<
							  *b:logTimestampExpr*
By default, the timestamp is expected as a whitespace-separated decimal number
starting at the first column. You should define the appropriate timestamp
format for each log filetype (in |g:LogViewer_Filetypes|). Typically, this is
done in ~/.vim/after/ftplugin/{filetype}.vim. For example, the log4j timestamp
pattern corresponding to the "%d" format is: >
    let b:logTimestampExpr = '^\d\S\+\d \d\S\+\d\ze\s' " %d, e.g. 2011-08-17 13:08:30,509
To determine the chronological order, LogViewer uses a numerical compare for
integer timestamps, and case-sensitive string comparison for everything else.

							     *LogViewer-signs*
To mark the current target logline and the corresponding log line ranges in
the other log buffers, LogViewer uses |signs|:
    LogViewerTarget	The target log line at the current cursor position, or
			set via |:LogViewerTarget|
    LogViewerFrom	The (earliest when moving down towards later log
			entries) log line corresponding to the move of the
			target.
    LogViewerTo		The last log line corresponding to the move of the
			target.

You can redefine the sign definitions after the plugin/LogViewer.vim script
has been sourced, e.g.: >
    runtime plugin/LogViewer.vim
    sign define LogViewerTarget   text=T linehl=CursorLine
<
The default signs use line highlighting for a |hl-CursorLine|-like visual
indication of the positions (the 'cursorline' setting is disabled
automatically for log windows); you can define you own colors for those, too: >
    highlight LogViewerTarget gui=underline guibg=Red
<
==============================================================================
INTEGRATION					       *LogViewer-integration*

==============================================================================
LIMITATIONS					       *LogViewer-limitations*

KNOWN PROBLEMS					    *LogViewer-known-problems*

TODO							      *LogViewer-todo*

IDEAS							     *LogViewer-ideas*

- Compare and mark current lines that are identical in all logs. Keep those
  lines so that a full picture emerges when moving along.

==============================================================================
HISTORY							   *LogViewer-history*

1.00	01-Aug-2012
First published version.

0.01	23-Aug-2011
Started development.

==============================================================================
Copyright: (C) 2011-2012 Ingo Karkat
The VIM LICENSE applies to this script; see |copyright|.

Maintainer:	Ingo Karkat <ingo@karkat.de>
==============================================================================
 vim:tw=78:ts=8:ft=help:norl:
