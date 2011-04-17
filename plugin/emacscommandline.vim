" Make more like emacs
cnoremap <C-A> <Home>
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>
cnoremap <Esc>r <C-F>?
cmap <M-R> <Esc>r

" Maps to old shortcuts using Ctrl-O as a prefix
cnoremap <C-O><C-A>      <C-A>
cnoremap <C-O><C-E>      <C-E>
cnoremap <C-O><C-B>      <C-B>
cnoremap <C-O><C-F>      <C-F>
cnoremap <C-O><C-P>      <C-P>
cnoremap <C-O><C-D>      <C-D>
cnoremap <C-O><C-K>      <C-K>
cnoremap <C-O><C-U>      <C-U>
cnoremap <C-O><C-W>      <C-W>
cnoremap <C-O><C-Y>      <C-Y>
cnoremap <C-O><C-Z>      <C-Z>
cnoremap <C-O><C-_>      <C-_>
cnoremap <C-O><C-X><C-U> <C-X><C-U>
cnoremap <C-O><Del>      <Del>
cnoremap <C-O><BS>       <BS>

cnoremap <Esc>f <C-\>e<SID>ForwardWord()<CR>
cmap <M-F> <Esc>f
function! <SID>ForwardWord()
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:roc =~ '\v^\s*\w')
        let l:rem = matchstr(l:roc, '\v^\s*\w+')
    elseif (l:roc =~ '\v^\s*[^[:alnum:]_[:blank:]]')
        let l:rem = matchstr(l:roc, '\v^\s*[^[:alnum:]_[:blank:]]+')
    else
        call setcmdpos(strlen(getcmdline()) + 1)
        return getcmdline()
    endif
    call setcmdpos(strlen(l:loc) + strlen(l:rem) + 1)
    return getcmdline()
endfunction

cnoremap <Esc>b <C-\>e<SID>BackwardWord()<CR>
cmap <M-B> <Esc>b
function! <SID>BackwardWord()
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:loc =~ '\v\w\s*$')
        let l:rem = matchstr(l:loc, '\v\w+\s*$')
    elseif (l:loc =~ '\v[^[:alnum:]_[:blank:]]\s*$')
        let l:rem = matchstr(l:loc, '\v[^[:alnum:]_[:blank:]]+\s*$')
    else
        call setcmdpos(1)
        return getcmdline()
    endif
    let @c = l:rem
    call setcmdpos(strlen(l:loc) - strlen(l:rem) + 1)
    return getcmdline()
endfunction

cnoremap <Del> <C-\>e<SID>DeleteChar()<CR>
cmap <C-D> <Del>
function! <SID>DeleteChar()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd = getcmdline()
    let l:rem = strpart(l:cmd, getcmdpos() - 1, 1)
    if ('' != l:rem)
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, 0, getcmdpos() - 1) . strpart(l:cmd, getcmdpos())
    call <SID>saveUndoHistory(l:ret, getcmdpos())
    return l:ret
endfunction

cnoremap <BS> <C-\>e<SID>BackwardDeleteChar()<CR>
function! <SID>BackwardDeleteChar()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    if (getcmdpos() < 2)
        return getcmdline()
    endif
    let l:cmd = getcmdline()
    let l:rem = strpart(l:cmd, getcmdpos() - 2, 1)
    let @c    = l:rem
    let l:pos = getcmdpos() - 1
    let l:ret = strpart(l:cmd, 0, getcmdpos() - 2) . strpart(l:cmd, getcmdpos() - 1)
    call <SID>saveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

cnoremap <C-K> <C-\>e<SID>KillLine()<CR>
function! <SID>KillLine()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd = getcmdline()
    let l:rem = strpart(l:cmd, getcmdpos() - 1)
    if ('' != l:rem)
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, 0, getcmdpos() - 1)
    call <SID>saveUndoHistory(l:ret, getcmdpos())
    return l:ret
endfunction

cnoremap <C-U> <C-\>e<SID>BackwardKillLine()<CR>
function! <SID>BackwardKillLine()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd = getcmdline()
    let l:rem = strpart(l:cmd, 0, getcmdpos() - 1)
    if ('' != l:rem)
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, getcmdpos() - 1)
    call <SID>saveUndoHistory(l:ret, 1)
    call setcmdpos(1)
    return l:ret
