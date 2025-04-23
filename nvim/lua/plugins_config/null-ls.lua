local _M = {}
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local function attach_ls(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
				vim.lsp.buf.format({})
				--vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
	end
end

function _M.config()
	local null_ls = require("null-ls")
	local mason_null_ls = require("mason-null-ls")
	local btns = null_ls.builtins

	-- Please set additional flags for the supported servers here
	-- Don't specify any config here if you are using the default one.
	local sources = {
		btns.formatting.black.with({
			extra_args = { "--fast" },
		}),
		btns.formatting.clang_format.with({
			filetypes = { "c", "cpp" },
			extra_args = { "-style={BasedOnStyle: LLVM, IndentWidth: 4}" },
		}),
		btns.formatting.prettier.with({
			filetypes = {
				"vue",
				"typescript",
				"javascript",
				"typescriptreact",
				"javascriptreact",
				"yaml",
				"html",
				"css",
				"scss",
				"sh",
				"markdown",
			},
			--env = {
			--	PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/.prettierrc.json"),
			--},
			extra_args = { "--tab-width", "4", "--use-tabs", "false" }, -- 强制 4 空格
		}),
	}

	null_ls.setup({
		border = "rounded",
		debug = true,
		log_level = "trace",
		update_in_insert = false,
		sources = sources,
		on_attach = attach_ls,
	})

	mason_null_ls.setup({
		ensure_installed = {
			"black",
			"clang_format",
			"editorconfig_checker",
			"prettier",
			"rustfmt",
			"stylua",
			"vint",
		},
		automatic_installation = false,
		automatic_setup = true,
		handlers = {},
	})
end

return _M
