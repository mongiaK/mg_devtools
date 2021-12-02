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

source ./log.sh

set_git_env()
{
    if ! command -v git >/dev/null 2>&1 ; then
        log_warning "git uninstall, please install and run this script!"
        return
    fi
    git config --global pager.branch false
    git config --global user.name mongia
    git config --global user.email mr_pengmj@outlook.com
    git config --global credential.helper store
}

set_go_env()
{
    if ! command -v go >/dev/null 2>&1; then
        log_warning "go uninstall, please install and run this script!"
        return
    fi
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

set_node_cnpm()
{
    if command -v npm >/dev/null 2>&1 ; then
        if ! command -v cnpm >/dev/null 2>&1 ; then
            sudo npm install -g cnpm --registry=https://registry.npm.taobao.org
        fi
    fi
}

shell_rc=""
get_shell_file()
{
    shell=${SHELL##*/}
    case ${shell} in
        zsh)
            shell_rc=${HOME}/.zshrc
            ;;
        bash)
            shell_rc=${HOME}/.bashrc
            ;;
        *)
            log_warning "unsurport your shell, sorry!"
            ;;
    esac
    log_info "your shell rc is ${shell_rc}"
}

set_shell_rc_config()
{
    if grep 'mongia' ${shell_rc} >/dev/null 2>&1; then 
        return
    fi
cat << EOF >> ${shell_rc}

# mongia usage
export TERM=xterm-256color

export SVN_EDITOR=vim
export GIT_EDITOR=vim

alias grep='grep --color'
alias tmux='tmux -2'
alias ls='ls --color=auto'
alias vi='vim'
alias cmake='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
EOF
}

main()
{
    log_info "build develop env. git, go, zsh ...!"

    set_go_env 

    set_git_env

    set_node_cnpm

    get_shell_file

    set_shell_rc_config

    log_info "install develop env success!" 
}

main 
