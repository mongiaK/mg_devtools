let g:vimuser = "god"
let g:useremail = "god@sky.com"


call plug#begin('~/.vim/autoload')  " 表示插件安装在~/.vim/autoload 目录

" 自动根据工程文件.svn .git等生成工程的tag索引
Plug 'ludovicchabant/vim-gutentags'

" 显示文件函数，变量
Plug 'majutsushi/tagbar'

" vim 配色库，很多种
Plug 'flazz/vim-colorschemes'

" 目录树
Plug 'scrooloose/nerdtree'

" 异步执行插件
Plug 'skywind3000/asyncrun.vim'

" 搜索工具
Plug 'mileszs/ack.vim'

" 语法检测工具
Plug 'w0rp/ale'

" vim go开发插件
Plug 'fatih/vim-go'

" 注释插件
Plug 'vim-scripts/DoxygenToolkit.vim'

" 格式化插件，依赖于clangformat
Plug 'rhysd/vim-clang-format'

" vim 调试go工程插件
Plug 'sebdah/vim-delve'

" 设置vim leader键
" Plug 'Yggdroot/LeaderF'

" 补全插件
Plug 'prabirshrestha/async.vim'

" 利用 async.vim 做的补全，相当于一个补全引擎。
Plug 'prabirshrestha/asyncomplete.vim'

" Async Language Server Protocol plugin
Plug 'prabirshrestha/vim-lsp'

" 配合vim-lsp使用，自动配置lsp 识别设置
Plug 'mattn/vim-lsp-settings'

" 将 lsp 中的内容交给 asyncomplete 做补全
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" vim markdown 文件插件
Plug 'plasticboy/vim-markdown'

" markdown 文件预览
Plug 'iamcco/markdown-preview.vim'

" 自动括号，大括号等补全
Plug 'tpope/vim-surround'

" 自动匹配括号等
Plug 'jiangmiao/auto-pairs'

" 状态栏
Plug 'vim-airline/vim-airline'

call plug#end()

syntax on
set t_Co=256

colorscheme molokai

" 设置文件读的格式,终端格式等等
set fencs=utf-8,gbk 
set termencoding=utf-8
set fileencoding=utf-8
set encoding=utf-8
" 关闭兼容模式
set nocompatible    
" 你输入查找内容的同时，vim就开始对你输入的内容进行匹配，并显示匹配的位置。打开这个选项，你可以即时看到查找的结果。
set incsearch       
" 选项表示在查找时忽略大小写
set ignorecase
" 取消 set nowildmenu，将不能出现tab选择
set wildmenu
" 当检测到一个文件已经在Vim之外被更改，并且它没有在Vim的内部被更改时，自动读取它
set autoread
" 设置光标不要闪烁
set gcr=a:block-blinkon0
" 将状态行显示在窗口底部倒数第二行
set laststatus=2
" 底部的行号等显示
set ruler
" 行号显示(nu)
set number
" 高亮当前行(青色)
set cursorline
" 查询显示高亮
set hlsearch
" 使vi可以用退格键删除
set backspace=indent,eol,start
" 是vim不闪屏
set novisualbell
" 自动缩进时缩进为4格(sw)
set shiftwidth=4
" 启动折叠
" set foldenable
" 启用语法折叠
" set foldmethod=syntax
set nofoldenable

"  不换行
set nowrap
" #开启自动缩进   (ai)
set autoindent
" #编辑时可以将tab替换为空格(et)，输入的不再是tab，而是空格
set expandtab
" 设置tab等于4个空格
set tabstop=4
" 设置当前工程的工作目录，将系统的头文件加进来，方便查看系统函数
set path=.,/usr/include,/usr/local/include
" 设置右下角显示完整命令
" set showcmd
" 设置c语言自动缩进
set cindent
" 设置鼠标可以在普通模式跟可视模式使用
set mouse=nv
" 设置tag索引文件查询目录，当使用gentags时可以去掉该选项
" set tags=tags,../tags,../../tags
" 设置leader键
let mapleader=','  

