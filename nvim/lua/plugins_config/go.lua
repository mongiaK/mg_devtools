local _M = {}

function _M.config()
	local go = require("go")
	local opts = {
		lint_prompt_style = "vt", -- 在代码行内显示 lint 提示
	}
	go.setup(opts)
end

return _M