endfunction

cnoremap <Esc>d <C-\>e<SID>KillWord()<CR>
cmap <M-D> <Esc>d
function! <SID>KillWord()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:roc =~ '\v^\s*\w')
        let l:rem = matchstr(l:roc, '\v^\s*\w+')
    elseif (l:roc =~ '\v^\s*[^[:alnum:]_[:blank:]]')
        let l:rem = matchstr(l:roc, '\v^\s*[^[:alnum:]_[:blank:]]+')
    elseif (l:roc =~ '\v^\s+$')
        let @c = l:roc
        return l:loc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:ret = l:loc . strpart(l:roc, strlen(l:rem))
    call <SID>saveUndoHistory(l:ret, getcmdpos())
    return l:ret
endfunction

cnoremap <C-W> <C-\>e<SID>DeleteBackwardsToWhiteSpace()<CR>
function! <SID>DeleteBackwardsToWhiteSpace()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:loc =~ '\v\S\s*$')
        let l:rem = matchstr(l:loc, '\v\S+\s*$')
    elseif (l:loc =~ '\v^\s+$')
        let @c = l:loc
        call setcmdpos(1)
        return l:roc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:pos = getcmdpos() - strlen(l:rem)
    let l:ret = strpart(l:loc, 0, strlen(l:loc) - strlen(l:rem)) . l:roc
    call <SID>saveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

cnoremap <Esc><BS> <C-\>e<SID>BackwardKillWord()<CR>
cmap <M-BS> <Esc><BS>
function! <SID>BackwardKillWord()
    " Do same as in-built Ctrl-W, except assign deleted text to @c
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:loc =~ '\v\w\s*$')
        let l:rem = matchstr(l:loc, '\v\w+\s*$')
    elseif (l:loc =~ '\v[^[:alnum:]_[:blank:]]\s*$')
        let l:rem = matchstr(l:loc, '\v[^[:alnum:]_[:blank:]]+\s*$')
    elseif (l:loc =~ '\v^\s+$')
        let @c = l:loc
        call setcmdpos(1)
        return l:roc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:pos = getcmdpos() - strlen(l:rem)
    let l:ret = strpart(l:loc, 0, strlen(l:loc) - strlen(l:rem)) . l:roc
    call <SID>saveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

cnoremap <C-Y> <C-\>e<SID>Yank()<CR>
function! <SID>Yank()
    let l:cmd = getcmdline()
    call setcmdpos(getcmdpos() + strlen(@c))
    return strpart(l:cmd, 0, getcmdpos() - 1) . @c . strpart(l:cmd, getcmdpos() - 1)
endfunction

cnoremap <C-Z> <C-\>e<SID>ToggleExternalCommand()<CR>
function! <SID>ToggleExternalCommand()
    let l:cmd = getcmdline()
    if ('!' == strpart(l:cmd, 0, 1))
        call setcmdpos(getcmdpos() - 1)
        return strpart(l:cmd, 1)
    else
        call setcmdpos(getcmdpos() + 1)
        return '!' . l:cmd
    endif
endfunction

let s:oldcmdline = [ ]
function! <SID>saveUndoHistory(cmdline, cmdpos)
    if len(s:oldcmdline) == 0 || a:cmdline != s:oldcmdline[0][0]
        call insert(s:oldcmdline, [ a:cmdline, a:cmdpos ], 0)
    else
        let s:oldcmdline[0][1] = a:cmdpos
    endif
    if len(s:oldcmdline) > 100
        call remove(s:oldcmdline, 100)
    endif
endfunction
cnoremap <C-_> <C-\>e<SID>Undo()<CR>
cmap <C-X><C-U> <C-_>
function! <SID>Undo()
    if len(s:oldcmdline) == 0
        return getcmdline()
    endif
    if getcmdline() == s:oldcmdline[0][0]
        call remove(s:oldcmdline, 0)
        if len(s:oldcmdline) == 0
            return getcmdline()
        endif
    endif
    let l:ret = s:oldcmdline[0][0]
    call setcmdpos(s:oldcmdline[0][1])
    call remove(s:oldcmdline, 0)
    return l:ret
endfunction

