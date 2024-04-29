local _M = {}

function _M.config()
	local ll = require("lualine")
	local opts = {
		options = { theme = "tokyonight" },
		extensions = { "neo-tree", "quickfix" },
	}
	ll.setup(opts)
end

return _M
