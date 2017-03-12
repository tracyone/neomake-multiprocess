# neomake-multiprocess [![Build Status](https://travis-ci.org/tracyone/neomake-multiprocess.svg?branch=master)](https://travis-ci.org/tracyone/neomake-multiprocess)

A vim plugin for running multiple process asynchronously base on [neomake](https://github.com/neomake/neomake).

# Feature

1. Run multiple process asynchronously.
2. Global search asynchronously, support ag and grep.

# Screenshot

# Usage

```vim
neomakemp#run_command(command [, callback] [,arglist] [, flag])
```

Run `command` asynchronously.

- `callback` is a `Funcref` variable which will be called after `command` exit.
- `arglist` is a `list` variable which will be passed to `callback`
- `flag` specify whether open quickfix window after command exited.

```vim
neomakemp#global_search(pattern)
```

Global search charactor containing a match to the given PATTERN.

Shortcut   | mode  | Description
--------   | ----- | -----------
`<Leader>vv` | visual,normal| global search selected word or under current curosr
`<Leader>vr` | normal| run command from user input
`<Leader>vs` | normal| global search from user input

you can remap it:

```vim
nmap <yourkey> <Plug>(neomakemp_global_search) 
nmap <yourkey> <Plug>(neomakemp_run_command) 
nmap <yourkey> <Plug>(neomakemp_global_search2) 
```

# Option

Name                         | Description
----                         | -----------
g:neomakemp_grep_command     | `ag` or `grep`
g:neomakemp_exclude_files    | list variable,specify the ignore file
g:neomakemp_exclude_dirs     | list variable,specify the ignore directory


Config example:

```vim
"following is default value
let g:neomakemp_grep_command = "ag"
let g:neomakemp_exclude_files=['*.jpg', '*.png', '*.min.js', '*.swp', '*.pyc','*.out','*.o']
let g:neomakemp_exclude_dirs=[ '.git', 'bin', 'log', 'build', 'node_modules', '.bundle', '.tmp','.svn' ]

" Display process in vim-airline
let g:airline_section_error = airline#section#create_right(['%{neomakemp#run_status()}'])
```

Quickfix window will be opened under following condition:

1. Global search
2. Some error happened
3. `flag` is equal to 1


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
