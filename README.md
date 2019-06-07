# neomake-multiprocess [![Build Status](https://travis-ci.org/tracyone/neomake-multiprocess.svg?branch=master)](https://travis-ci.org/tracyone/neomake-multiprocess)

A vim plugin for running multiple process asynchronously base on [neomake](https://github.com/neomake/neomake).


<!-- vim-markdown-toc GFM -->

* [Feature](#feature)
* [Screenshot](#screenshot)
* [Installation](#installation)
* [Usage](#usage)
    * [Functions](#functions)
    * [Keymappings](#keymappings)
    * [Options](#options)
    * [Show running status in statusline](#show-running-status-in-statusline)
* [Example](#example)
* [Buy me a coffee](#buy-me-a-coffee)

<!-- vim-markdown-toc -->

# Feature

1. Run multiple process asynchronously and output to quickfix window.
2. Global search asynchronously, support [ag](https://github.com/ggreer/the_silver_searcher), [rg](https://github.com/BurntSushi/ripgrep), grep and git grep, and output to quickfix window with `errorformat` option seted properly.

# Screenshot

[![asciicast](https://asciinema.org/a/250355.svg)](https://asciinema.org/a/250355)

# Installation

Use [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'neomake/neomake'
Plug 'tracyone/neomake-multiprocess'
```

# Usage


```vim
:h neomakemp.txt
```

## Functions

```vim
neomakemp#run_command(command [, callback] [,arglist] [, flag])
```

Run `command` asynchronously:

- `callback` is a `Funcref` variable which will be called after `command` exit.
- `arglist` is a `list` variable which will be passed to `callback`
- `flag` specify whether open quickfix window after command exited.

Global search charactor containing a match to the given PATTERN:

```vim
neomakemp#global_search(pattern [, flag])
```

`flag` is bit base variable:

- 0x01-->search in opened buffer
- 0x02-->search original string


## Keymappings

Shortcut   | mode  | Description
--------   | ----- | -----------
`<Leader>vv` | visual,normal| global search selected word or under current curosr
`<Leader>vb` | visual,normal| searching through all existing buffers
`<Leader>vg` | visual,normal| searching in current file
`<Leader>vr` | normal| run command from user input
`<Leader>vs` | normal| global search from user input

you can remap it:

```vim
"search words on current cursor.
nmap <yourkey> <Plug>(neomakemp_global_search) 
"run commands from user input
nmap <yourkey> <Plug>(neomakemp_run_command) 
"search words from user input(regular expression)
nmap <yourkey> <Plug>(neomakemp_global_search2) 
"search word on current cursor in exist buffers
nmap <yourkey> <Plug>(neomakemp_global_search_buf)
"search word in current file
nmap <yourkey> <Plug>(neomakemp_global_search_cur_file)
```

## Options

Name                         | Description
----                         | -----------
g:neomakemp_grep_command     | `rg`, `ag` , `grep` or `git`
g:neomakemp_exclude_files    | list variable,specify the ignore file
g:neomakemp_exclude_dirs     | list variable,specify the ignore directory


Config example:

```vim
"autodetect the existence of commands and select the faster one(rg > ag > grep)
let g:neomakemp_grep_command = "ag"
"following is default value
let g:neomakemp_exclude_files=['*.jpg', '*.png', '*.min.js', '*.swp', '*.pyc','*.out','*.o']
let g:neomakemp_exclude_dirs=[ '.git', 'bin', 'log', 'build', 'node_modules', '.bundle', '.tmp','.svn' ]

```

Quickfix window will be opened under following condition:

1. Global search
2. Some error happened
3. `flag` is equal to 1

## Show running status in statusline

**Display running status of commands in [vim-airline](https://github.com/vim-airline/vim-airline):**

```vim
let g:airline_section_error = airline#section#create_right(['%{neomakemp#run_status()}'])
```

Display running status in vim's buildin statusline:

```vim
let statusline.=neomakemp#run_status()
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

# Buy me a coffee

![donation](https://cloud.githubusercontent.com/assets/4246425/24827592/553bc732-1c7f-11e7-8207-284cccbc2e5c.jpg)
