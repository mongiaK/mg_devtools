# mg_devtools

个人开发环境配置集合：vim / nvim / tmux 编辑器配置，Linux（Ubuntu、CentOS、Arch）与 macOS 的 bootstrap 安装脚本，以及一套面向 Arch + Hyprland 的 Wayland 桌面 dotfiles。

本仓库没有可构建的应用程序，交付物就是配置文件和 bash 安装脚本。

## 目录结构

每个顶层目录都是某个工具独立的配置树，运行时彼此不引用——按需 copy / symlink 到 `$HOME` 或 `~/.config`。

| 目录 / 文件        | 描述                                                                   |
| ------------------ | ---------------------------------------------------------------------- |
| `install/`         | bootstrap 脚本：`build_vim.sh`（vim 环境）、`build_env.sh`（工具环境分发器） |
| `vim/`             | vim 8+ 配置：`.vimrc`（基于 **vim-plug**，首启自动拉取 plug.vim）、`vimrc`、`templates/` 文件模板 |
| `nvim/`            | Neovim Lua 配置，入口 `init.lua → require("core")`，基于 **lazy.nvim**  |
| `tmux/`            | `tmux.conf`：前缀键 `C-a`、base-index 1、鼠标开启、vi copy-mode、系统剪贴板 |
| `dotfiles/`        | Arch Linux + Hyprland Wayland 桌面完整配置（详见下文）                 |
| `.gitignore`       | 忽略 `.claude-trace`、`.DS_Store`                                      |

## 快速开始

### 1. 安装 vim 开发环境

`build_vim.sh` 按发行版（Ubuntu / CentOS / Arch / macOS）用 apt / yum / pacman / brew 安装 `ag`、`ctags`、`wget`、`tmux`、`clang-format`、`ripgrep`、`global` 等工具，并把配置拷贝到 `$HOME`：

```bash
bash install/build_vim.sh
```

> ⚠️ 脚本使用 `set -e -x`（失败即终止、逐条打印命令），会交互式询问 author/email 和 sudo 确认，**无法非交互运行**。包名与校验命令分别维护在 `packages` / `exebin` 两个数组中，长度必须一致，否则脚本中止。新增工具需同时改两处。

vim 插件安装：进入 vim 执行 `:PlugInstall`。

### 2. 配置各类工具环境

`build_env.sh` 是扁平分发器，一次传入**一个**子命令：

```bash
bash install/build_env.sh go         # GOPROXY=https://goproxy.cn, GO111MODULE=on
bash install/build_env.sh git        # 全局 user.name/email + credential.helper store
bash install/build_env.sh npm        # taobao registry
bash install/build_env.sh yarn       # taobao registry
bash install/build_env.sh cnpm       # 通过 npm 安装 cnpm
bash install/build_env.sh shell      # 追加 aliases/exports 到 ~/.zshrc 或 ~/.bashrc
bash install/build_env.sh oh-my-zsh  # 从 gitee 镜像安装 oh-my-zsh
```

每个 setter 独立幂等（通过 `command -v` 或 rc 文件中的 marker 注释 `'mongia usage'` 去重）。

### 3. nvim 配置

首次启动由 lazy.nvim 自动安装插件，无需手动 `:PlugInstall`。require 链即架构：

1. `init.lua` → `require("core")` → `lua/core/init.lua`
2. `core/init.lua` 依次加载 `core.basic`（leader = space）、`core.lazy`（引导 lazy.nvim 并 `require("lazy").setup("plugins", ...)`）、`core.keymaps`、`core.autocmds`、`core.options`，最后 `background=dark` + `colorscheme tokyonight`
3. `lazy.setup("plugins")` 自动导入 `lua/plugins/` 下每个文件（`ai`、`code`、`lang`、`lsp_cmp`、`telescope`、`tools`、`treesitter`、`ui`），每个文件返回插件 spec 列表
4. `lua/plugins/*.lua` 的 spec 把配置委托给 `lua/plugins_config/<name>.lua`：`config = require("plugins_config.<name>").config`。**`plugins/` 声明装什么、何时懒加载；`plugins_config/` 才是真正的配置与快捷键。** 调行为改 `plugins_config/`；加插件在对应 `plugins/<category>.lua` 加 spec 并新建 `plugins_config/<name>.lua`
5. 全局路径定义在 `lua/core/config.lua`（`mg_cachedir`、`mg_datadir`），复用而非硬编码

