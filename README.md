# mg_devtools

个人收藏的编辑器 / Shell / 窗口管理器配置文件，以及一套用于在 Linux（Ubuntu、CentOS、Arch）和 macOS 上引导安装 CLI 开发环境（vim/nvim/tmux 及配套工具）的 bootstrap 脚本。

本仓库没有可构建的应用程序，"交付物"就是配置文件和 `install/` 下的 bash 安装脚本。

## 目录结构

每个顶层目录都是某个工具独立的配置树，运行时彼此不引用——用户自行 copy / symlink 到 `$HOME`。

| 目录 / 文件         | 描述                                                                     |
| ------------------- | ------------------------------------------------------------------------ |
| `install/`          | bootstrap 脚本：`build_vim.sh`（vim 环境）与 `build_env.sh`（各类工具环境配置） |
| `vim/.vimrc`        | vim 8+ 单文件配置，基于 **vim-plug**（首次运行自动 curl 拉取 `plug.vim`） |
| `nvim/`             | Lua 配置，入口 `init.lua → require("core")`，基于 **lazy.nvim**          |
| `tmux/.tmux.conf`   | tmux 配置，前缀键重绑为 `C-a`，base-index 1                              |
| `dotfiles/`         | Wayland 桌面相关（`hypr/`、`waybar/`、`rofi/`、`icons/`、`scripts/` 等），多数为占位空目录，目前仅 `waybar/{config,style.css}` 有实际内容 |
| `alacritty/`        | Alacritty 终端配置                                                       |
| `bspwm/bspwmrc`     | bspwm 窗口管理器配置                                                     |
| `polybar/<theme>/`  | polybar 主题配置                                                         |
| `rofi/`             | rofi 启动器配置与主题                                                    |
| `fontconfig/`       | 字体配置                                                                 |
| `install.sh`        | 根目录存根脚本（仅一个 `pkgs` 数组，无实际安装逻辑），真正的安装入口在 `install/` |
| `参考文档地址.txt`  | 中文参考资料链接备忘                                                     |

## 快速开始

### 1. 安装 vim 开发环境

通过宿主包管理器安装 `ag` / `ctags` / `wget` / `tmux` / `clang-format` / `ripgrep` / `global`，然后把 `vim/.vimrc` 和 `tmux/.tmux.conf` 拷贝到 `$HOME`：

```bash
bash install/build_vim.sh
```

> ⚠️ 该脚本使用 `set -e -x`（失败即终止、逐条打印命令），并会交互式地询问 author/email 和 sudo 确认，**无法非交互运行**。脚本依据 `$distributor_id` 分发，按发行版选择包名（如 Ubuntu/Arch 用 `silversearcher-ag`，CentOS/macOS 用 `the_silver_searcher`），并通过 `exebin` 校验每个安装。新增工具时需同时维护 `packages` 和 `exebin` 两个数组且长度一致，否则脚本中止。

vim 插件安装：进入 vim 执行 `:PlugInstall`。

### 2. 配置各类工具环境

`build_env.sh` 是一个扁平的分发器，一次传入**一个**子命令：

```bash
bash install/build_env.sh go        # GOPROXY=https://goproxy.cn, GO111MODULE=on
bash install/build_env.sh git       # 全局 user.name/email + credential.helper store
bash install/build_env.sh npm       # taobao registry
bash install/build_env.sh yarn      # taobao registry
bash install/build_env.sh cnpm      # 通过 npm 安装 cnpm
bash install/build_env.sh shell     # 追加 aliases/exports 到 ~/.zshrc 或 ~/.bashrc
bash install/build_env.sh oh-my-zsh # 从 gitee 镜像安装 oh-my-zsh
```

每个 setter 都独立幂等（通过 `command -v` 或 rc 文件中的 marker 注释如 `'mongia usage'` 去重）。

### 3. nvim 配置

nvim 配置首次启动时由 lazy.nvim 自动安装插件，无需手动 `:PlugInstall`。其 require 链即架构本身：

1. `init.lua` → `require("core")` → `lua/core/init.lua`
2. `core/init.lua` 依次加载：`core.basic`（leader = space，约 50 个 vim 选项）、`core.lazy`（引导 lazy.nvim 并 `require("lazy").setup("plugins", ...)`）、`core.keymaps`、`core.autocmds`、`core.options`，最后设置 `background=dark` + `colorscheme tokyonight`。
3. `lazy.setup("plugins")` 自动导入 `lua/plugins/` 下**每个**文件（`ai`、`code`、`lang`、`lsp_cmp`、`telescope`、`tools`、`treesitter`、`ui`），每个文件返回一个插件 spec 列表。
4. `lua/plugins/*.lua` 中的 spec 把详细配置委托给 `lua/plugins_config/<name>.lua`：`config = require("plugins_config.<name>").config`。**`plugins/` 声明安装什么、何时懒加载；`plugins_config/` 才是真正的配置表与快捷键。** 调整行为改 `plugins_config/`；新增插件在对应 `plugins/<category>.lua` 加 spec 并新建 `plugins_config/<name>.lua`。
5. 全局路径定义在 `lua/core/config.lua`（`mg_cachedir = ~/.cache/nvim/`、`mg_datadir = stdpath("data") .. "/site/"`），复用而非硬编码。

`nvim/mgsnips/` 存放自定义 LuaSnip snippets；`nvim/lazy-lock.json` 固定插件版本并已提交。

## 依赖速查

| 工具 | 依赖                              |
| ---- | --------------------------------- |
| vim  | global、ripgrep、ctags            |
| nvim | ripgrep、lazygit、global、ctags   |

## 常见问题汇总

1. ag 搜索软件安装问题

   - 官网下载地址 [ag 官网](https://github.com/mizuno-as/silversearcher-ag)
   - yum 直接安装失败，可以配置阿里云的镜像，[阿里云源](https://developer.aliyun.com/mirror)

2. vim-plug 安装插件失败（github 访问错误）

   - 打开 `~/.vim/autoload/plug.vim` 文件，从网上找一下 github 的替代地址，一般安装浏览器插件有推荐的

3. zsh 安装失败

   - 一般就是 github 访问异常，建议科学上网

4. mac 电脑安装 brew 包管理器失败

   ```bash
   /usr/bin/ruby -e "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install)"
   ```

   参考链接 [国内安装 brew 正确姿势](https://cloud.tencent.com/developer/article/1853162)

## 中间可能用到的工具

| 地址                            | 描述               |
| ------------------------------- | ------------------ |
| https://websites.ipaddress.com/ | 查询域名对应 ip 地址 |

## Windows Terminal 配色

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
}
```
