if !exists('g:EmacsCommandLineMaxUndoHistory')
    let g:EmacsCommandLineMaxUndoHistory = 100
endif
if !exists('g:EmacsCommandLineOldMapPrefix')
    let g:EmacsCommandLineOldMapPrefix = '<C-O>'
endif
if !exists('g:EmacsCommandLineWordCharCharacterClass')
    " Latin-1, Latin Extended-A, Extended-B, Greek and Coptic, and Cyrillic scripts:
    "let g:EmacsCommandLineWordCharCharacterClass = 'a-zA-Z0-9_À-ÖØ-öø-ÿĀ-ǿȀ-ɏͰ-ͳͶͷΆΈΉΊΌΎ-ΡΣ-ώϚ-ϯϷϸϺϻЀ-ҁ'
    " Latin-1 (the most common European letters):
    let g:EmacsCommandLineWordCharCharacterClass = 'a-zA-Z0-9_À-ÖØ-öø-ÿ'
    " Basic Latin (unaccented) word characters:
    "let g:EmacsCommandLineWordCharCharacterClass = '\w'
endif
if !exists('g:EmacsCommandLineSearchCommandLineMapOnlyWhenEmpty')
    let g:EmacsCommandLineSearchCommandLineMapOnlyWhenEmpty = 1
endif
if !exists('g:EmacsCommandLineForwardCharNoMapAtEnd')
    let g:EmacsCommandLineForwardCharNoMapAtEnd = 1
endif
if !exists('g:EmacsCommandLineEndOfLineNoMapAtEnd')
    let g:EmacsCommandLineEndOfLineNoMapAtEnd = 1
endif
if !exists('g:EmacsCommandLineDeleteCharNoMapAtEnd')
    let g:EmacsCommandLineDeleteCharNoMapAtEnd = 1
endif
if !exists('g:EmacsCommandLineKillLineNoMapAtEnd')
    let g:EmacsCommandLineKillLineNoMapAtEnd = 1
endif

let s:mappings = {
    \'ForwardChar':              ['<C-F>', '<Right>'],
    \'BackwardChar':             ['<C-B>', '<Left>'],
    \'BeginningOfLine':          ['<C-A>', '<Home>'],
    \'EndOfLine':                ['<C-E>', '<End>'],
    \'OlderMatchingCommandLine': ['<C-P>', '<Up>'],
    \'NewerMatchingCommandLine': ['<C-N>', '<Down>'],
    \'FirstLineInHistory':       ['<M-<>', '<C-F>gg<C-C>'],
    \'LastLineInHistory':        ['<M->>', '<C-F>Gk<C-C>'],
    \'SearchCommandLine':        ['<C-R>', '<C-F>?'],
    \'AbortCommand':             ['<C-G>', '<C-C>']
    \}
if !has('gui_running') && !has('nvim')
    let s:mappings['FirstLineInHistory'][0] = '<Esc><'
    let s:mappings['LastLineInHistory'][0]  = '<Esc>>'
