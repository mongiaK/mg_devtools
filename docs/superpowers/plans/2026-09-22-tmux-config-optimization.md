# tmux 配置优化 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在保持零依赖极简风格的前提下，为 `tmux/tmux.conf` 补齐多开效率、状态栏信息、鼠标复制与稳定性四方面配置。

**Architecture:** 单文件增量改造：`tmux/tmux.conf` 按「稳定性基础选项 → 效率键位 → 鼠标/剪贴板 → 状态栏」四段依次改写，每段改完后用临时 socket（`tmux -L cfgtest -f tmux/tmux.conf`）加载并断言选项/键位生效。不引入插件、不改 install 脚本。

**Tech Stack:** tmux 3.2a（本机）、tmux conf DSL、bash 断言命令；剪贴板按平台选 `pbcopy` / `wl-copy` / `xclip`。

## Global Constraints

- 仅修改 `tmux/tmux.conf`；不引入 tpm/任何插件；不改 `install/` 脚本；不改 README。
- 保留：前缀 `C-a`、`base-index 1`、`pane-base-index 1`、`default-terminal "tmux-256color"`、`automatic-rename off`、`allow-rename off`、`status-interval 1`、`status-justify centre`、`status-left-length 40`、`status-right-length 80`、`window-status-format`/`window-status-current-format` 原有配色与格式。
- 不做会话持久化恢复。
- 所有命令在仓库根 `/Users/mongia/workspace/mg_devtools` 下执行（或用 `workdir` 参数等价指定）。
- 测试一律用临时 socket `cfgtest`，`kill-server` 清理，绝不触碰用户真实 tmux 会话。
- 断言失败必须修复后重跑，禁止跳过；成功标准以命令实际输出为准。
- 仓库工作区存在大量与本任务无关的既有未提交改动：**只 `git add tmux/tmux.conf`（及本 plan/spec 文档若未提交），禁止 `git add -A` / `git add .`**。

## 目标文件终态（参考全文）

实施各 Task 时按下方分段落地；Task 5 以全文核对。`tmux/tmux.conf` 最终内容：

```tmux
# 设置全局tmux快捷前缀 ctrl+a
set -g prefix C-a

unbind C-b # C-b即Ctrl+b键，unbind意味着解除绑定
bind a send-prefix # C-a a 向内层 tmux 发送前缀（嵌套场景）
bind C-a last-window # 连按前缀切换到上一个窗口（多开回跳）

# 状态栏刷新间隔
set -g status-interval 1

set -g default-terminal "tmux-256color"  # 这是 256色
set -as terminal-features ",*:RGB" # truecolor 色准

# 稳定性
set -sg escape-time 0 # 消除 vim/nvim 的 Esc 延迟
set -g focus-events on # 编辑器感知焦点切换
set -g history-limit 10000 # 回滚缓冲加大

# 这是序号从 1 开始
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on # 关窗后自动补号，编号连续

# 关闭状态栏窗口占位的自动命名
setw -g automatic-rename off
set-option -g allow-rename off

# 鼠标：滚轮翻历史、点击切窗、拖拽进 copy-mode
set -g mouse on

# copy-mode 采用 vi 键位（与 nvim 一致）
setw -g mode-keys vi

# 拖选松手自动复制到系统剪贴板（按平台选择命令）
if-shell "uname | grep -q Darwin" {
  bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
} {
  if-shell '[ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy' {
    bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy"
  } {
    bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection clipboard"
  }
}

# 快捷分屏 / 新建窗口：继承当前目录
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# 窗格导航 vi 风格
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# 状态栏：背景黑、前景青
set -g status-style "fg=#00e5ee,bg=black"
set-option -g status-justify centre

# 当前激活窗口在状态栏的展位格式
setw -g window-status-current-format '#[fg=#ff6a6a] [#I #W]'
# 未激活每个窗口占位的格式
setw -g window-status-format '#[fg=#ffffff] [#I #W]'

# 状态栏左右显示：左=会话名，右=窗口号/总数+主机+时间
set -g status-left-length 40
set -g status-left "[ #S ]"
set -g status-right-length 80
set -g status-right "[#I/#{session_windows}] [ #H ] [%Y-%m-%d %H:%M:%S]"
```

