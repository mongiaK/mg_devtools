local _M = {}

function _M.keys()
	return {
		{ "<leader>f", desc = "+Telescope" },
		{
			"<leader>ff",
			"<cmd>Telescope find_files<cr>",
			desc = "Find Files (root dir)",
		},
		{
			"<leader>fw",
			"<cmd>Telescope live_grep<cr>",
			desc = "Live Grep (cwd)",
		},
		{
			"<leader>fg",
			"<cmd>Telescope git_files<cr>",
			desc = "Find Files (git-files)",
		},
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },

		{ "<leader>s", desc = "+Search" },
		{
			'<leader>s"',
			"<cmd>Telescope registers<cr>",
			desc = "Registers",
		},
		{
			"<leader>sa",
			"<cmd>Telescope autocommands<cr>",
			desc = "Auto Commands",
		},
		{ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
		{
			"<leader>sc",
			"<cmd>Telescope command_history<cr>",
			desc = "Command History",
		},
		{
			"<leader>sC",
			"<cmd>Telescope commands<cr>",
			desc = "Commands",
		},
		{
			"<leader>sd",
			"<cmd>Telescope diagnostics bufnr=0<cr>",
			desc = "Document Diagnostics",
		},
		{
			"<leader>sD",
			"<cmd>Telescope diagnostics<cr>",
			desc = "Workspace Diagnostics",
		},
		{
			"<leader>sw",
			"<cmd>lua require('telescope.builtin').grep_string({word_match = '-w'})<cr>",
			desc = "Search Current Word (cwd)",
		},
	}
end

function _M.config() end

return _M
