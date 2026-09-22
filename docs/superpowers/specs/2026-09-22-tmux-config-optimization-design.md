# tmux 配置优化设计

日期：2026-09-22
范围：仅修改 `tmux/tmux.conf`（仓库内），不引入插件，不改 install 脚本。

## 背景与目标

用户以"多开"（同时管理大量窗口/会话）为主要用法，要求在保持现有极简零依赖风格的前提下改进四个方面：

1. **多开效率**——窗口编号、分屏、切窗格、回跳上一窗口
2. **状态栏信息**——多会话场景下可区分当前会话与窗口数量
3. **鼠标 + 复制**——鼠标操作与系统剪贴板集成
4. **稳定性**——vim/nvim 下的 Esc 延迟、焦点事件、truecolor

## 现状问题

| # | 问题 | 位置 |
|---|------|------|
| 1 | 注释错别字"转台了"应为"状态栏"；`status-fg` 注释写"黄色"实际为青色 `#00e5ee` | L7, L22 |
| 2 | `status-bg`/`status-fg` 为旧式分拆写法，tmux 3.x 推荐 `status-style` | L21-22 |
| 3 | 鼠标未开启，无法点选窗口、拖拽选中 | 缺失 |
| 4 | 缺 `escape-time`（vim Esc 卡顿）、`focus-events`、truecolor 声明 | 缺失 |
| 5 | 关窗后编号留洞（无 `renumber-windows`）；分屏/切窗格用默认键且不继承 cwd；`C-a C-a` 仅发前缀无法回上一窗 | 缺失 |
| 6 | 状态栏只有主机名+时间，多开会话无法区分 | L33-35 |

## 设计

### ① 多开效率

- `set -g renumber-windows on`：关闭窗口后自动补号，编号始终连续。
- 快捷分屏（继承当前目录）：
  - `C-a |` → `split-window -h -c "#{pane_current_path}"`
  - `C-a -` → `split-window -v -c "#{pane_current_path}"`（conf 中写作 `bind-key -- - ...` 或等价安全写法，避免 `-` 被解析为选项）
  - 新建窗口：`bind c new-window -c "#{pane_current_path}"`（默认键 `c`，同样继承当前目录）。
- `C-a C-a` 改为 `last-window`：连按前缀即在最近两窗口间跳转（多开最高频动作）。原 `send-prefix` 功能由 `C-a a` 保留（`bind a send-prefix`）。
- 窗格导航 vi 风格：`C-a h/j/k/l` → `select-pane -L/-D/-U/-R`。
- `setw -g mode-keys vi`：copy-mode 采用 vi 键位，与 nvim 习惯一致。

### ② 状态栏信息

- `set -g status-style "fg=#00e5ee,bg=black"` 合并替换 `status-bg`/`status-fg`，修正注释颜色描述。
- 左侧改为 `[ #S ]`（会话名），主机名移至右侧。
- 右侧格式：`[#I/#{session_windows}] [ #H ] [%Y-%m-%d %H:%M:%S]`（当前窗口号/会话窗口总数、主机、日期时间）。
- 保留 `status-interval 1`、`status-justify centre`、`status-left-length 40`、`status-right-length 80` 及现有 `window-status-format` / `window-status-current-format` 配色风格。

### ③ 鼠标 + 复制

- `set -g mouse on`：滚轮浏览历史、点击切换窗格/窗口、拖拽进入 copy-mode。
- 拖选松手自动复制到系统剪贴板，按平台分支：
  - macOS：`pbcopy`
  - Linux X11：`xclip -selection clipboard`
  - Linux Wayland：`wl-copy`
  - 实现：`if-shell "uname | grep -q Darwin"` 选择命令，否则按 `WAYLAND_DISPLAY`/`DISPLAY` 选择 `wl-copy` 或 `xclip`；绑定 `MouseDragEnd1Pane` 的 `copy-pipe-and-cancel`。
- 保留 `automatic-rename off`、`allow-rename off`（窗口名不被 shell 篡改）。

### ④ 稳定性

- `set -sg escape-time 0`：消除 vim/nvim 的 Esc 延迟。
- `set -g focus-events on`：编辑器感知焦点切换。
- `set -as terminal-features ",*:RGB"`：truecolor 色准（tmux ≥ 3.2，当前环境 3.2a 满足）。
- `set -g history-limit 10000`：加大回滚缓冲，多开跑日志可用。
- `set -g default-terminal "tmux-256color"` 保持不变。

### 明确不做（YAGNI）

- 不引入 tpm / 任何插件。
- 不做会话持久化恢复（resurrect/continuum）。
- 不改前缀 `C-a`、`base-index 1`、`pane-base-index 1`。
- 不改整体配色主题与窗口状态格式风格。
- 不改 `install/` 脚本。

## 验证方式

1. 语法与加载：`tmux -f tmux/tmux.conf start-server` 于临时 socket（如 `tmux -L cfgtest`），确认无报错。
2. 选项核对：在测试实例上 `show-options` / `list-keys` 断言关键项生效：`mouse on`、`escape-time 0`、`focus-events on`、`renumber-windows on`、`history-limit 10000`、`mode-keys vi`、`terminal-features` 含 RGB、`status-style`、`status-left` 含 `#S`、`status-right` 含 `#{session_windows}`、`C-a C-a` 绑定 `last-window`、`|` 与 `-` 分屏绑定存在、`MouseDragEnd1Pane` 绑定 `copy-pipe-and-cancel`。
3. 手工冒烟（可选，用户侧）：重载真实会话 `tmux source-file ~/.tmux.conf` 后验证鼠标点选、拖拽复制、`C-a C-a` 回跳。
4. 清理：`tmux -L cfgtest kill-server`。

## 交付与同步

- 变更文件：`tmux/tmux.conf`（单文件）。
- `$HOME/.tmux.conf` 为独立拷贝非软链：仓库改完后需重新 copy 才在真实环境生效；是否同步 `$HOME` 由用户在实施时确认。
- README 中 `tmux/.tmux.conf` 的路径描述与实际 `tmux/tmux.conf` 不符属既有笔误，本次不改 README（超出本设计范围）。
