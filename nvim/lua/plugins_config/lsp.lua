local _M = {}

local function get_binary_path(binary)
	local path = nil
	path = vim.fn.trim(vim.fn.system("which " .. binary))
	if vim.v.shell_error ~= 0 then
		path = nil
	end
	return path
end

local function get_binary_path_list(binaries)
	local path_list = {}
	for _, binary in ipairs(binaries) do
		local path = get_binary_path(binary)
		if path then
			table.insert(path_list, path)
		end
	end
	return table.concat(path_list, ",")
end

function _M.config()
	local lspconfig = require("lspconfig")
	local mason = require("mason")
	local mason_lspconfig = require("mason-lspconfig")

	mason.setup({
		ui = {
			border = "rounded",
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
		ensure_installed = {
			"shfmt",
			"codelldb",
			"delve",
			"debugpy",
			"stylua",
			"sumneko_lua",
		},
	})
	mason_lspconfig.setup({
		ensure_installed = {
			"bashls",
			"clangd",
			"gopls",
			"pyright",
			"rust_analyzer",
		},
	})

	mason_lspconfig.setup_handlers({
		function(server_name)
			lspconfig[server_name].setup({})
		end,
		["clangd"] = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.offsetEncoding = { "utf-16" }
			lspconfig.clangd.setup({
				cmd = {
					"clangd",
					"--background-index",
					"--pch-storage=memory",
					-- You MUST set this arg ↓ to your c/cpp compiler location (if not included)!
					"--query-driver=" .. get_binary_path_list({ "clang++", "clang", "gcc", "g++" }),
					"--clang-tidy",
					"--all-scopes-completion",
					"--completion-style=detailed",
					"--header-insertion-decorators",
					"--header-insertion=iwyu",
				},
				capabilities = capabilities,
			})
		end,
	})
end

return _M
