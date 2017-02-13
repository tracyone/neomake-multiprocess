# neomake-multiprocess

# Feature

1. Run multiple process asynchronously.
2. Global search asynchronously, support ag and grep.

# Screenshot

# Usage

Run `command`, function `callback` with its args in `arglist` will be called
after `command` exit.`flag` specify whether open quickfix window after command exited.

    neomakemp#RunCommand (command [, callback] [,arglist] [, flag)

Global search charactor with `pattern`

    neomakemp#global_search(pattern)

Shortcut   | mode  | Description
--------   | ----- | -----------
`<Leader>vv` | visual,normal| global search selected word or under current curosr

you can remap it:

```vim
nmap <yourkey> <Plug>(NeomakempGlobalSearcher) 
```

# Option

Name                      | Description
----                      | -----------
g:neomakemp_grep_command  | `ag` or `grep`
g:neomakemp_exclude_files | list variable,specify the ignore file
g:neomakemp_exclude_dirs  | list variable,specify the ignore directory


Config example:

```vim
"following is default value
let g:neomakemp_grep_command = "ag"
let g:neomakemp_exclude_files=['*.jpg', '*.png', '*.min.js', '*.swp', '*.pyc','*.out','*.o']
let g:neomakemp_exclude_dirs=[ '.git', 'bin', 'log', 'build', 'node_modules', '.bundle', '.tmp','.svn' ]
```

# Example

Following example showing how to generate cscope file asynchronously.

```vim
function! s:AddCscopeOut(read_project,...)
    if a:read_project == 1
        if empty(glob('.project'))
            exec 'silent! cs add cscope.out'
        else
            for s:line in readfile('.project', '')
                exec 'silent! cs add '.s:line.'/cscope.out'
            endfor
        endif
    else
        if a:0 == 1
            exec 'cs add '.a:1.'/cscope.out'
        else
            exec 'silent! cs add cscope.out'
        endif
    endif
endfunction
let l:gen_cscope_files='find ' .a:dir. ' -name "*.[chsS]" > '  . l:cscopefiles
call neomakemp#RunCommand(l:gen_cscope_files.'&&cscope -Rbkq -i '.l:cscopefiles, function('<SID>AddCscopeOut'),[0,a:dir])
```
