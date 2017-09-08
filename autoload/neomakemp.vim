if !exists('g:neomakemp_grep_command')
    if executable('rg')
        let g:neomakemp_grep_command = 'rg'
    elseif executable('ag')
        let g:neomakemp_grep_command = 'ag'
    elseif executable('grep')
        let g:neomakemp_grep_command = 'grep'
    else
        let g:neomakemp_grep_command = ''
    endif
endif

let g:neomakemp_job_list=[]

let g:asyncrun_status = ''

if g:neomakemp_grep_command ==# 'rg'
    let s:arg_init = ['-H', '--no-heading', '--vimgrep']
    let s:error_format='%f:%l:%c:%m'
elseif g:neomakemp_grep_command ==# 'ag'
    let s:arg_exclude_file     = '--ignore='
    let s:arg_exclude_dir      = '--ignore='
    let s:arg_init = ['--vimgrep']
    let s:error_format='%f:%l:%c:%m,%f:%l%m,%f  %l%m'
elseif g:neomakemp_grep_command ==# 'grep'
    let s:arg_exclude_file     = '--exclude='
    let s:arg_exclude_dir      = '--exclude-dir='
    let s:arg_init = ['-nRI']
    let s:error_format='%f:%l:%m,%f:%l%m,%f  %l%m'
endif

if !exists('g:neomakemp_exclude_files')
    let g:neomakemp_exclude_files=['*.jpg', '*.png', '*.min.js', '*.swp', '*.pyc','*.out','*.o']
elseif type(g:neomakemp_exclude_files) != v:t_list
    echom 'g:neomakemp_exclude_files must be a list variable'
    finish
endif

if !exists('g:neomakemp_exclude_dirs')
    let g:neomakemp_exclude_dirs=[ '.git', 'bin', 'log', 'build', 'node_modules', '.bundle', '.tmp','.svn' ]
elseif type(g:neomakemp_exclude_dirs) != v:t_list
    echom 'g:neomakemp_exclude_dirs must be a list variable'
    finish
endif



function! neomakemp#entry_to_warning(entry) abort
  let a:entry.type = 'I'
endfunction

function! neomakemp#SampleCallBack(command) abort
    execute a:command
endfunction

"neomakemp#global_search(pattern [, flag])
"argument flag is bit base varabile
"flag:0x01-->search in opened buffer
"flag:0x02-->search original string
function! neomakemp#global_search(pattern,...) abort
    if g:neomakemp_grep_command ==# ''
        echom 'grepper command not found! Please install pg, ag or grep.'
        return -1
    endif
    let g:asyncrun_status = ''
    if a:pattern =~# '^\s*$'
        let l:neomake_searchql=input('Global Search: ')
    else
        let l:neomake_searchql=a:pattern
    endif
    if l:neomake_searchql =~# '^\s*$'
        return 0
    endif
    let l:flag=0x0
    if a:0 == 1
        let l:flag=a:1
    endif
    if type(l:flag) != v:t_number
        echom 'Wrong argument! Option must be a number'
        return -1
    endif
    if and(l:flag, 0x02)
        if g:neomakemp_grep_command ==# 'ag' || g:neomakemp_grep_command ==# 'rg'
            "let l:neomake_searchql=escape(l:neomake_searchql,'->()')
            let l:neomake_searchql=escape(l:neomake_searchql,'\^$.*+?()[]{}|')
        else
            let l:neomake_searchql=escape(l:neomake_searchql,'-')
        endif
    endif
    let l:args = []
    call extend(l:args, s:arg_init)
    let l:exfile=''
    let l:exdir=''
    
    if exists('s:arg_exclude_file')
        for l:exfile in g:neomakemp_exclude_files
            let l:args += [s:arg_exclude_file.l:exfile]
        endfor
    endif

    if exists('s:arg_exclude_dir')
        for l:exdir in g:neomakemp_exclude_dirs
            let l:args += [s:arg_exclude_dir.l:exdir]
        endfor
    endif

    call add(l:args, l:neomake_searchql)

    "search in opend buffers
    if and(l:flag, 0x01)
        if a:1 == 1
            let l:bufname=[]
            :silent bufdo call add(l:bufname,expand('%'))
            call extend(l:args, l:bufname)
        endif
    else
        call add(l:args, '.')
    endif

    let l:neomake_tmp_maker = {
        \ 'exec': g:neomakemp_grep_command,
        \ 'args': l:args,
        \ 'errorformat': s:error_format,
        \ 'append_file': 0,
        \ 'postprocess': function('neomakemp#entry_to_warning')
        \ }
    if g:neomakemp_grep_command ==# 'rg'
        let g:neomake_rg_maker=l:neomake_tmp_maker
    elseif g:neomakemp_grep_command ==# 'ag'
        let g:neomake_ag_maker=l:neomake_tmp_maker
    else
        let g:neomake_grep_maker=l:neomake_tmp_maker
    endif
    let l:job_info={}
    let l:job_info.jobid = neomake#Make(0, [g:neomakemp_grep_command])[0]
    let l:job_info.callback=''
    let l:job_info.args=[]
    let l:job_info.flags=1
    if l:job_info.jobid != -1

        call add(g:neomakemp_job_list, l:job_info)
        let g:asyncrun_status='Running:'.len(g:neomakemp_job_list)
    endif
