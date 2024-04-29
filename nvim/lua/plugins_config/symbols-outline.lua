local _M = {}

function _M.keys()
	return {
		{ "<leader>S", "<cmd>SymbolsOutline<cr>", desc = "SymbolsOutline" },
	}
end

function _M.config()
	require("symbols-outline").setup({
		relative_width = false,
		width = 30,
	})
end

return _M
