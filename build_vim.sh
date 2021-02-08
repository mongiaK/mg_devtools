#!/bin/bash

set -e

source ./lib.sh

log_info "🙈 【install vim develop env!】"

user=`echo ~`
if command -v vim 2>/dev/null; then
    vim_version=`vim --version | head -1 | awk -F' ' '{print $5}'`
    min_version=8
    if [ `echo "$vim_version >= $min_version" | bc` -eq 1 ]; then
	log_info "your vim version is $vim_version"
    else
        log_error "sorry, this script is not support vim less than version 8.0, your version is $vim_version !"
        exit 0
    fi
else
    log_error "you must install vim and version >= 8.0 !"
    exit 0
fi

if [ $EUID -ne 0 ]; then
    log_warning "Warning: This script use sudo or root to install tools!" 1>&2
    log_warning "be sure you can run sudo or you have installed tmux, ag, wget, ctags!!!"
    read -p "continue yes(Y) or not(N)" select
    case $select in
    Y | y | yes | YES | Yes)
        echo ""
        ;;
    *)
        exit 1
        ;;
    esac
fi

if [ -z `cat /etc/hosts | grep 'github'` ]; then
sudo bash -c 'cat >> /etc/hosts << EOF

52.74.223.119 github.com
151.101.76.133 raw.githubusercontent.com

EOF'
fi

check_result()
{
    if [ $? -eq 0 ]; then
        log_success "$1 安装成功"
    else
        log_error "$1 安装失败"
        if [ "$1" == "ag" ]; then
            log_warning "you can build source code for use, https://github.com/mizuno-as/silversearcher-ag "
	        log_warning "maybe you can set aliyun mirror, https://developer.aliyun.com/mirror"
        fi
        exit 1
    fi
}

if command -v lsb_release 2>/dev/null; then
    distributor_id=$(lsb_release -a 2>&1 | grep 'Distributor ID' | awk '{print $3}')
elif [ -e /etc/redhat-release ]; then
    distributor_id=$(cat /etc/redhat-release | cut -d ' ' -f 1)
elif [ -e /etc/fedora-release ]; then
    distributor_id="Fedora"
elif [ -e /etc/arch-release ]; then
    distributor_id="Arch"
elif [ -e /etc/SuSE-release ]; then
    distributor_id="SUSE"
elif [ -e /etc/mandriva-release ]; then
    distributor_id="Mandriva"
elif [ -e /etc/vine-release ]; then
    distributor_id="Vine"
elif [ -e /etc/gentoo-release ]; then
    distributor_id="Gentoo"
else
    distributor_id="Unkown"
fi

log_info "your device is ${distributor_id}"

case $distributor_id in
Ubuntu)
    if command -v ag >/dev/null 2>&1; then
        log_success "ag 已安装"
    else
        sudo apt install -y silversearcher-ag
        check_result "ag"
    fi

    if command -v ctags >/dev/null 2>&1; then
        log_success "ctags 已安装"
    else
        sudo apt install -y ctags
        check_result "ctags"
    fi

    if command -v wget >/dev/null 2>&1; then
        log_success "wget 已安装"
    else
        sudo apt install -y wget
        check_result "wget"
    fi

    if command -v tmux >/dev/null 2>&1; then
        log_success "tmux 已安装"
    else
        sudo apt install -y tmux
        check_result "tmux"
    fi

    if command -v clang-format >/dev/ull 2>&1; then 
        log_success "clang-format 已安装"
    else 
        sudo apt install -y clang-format 
        check_result "clang-format"
    fi
    ;;
CentOS)
    if command -v ag >/dev/null 2>&1; then
        log_success "ag 已安装"
    else
        sudo yum install -y the_silver_searcher
        check_result "ag"
    fi

    if command -v ctags >/dev/null 2>&1; then
        log_success "ctags 已安装"
    else
        sudo yum install -y ctags
        check_result "ctags"
    fi

    if command -v wget >/dev/null 2>&1; then
        log_success "wget 已安装"
    else
        sudo yum install -y wget
        check_result "wget"
    fi

    if command -v tmux >/dev/null 2>&1; then
        log_success "tmux 已安装"
    else
        sudo yum install -y tmux
        check_result "tmux"
    fi
    
    if command -v clang-format >/dev/ull 2>&1; then 
        log_success "clang-format 已安装"
    else 
        sudo yum install -y clang-format 
        check_result "clang-format"
    fi

    ;;
*)
    log_warning "[`date -s`] not support this system yet, sorry!"
    exit 0
    ;;
esac

if [ -e "$user/.vim/autoload/plug.vim" ]; then
    log_info "plug.vim 已存在"
else
    wget -P ~/.vim/autoload/ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    check_result "plug.vim"
fi

if [ -e "$user/.vimrc" ]; then
    log_info ".vimrc 已存在"
else
    wget -P ~/ https://raw.githubusercontent.com/PengMengJia/doc/master/develop_env_doc/.vimrc
    check_result "vimrc"
fi

if [ -e "$user/.tmux.conf" ]; then
    log_info ".tmux.conf 已存在"
else
    wget -P ~/ https://raw.githubusercontent.com/PengMengJia/doc/master/develop_env_doc/.tmux.conf
    check_result "tmux.conf"
fi

log_success "🙈 【install develop env success! ( open vim run :PlugInstall )】" 