func Airline()
    let g:airline_powerline_fonts = 1   " 使用powerline打过补丁的字体
    let g:airline_theme="dark"      " 设置主题
    
    " 开启tabline
    let g:airline#extensions#tabline#enabled = 1      "tabline中当前buffer两端的分隔字符
    let g:airline#extensions#tabline#left_sep = ' '   "tabline中未激活buffer两端的分隔字符
    let g:airline#extensions#tabline#left_alt_sep = '|'      "tabline中buffer显示编号
    let g:airline#extensions#tabline#buffer_nr_show = 1
endfunc

function VimGo()
    let g:go_template_autocreate = 0
    let g:go_template_file = ""
endfunction 
call VimGo()

function GutenTags()
    " --------------- gutentags 配置------------------
    " gutentags 搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归
    let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

    " 所生成的数据文件的名称
    let g:gutentags_ctags_tagfile = '.tags'

    " 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
    let s:vim_tags = expand('~/.cache/tags')
    let g:gutentags_cache_dir = s:vim_tags

    " 配置 ctags 的参数
    let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
    let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
    let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

    " 检测 ~/.cache/tags 不存在就新建
    if !isdirectory(s:vim_tags)
        silent! call mkdir(s:vim_tags, 'p')
    endif
endfunction
call GutenTags()

function Nerdtree()
    "  右侧显示文件树
    let NERDTreeWinPos=0
    let NERDTreeHighlightCursorline = 1
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
    let g:NERDTreeDirArrowExpandable = '▸'
    let g:NERDTreeDirArrowCollapsible = '▾'
    let NERDTreeMinimalUI = 1
    let NERDTreeDirArrows = 1
    let NERDTreeShowBookmarks=1
endfunction 
call Nerdtree()

function Tagbar()
    " 左侧显示函数
    let g:tagbar_left = 0
    " tagbar 设置
    let g:tagbar_width = 30
endfunction 
call Tagbar()

function Ale()
    let g:ale_sign_column_always = 0  " 侧边栏不可见，只有错误的时候才显示
    let g:ale_set_highlights = 0
    "自定义error和warning图标
    let g:ale_sign_error = '✗'
    let g:ale_sign_warning = '⚡'
    "在vim自带的状态栏中整合ale
    let g:ale_statusline_format = ['✗ %d', '⚡ %d', '✔ OK']
    "显示Linter名称,出错或警告等相关信息
    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

    " ------------------  ale cpp ---------------------------
    let g:ale_cpp_clang_options = '-std=c++11 -Wall'
    let g:ale_cpp_gcc_options = '-std=c++11 -Wall'

    " ------------------  ale c   --------------------------
    let b:ale_c_parse_makefile = 1
    let g:ale_c_parse_compile_commands = 0
    "

    " 不开启文件变了就立刻检查
    let g:ale_lint_on_text_changed = 'never'
    " let g:ale_lint_on_insert_leave = 1
    " let g:ale_lint_on_enter = 1 
    " let g:ale_completion_enabled = 1  "  开启自动补全
    " let g:ale_lint_on_save = 1

    " 设置语法检测
    let g:ale_linters = {
                \   'cpp': ['gcc'],
                \   'c': ['gcc'],
                \   'python': ['pylint'],
                \   'go': ['gometalinter', 'gofmt', 'golint'],
                \   'javascript': ['eslint'],
                \   'jsx': ['stylelint', 'eslint'],
                \}
    " 设置代码格式化
    let g:ale_fixers = {
                \   'javascript': ['prettier'],
                \   'css': ['prettier'],
                \   'jsx': ['prettier'],
                \}
endfunction 
cal Ale()

function BuildComment()
    " 当新建 .h .c .hpp .cpp .mk .sh等文件时自动调用SetTitle 函数
    autocmd BufNewFile *.[ch],*.hpp,*.cpp,*.cc,Makefile,*.mk,*.sh,*.go,*.py exec ":call SetTitle()"
endfunction 
call BuildComment()