## 通用测试辅助（每个 Task 复用）

```bash
# 从仓库根执行；SOCK/CONF 变量供各断言步骤引用
SOCK=cfgtest
CONF=tmux/tmux.conf

tmux -L "$SOCK" kill-server 2>/dev/null || true
tmux -L "$SOCK" -f "$CONF" start-server
# start-server 后所有 show-options / list-keys 都带 -L "$SOCK"
```

失败清理（任何断言失败后执行）：`tmux -L cfgtest kill-server 2>/dev/null || true`

---

### Task 1: 稳定性 + 效率基础选项

**Files:**
- Modify: `tmux/tmux.conf:1-19`（前缀区与基础选项区）

**Interfaces:**
- Consumes: 现有文件内容（见仓库当前 35 行版本）。
- Produces: 全局选项 `escape-time=0`、`focus-events=on`、`history-limit=10000`、`terminal-features` 含 `RGB`、`renumber-windows=on`；前缀绑定改为 `bind a send-prefix` + `bind C-a last-window`（Task 2 的分屏键不依赖此项，但后续任务均在此文件上继续改）。

- [ ] **Step 1: 写失败断言（针对当前旧配置）**

在仓库根执行：

```bash
SOCK=cfgtest
CONF=tmux/tmux.conf
tmux -L "$SOCK" kill-server 2>/dev/null || true
tmux -L "$SOCK" -f "$CONF" start-server

fail=0
check() { # $1=描述, $2=实际输出, $3=期望子串
  case "$2" in
    *"$3"*) echo "PASS: $1" ;;
    *) echo "FAIL: $1 | got: $2 | want: $3"; fail=1 ;;
  esac
}

check "escape-time 0" "$(tmux -L "$SOCK" show-options -gsv escape-time 2>/dev/null || tmux -L "$SOCK" show-options -gv escape-time)" "0"
check "focus-events on" "$(tmux -L "$SOCK" show-options -gv focus-events)" "on"
check "history-limit 10000" "$(tmux -L "$SOCK" show-options -gv history-limit)" "10000"
check "renumber-windows on" "$(tmux -L "$SOCK" show-options -gv renumber-windows)" "on"
check "terminal-features RGB" "$(tmux -L "$SOCK" show-options -gsv terminal-features)" "RGB"
check "C-a C-a -> last-window" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E '^bind-key.*C-a')" "last-window"
exit $fail
```

（可将上述块存为临时脚本 `bash -s <<'EOF' ... EOF` 执行；下文 Step 3 为同一断言的复用形态。）

Run: 执行上述 bash 块  
Expected: 旧配置下至少 `FAIL: escape-time`、`FAIL: focus-events`、`FAIL: history-limit`、`FAIL: renumber-windows`、`FAIL: terminal-features RGB`，且 `C-a C-a` 断言为 `send-prefix` 而 FAIL（exit code 1）。

- [ ] **Step 2: 改写 `tmux/tmux.conf` 头部（前缀 + 稳定性选项）**

将文件第 1–19 行替换为：

```tmux
# 设置全局tmux快捷前缀 ctrl+a
set -g prefix C-a

unbind C-b # C-b即Ctrl+b键，unbind意味着解除绑定
bind a send-prefix # C-a a 向内层 tmux 发送前缀（嵌套场景）
bind C-a last-window # 连按前缀切换到上一个窗口（多开回跳）

# 状态栏刷新间隔
set -g status-interval 1

set -g default-terminal "tmux-256color"  # 这是 256色
set -as terminal-features ",*:RGB" # truecolor 色准

# 稳定性
set -sg escape-time 0 # 消除 vim/nvim 的 Esc 延迟
set -g focus-events on # 编辑器感知焦点切换
set -g history-limit 10000 # 回滚缓冲加大

# 这是序号从 1 开始
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on # 关窗后自动补号，编号连续

# 关闭状态栏窗口占位的自动命名
setw -g automatic-rename off
set-option -g allow-rename off
```

