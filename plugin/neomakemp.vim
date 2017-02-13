if !exists(':Neomake') || &cp
    finish
endif

nnoremap <silent> <Plug>(NeomakempGlobalSearcher) :call neomakemp#global_search('\b'.expand("<cword>").'\b')<cr>

vnoremap <silent> <Plug>(NeomakempGlobalSearcher) :<c-u>:call neomakemp#global_search(getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1])<cr>

"ag search for the word on current curosr
nmap <Leader>vv <Plug>(NeomakempGlobalSearcher)

"global search selected charactor
vmap <Leader>vv <Plug>(NeomakempGlobalSearcher)
