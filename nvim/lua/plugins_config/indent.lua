local _M = {}

function _M.config()
	require("indent_blankline").setup({
		indent = {
			char = "│",
			tab_char = "│",
		},
		show_current_context = false,
		scope = { enabled = false },
		exclude = {
			filetypes = {
				"help",
				"alpha",
				"dashboard",
				"neo-tree",
				"Trouble",
				"trouble",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
				"lazyterm",
			},
		},
	})
end

return _M
