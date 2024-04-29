return {
	-- 语法高亮
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = true,
		event = { "BufReadPre", "BufNewFile" }, -- 指定触发事件
		build = ":TSUpdate",
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall", "TSInstallInfo" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = require("plugins_config.treesitter").config,
	},
}