注意：`escape-time` 是 server 级选项，断言用 `show-options -gv escape-time`（不是 `-gsv`；`-s` 为 server 选项在部分版本与 `-g` 混用会报错，若报错改用 `tmux -L cfgtest show-options -v escape-time`）。

- [ ] **Step 3: 重跑断言验证通过**

Run: 与 Step 1 相同的 bash 断言块（kill-server 后重新 `start-server` 加载新 conf）  
Expected: 全部 `PASS`，exit 0。

- [ ] **Step 4: 清理并提交**

```bash
tmux -L cfgtest kill-server 2>/dev/null || true
git add tmux/tmux.conf
git commit -m "tmux: stability options and last-window prefix binding"
```

Expected: commit 成功，仅 `tmux/tmux.conf` 入库。

---

### Task 2: 多开效率键位（分屏 / 新窗 / 窗格导航 / vi copy-mode）

**Files:**
- Modify: `tmux/tmux.conf`（在 Task 1 结果上，`allow-rename` 行之后、`status-bg` 行之前插入）

**Interfaces:**
- Consumes: Task 1 已完成的文件（前缀与稳定性选项已就位）。
- Produces: prefix 表键位 `|`、`-`、`c`、`h`、`j`、`k`、`l`；session 级选项 `mode-keys=vi`。Task 3 的 `copy-mode-vi` 表绑定依赖 `mode-keys vi`（表名本身也以 `-T copy-mode-vi` 显式指定，顺序无硬依赖）。

- [ ] **Step 1: 写失败断言**

```bash
SOCK=cfgtest
CONF=tmux/tmux.conf
tmux -L "$SOCK" kill-server 2>/dev/null || true
tmux -L "$SOCK" -f "$CONF" start-server
fail=0
check() { case "$2" in *"$3"*) echo "PASS: $1";; *) echo "FAIL: $1 | got: $2 | want: $3"; fail=1;; esac; }

check "mode-keys vi" "$(tmux -L "$SOCK" show-options -gv mode-keys)" "vi"
check "bind | split h cwd" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E "bind-key.*\|")" "split-window -h"
check "bind - split v cwd" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E "bind-key +-[[:space:]]")" "split-window -v"
check "bind c new-window cwd" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E "bind-key +c[[:space:]]")" "new-window"
check "bind h select-pane -L" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E "bind-key +h[[:space:]]")" "select-pane -L"
check "bind j select-pane -D" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E "bind-key +j[[:space:]]")" "select-pane -D"
check "bind k select-pane -U" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E "bind-key +k[[:space:]]")" "select-pane -U"
check "bind l select-pane -R" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E "bind-key +l[[:space:]]")" "select-pane -R"
exit $fail
```

Run: 执行该块  
Expected: `mode-keys vi` 及 7 条键位断言全部 FAIL（当前 conf 尚无这些绑定），exit 1。

- [ ] **Step 2: 插入效率键位段**

在 `set-option -g allow-rename off` 行之后插入：

