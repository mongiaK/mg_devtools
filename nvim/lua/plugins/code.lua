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
	-- 关键:不要 eager load。只在真正读到磁盘上的文件时再启动,
	-- 并且通过 plugins_config.gutentags 里的熔断/黑名单/.notags 哨兵控制范围
	{
		"ludovicchabant/vim-gutentags",
		event = { "BufReadPost" },
		cmd = { "GutentagsUpdate", "GutentagsToggleEnabled", "TagsUpdate", "TagsToggle" },
		init = function()
			-- 必须在插件 source 之前设,所以放 init
			vim.g.gutentags_dont_load = 0
		end,
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
		enable = true,
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
	--	{
	--		"terrortylor/nvim-comment",
	--		config = require("plugins_config.comment").config,
	--	},
}