endif
for s:key in keys(s:mappings)
    if !exists('g:EmacsCommandLine' . s:key . 'Disable') || g:EmacsCommandLine{s:key}Disable != 1
        let s:{s:key}MapDefined = exists('g:EmacsCommandLine' . s:key . 'Map')
        if !s:{s:key}MapDefined
            let g:EmacsCommandLine{s:key}Map = s:mappings[s:key][0]
        endif
        if type(g:EmacsCommandLine{s:key}Map) == 3
            for s:mapping in g:EmacsCommandLine{s:key}Map
                if exists('g:EmacsCommandLine' . s:key . 'MapOnlyWhenEmpty') && g:EmacsCommandLine{s:key}MapOnlyWhenEmpty == 1
                    exe 'cnoremap <expr> ' . s:mapping . ' strlen(getcmdline())>0?''' . s:mapping . ''':''' . s:mappings[s:key][1] . ''''
                elseif exists('g:EmacsCommandLine' . s:key . 'NoMapAtEnd') && g:EmacsCommandLine{s:key}NoMapAtEnd == 1
                    exe 'cnoremap <expr> ' . s:mapping . ' getcmdpos()>strlen(getcmdline())?''' . s:mapping . ''':''' . s:mappings[s:key][1] . ''''
                else
                    exe 'cnoremap ' . s:mapping . ' ' . s:mappings[s:key][1]
                endif
                if maparg(g:EmacsCommandLineOldMapPrefix . s:mapping, 'c') == ''
                    exe 'cnoremap ' . g:EmacsCommandLineOldMapPrefix . s:mapping . ' ' . s:mapping
                endif
            endfor
        else
            if exists('g:EmacsCommandLine' . s:key . 'MapOnlyWhenEmpty') && g:EmacsCommandLine{s:key}MapOnlyWhenEmpty == 1
                exe 'cnoremap <expr> ' . g:EmacsCommandLine{s:key}Map . ' strlen(getcmdline())>0?''' . g:EmacsCommandLine{s:key}Map . ''':''' . s:mappings[s:key][1] . ''''
            elseif exists('g:EmacsCommandLine' . s:key . 'NoMapAtEnd') && g:EmacsCommandLine{s:key}NoMapAtEnd == 1
                exe 'cnoremap <expr> ' . g:EmacsCommandLine{s:key}Map . ' getcmdpos()>strlen(getcmdline())?''' . g:EmacsCommandLine{s:key}Map . ''':''' . s:mappings[s:key][1] . ''''
            else
                exe 'cnoremap ' . g:EmacsCommandLine{s:key}Map . ' ' . s:mappings[s:key][1]
            endif
            if maparg(g:EmacsCommandLineOldMapPrefix . g:EmacsCommandLine{s:key}Map, 'c') == ''
                exe 'cnoremap ' . g:EmacsCommandLineOldMapPrefix . g:EmacsCommandLine{s:key}Map . ' ' . g:EmacsCommandLine{s:key}Map
            endif
        endif
    endif
endfor

function! <SID>ForwardWord()
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if l:roc =~ '\v^\s*[' . g:EmacsCommandLineWordCharCharacterClass . ']'
        let l:rem = matchstr(l:roc, '\v^\s*[' . g:EmacsCommandLineWordCharCharacterClass . ']+')
    elseif l:roc =~ '\v^\s*[^[:alnum:]_[:blank:]]'
        let l:rem = matchstr(l:roc, '\v^\s*[^[:alnum:]_[:blank:]]+')
    else
        call setcmdpos(strlen(getcmdline()) + 1)
        return getcmdline()
    endif
    call setcmdpos(strlen(l:loc) + strlen(l:rem) + 1)
    return getcmdline()
endfunction

function! <SID>BackwardWord()
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if l:loc =~ '\v[' . g:EmacsCommandLineWordCharCharacterClass . ']\s*$'
        let l:rem = matchstr(l:loc, '\v[' . g:EmacsCommandLineWordCharCharacterClass . ']+\s*$')
    elseif l:loc =~ '\v[^[:alnum:]_[:blank:]]\s*$'
        let l:rem = matchstr(l:loc, '\v[^[:alnum:]_[:blank:]]+\s*$')
    else
        call setcmdpos(1)
        return getcmdline()
    endif
    let @c = l:rem
    call setcmdpos(strlen(l:loc) - strlen(l:rem) + 1)
    return getcmdline()
endfunction

function! <SID>DeleteChar()
    call <SID>SaveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd     = getcmdline()
    " Get length of character to be deleted (in bytes)
    let l:charlen = strlen(matchstr(strpart(l:cmd, getcmdpos() - 1), '^.'))
    let l:rem     = strpart(l:cmd, getcmdpos() - 1, l:charlen)
    if '' != l:rem
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, 0, getcmdpos() - 1) . strpart(l:cmd, getcmdpos() + l:charlen - 1)
    call <SID>SaveUndoHistory(l:ret, getcmdpos())
    return l:ret
endfunction

function! <SID>BackwardDeleteChar()
    call <SID>SaveUndoHistory(getcmdline(), getcmdpos())
    if getcmdpos() < 2
        return getcmdline()
    endif
    let l:cmd     = getcmdline()
    " Get length of character to be deleted (in bytes)
    let l:charlen = strlen(matchstr(strpart(l:cmd, 0, getcmdpos() - 1), '.$'))
    let l:pos     = getcmdpos() - l:charlen
    let l:rem     = strpart(l:cmd, getcmdpos() - l:charlen - 1, l:charlen)
    let @c        = l:rem
    let l:ret     = strpart(l:cmd, 0, l:pos - 1) . strpart(l:cmd, getcmdpos() - 1)
    call <SID>SaveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

function! <SID>KillLine()
    call <SID>SaveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd = getcmdline()
    let l:rem = strpart(l:cmd, getcmdpos() - 1)
    if '' != l:rem
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, 0, getcmdpos() - 1)
    call <SID>SaveUndoHistory(l:ret, getcmdpos())
    return l:ret
endfunction

function! <SID>BackwardKillLine()
    call <SID>SaveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd = getcmdline()
    let l:rem = strpart(l:cmd, 0, getcmdpos() - 1)
    if '' != l:rem
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, getcmdpos() - 1)
    call <SID>SaveUndoHistory(l:ret, 1)
    call setcmdpos(1)
    return l:ret
endfunction

function! <SID>KillWord()
    call <SID>SaveUndoHistory(getcmdline(), getcmdpos())
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if l:roc =~ '\v^\s*[' . g:EmacsCommandLineWordCharCharacterClass . ']'
        let l:rem = matchstr(l:roc, '\v^\s*[' . g:EmacsCommandLineWordCharCharacterClass . ']+')
    elseif l:roc =~ '\v^\s*[^[:alnum:]_[:blank:]]'
        let l:rem = matchstr(l:roc, '\v^\s*[^[:alnum:]_[:blank:]]+')
    elseif l:roc =~ '\v^\s+$'
        let @c = l:roc
        return l:loc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:ret = l:loc . strpart(l:roc, strlen(l:rem))
    call <SID>SaveUndoHistory(l:ret, getcmdpos())
    return l:ret
endfunction

function! <SID>DeleteBackwardsToWhiteSpace()
    call <SID>SaveUndoHistory(getcmdline(), getcmdpos())
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if l:loc =~ '\v\S\s*$'
        let l:rem = matchstr(l:loc, '\v\S+\s*$')
    elseif l:loc =~ '\v^\s+$'
        let @c = l:loc
        call setcmdpos(1)
        return l:roc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:pos = getcmdpos() - strlen(l:rem)
    let l:ret = strpart(l:loc, 0, strlen(l:loc) - strlen(l:rem)) . l:roc
    call <SID>SaveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

function! <SID>BackwardKillWord()
    " Do same as in-built Ctrl-W, except assign deleted text to @c
    call <SID>SaveUndoHistory(getcmdline(), getcmdpos())
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if l:loc =~ '\v[' . g:EmacsCommandLineWordCharCharacterClass . ']\s*$'
        let l:rem = matchstr(l:loc, '\v[' . g:EmacsCommandLineWordCharCharacterClass . ']+\s*$')
    elseif l:loc =~ '\v[^[:alnum:]_[:blank:]]\s*$'
        let l:rem = matchstr(l:loc, '\v[^[:alnum:]_[:blank:]]+\s*$')
    elseif l:loc =~ '\v^\s+$'
        let @c = l:loc
        call setcmdpos(1)
        return l:roc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:pos = getcmdpos() - strlen(l:rem)
    let l:ret = strpart(l:loc, 0, strlen(l:loc) - strlen(l:rem)) . l:roc
    call <SID>SaveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

function! <SID>TransposeChar()
    call <SID>SaveUndoHistory(getcmdline(), getcmdpos())
    let l:pos = getcmdpos() + strlen(matchstr(strpart(getcmdline(), getcmdpos() - 1), '^.' . (getcmdpos() < 2 ? '.' : '')))
    let l:ret = substitute(strpart(getcmdline(), 0, l:pos - 1), '\v(.*)(.)(.)$', '\1\3\2', '') . strpart(getcmdline(), l:pos - 1)
    call <SID>SaveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

function! <SID>TransposeWord()
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1) . matchstr(strpart(getcmdline(), getcmdpos() - 1), '^.')
    let l:roc = strpart(getcmdline(), strlen(l:loc))
    if !(l:loc =~ '\v^\s*\S+\s')
        return getcmdline()
    endi
    if l:loc =~ '\s$'
        if l:roc =~ '^\s*\S'
            let l:loc = l:loc . matchstr(l:roc, '\v^\s*\S+')
            let l:roc = strpart(getcmdline(), strlen(l:loc))
        elseif l:roc =~ '^\s*$'
            let l:roc = matchstr(l:loc, '\v\s+$') . l:roc
            let l:loc = strpart(getcmdline(), 0, strlen(getcmdline()) - strlen(l:roc))
        endif
    elseif l:loc =~ '\S$' && l:roc =~ '^\S'
        let l:loc = l:loc . matchstr(l:roc, '\v^\S+')
        let l:roc = strpart(getcmdline(), strlen(l:loc))
    endif
    let l:pos = strlen(l:loc) + 1
    let l:ret = substitute(l:loc, '\v^(.{-})(\S+)(\s+)(\S+)(\s*)$', '\1\4\3\2\5', '') . l:roc
    call <SID>SaveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

function! <SID>Yank()
    let l:cmd = getcmdline()
    call setcmdpos(getcmdpos() + strlen(@c))
    return strpart(l:cmd, 0, getcmdpos() - 1) . @c . strpart(l:cmd, getcmdpos() - 1)
endfunction

cnoremap <C-Z> <C-\>e<SID>ToggleExternalCommand()<CR>
function! <SID>ToggleExternalCommand()
    call <SID>SaveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd = getcmdline()
    if '!' == strpart(l:cmd, 0, 1)
        let l:pos = getcmdpos() - 1
        let l:ret = strpart(l:cmd, 1)
    else
        let l:pos = getcmdpos() + 1
        let l:ret = '!' . l:cmd
    endif
    call <SID>SaveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

let s:oldcmdline = [ ]
function! <SID>SaveUndoHistory(cmdline, cmdpos)
    if len(s:oldcmdline) == 0 || a:cmdline != s:oldcmdline[0][0]
        call insert(s:oldcmdline, [ a:cmdline, a:cmdpos ], 0)
    else
        let s:oldcmdline[0][1] = a:cmdpos
    endif
    if len(s:oldcmdline) > g:EmacsCommandLineMaxUndoHistory
        call remove(s:oldcmdline, g:EmacsCommandLineMaxUndoHistory)
    endif
endfunction

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

let s:functions = {
    \'ForwardWord':                 '<M-f>',
    \'BackwardWord':                '<M-b>',
    \'DeleteChar':                  ['<Del>', '<C-D>'],
    \'BackwardDeleteChar':          ['<BS>', '<C-H>'],
    \'KillLine':                    '<C-K>',
    \'BackwardKillLine':            '<C-U>',
    \'KillWord':                    '<M-d>',
    \'DeleteBackwardsToWhiteSpace': '<C-W>',
    \'BackwardKillWord':            '<M-BS>',
    \'TransposeChar':               '<C-T>',
    \'TransposeWord':               '<M-t>',
    \'Yank':                        '<C-Y>',
    \'Undo':                        ['<C-_>', '<C-X><C-U>'],
    \'ToggleExternalCommand':       '<C-Z>'
    \}
if !has('gui_running') && !has('nvim')
    let s:functions['ForwardWord']      = '<Esc>f'
    let s:functions['BackwardWord']     = '<Esc>b'
    let s:functions['KillWord']         = '<Esc>d'
    let s:functions['BackwardKillWord'] = '<Esc><BS>'
    let s:functions['TransposeWord']    = '<Esc>t'
endif
for s:key in keys(s:functions)
    if !exists('g:EmacsCommandLine' . s:key . 'Disable') || g:EmacsCommandLine{s:key}Disable != 1
        let s:{s:key}MapDefined = exists('g:EmacsCommandLine' . s:key . 'Map')
        if !s:{s:key}MapDefined
            let g:EmacsCommandLine{s:key}Map = s:functions[s:key]
        endif
        if type(g:EmacsCommandLine{s:key}Map) == 3
            for s:mapping in g:EmacsCommandLine{s:key}Map
                if exists('g:EmacsCommandLine' . s:key . 'MapOnlyWhenEmpty') && g:EmacsCommandLine{s:key}MapOnlyWhenEmpty == 1
                    exe 'cnoremap <expr> ' . s:mapping . ' strlen(getcmdline())>0?''' . s:mapping . ''':''<C-\>e<SID>' . s:key . '()<CR>'''
                elseif exists('g:EmacsCommandLine' . s:key . 'NoMapAtEnd') && g:EmacsCommandLine{s:key}NoMapAtEnd == 1
                    exe 'cnoremap <expr> ' . s:mapping . ' getcmdpos()>strlen(getcmdline())?''' . s:mapping . ''':''<C-\>e<SID>' . s:key . '()<CR>'''
                else
                    exe 'cnoremap ' . s:mapping . ' <C-\>e<SID>' . s:key . '()<CR>'
                endif
                if maparg(g:EmacsCommandLineOldMapPrefix . s:mapping, 'c') == ''
                    exe 'cnoremap ' . g:EmacsCommandLineOldMapPrefix . s:mapping . ' ' . s:mapping
                endif
            endfor
        else
            if exists('g:EmacsCommandLine' . s:key . 'MapOnlyWhenEmpty') && g:EmacsCommandLine{s:key}MapOnlyWhenEmpty == 1
                exe 'cnoremap <expr> ' . g:EmacsCommandLine{s:key}Map . ' strlen(getcmdline())>0?''' . g:EmacsCommandLine{s:key}Map . ''':''<C-\>e<SID>' . s:key . '()<CR>'''
            elseif exists('g:EmacsCommandLine' . s:key . 'NoMapAtEnd') && g:EmacsCommandLine{s:key}NoMapAtEnd == 1
                exe 'cnoremap <expr> ' . g:EmacsCommandLine{s:key}Map . ' getcmdpos()>strlen(getcmdline())?''' . g:EmacsCommandLine{s:key}Map . ''':''<C-\>e<SID>' . s:key . '()<CR>'''
            else
                exe 'cnoremap ' . g:EmacsCommandLine{s:key}Map . ' <C-\>e<SID>' . s:key . '()<CR>'
            endif
            if maparg(g:EmacsCommandLineOldMapPrefix . g:EmacsCommandLine{s:key}Map, 'c') == ''
                exe 'cnoremap ' . g:EmacsCommandLineOldMapPrefix . g:EmacsCommandLine{s:key}Map . ' ' . g:EmacsCommandLine{s:key}Map
            endif
        endif
    endif
endfor

