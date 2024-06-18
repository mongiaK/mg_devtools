local _M = {}

function _M.keys()
	return {
		{ "<leader>f", desc = "+Telescope" },
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (root dir)" },
		{ "<leader>fw", "<cmd>Telescope live_grep<cr>", desc = "Live Grep (cwd)" },

		{ "<leader>s", desc = "+Search" },
		{ "<leader>sr", "<cmd>Telescope lsp_references<cr>", desc = "List References（LSP）" },
		{
			"<leader>sd",
			function()
				require("telescope.builtin").lsp_definitions({ reuse_win = true })
			end,
			desc = "Goto Definition（LSP）",
			has = "definition",
		},
		{
			"<leader>sI",
			function()
				require("telescope.builtin").lsp_implementations({ reuse_win = true })
			end,
			desc = "Goto Implementation（LSP）",
		},
	}
end

function _M.config() end

return _M
