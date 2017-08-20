if !exists(':Neomake') || &cp
    finish
endif

"search words on current cursor.
nnoremap <silent> <Plug>(neomakemp_global_search) :call neomakemp#global_search('\b'.expand("<cword>").'\b')<cr>

"search selected words.
vnoremap <silent> <Plug>(neomakemp_global_search) :<c-u>:call neomakemp#global_search(getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1], 0x2)<cr>

"search words from user input(regular expression)
nnoremap <silent> <Plug>(neomakemp_global_search2) :call neomakemp#global_search('')<cr>

"run commands from user input
nnoremap <silent> <Plug>(neomakemp_run_command) :call neomakemp#run_command('')<cr>

"search word on current cursor in exist buffers
nnoremap <silent> <Plug>(neomakemp_global_search_buf) :call neomakemp#global_search('\b'.expand("<cword>").'\b',0x3)<cr>

"search selected words in exist buffers
vnoremap <silent> <Plug>(neomakemp_global_search_buf) :call neomakemp#global_search(getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1],0x3)<cr>

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
