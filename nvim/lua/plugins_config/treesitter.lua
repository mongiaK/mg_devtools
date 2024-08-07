local _M = {}

function _M.config()
	--  vim.api.nvim_set_option_value("foldmethod", "expr", {})
	--  vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"bash",
			"c",
			"cpp",
			"css",
			"go",
			"gomod",
			"html",
			"javascript",
			"json",
			"lua",
			"make",
			"markdown",
			"markdown_inline",
			"python",
			"typescript",
			"vimdoc",
			"vue",
			"yaml",
			"rust",
		},
		highlight = {
			enable = true,
			disable = function(ft, bufnr)
				if vim.tbl_contains({ "vim" }, ft) then
					return true
				end

				local ok, is_large_file = pcall(vim.api.nvim_buf_get_var, bufnr, "bigfile_disable_treesitter")
				return ok and is_large_file
			end,
			additional_vim_regex_highlighting = { "c", "cpp" },
		},
		rainbow = {
			enable = true,
			extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
			max_file_lines = 2000, -- Do not enable for files with more than 2000 lines, int
		},
		context_commentstring = { enable = true, enable_autocmd = false },
		matchup = { enable = true },
	})
	require("nvim-treesitter.install").prefer_git = true
end

return _M
