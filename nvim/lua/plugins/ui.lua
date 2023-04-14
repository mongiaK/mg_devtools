return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
	},
	{
		"goolord/alpha-nvim",
		lazy = true,
		event = "BufWinEnter",
		config = require("plugins_config.alpha"),
	},
}
