if !exists(':Neomake') || &cp
    finish
endif

nnoremap <silent> <Plug>(neomakemp_global_search) :call neomakemp#global_search('\b'.expand("<cword>").'\b')<cr>

vnoremap <silent> <Plug>(neomakemp_global_search) :<c-u>:call neomakemp#global_search(getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1])<cr>

nnoremap <silent> <Plug>(neomakemp_run_command) :call neomakemp#run_command('')<cr>

"ag search for the word on current curosr
nmap <Leader>vv <Plug>(neomakemp_global_search)

"global search selected charactor
vmap <Leader>vv <Plug>(neomakemp_global_search)

" run command which is from user input.
nmap <Leader>vr <Plug>(neomakemp_run_command)
