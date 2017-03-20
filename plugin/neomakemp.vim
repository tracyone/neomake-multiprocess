if !exists(':Neomake') || &cp
    finish
endif

nnoremap <silent> <Plug>(neomakemp_global_search) :call neomakemp#global_search('\b'.expand("<cword>").'\b')<cr>

vnoremap <silent> <Plug>(neomakemp_global_search) :<c-u>:call neomakemp#global_search(getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1])<cr>

nnoremap <silent> <Plug>(neomakemp_run_command) :call neomakemp#run_command('')<cr>

nnoremap <silent> <Plug>(neomakemp_global_search2) :call neomakemp#global_search('')<cr>

nnoremap <silent> <Plug>(neomakemp_global_search_buf) :call neomakemp#global_search('\b'.expand("<cword>").'\b',1)<cr>

vnoremap <silent> <Plug>(neomakemp_global_search_buf) :call neomakemp#global_search(getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1],1)<cr>

"ag global recursive search for the word on current curosr
nmap <Leader>vv <Plug>(neomakemp_global_search)

"ag searching through all existing buffers
nmap <Leader>vb <Plug>(neomakemp_global_search_buf)
vmap <Leader>vb <Plug>(neomakemp_global_search_buf)

"global search selected charactor
vmap <Leader>vv <Plug>(neomakemp_global_search)

" run command which is from user input.
nmap <Leader>vr <Plug>(neomakemp_run_command)

"ag search for the word on current curosr
nmap <Leader>vs <Plug>(neomakemp_global_search2)
