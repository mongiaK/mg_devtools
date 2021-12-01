#!/bin/bash

set -e

source ./log.sh

function check_vim_version {
    if command -v vim >/dev/null 2>&1; then
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
}

function check_user {
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
}

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

distributor_id=
function get_os {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
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
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        distributor_id="MacOS"
    else
        distributor_id="Unknown"
    fi
    log_info "your device is ${distributor_id}"
}

packages=
exebin=
pkgtools=
condition=
function init_packages {
    case $distributor_id in
    Ubuntu)
        packages=(silversearcher-ag ctags wget tmux clang-format)
        exebin=(ag ctags wget tmux clang-format)
        pkgtools=apt
        condition="-y"
        ;;
    CentOS)
        packages=(the_silver_searcher ctags wget tmux clang-format)
        exebin=(ag ctags wget tmux clang-format)
        pkgtools=yum
        condition="-y"
        ;;
    MacOS)
        packages=(the_silver_searcher ctags wget tmux clang-format)
        exebin=(ag ctags wget tmux clang-format)
        pkgtools=brew
        ;;
    *)
        log_warning "[`date -s`] not support this system yet, sorry!"
        exit 0
        ;;
    esac
}

function install_packages {
    if [[ ${#packages[@]} -ne ${#exebin[@]} ]]; then
        log_error "packages number is not equal with exebin"
        exit 1
    fi

    for i in $(seq 0 ${#packages[@]}); do
         if command -v ${exebin[$i]} >/dev/null 2>&1; then
             log_success "${exebin[$i]} 已安装"
         else
             sudo $tools install ${condition} ${packages[$i]}
             check_result "${$exebin[$i]}"
         fi
    done
}

function copy_config_to_user_dir {
    build_dir=/tmp/vimenv
    mkdir -p ${build_dir}
    pushd ${build_dir}
    git clone https://hub.fastgit.org/junegunn/vim-plug.git
    git clone https://hub.fastgit.org/PengMengJia/vim.git
    popd
    
    if [ -e "$HOME/.vim/autoload/plug.vim" ]; then
        log_info "plug.vim 已存在"
    else
        mkdir -p ~/.vim/autoload
        cp ${build_dir}/vim-plug/plug.vim ~/.vim/autoload/
    fi
    
    if [ -e "$HOME/.vimrc" ]; then
        log_info ".vimrc 已存在"
    else
        cp ${build_dir}/vim/.vimrc ~/
    fi
    
    if [ -e "$HOME/.tmux.conf" ]; then
        log_info ".tmux.conf 已存在"
    else
        cp ${build_dir}/vim/.tmux.conf ~/
    fi
    
    rm -rf ${build_dir}
}

function main {
    log_info "🙈 【install vim develop env!】"
    
    check_user

    check_vim_version

    get_os

    init_packages

    install_packages

#    copy_config_to_user_dir

    log_info "🙈 【install develop env success! ( open vim run :PlugInstall )】" 
}

main
