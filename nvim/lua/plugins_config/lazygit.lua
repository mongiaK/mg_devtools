local _M = {}

function _M.keys()
	return {
		{ "<leader>g", desc = "+git" },
		{ "<leader>gl", "<cmd>LazyGit<cr>", desc = "LazyGit" },
	}
end

return _M
