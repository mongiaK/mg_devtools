return { --
	-- {
	--     "olimorris/codecompanion.nvim",
	--     config = true,
	--     dependencies = {"nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter"}
	-- },
	-- ai 补全
	--{
	--	"Exafunction/windsurf.vim",
	--	event = "BufEnter",
	--	config = require("plugins_config.winsurf").config,
	--},
	{
		"github/copilot.vim",
		event = "InsertEnter",
		config = require("plugins_config.copilot").config,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "github/copilot.vim" },
			{ "nvim-lua/plenary.nvim" },
		},
		event = "VeryLazy",
		keys = require("plugins_config.copilot_chat").keys(),
		config = require("plugins_config.copilot_chat").config,
	},
}