```tmux
# copy-mode 采用 vi 键位（与 nvim 一致）
setw -g mode-keys vi

# 快捷分屏 / 新建窗口：继承当前目录
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# 窗格导航 vi 风格
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

说明：`bind - split-window ...` 中单独的 `-` 按 POSIX 不被解析为选项，tmux 3.2a 可直接用；若 `start-server` 报错，改用 `bind-key -T prefix - split-window -v -c "#{pane_current_path}"` 等价写法并重载。

- [ ] **Step 3: 重跑断言验证通过**

Run: 与 Step 1 相同断言块（先 kill-server 再 start-server）  
Expected: 8 条全部 PASS，exit 0。

- [ ] **Step 4: 清理并提交**

```bash
tmux -L cfgtest kill-server 2>/dev/null || true
git add tmux/tmux.conf
git commit -m "tmux: efficiency keybindings for splits, windows, panes"
```

Expected: commit 成功。

---

### Task 3: 鼠标 + 系统剪贴板

**Files:**
- Modify: `tmux/tmux.conf`（在 Task 2 结果上，`allow-rename`/效率段之后插入鼠标与剪贴板段）

**Interfaces:**
- Consumes: Task 2 的 `mode-keys vi`（`copy-mode-vi` 表）。
- Produces: 全局选项 `mouse=on`；`MouseDragEnd1Pane` 在 `copy-mode-vi` 表绑定 `copy-pipe-and-cancel`，命令按平台为 `pbcopy`（本机 Darwin）。

- [ ] **Step 1: 写失败断言**

```bash
SOCK=cfgtest
CONF=tmux/tmux.conf
tmux -L "$SOCK" kill-server 2>/dev/null || true
tmux -L "$SOCK" -f "$CONF" start-server
fail=0
check() { case "$2" in *"$3"*) echo "PASS: $1";; *) echo "FAIL: $1 | got: $2 | want: $3"; fail=1;; esac; }

check "mouse on" "$(tmux -L "$SOCK" show-options -gv mouse)" "on"
check "MouseDragEnd1Pane copy-pipe" "$(tmux -L "$SOCK" list-keys -T copy-mode-vi | grep MouseDragEnd1Pane)" "copy-pipe-and-cancel"
check "clipboard cmd pbcopy on Darwin" "$(tmux -L "$SOCK" list-keys -T copy-mode-vi | grep MouseDragEnd1Pane)" "pbcopy"
exit $fail
```

Run: 执行该块  
Expected: 3 条全 FAIL（旧配置无鼠标与该绑定），exit 1。

- [ ] **Step 2: 插入鼠标与剪贴板段**

在 Task 2 的「窗格导航」块之后（`bind l select-pane -R` 行后）插入：

```tmux
# 鼠标：滚轮翻历史、点击切窗、拖拽进 copy-mode
set -g mouse on

# 拖选松手自动复制到系统剪贴板（按平台选择命令）
if-shell "uname | grep -q Darwin" {
  bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
} {
  if-shell '[ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy' {
    bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy"
  } {
    bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection clipboard"
  }
}
```

说明：花括号块 `if-shell ... { } { }` 需要 tmux ≥ 3.0，本机 3.2a 满足。若 `start-server` 报花括号语法错，回退为单行形式：

```tmux
if-shell "uname | grep -q Darwin" "bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'pbcopy'" "bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'xclip -selection clipboard'"
```

（Linux 分支在不支持花括号时降级为仅 xclip，Wayland `wl-copy` 分支以 3.2a 花括号形式为首选。）

- [ ] **Step 3: 重跑断言验证通过**

Run: 与 Step 1 相同断言块（先 kill-server 再 start-server）  
Expected: 3 条全 PASS（本机 `uname` 为 Darwin，绑定应含 `pbcopy`），exit 0。

- [ ] **Step 4: 清理并提交**

```bash
tmux -L cfgtest kill-server 2>/dev/null || true
git add tmux/tmux.conf
git commit -m "tmux: mouse support and platform clipboard copy"
```

Expected: commit 成功。

---

### Task 4: 状态栏信息

**Files:**
- Modify: `tmux/tmux.conf` 尾部状态栏段（替换原 `status-bg`/`status-fg`/`status-left`/`status-right` 相关行）

**Interfaces:**
- Consumes: Task 1 保留的 `status-interval 1`；当前文件中旧状态栏行（`set -g status-bg black` 至文件末尾）。
- Produces: `status-style`、`status-left` 含 `#S`、`status-right` 含 `#{session_windows}`；`window-status-format` 两行与 `status-justify`/`status-left-length`/`status-right-length` 保持原值。

- [ ] **Step 1: 写失败断言**

