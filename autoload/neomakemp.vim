if !exists('g:neomakemp_grep_command')
    if executable('ag')
        let g:neomakemp_grep_command = "ag"
    else
        let g:neomakemp_grep_command = "grep"
    endif
endif

let g:neomakemp_job_list=[]

let g:asyncrun_status = ''

if g:neomakemp_grep_command ==# 'ag'
    let s:arg_exclude_file     = '--ignore='
    let s:arg_exclude_dir      = '--ignore='
    let s:arg_init = '--vimgrep'
    let s:error_format='%f:%l:%c:%m,%f:%l%m,%f  %l%m'
elseif g:neomakemp_grep_command ==# 'grep'
    let s:arg_exclude_file     = '--exclude='
    let s:arg_exclude_dir      = '--exclude-dir='
    let s:arg_init = '-nRI'
    let s:error_format='%f:%l:%m,%f:%l%m,%f  %l%m'
else
    echom "Unsupport searcher"
    finish
endif

if !exists('g:neomakemp_exclude_files')
    let g:neomakemp_exclude_files=['*.jpg', '*.png', '*.min.js', '*.swp', '*.pyc','*.out','*.o']
elseif type(g:neomakemp_exclude_files) != v:t_list
    echom "g:neomakemp_exclude_files must be a list variable"
    finish
endif

if !exists('g:neomakemp_exclude_dirs')
    let g:neomakemp_exclude_dirs=[ '.git', 'bin', 'log', 'build', 'node_modules', '.bundle', '.tmp','.svn' ]
elseif type(g:neomakemp_exclude_dirs) != v:t_list
    echom "g:neomakemp_exclude_dirs must be a list variable"
    finish
endif



function! neomakemp#entry_to_warning(entry) abort
  let a:entry.type = 'I'
endfunction

function! neomakemp#SampleCallBack(command)
    execute a:command
endfunction

"neomakemp#global_search(pattern)
function! neomakemp#global_search(pattern) abort
    let g:asyncrun_status = ''
    if a:pattern =~# '^\s*$'
        let l:neomake_searchql=input('Global Search: ')
    else
        let l:neomake_searchql=a:pattern
    endif
    if g:neomakemp_grep_command ==# 'ag'
        let l:neomake_searchql=escape(l:neomake_searchql,'->()')
    else
        let l:neomake_searchql=escape(l:neomake_searchql,'-')
    endif
    let args = [s:arg_init]
    let exfile=""
    let exdir=""
    
    for exfile in g:neomakemp_exclude_files
        let args += [s:arg_exclude_file.exfile]
    endfor

    for exdir in g:neomakemp_exclude_dirs
        let args += [s:arg_exclude_dir.exdir]
    endfor

    let args += [l:neomake_searchql]

    let l:neomake_tmp_maker = {
        \ 'exec': g:neomakemp_grep_command,
        \ 'args': args,
        \ 'errorformat': s:error_format,
        \ 'append_file': 0,
        \ 'postprocess': function('neomakemp#entry_to_warning')
        \ }
    if g:neomakemp_grep_command ==# 'ag'
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

    for needle in g:neomakemp_job_list
        if needle.jobid == g:neomake_hook_context.jobinfo.id
            if type(needle.callback) == v:t_string
                if needle.callback !~ '^\s*$'
                    let l:Callback = function(needle.callback)
                else
                    let l:Callback=''
                endif
            elseif type(needle.callback) == v:t_func
                let l:Callback = needle.callback
            else
                let l:Callback=''
            endif
            try
                call call(l:Callback, needle.args)
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
                    \ || needle.flags == 1
            :copen
        endif
        if has('timers')
            call timer_start(10000,'neomakemp#update_run_status')
        endif
    endif
endfunction

function! neomakemp#update_run_status(timer) abort
    if len(g:neomakemp_job_list) == 0
        let g:asyncrun_status=''
    endif
endfunction

function! neomakemp#run_status()
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
            return 0
        endif 
    endfor

    let l:job_info.jobid=neomake#Sh(l:command)
    if l:job_info.jobid != -1
        call add(g:neomakemp_job_list, l:job_info)
        let g:asyncrun_status='Running:'.len(g:neomakemp_job_list)
    endif
endfunction

augroup neomakemp
    au!
    autocmd User NeomakeJobFinished call neomakemp#on_neomake_finished()
augroup END
