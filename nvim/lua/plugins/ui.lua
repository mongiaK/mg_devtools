return {
	-- 主题配色
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
	},
	-- 启动logo
	{
		"goolord/alpha-nvim",
		lazy = true,
		event = "BufWinEnter",
		config = require("plugins_config.alpha").config,
	},
}
