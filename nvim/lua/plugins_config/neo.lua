local _M = {}

function _M.keys()
	return {
		{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Neotree Toggle" },
	}
end

function _M.config()
	local neo_tree = require("neo-tree")
	local opts = {
		close_if_last_window = true,
		filesystem = {
			bind_to_cwd = false,
			--follow_current_file = true,
			follow_current_file = {
				enable = true,
			},
		},
		window = {
			width = 30,
			mappings = {
				["<space>"] = "none",
			},
		},
		default_component_configs = {
			indent = {
				with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
				expander_collapsed = "",
				expander_expanded = "",
				expander_highlight = "NeoTreeExpander",
			},
		},
	}
	neo_tree.setup(opts)
end

return _M