```bash
SOCK=cfgtest
CONF=tmux/tmux.conf
tmux -L "$SOCK" kill-server 2>/dev/null || true
tmux -L "$SOCK" -f "$CONF" start-server
fail=0
check() { case "$2" in *"$3"*) echo "PASS: $1";; *) echo "FAIL: $1 | got: $2 | want: $3"; fail=1;; esac; }

check "status-style" "$(tmux -L "$SOCK" show-options -gv status-style)" "fg=#00e5ee,bg=black"
check "status-left has session" "$(tmux -L "$SOCK" show-options -gv status-left)" "#S"
check "status-right has window count" "$(tmux -L "$SOCK" show-options -gv status-right)" "#{session_windows}"
check "status-left no bare hostname only" "$(tmux -L "$SOCK" show-options -gv status-left)" "[ #S ]"
exit $fail
```

Run: 执行该块  
Expected: 前 3 条 FAIL（旧配置 `status-left` 为 `[ #H ]`、无 `status-style`/`session_windows`）；`status-left` 含 `[ #S ]` 亦 FAIL；exit 1。

- [ ] **Step 2: 改写状态栏段**

删除旧状态栏相关行：

```tmux
set -g status-bg black # 设置状态栏背景黑色
set -g status-fg '#00e5ee' # 设置状态栏前景黄色

set-option -g status-justify centre
...（window-status-current-format / window-status-format 两行）
# 状态栏左右显示
set -g status-left-length 40
set -g status-left "[ #H ]"
set -g status-right-length 80
set -g status-right "[%Y-%m-%d %H:%M:%S]"
```

在文件末尾写入：

```tmux
# 状态栏：背景黑、前景青
set -g status-style "fg=#00e5ee,bg=black"
set-option -g status-justify centre

# 当前激活窗口在状态栏的展位格式
setw -g window-status-current-format '#[fg=#ff6a6a] [#I #W]'
# 未激活每个窗口占位的格式
setw -g window-status-format '#[fg=#ffffff] [#I #W]'

# 状态栏左右显示：左=会话名，右=窗口号/总数+主机+时间
set -g status-left-length 40
set -g status-left "[ #S ]"
set -g status-right-length 80
set -g status-right "[#I/#{session_windows}] [ #H ] [%Y-%m-%d %H:%M:%S]"
```

注意：若文件中因 Task 1 已无「转台了」注释、或 Task 2/3 插入点不同，以「最终状态参考全文」为准做整段对齐，勿留下重复的 `status-bg`/`status-fg` 行。

- [ ] **Step 3: 重跑断言验证通过**

Run: 与 Step 1 相同断言块（先 kill-server 再 start-server）  
Expected: 4 条全 PASS，exit 0。

- [ ] **Step 4: 清理并提交**

```bash
tmux -L cfgtest kill-server 2>/dev/null || true
git add tmux/tmux.conf
git commit -m "tmux: richer status bar with session and window count"
```

Expected: commit 成功。

---

### Task 5: 终验（全文核对 + spec 断言 + 可选 $HOME 同步）

**Files:**
- Verify: `tmux/tmux.conf`（与「目标文件终态」逐段 diff）
- Optional Modify: `$HOME/.tmux.conf`（仅当用户确认同步）

**Interfaces:**
- Consumes: Task 1–4 产出的完整文件。
- Produces: 全量断言通过的最终交付；用户确认后的 `$HOME` 同步（若执行）。

- [ ] **Step 1: 与终态全文 diff**

Run:

```bash
# 将「目标文件终态」代码块存入临时文件后比对（实施者从本 plan 复制该块到 /tmp/tmux.conf.desired）
diff -u /tmp/tmux.conf.desired tmux/tmux.conf
```

Expected: 无差异（exit 0）。若有差异，以 spec 设计意图为准修正 `tmux/tmux.conf` 至终态。

- [ ] **Step 2: 跑 spec 全量断言**

