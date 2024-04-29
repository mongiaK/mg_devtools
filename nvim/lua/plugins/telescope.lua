return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = require("plugins_config.telescope").config,
		keys = require("plugins_config.telescope").keys(),
	},
}
