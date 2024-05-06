local _M = {}

function _M.keys()
	return {
		{
			"<leader>m",
			desc = "Mark Word",
		},
		{
			"<leader>ma",
			function()
				require("mg_mark").clear_all()
			end,
			desc = "Clear Mark(ALL)",
		},
		{
			"<leader>mm",
			function()
				require("mg_mark").mark()
			end,
			desc = "Mark",
		},
		{
			"<leader>mn",
			function()
				require("mg_mark").next()
			end,
			desc = "Mark Next",
		},
		{
			"<leader>mp",
			function()
				require("mg_mark").prev()
			end,
			desc = "Mark Prev",
		},
	}
end

function _M.config()
	require("mg_mark").setup({
		groups = { "#AEEE00", "#aa2222", "#22aa22", "#2222aa", "#B08020", "#FFA020", "#22aa22", "#8888ff" },
	})
end

return _M