endfunction

function! neomakemp#on_neomake_finished() abort
    let l:i = 0
    if len(g:neomakemp_job_list) == 0
        return -1
    endif

    for l:needle in g:neomakemp_job_list
        if l:needle.jobid == g:neomake_hook_context.jobinfo.id
            if type(l:needle.callback) == v:t_string
                if l:needle.callback !~# '^\s*$'
                    let l:Callback = function(l:needle.callback)
                else
                    let l:Callback=''
                endif
            elseif type(l:needle.callback) == v:t_func
                let l:Callback = l:needle.callback
            else
                let l:Callback=''
            endif
            try
                call call(l:Callback, l:needle.args)
            catch /^Vim\%((\a\+)\)\=:E117/
            endtry
            "echom 'remove '.g:neomakemp_job_list[l:i].jobid
            call remove(g:neomakemp_job_list, l:i)
            break
        endif
        let l:i += 1
    endfor
    if len(g:neomakemp_job_list) != 0
        let g:asyncrun_status='Running:'.len(g:neomakemp_job_list)
    else
        let g:asyncrun_status='All Done'
        if g:neomake_hook_context.jobinfo.exit_code != 0 
                    \ || l:needle.flags == 1
            :copen
        endif
        if has('timers')
            call timer_start(8000,'neomakemp#update_run_status')
        endif
    endif
endfunction

function! neomakemp#update_run_status(timer) abort
    if len(g:neomakemp_job_list) == 0 && a:timer > 0
        let g:asyncrun_status=''
    endif
endfunction

function! neomakemp#run_status() abort
    return g:asyncrun_status
endfunction

"neomakemp#RunCommand (command [, callback] [,arglist] [, flag)
function! neomakemp#run_command(command,...) abort
    let g:asyncrun_status = ''
    let l:job_info={}
    let l:job_info.callback=''
    let l:job_info.args=[]
    let l:job_info.flags=0
    if a:command =~# '^\s*$'
        let l:command=input('Run command: ')
    else
        let l:command=a:command
    endif
    for s:needle in a:000
        if type(s:needle) == v:t_func
            let l:job_info.callback=s:needle
        elseif type(s:needle) == v:t_list
            let l:job_info.args=s:needle
        elseif type(s:needle) == v:t_number
            let l:job_info.flags=s:needle
        else
            echom 'Wrong argument'
            return -1 
        endif 
    endfor

    let l:job_info.jobid=neomake#Sh(l:command)
    if l:job_info.jobid != -1
        call add(g:neomakemp_job_list, l:job_info)
        let g:asyncrun_status='Running:'.len(g:neomakemp_job_list)
    endif
    return l:job_info.jobid
endfunction

augroup neomakemp
    au!
    autocmd User NeomakeJobFinished call neomakemp#on_neomake_finished()
augroup END
