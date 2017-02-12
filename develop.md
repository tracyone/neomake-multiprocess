```vim
g:neomake_hook_context
{
   jobinfo
   {
    name                          ----------------任务的名字,实际上只是个数字
    id                            ----------------表示任务id
    make_id
    vim_job                       ----------------包含了vim的job id信息
    maker
    {
      Funcref postprocess
      ft
      errorformat                 ----------------字符变量标识vim的errorformat
      exec                        ----------------比如ag,make grep这些,只有使能该maker的时候这个才有
      Funcref get_argv
      append_file                 -----------------标志,1表示使用当前文件为输入文件
      name                        -----------------和exec类似,一直存在,NeomakeSh的时候是这样的sh: 命令行
      remove_invalid_entries      -----------------标志
      buffer_output               -----------------标志
      list args                   ----------------- exec的参数
    }
    next
    {
    }
   }
}
```

维护一个全局的job_list，新job就add，完成就remove，list的每个成员是一个dict

这个dict有以下的key:

job_id，用来区分不同job
callback,这个job的回调函数
args，这个回调函数的arg list

指向