" 加入注释
func Comment(start_line, label)
    if a:label == "*"
        call setline(a:start_line, "/*================================================================")
    elseif a:label == "#"
        call setline(a:start_line, "#=================================================================")
    endif

    call setline(a:start_line + 1, a:label."  ")
    call setline(a:start_line + 2, a:label."  文件名称：".expand("%:t"))
    call setline(a:start_line + 3, a:label."  创 建 者: ".g:vimuser)
    call setline(a:start_line + 4, a:label."  创建日期：".strftime("%Y年%m月%d日"))
    call setline(a:start_line + 5, a:label."  邮    箱：".g:useremail)
    call setline(a:start_line + 6, a:label."  ")

    if a:label == "*"
        call setline(a:start_line + 7, "================================================================*/")
    elseif a:label == "#"
        call setline(a:start_line + 7, "#=================================================================")
    endif

    call setline(a:start_line + 8, "")
endfunc

" 定义函数SetTitle，自动插入文件头 
func SetTitle()
	if &filetype == 'make'
		call Comment(1, "#")
	elseif &filetype == 'sh' 
		call setline(1,"#!/bin/bash") 
		call setline(2,"")
        call Comment(3, "#")
	else
        if expand("%:e") == 'hpp' 
            call Comment(1, "*")
            call setline(10, "#ifndef __".toupper(expand("%:t:r"))."_H__") 
            call setline(11, "#define __".toupper(expand("%:t:r"))."_H__") 
            call setline(12, "#ifdef __cplusplus") 
            call setline(13, "extern \"C\"") 
            call setline(14, "{") 
            call setline(15, "#endif") 
            call setline(16, "") 
            call setline(17, "#ifdef __cplusplus") 
            call setline(18, "}") 
            call setline(19, "#endif") 
            call setline(20, "#endif //".toupper(expand("%:t:r"))."_H") 
        elseif expand("%:e") == 'h' 
            call Comment(1, "*")
            call setline(10, "#pragma once") 
        elseif expand("%:e") == 'py'
            call setline(1,"#!/usr/bin/python")
            call setline(2,"# -*- coding: utf-8 -*- ")
            call Comment(3, "#")
        elseif expand("%:e") == 'go'
            call Comment(1, "*")
        elseif &filetype == 'c' 
            call Comment(1, "*")
            call setline(10, "#include \"".expand("%:t:r").".h\"") 
        elseif &filetype == 'cpp'
            call Comment(1, "*")
            call setline(10, "#include \"".expand("%:t:r").".h\"")
        elseif &filetype == 'cc'
            call Comment(1, "*")
            call setline(10, "#include \"".expand("%:t:r").".h\"")
        endif
    endif
endfunc

function Doxygen()
    let g:DoxygenToolkit_briefTag_funcName = "yes"
    " for C++ style, change the '@' to '\'
    let g:DoxygenToolkit_commentType          = "C++"
    let g:DoxygenToolkit_briefTag_pre         = "brief "
    let g:DoxygenToolkit_templateParamTag_pre = "tparam "
    let g:DoxygenToolkit_paramTag_pre         = "param "
    let g:DoxygenToolkit_returnTag            = "return "
    let g:DoxygenToolkit_throwTag_pre         = "throw " " @exception is also valid
    let g:DoxygenToolkit_fileTag              = "file "
    let g:DoxygenToolkit_dateTag              = "date "
    let g:DoxygenToolkit_authorTag            = "author "
    let g:DoxygenToolkit_versionTag           = "version "
    let g:DoxygenToolkit_blockTag             = "name "
    let g:DoxygenToolkit_classTag             = "class "
    let g:DoxygenToolkit_authorName           = g:vimuser
    let g:doxygen_enhanced_color              = 1
    let g:DoxygenToolkit_blockHeader          = "/****************************************************************************"
    let g:DoxygenToolkit_blockFooter          = "****************************************************************************/"
    let g:DoxygenToolkit_startCommentTag      = ""
    let g:DoxygenToolkit_interCommentTag      = "*"
    let g:DoxygenToolkit_endCommentTag        = ""
    let g:DoxygenToolkit_startCommentBlock    = ""
    let g:DoxygenToolkit_interCommentBlock    = "* "
    let g:DoxygenToolkit_endCommentBlock      = ""
endfunction
call Doxygen()

