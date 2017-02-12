if !exists('g:neomakemp_grep_command')
    if executable('ag')
        let g:neomakemp_grep_command = "ag"
    else
        let g:neomakemp_grep_command = "grep"
    endif
endif

let g:neomakemp_job_list=[]

if g:neomakemp_grep_command ==# 'ag'
    let s:arg_exclude_file     = '--ignore='
    let s:arg_exclude_dir      = '--ignore='
    let s:arg_init = '--vimgrep'
    let s:error_format='%f:%l:%m,%f:%l%m,%f  %l%m'
elseif g:neomakemp_grep_command ==# 'grep'
    let s:arg_exclude_file     = '--exclude='
    let s:arg_exclude_dir      = '--exclude-dir='
    let s:arg_init = '-nRI'
    let s:error_format='%f:%l:%m,%f:%l%m,%f  %l%m'
else
    echom "Unsupport searcher"
    finish
endif

let g:neomakemp_exclude_files=['*.jpg', '*.png', '*.min.js', '*.swp', '*.pyc','*.out','*.o']
let g:neomakemp_exclude_dirs=[ '.git', 'bin', 'log', 'build', 'node_modules', '.bundle', '.tmp','.svn' ]


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
        let neomake_searchq=input('Global Search: ')
    else
        let neomake_searchq=a:pattern
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

    let args += [neomake_searchq]

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
    if l:job_info.jobid != -1
        call add(g:neomakemp_job_list, l:job_info)
        let g:asyncrun_status='Running:'.len(g:neomakemp_job_list)
    endif
endfunction

function! neomakemp#OnNeomakeFinished() abort
    if g:neomake_hook_context.jobinfo.maker.name ==# g:neomakemp_grep_command
        :copen
    endif
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
    endif
endfunction


"neomakemp#RunCommand (command [, callback] [,arglist])
function! neomakemp#RunCommand(command,...) abort
    let l:job_info={}
    if a:0 == 1
        let l:job_info.callback=a:1
        let l:job_info.args=[]
    elseif a:0 == 2
        let l:job_info.callback=a:1
        let l:job_info.args=a:2
    else
        let l:job_info.callback=''
        let l:job_info.args=[]
    endif
    let l:job_info.jobid=neomake#Sh(a:command)
    if l:job_info.jobid != -1
        call add(g:neomakemp_job_list, l:job_info)
        let g:asyncrun_status='Running:'.len(g:neomakemp_job_list)
    endif
endfunction

augroup neomakemp
    au!
    autocmd User NeomakeJobFinished call neomakemp#OnNeomakeFinished()
augroup END
