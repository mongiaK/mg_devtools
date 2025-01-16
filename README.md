# 快速构建linux 环境下的各种工具

## 文件功能

| 文件名  | 描述                   | 依赖                            |
| ------- | ---------------------- | ------------------------------- |
| install | 存放各种工具的安装脚本 |                                 |
| vim     | vim 配置               | global，ripgrep，ctags          |
| tmux    | tmux 配置              |                                 |
| nvim    | nvim 配置              | ripgrep，lazygit，global，ctags |

## 常见问题汇总

1. ag搜索软件安装问题

   - 官网下载地址 [ag 官网](https://github.com/mizuno-as/silversearcher-ag)
   - yum 直接安装失败，可以配置阿里云的镜像，[阿里云源](https://developer.aliyun.com/mirror)

2. vim-plug 安装插件失败（github 访问错误）

   - 打开~/.vim/autoload/plug.vim 文件，从网上找一下github的替代地址，一般安装浏览器插件有推荐的

3. zsh 安装失败

   - 一般就是github访问异常，建议科学使用上网

4. mac电脑安装brew包管理器失败
   - 【/usr/bin/ruby -e "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install)" 】（参考链接 [国内安装brew正确姿势](https://cloud.tencent.com/developer/article/1853162)）

## 中间可能用到的工具

| 地址                            | 描述               |
| ------------------------------- | ------------------ |
| https://websites.ipaddress.com/ | 查询域名对应ip地址 |

## windows terminal 配色

```
{
            "background": "#1C2024",
            "black": "#000000",
            "blue": "#2980B9",
            "brightBlack": "#52677C",
            "brightBlue": "#3498DB",
            "brightCyan": "#1ABC9C",
            "brightGreen": "#2ECC71",
            "brightPurple": "#9B59B6",
            "brightRed": "#E67E22",
            "brightWhite": "#ECF0F1",
            "brightYellow": "#F1C40F",
            "cursorColor": "#FFFFFF",
            "cyan": "#16A085",
            "foreground": "#ECF0F1",
            "green": "#27AE60",
            "name": "Flat UI Palette v1 Modified",
            "purple": "#8E44AD",
            "red": "#E74C3C",
            "selectionBackground": "#FFFFFF",
            "white": "#FFFFFF",
            "yellow": "#F1C40F"
},

```
