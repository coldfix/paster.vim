
function! s:GetTextRange(start, stop)
    let l:lines = getline(a:start[0], a:stop[0])
    let l:lines[-1] = l:lines[-1][:a:stop[1]-1]
    let l:lines[0] = l:lines[0][a:start[1]-1:]
    return join(l:lines, "\n")
endfunction

function! s:GetTextBlock(...)
    let aval = getreg('a')
    let amod = getregtype('a')
    silent normal! gv"ay
    let l:text = getreg('a')
    call setreg('a', aval, amod)
    return l:text
endfunction

function! s:PastePlugin(mode) range
    if a:mode ==# 'v'
        let l:text = s:GetTextRange(getpos("'<")[1:2], getpos("'>")[1:2])
    elseif a:mode ==# ''
        let l:text = s:GetTextBlock()
    else
        let l:text = join(getline(a:firstline, a:lastline), "\n")
    endif
    call pastebin#paste('\.\*', l:text)
endfunction

map <silent> <Plug>nPastebin :call <SID>PastePlugin(mode())<cr>
map <silent> <Plug>vPastebin :call <SID>PastePlugin(visualmode())<cr>

nmap <S-F8> <Plug>nPastebin
vmap <S-F8> <Plug>vPastebin


