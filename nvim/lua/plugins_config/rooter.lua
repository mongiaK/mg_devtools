local _M = {}

_M.opts = {
	--	update_cwd = true,
	--	update_focused_file = {
	--		enable = true,
	--		update_cwd = true,
	--	},
	rooter_patterns = { ".git", ".hg", ".svn", ".project", "go.mod", ".root", ".vscode" },
}

function _M.config()
	require("nvim-rooter").setup(_M.opts)
end

return _M