```bash
SOCK=cfgtest
CONF=tmux/tmux.conf
tmux -L "$SOCK" kill-server 2>/dev/null || true
tmux -L "$SOCK" -f "$CONF" start-server || { echo "FAIL: start-server"; exit 1; }
fail=0
check() { case "$2" in *"$3"*) echo "PASS: $1";; *) echo "FAIL: $1 | got: $2 | want: $3"; fail=1;; esac; }

check "mouse on" "$(tmux -L "$SOCK" show-options -gv mouse)" "on"
check "escape-time 0" "$(tmux -L "$SOCK" show-options -v escape-time)" "0"
check "focus-events on" "$(tmux -L "$SOCK" show-options -gv focus-events)" "on"
check "renumber-windows on" "$(tmux -L "$SOCK" show-options -gv renumber-windows)" "on"
check "history-limit 10000" "$(tmux -L "$SOCK" show-options -gv history-limit)" "10000"
check "mode-keys vi" "$(tmux -L "$SOCK" show-options -gv mode-keys)" "vi"
check "terminal-features RGB" "$(tmux -L "$SOCK" show-options -gsv terminal-features)" "RGB"
check "status-style" "$(tmux -L "$SOCK" show-options -gv status-style)" "fg=#00e5ee,bg=black"
check "status-left #S" "$(tmux -L "$SOCK" show-options -gv status-left)" "#S"
check "status-right session_windows" "$(tmux -L "$SOCK" show-options -gv status-right)" "#{session_windows}"
check "C-a C-a last-window" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E '^bind-key.*C-a')" "last-window"
check "bind | split" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E "bind-key.*\|")" "split-window -h"
check "bind - split" "$(tmux -L "$SOCK" list-keys -T prefix | grep -E "bind-key +-[[:space:]]")" "split-window -v"
check "MouseDragEnd copy-pipe" "$(tmux -L "$SOCK" list-keys -T copy-mode-vi | grep MouseDragEnd1Pane)" "copy-pipe-and-cancel"
check "prefix still C-a" "$(tmux -L "$SOCK" show-options -gv prefix)" "C-a"
check "base-index 1" "$(tmux -L "$SOCK" show-options -gv base-index)" "1"

tmux -L "$SOCK" kill-server 2>/dev/null || true
exit $fail
```

Run: 执行该块  
Expected: 全部 PASS，exit 0。

- [ ] **Step 3: 确认是否同步 `$HOME/.tmux.conf`**

向用户提问：「是否将 `tmux/tmux.conf` 覆盖拷贝到 `~/.tmux.conf`？」  
- 若「否」：跳过 Step 4。  
- 若「是」：执行 Step 4。

- [ ] **Step 4（条件执行）: 同步到 $HOME 并提示重载**

```bash
cp tmux/tmux.conf "$HOME/.tmux.conf"
# 若用户当前有运行中的真实会话，仅提示其自行重载，不 kill 真实 server：
echo "已同步 ~/.tmux.conf；在现有会话内执行 tmux source-file ~/.tmux.conf 生效"
```

Expected: cp 成功；不执行 `tmux kill-server`（真实会话）。

- [ ] **Step 5: 最终清理与提交收尾**

```bash
tmux -L cfgtest kill-server 2>/dev/null || true
git status --porcelain tmux/tmux.conf   # 应为空（Task 1–4 已分步提交；若 Step 1 有修正则再提交一次）
git log --oneline -5                    # 应看到 Task 1–4 的提交
```

Expected: `tmux/tmux.conf` 无未提交变更；日志含 4 条 tmux 提交。

---

## Self-Review 结果（已内联修复）

1. **Spec 覆盖**：①效率→Task 1（renumber/last-window）+ Task 2（分屏/新窗/窗格/vi）；②状态栏→Task 4；③鼠标剪贴板→Task 3；④稳定性→Task 1；验证方式→各 Task Step 1/3 + Task 5 全量断言；$HOME 同步→Task 5 Step 3–4；「不做清单」→Global Constraints。无缺口。
2. **占位符扫描**：无 TBD/TODO；每个断言与 conf 片段均为可直接执行的字面内容。
3. **一致性**：`#{session_windows}`、`copy-pipe-and-cancel`、`MouseDragEnd1Pane`、`mode-keys vi` 在各 Task 与终态全文中拼写一致；`escape-time` 断言在 Task 1 用 `-gv`、Task 5 用 `-v escape-time`（server 级）已注明差异原因。
