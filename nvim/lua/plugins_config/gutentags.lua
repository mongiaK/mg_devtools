local _M = {}
local vim = vim

-- 超过这个文件数就直接放弃建索引,避免卡死
-- 命中 .notags 也会跳过(适合显式标记不想建索引的大仓库)
local MAX_FILES = 50000

-- 项目根黑名单:这些目录即便有 .git 也不建索引
-- $HOME 是常见的卡死源(很多人把 dotfiles 放 $HOME 并 git init)
local function project_root_blacklist()
	local home = os.getenv("HOME") or ""
	return {
		home,
		"/",
		"/tmp",
		"/usr",
		"/etc",
		"/var",
		"/opt",
		"/root",
		home .. "/Downloads",
		home .. "/Desktop",
	}
end

function _M.config()
	vim.g.gutentags_ctags_exclude = {
		"*.git",
		"*.svg",
		"*.hg",
		"*/tests/*",
		"build",
		"dist",
		"*sites/*/files/*",
		"bin",
		"node_modules",
		"bower_components",
		"cache",
		"compiled",
		"docs",
		"example",
		"bundle",
		"vendor",
		"*.md",
		"*-lock.json",
		"*.lock",
		"*bundle*.js",
		"*build*.js",
		".*rc*",
		"*.json",
		"*.min.*",
		"*.map",
		"*.bak",
		"*.zip",
		"*.pyc",
		"*.class",
		"*.sln",
		"*.Master",
		"*.csproj",
		"*.tmp",
		"*.csproj.user",
		"*.cache",
		"*.pdb",
		"tags*",
		"cscope.*",
		"*.exe",
		"*.dll",
		"*.mp3",
		".md",
		"*.ogg",
		"*.flac",
		"*.swp",
		"*.swo",
		"*.bmp",
		"*.gif",
		"*.ico",
		"*.jpg",
		"*.png",
		"*.rar",
		"*.zip",
		"*.tar",
		"*.tar.gz",
		"*.tar.xz",
		"*.tar.bz2",
		"*.pdf",
		"*.doc",
		"*.docx",
		"*.ppt",
		"*.pptx",
	}

	-- 只把显式标记当工程根 (.root / .project / package.json 等);
	-- .git 也保留,但下面有熔断兜底
	vim.g.gutentags_add_default_project_roots = false
	vim.g.gutentags_project_root = {
		".root",
		".project",
		".vscode",
		"package.json",
		"go.mod",
		"Cargo.toml",
		".git",
		".svn",
		".hg",
	}
	-- 命中黑名单根就直接跳过(项目根正好是 $HOME 之类时)
	vim.g.gutentags_exclude_project_root = project_root_blacklist()

	vim.g.gutentags_ctags_tagfile = ".tags"
	vim.g.gutentags_cache_dir = vim.fn.stdpath("cache") .. "/ctags"
	vim.g.gutentags_ctags_extra_args =
		{ "--tag-relative=yes", "--fields=+ailmnS", "--extra=+q", "--c++-kinds=+px", "--c-kinds=+px" }
	vim.g.gutentags_modules = { "ctags" }

	-- 关键提速:让 gutentags 用 ripgrep 列文件,自动走 .gitignore,
	-- 不再让 ctags 自己 -R 递归全工程
	if vim.fn.executable("rg") == 1 then
		local rg = "rg --files --hidden --follow"
		vim.g.gutentags_file_list_command = {
			markers = {
				[".git"] = rg,
				[".hg"] = rg,
				[".svn"] = rg,
				[".root"] = rg,
				[".project"] = rg,
			},
		}
	end

	-- 不在打开空 buffer / 没识别出根时瞎跑
	vim.g.gutentags_generate_on_empty_buffer = 0
	vim.g.gutentags_generate_on_new = 1
	vim.g.gutentags_generate_on_missing = 1
	vim.g.gutentags_generate_on_write = 1

	if vim.fn.isdirectory(vim.g.gutentags_cache_dir) == 0 then
		os.execute("mkdir -p " .. vim.g.gutentags_cache_dir)
	end

	-- 熔断:工程文件数过多 / 存在 .notags 哨兵 就关掉 gutentags
	-- gutentags 的 init_user_func 必须是 vim 函数名,所以这里挂一个全局函数
	_mg_gutentags_init = function(path)
		if path == nil or path == "" then
			return 0
		end
		-- 哨兵: 在任何不想建索引的仓库根下 `touch .notags`
		if vim.fn.filereadable(path .. "/.notags") == 1 then
			return 0
		end
		-- 文件数熔断
		if vim.fn.executable("rg") == 1 then
			local out = vim.fn.systemlist({ "rg", "--files", "--hidden", "--follow", path })
			if vim.v.shell_error == 0 and #out > MAX_FILES then
				vim.schedule(function()
					vim.notify(
						string.format("[gutentags] skip %s (%d files > %d)", path, #out, MAX_FILES),
						vim.log.levels.WARN
					)
				end)
				return 0
			end
		end
		return 1
	end
	vim.g.gutentags_init_user_func = _mg_gutentags_init

	-- 手动命令,需要时再开/关
	vim.api.nvim_create_user_command("TagsToggle", "GutentagsToggleEnabled", {})
	vim.api.nvim_create_user_command("TagsUpdate", "GutentagsUpdate", {})
end

return _M