`nvim/mgsnips/` 自定义 LuaSnip snippets（c / cpp / go / sh）；`nvim/lazy-lock.json` 固定插件版本并已提交。

### 4. tmux

把 `tmux/tmux.conf` 拷贝/软链为 `~/.tmux.conf`。要点：

- 前缀键 `C-a`（`C-a a` 向内层发送前缀，`C-a C-a` 切上一窗口）
- `base-index 1`、关窗自动补号、history 10000、`escape-time 0`
- 鼠标开启，copy-mode 为 vi 键位，拖选自动进系统剪贴板（pbcopy / wl-copy / xclip 自适应）

### 5. Arch + Hyprland 桌面（dotfiles/）

`dotfiles/` 是自洽的 Wayland 桌面配置树，部署方式为**把仓库中的 dotfiles 根软链为 `~/.config`**：

```bash
cd dotfiles
./install.sh                # 完整安装：装包 + 软链 ~/.config + 拷贝 greetd
./install.sh --dry-run      # 只打印将执行的动作
./install.sh --skip-packages
./install.sh --skip-greetd
```

- `pkgs.list`：pacman 官方包 + AUR 包（yay/paru）清单（hyprland 全家桶、waybar、wofi、walker、kitty、fcitx5 等）
- `hypr/`：Hyprland 主配置为 **Lua 模块**（0.55+）——`monitors`、`env`、`input`、`appearance`、`theme`、`keybinds`、`rules`、`autostart`，另有 `hypridle.conf`、`hyprlock.conf`
- `waybar/`：`config.jsonc` + `style.css`，含 `custom/theme` 主题切换模块与 cpu / memory / network 脚本
- `colors/`：Catppuccin 四套色板（latte / frappe / macchiato / mocha），`current.css` 为当前主题软链
- `scripts/theme-toggle.sh`：mocha ↔ latte 全局切换（写 `theme` 状态、切色板软链、更新 GTK / foot 配置、reload hyprland + waybar，带 flock 防并发）
- `greetd/`：登录管理器配置，安装时拷贝到 `/etc/greetd`
- 其余：`foot/`、`wofi/`、`walker/`、`mako` 相关、`qt5ct`/`qt6ct`、`gtk-3.0/4.0`、`scripts/`

## 依赖速查

| 工具 | 依赖                             |
| ---- | -------------------------------- |
| vim  | global、ripgrep、ctags           |
| nvim | ripgrep、lazygit、global、ctags  |

## 常见问题

1. **ag 安装失败**：yum 源可换阿里云镜像（[阿里云源](https://developer.aliyun.com/mirror)）
2. **vim-plug 装插件失败（github 访问错误）**：改 `g:plug_url_format` 为镜像，或编辑 `~/.vim/autoload/plug.vim` 中的 github 地址
3. **zsh / oh-my-zsh 安装失败**：多为 github 访问异常；本仓库 `oh-my-zsh` 子命令已走 gitee 镜像
4. **macOS 安装 brew 失败**：参考 [国内安装 brew 正确姿势](https://cloud.tencent.com/developer/article/1853162)

## 实用工具

| 地址                       | 描述             |
| -------------------------- | ---------------- |
| https://websites.ipaddress.com/ | 查询域名对应 IP |

## Windows Terminal 配色

```json
{
    "name": "Flat UI Palette v1 Modified",
    "background": "#1C2024",
    "foreground": "#ECF0F1",
    "cursorColor": "#FFFFFF",
    "selectionBackground": "#FFFFFF",
    "black": "#000000",
    "red": "#E74C3C",
    "green": "#27AE60",
    "yellow": "#F1C40F",
    "blue": "#2980B9",
    "purple": "#8E44AD",
    "cyan": "#16A085",
    "white": "#FFFFFF",
    "brightBlack": "#52677C",
    "brightRed": "#E67E22",
    "brightGreen": "#2ECC71",
    "brightYellow": "#F1C40F",
    "brightBlue": "#3498DB",
    "brightPurple": "#9B59B6",
    "brightCyan": "#1ABC9C",
    "brightWhite": "#ECF0F1"
}
```
