return {
	-- 配置lsp客户端
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		config = require("plugins_config.lsp").config,
		dependencies = {
			"williamboman/mason.nvim", -- lsp server端
			"williamboman/mason-lspconfig.nvim",
		},
	},
	-- 格式化代码
	{
		"jose-elias-alvarez/null-ls.nvim",
		lazy = "veryLazy",
		event = { "CursorHold", "CursorHoldI" },
		config = require("plugins_config.null-ls").config,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"jay-babu/mason-null-ls.nvim",
		},
	},
	-- 代码片段
	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		event = { "InsertEnter" },
		dependencies = {
			"rafamadriz/friendly-snippets",
			"saadparwaiz1/cmp_luasnip",
		},
		keys = require("plugins_config.luasnip").keys(),
		config = require("plugins_config.luasnip").config,
	},

	-- 自动补全插件
	{
		"hrsh7th/nvim-cmp",
		version = false,
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip", -- 用来调用LuaSnip进行自动补全
		},
		config = require("plugins_config.cmp").config,
	},
}
