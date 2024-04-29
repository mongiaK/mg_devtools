return {
	-- 目录树
	{
		"nvim-neo-tree/neo-tree.nvim",
		lazy = true,
		cmd = "Neotree",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		config = require("plugins_config.neo").config,
		keys = require("plugins_config.neo").keys(),
	},
	-- 状态栏
	{
		"nvim-lualine/lualine.nvim",
		lazy = true,
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		config = require("plugins_config.lualine").config,
	},
	-- 快捷键提示
	{
		"folke/which-key.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = require("plugins_config.wk").config,
	},
	-- 自动成对符号
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		config = require("plugins_config.mini").config,
	},
	-- 显示函数
	{
		"simrat39/symbols-outline.nvim",
		event = "VeryLazy",
		config = require("plugins_config.symbols-outline").config,
		keys = require("plugins_config.symbols-outline").keys(),
	},

	-- 打开终端
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = true,
		keys = require("plugins_config.toggleterm").keys(),
	},
	-- vim的命令行
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = require("plugins_config.noice").opts,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},
	-- 缩进
	{
		"lukas-reineke/indent-blankline.nvim",
		lazy = true,
		config = require("plugins_config.indent").config,
	},
}
