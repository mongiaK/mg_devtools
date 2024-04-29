local _M = {}

function _M.config()
	local wk = require("which-key")
	local opts = {
		plugins = {
			spelling = true,
		},
		layout = {
			align = "center",
		},
	}
	wk.setup(opts)
end

return _M
