"----------------------------------------
" static variables
"----------------------------------------

let s:config = {}
let s:logic = {}
let s:httpCLC = 'curl -is'


"----------------------------------------
" control functions
"----------------------------------------


function! pastebin#config(server, ...)
    if a:0 == 0 && !has_key(s:config, a:server)
        let s:config[a:server] = {}
    elseif a:0 == 1
        let s:config[a:server] = a:1
    endif
    return s:config[a:server]
endfunction

if exists('*g:InstallPasterConfig')
    call g:InstallPasterConfig()
endif



function! pastebin#paste(server, text)
    " paste contents
    let l:title = expand('%:p:t')
    let l:format = &filetype

    for [l:name, l:logic] in items(s:logic)
        if match(l:name, '\V\^'.a:server.'\$') != -1
            let l:choice = confirm("Post to ".l:name."?", "&Yes\n&No\n&Cancel")
            if l:choice == 2
                continue
            elseif l:choice == 3
                return
            endif
            let l:post = l:logic.HttpParams(l:title, a:text, l:format)
            let l:response = s:HttpRequest(l:logic['url'], l:post)
            let l:location = l:logic.ParseResponse(l:response)

            " copy to clipboard
            if l:location != ''
                call setreg('+', l:location, 'c')
                call setreg('*', l:location, 'c')
                echo "\n" | echomsg l:location
                return 1
            else
                call setreg('+', l:response, 'c')
                call setreg('*', l:response, 'c')
                echohl WarningMsg | echo "\n" | echomsg "Paste failed. Response copied to clipboard..." | echohl None
            endif
        endif
    endfor
    return 0
endfunction


"----------------------------------------
" utility functions
"----------------------------------------

function! s:HttpRequest(url, post)
    let l:command = s:httpCLC
    for [l:key, l:value] in items(a:post)
        if type(l:value) == type('')
            let l:data_urlencode = l:key.'='.l:value
        elseif type(l:value) == type([])
            let [l:type, l:data] = l:value
            if l:type == 'text'
                let l:data_urlencode = l:key.'='.l:data
            elseif l:type == 'file'
                let l:data_urlencode = l:key.'@'.l:data
            elseif l:type == 'input'
                let l:data_urlencode = l:key.'@-'
                let l:input = l:data
            endif
        endif
        if exists('l:data_urlencode')
            let l:command .= ' --data-urlencode ' . shellescape(l:data_urlencode)
            unlet l:data_urlencode
        endif
        unlet l:value
    endfor
    let l:command .= ' ' . shellescape(a:url)
    if exists('l:input')
        return system(l:command, l:input)
    else
        return system(l:command)
    endif
endfunction


"----------------------------------------
" default pastebin logic
"----------------------------------------

function! s:StandardHttpParams(title, content, format) dict
    " default values + user config
    let l:post = extend({ }, self['default'])
    call extend(l:post, pastebin#config(self['name']))

    " fill in paste
    let l:post[self['map']['title']]   = a:title
    let l:post[self['map']['content']] = ['input', a:content]
    if a:format != ''
        let l:post[self['map']['format']]  = a:format
    endif

    " prompt user
    for [l:key, l:value] in items(self['prompt'])
        if !has_key(l:post, l:key)
            let l:post[l:key] = ''
        endif
        let l:post[l:key] = input(l:value, l:post[l:key])
    endfor

    " remove empty values
    for [l:key, l:value] in items(l:post)
        if empty(l:value)
            call remove(l:post, l:key)
        endif
        unlet l:value
    endfor
    return l:post
endfunction

function! s:StandardParseResponse(response) dict
    for l:line in split(a:response, "\n")
        let l:location = matchstr(l:line, '^\s*\zshttps\?://.\{-}\ze\s*$')
        if l:location != ""
            return l:location
        endif
    endfor
    return ""
endfunction

"----------------------------------------
" Individual pastebin logic
"----------------------------------------

" pastebin.com
let s:logic['pastebin.com'] = {
\   'name': 'pastebin.com',
\   'url':  'http://pastebin.com/api/api_post.php',
\   'params': [
\       'api_dev_key',
\       'api_user_key',
\       'api_option',
\       'api_paste_code',
\       'api_paste_expire_date',
\       'api_paste_format',
\       'api_paste_name',
\       'api_paste_private'
\   ],
\   'map':  {
\       'title':      'api_paste_name',
\       'content':    'api_paste_code',
\       'format':     'api_paste_format',
\       'user':       'api_dev_key',
\       'expire':     'api_paste_expire_date'
\   },
\   'prompt': {
\       'api_dev_key':            'Key: ',
\       'api_paste_name':         'Title: ',
\       'api_paste_format':       'Format: ',
\       'api_paste_expire_date':  'Expire: '
\   },
\   'default': {
\       'api_option':             'paste',
\       'api_paste_private':      '1',
\       'api_paste_expire_date':  '1D',
\       'api_paste_format':       'text'
\   },
\   'HttpParams': function('s:StandardHttpParams'),
\   'ParseResponse': function('s:StandardParseResponse')
\ }


" paste.debian.com
let s:logic['paste.debian.net'] = {
\   'name': 'paste.debian.net',
\   'url': 'http://paste.debian.net',
\   'params': [
\       'code', 'lang', 'poster', 'private', 'expire', 'wrap', 'paste'
\   ],
\   'map': {
\       'title':  'ignore',
\       'content':  'code',
\       'format':   'lang',
\       'user':   'poster',
\       'expire': 'expire'
\   },
\   'prompt': {
\       'poster': 'Poster: ',
\       'lang':   'Format: ',
\       'expire': 'Expire: '
\   },
\   'default': {
\       'poster':  'Anonymous',
\       'private': '0',
\       'wrap':    '0',
\       'paste':   'Send',
\       'expire':  '43200'
\   },
\   'paste-base': 'http://paste.debian.net/',
\   'HttpParams': function('s:StandardHttpParams'),
\ }

function s:logic['paste.debian.net'].ParseResponse(response) dict
    for l:line in split(a:response, "\n")
        let l:match = matchlist(l:line, '^Location: \(.\{-}\)\s*$')
        if !empty(l:match)
            let l:location = l:match[1]
            if match(l:location, "^http://") == 0
                return l:location
            else
                return self['paste-base'] . l:location
            endif
        endif
    endfor
    return ""
endfunction

