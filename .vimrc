call plug#begin('~/.vim/autoload')  " 表示插件安装在~/.vim/autoload 目录

Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar'
Plug 'flazz/vim-colorschemes'
Plug 'scrooloose/nerdtree'
Plug 'skywind3000/asyncrun.vim'
Plug 'mileszs/ack.vim'
Plug 'w0rp/ale'
Plug 'fatih/vim-go'
Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'rhysd/vim-clang-format'
" Plug 'vim-scripts/luainspect.vim'
" Plug 'xolox/vim-misc'
" Plug 'xolox/vim-lua-ftplugin'
"Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'sebdah/vim-delve'
Plug 'Yggdroot/LeaderF'
Plug 'prabirshrestha/async.vim' " 补全插件
Plug 'prabirshrestha/asyncomplete.vim' " 利用 async.vim 做的补全，相当于一个补全引擎。
Plug 'prabirshrestha/vim-lsp' " Async Language Server Protocol plugin
Plug 'mattn/vim-lsp-settings' " 配合vim-lsp使用，自动配置lsp 识别设置
Plug 'prabirshrestha/asyncomplete-lsp.vim' " 将 lsp 中的内容交给 asyncomplete 做补全
Plug 'jiangmiao/auto-pairs'
" Plug 'hrsh7th/vim-vsnip'
" Plug 'hrsh7th/vim-vsnip-integ'
Plug 'plasticboy/vim-markdown'
"Plug 'lvht/phpcd.vim', { 'for': 'php', 'do': 'composer install' }
" Plug 'mxw/vim-jsx'
" Plug 'isRuslan/vim-es6'
" Plug 'pangloss/vim-javascript'
" html 基本框架
" Plug 'mattn/emmet-vim'
" Plug 'prettier/vim-prettier', {
"  \ 'do': 'cnpm install',
"  \ 'for': ['javascript', 'typescript', 'css', 'jsx', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }


call plug#end()

set t_Co=256
syntax on
" 设置文件读的格式
set fencs=utf-8,gbk 
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
set backspace=2
" 是vim不闪屏
set novisualbell
" 设置tab等于4个空格
set tabstop=4
" 自动缩进时缩进为4格(sw)
set shiftwidth=4
" 启动折叠
" set foldenable
" 启用语法折叠
" set foldmethod=syntax
set nofoldenable
set fdm=indent

"  不换行
set nowrap
" #开启自动缩进   (ai)
set autoindent
" #编辑时可以将tab替换为空格(et)
set expandtab
" set path=.,/usr/include,/usr/include/c++/4.4.7,/usr/include/c++/4.4.4
set background=dark " 黑色背景
set showcmd " 设置右下角显示完整命令
set laststatus=2      " 总是显示状态栏
set cindent
set mouse=nv " 设置鼠标可以在普通模式跟可视模式使用
set tags=tags,../tags,../../tags,~/workspace/include/tags
colorscheme molokai
let mapleader=';'

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
    let g:ale_sign_column_always = 1  " 保持侧边栏可见
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
    " let g:ale_cpp_clang_options = '-std=c++11 -Wall'
    " let g:ale_cpp_gcc_options = '-std=c++11 -Wall'

    " ------------------  ale c   --------------------------
    let b:ale_c_parse_makefile = 1
    " let g:ale_c_parse_compile_commands = 0
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
    call setline(a:start_line + 3, a:label."  创 建 者: mongia")
    call setline(a:start_line + 4, a:label."  创建日期：".strftime("%Y年%m月%d日"))
"    call setline(a:start_line + 5, a:label."  邮    箱：mr_pengmj@outlook.com")
    call setline(a:start_line + 5, a:label."  ")

    if a:label == "*"
        call setline(a:start_line + 6, "================================================================*/")
    elseif a:label == "#"
        call setline(a:start_line + 6, "#=================================================================")
    endif

    call setline(a:start_line + 7, "")
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
    let g:DoxygenToolkit_authorName           = "mongia"
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
nmap <F8> :DlvDebug<CR>
