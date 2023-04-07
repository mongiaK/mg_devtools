#!/bin/bash

set -e -x 

COLOR_RED='\033[0;31m'
COLOR_ORANGE='\033[0;33m'
COLOR_GREEN='\033[0;32m'
COLOR_LIGHTCYAN='\033[0;36m'
COLOR_BLUE='\033[0;94m'
COLOR_MAGENTA='\033[95m'
COLOR_BOLD='\033[1m'
COLOR_NONE='\033[0m' # No Color

function log_error {
  >&2 echo -n -e "${COLOR_BOLD}${COLOR_RED}"
  >&2 echo "🙈 【$@】"
  >&2 echo -n -e "${COLOR_NONE}"
}

function log_warning {
  >&2 echo -n -e "${COLOR_ORANGE}"
  >&2 echo "🙈 【$@】"
  >&2 echo -n -e "${COLOR_NONE}"
}

function log_callout {
  >&2 echo -n -e "${COLOR_LIGHTCYAN}"
  >&2 echo "🙈 【$@】"
  >&2 echo -n -e "${COLOR_NONE}"
}

function log_info {
  >&2 echo -n -e "${COLOR_BLUE}"
  >&2 echo "🙈 【$@】"
  >&2 echo -n -e "${COLOR_NONE}"
}

function log_success {
  >&2 echo -n -e "${COLOR_GREEN}"
  >&2 echo "🙈 【$@】"
  >&2 echo -n -e "${COLOR_NONE}"
}

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

author=
email=
function check_user {
    if [ $EUID -ne 0 ]; then
        log_warning "Warning: This script use sudo or root to install tools!"
        log_warning "be sure you can run sudo or you have installed tmux, ag, wget, ctags!!!"
        read -p "🙈 【continue yes(Y) or not(N)】" select
        case $select in
        Y | y | yes | YES | Yes)
            echo ""
            ;;
        *)
            exit 1
            ;;
        esac
    fi

    read -p "🙈 【author: 】" author
    read -p "🙈 【email:  】" email
}

function check_result() {
    if [ $? -eq 0 ]; then
        log_success "$1 安装成功"
    else
        log_error "$1 安装失败"
        exit 1
    fi
}

function check_command() {
    if ! command -v $1 >/dev/null 2>&1 ; then
        log_error "$1 not found, please be sure you have install this";
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
function prepare_packages {
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
        log_warning "not support this system yet, sorry!"
        exit 0
        ;;
    esac

    check_command $pkgtools
}

function install_packages {
    if [[ ${#packages[@]} -ne ${#exebin[@]} ]]; then
        log_error "packages number is not equal to exebin"
        exit 1
    fi

    for ((i=0; i < ${#packages[@]}; i++)); do
         if command -v ${exebin[$i]} >/dev/null 2>&1; then
             log_success "${exebin[$i]} 已安装"
         else
             sudo $pkgtools install ${condition} ${packages[$i]}
             check_result "${exebin[$i]}"
         fi
    done
}

function copy_config_to_user_dir {
    build_dir=/tmp/vimenv
    mkdir -p ${build_dir}
    pushd ${build_dir}
    git clone https://hub.fastgit.xyz/junegunn/vim-plug.git
    git clone https://hub.fastgit.xyz/PengMengJia/mg_devtools.git
    
    if [ -e "$HOME/.vim/autoload/plug.vim" ]; then
        log_info "plug.vim 已存在"
    else
        mkdir -p ~/.vim/autoload
        cp vim-plug/plug.vim ~/.vim/autoload/
    fi
    
    if [ -e "$HOME/.vimrc" ]; then
        log_info ".vimrc 已存在"
    else
        cp mg_devtools/vim/.vimrc ~/
        sed -i "" "s/god@sky.com/${email}/g" ~/.vimrc
        sed -i "" "s/god/${author}/g" ~/.vimrc
    fi
    
    if [ -e "$HOME/.tmux.conf" ]; then
        log_info ".tmux.conf 已存在"
    else
        cp mg_devtools/tmux/.tmux.conf ~/
    fi
    popd
    rm -rf ${build_dir}
}

function main {
    log_info "install vim develop env!"
 
    get_os

    prepare_packages

    check_user

    check_vim_version

    install_packages

    copy_config_to_user_dir

    log_info "install develop env success! ( open vim run :PlugInstall ), if you have github.com error, maybe you can edit ~/.vim/autoload/plug.vim , change github.com with hub.fastgit.org" 
}

main
