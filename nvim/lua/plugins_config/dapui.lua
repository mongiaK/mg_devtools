local _M = {}

function _M.keys()
	return {
		{
			"<F4>",
			function()
				require("dapui").toggle()
			end,
			desc = "Dap UI Open",
		},
	}
end

function _M.config()
	require("dapui").setup()
end

return _M
