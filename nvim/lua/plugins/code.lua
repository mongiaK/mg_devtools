return {
	-- golang的插件，自动跳转
	{
		"crispgm/nvim-go",
		lazy = true,
		ft = { "go" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"rcarriga/nvim-notify",
			"neovim/nvim-lspconfig",
		},
		config = require("plugins_config.go").config,
	},
	-- 自动生成tag文件
	{
		"ludovicchabant/vim-gutentags",
		enable = true,
		config = require("plugins_config.gutentags").config,
	},
	-- debug ui
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		keys = require("plugins_config.dapui").keys(),
		config = require("plugins_config.dapui").config,
	},
	-- 调试插件
	{
		"mfussenegger/nvim-dap",
		keys = require("plugins_config.dap").keys(),
		config = require("plugins_config.dap").config,
	},
	-- 编译插件
	{ -- This plugin
		"Zeioth/compiler.nvim",
		cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		dependencies = { "stevearc/overseer.nvim" },
		keys = require("plugins_config.compiler").keys(),
		opts = {},
	},
	{ -- The task runner we use
		"stevearc/overseer.nvim",
		commit = "68a2d344cea4a2e11acfb5690dc8ecd1a1ec0ce0",
		cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		opts = {
			task_list = {
				direction = "bottom",
				min_height = 25,
				max_height = 25,
				default_detail = 1,
			},
		},
	},
	-- 打开文件切换到工程目录
	{
		"notjedi/nvim-rooter.lua",
		config = require("plugins_config.rooter").config,
	},
	-- git 插件
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = require("plugins_config.lazygit").keys(),
	},
}