" autocmd! 删除自动命令
" autocmd 监听指定命令做相应操作
function LspSetting()
    let g:lsp_settings_servers_dir='~/.local/share/vim-lsp-settings/servers'
    let g:asyncomplete_auto_completeopt = 0
    let g:lsp_signature_help_enabled = 0
    set completeopt=menuone,noinsert,noselect " preview
"    autocmd CursorMovedI * if pumvisible() == 0 | pclose | endif 
"    autocmd InsertLeave * if pumvisible() == 0 | pclose | endif
"    autocmd CompleteDone * if pumvisible() == 0 | pclose | endif
"    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif "pumvisible 0: 开启 判断窗口时候打开，
    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
"    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    " inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"
    inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"
endfunction
call LspSetting()

function Ack()
    cnoreabbrev Ack Ack!
    let g:ackprg = 'ag --nogroup --nocolor --column'
endfunction
call Ack()

function AsyncRun()
    " 如果递归到根目录还没找到，那么文件所在目录就被当作项目目录。
    let g:asyncrun_rootmarks = ['.svn', '.git', '.root', '_darcs', 'build.xml'] 
    " 自动打开 quickfix window ，高度为 8
    let g:asyncrun_open = 8
endfunction
call AsyncRun()

function VimDelve()
    let g:delve_new_command = 'new'
endfunction 
call VimDelve()

"Command命令	常规模式	可视化模式	运算符模式	插入模式	命令行模式
":map	            √	        √	        √	 	 
":nmap	            √	 	 	 	 
":vmap	 	                    √	 	 	 
":omap	 	 	                            √	 	 
":map!	 	 	 	                                    √	        √
":imap	 	 	 	                                    √	 
":cmap	 	 	 	 	                                            √
" <Esc>代表Escape键:<CR>代表Enter键；<D>代表Command键。
" Alt键可以使用<M-key>或<A-key>来表示。<C>代表Ctrl.
" 对于组合键，可以用<C-Esc>代表Ctrl-Esc；使用<S-F1>表示Shift-F1
" % 当前完整的文件名
" %:h 文件名的头部，即文件目录.例如../path/test.c就会为../path
" %:t 文件名的尾部.例如../path/test.c就会为test.c
" %:r 无扩展名的文件名.例如../path/test就会成为test
" %:p 绝对路径
" %:e 扩展名
" map 可以递归映射，noremap 非递归映射

nmap <C-o> :NERDTree<CR>
nmap <C-i> :NERDTreeClose<CR>
nmap <S-f> :ClangFormat <CR>
nmap <C-f> :Ack <cword><CR>

" 快捷键 配置 <C-R>插入寄存器数据，=是vim的特殊寄存器
nmap <C-h> :vsp <C-R>=expand('%:p:r').'.h'<CR><CR>
nmap <C-p> :vsp <C-R>=expand('%:p:r').'.cpp'<CR><CR>
nmap <S-c> :vsp <C-R>=expand('%:p:r').'.c'<CR><CR>
nmap <S-p> :vsp <C-R>=expand('%:p:r').'.cc'<CR><CR>

" 查看二进制文件
nmap <S-b> :!xxd <CR>
nmap <S-q> :q!<CR>

" 设置 F5 从工程根目录编译整个工程
nmap <silent> <F5> :AsyncRun -cwd=<root> make -j8 <CR>
" 设置 F6 打开/关闭 Quickfix 窗口
nmap <F6> :call asyncrun#quickfix_toggle(8)<CR>
" ale快捷键
nmap <leader>p <Plug>(ale_previous_wrap)
nmap <leader>n <Plug>(ale_next_wrap)
nmap <leader>e :ALEDetail<CR>
nmap <leader>l :ALEInfo<CR>

nmap <leader>f :LeaderfFunction<CR>
nmap <leader>b :GoBuild<CR>
nmap <leader>r :GoRun<CR>
nmap <leader>i :GoImports<CR>
nmap <leader>t :Tagbar<CR>
nmap <leader>c :ccl<CR>
nmap <leader>o :copen<CR>
nmap <F7> :DlvAddBreakpoint<CR>
nmap <F8> :DlvRemoveBreakpoint<CR>
nmap <F9> :DlvDebug<CR>
