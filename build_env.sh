#!/bin/bash

#=================================================================
#  
#  文件名称：build_env.sh
#  创 建 者: mongia
#  创建日期：2021年01月13日
#  邮    箱：mr_pengmj@outlook.com
#  
#=================================================================

set -e

source ./lib.sh

log_info "🙈 【build develop env. git, go, zsh ...!】"

git_env()
{
    git config --global pager.branch false
    git config --global user.name mongia
    git config --global user.email mr_pengmj@outlook.com
    git config --global credential.helper store
}

go_env()
{
    # GOPROXY 配置go get 源，国内无法访问，必须配置goproxy
    go env -w GOPROXY=https://goproxy.cn

    # GOPRIVATE 指明域名为私有仓库，go get在处理该域名下的所有依赖时，会直接跳过goproxy和checksum等逻辑
    # go env -w GOPRIVATE=*.corp.example.com

    # GO111MODULE=off 无模块支持，go 会从 GOPATH 和 vendor 文件夹寻找包。
    # GO111MODULE=on 模块支持，go 会忽略 GOPATH 和 vendor 文件夹，只根据 go.mod 下载依赖。
    # GO111MODULE=auto 在 $GOPATH/src 外面且根目录有 go.mod 文件时，开启模块支持。
    go env -w GO111MODULE=on

    # 通过ssh公钥访问私有仓库，需配置git拉取私有仓库时使用ssh而不是https，修改.gitconfig 
    # [url "git@github.com"]:
    #    insteadOf = https://github.com/
}

node_env()
{
    if command -v npm >/dev/null 2>&1 ; then
        if !command -v cnpm >/dev/null 2>&1 ; then
            sudo npm install -g cnpm --registry=https://registry.npm.taobao.org
        fi
    fi
}

bash_env()
{
    if [ -z `grep 'mongia' $HOME/.bashrc` ]; then 
cat << EOF >> $HOME/.bashrc
# mongia usage
export TERM=xterm

export SVN_EDITOR=vim
export GIT_EDITOR=vim

alias grep='grep --color'
alias tmux='tmux -2'
alias ls='ls --color=auto'
alias vi='vim'
alias cmake='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
EOF
    fi
}

zsh_env()
{
    if command -v zsh >/dev/null 2>&1 ; then 
        if [ ! -d $HOME/.oh-my-zsh ]; then 
            wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh 
        else 
            log_info "oh-my-zsh 已安装"
        fi
    else 
        log_error "zsh is 未安装，请先安装zsh "
        exit 0
    fi 

    sudo chsh -s /bin/zsh

    if [ -e "$HOME/.tmux.conf" ]; then 
        if [ -z `grep 'zsh' $HOME/.tmux.conf` ]; then 
cat << EOF >> $HOME/.tmux.conf

set -g default-shell /bin/zsh

EOF
        else 
            log_info "已设置tmux默认的sh为zsh"
        fi 
    else 
        log_warning "tmux.conf 文件不存在"
    fi
}

main()
{
    git_env

    go_env 

    bash_env

    node_env
}

main 

read -p "Do you want to use zsh and oh-my-zsh in current user?" result
case $result in 
Y | y | yes | YES | Yes)
    zsh_env
    ;;
*)
    ;;
esac

log_success "🙈 【install develop env success! 】" 
