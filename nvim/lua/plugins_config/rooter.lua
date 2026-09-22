local _M = {}

_M.opts = {
	rooter_patterns = {
		".root", ".project", ".vscode",
		"go.mod", "Cargo.toml", "package.json", "Makefile", "makefile",
		".git", ".hg", ".svn",
	},
	-- 命中以下目录就不切 cwd,避免把家目录之类当工程根
	exclude_filetypes = { "alpha", "dashboard", "neo-tree", "TelescopePrompt" },
}

function _M.config()
	local home = os.getenv("HOME") or ""
	local blacklist = {
		[home] = true,
		["/"] = true,
		["/tmp"] = true,
		["/root"] = true,
	}

	require("nvim-rooter").setup(_M.opts)

	-- rooter 切完根之后,如果落到黑名单目录,撤销回原来的 cwd
	local last_cwd
	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function()
			last_cwd = vim.fn.getcwd()
		end,
	})
	vim.api.nvim_create_autocmd("DirChanged", {
		callback = function()
			local cwd = vim.fn.getcwd()
			if blacklist[cwd] and last_cwd and last_cwd ~= cwd then
				vim.cmd("silent! cd " .. vim.fn.fnameescape(last_cwd))
			end
		end,
	})
end

return _M
