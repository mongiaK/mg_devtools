local _M = {}

function _M.keys()
	return {
		{
			"<tab>",
			function()
				return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
			end,
			expr = true,
			silent = true,
			mode = "i",
		},
		{
			"<tab>",
			function()
				require("luasnip").jump(1)
			end,
			mode = "s",
		},
		{
			"<s-tab>",
			function()
				require("luasnip").jump(-1)
			end,
			mode = { "i", "s" },
		},
	}
end

function _M.config()
	require("luasnip").config.set_config({
		history = true,
		delete_check_events = "TextChanged",
	})

	-- 先加载自定义snippets（立即加载）
	require("luasnip.loaders.from_vscode").load({
		paths = vim.fn.stdpath("config") .. "/mgsnips"
	})
	
	-- 然后延迟加载默认snippets
	require("luasnip.loaders.from_vscode").lazy_load()
end

return _M
