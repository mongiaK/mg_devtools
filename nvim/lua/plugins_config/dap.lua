local c_cpp_rust_config = require("plugins_config.dap.c_cpp_rust")
local go_config = require("plugins_config.dap.go")

local _M = {}

function _M.keys()
	return {
		{
			"<F5>",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Add Breakpoint",
		},
		{
			"<F6>",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<F7>",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		{
			"<F8>",
			function()
				require("dap").continue()
			end,
			desc = "Continue",
		},
	}
end

function _M.config()
	c_cpp_rust_config.config()
	go_config.config()
end

return _M
