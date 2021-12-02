# c++ 服务器快速构建开发环境

**本脚本包含很多用户自己名称，建议使用者进行相应替换（关键字：mongia，pengmj，pengmengjia）**

## 文件功能

| 文件名 | 描述 |
| ----   | ---- |
| build_vim.sh | 构建终端vim开发环境，包含相应的一些工具库。基于vim version >= 8 的环境，低于这个版本不予安装 |
| build_env.sh | 初始化一些常用的开发配置变量。按需安装。|
| log.sh       | shell 打印log封装的函数 ｜
| .vimrc       | 作者自己的vim配置，可按需拿去，vim低版本问题可询问作者解决 |
| .tmux.conf   | tmux分屏配置文件 |

## 常见问题汇总
1. ag搜索软件安装问题
    * 官网下载地址 [ag 官网](https://github.com/mizuno-as/silversearcher-ag)
    * yum 直接安装失败，可以配置阿里云的镜像，[阿里云源](https://developer.aliyun.com/mirror)

2. vim-plug 安装插件失败（github 访问错误）
    *  打开~/.vim/autoload/plug.vim 文件，将文件里面的github.com的地址全部改为hub.fastgit.org。注释的可以不用管，不要用命令行直接替换，因为有些地方有转移字符

3. zsh 安装失败
    * 使用下面的命令安装 【git clone https://hub.fastgit.org/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh 】

4. mac电脑安装brew包管理器失败
    * 【/usr/bin/ruby -e "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install)" 】（参考链接 [国内安装brew正确姿势](https://cloud.tencent.com/developer/article/1853162)）

## 中间可能用到的工具
| 地址 | 描述 |
| ---- | ---- |
| https://websites.ipaddress.com/ | 查询域名对应ip地址 | 
