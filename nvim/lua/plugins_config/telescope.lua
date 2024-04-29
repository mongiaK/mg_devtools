local _M = {}

function _M.keys()
	return {
		{ "<leader>f", desc = "+Telescope" },
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (root dir)" },
		{ "<leader>fw", "<cmd>Telescope live_grep<cr>", desc = "Live Grep (cwd)" },
	}
end

function _M.config() end

return _M
