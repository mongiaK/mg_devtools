local function main()
	require("core.basic")
	require("core.lazy")
	require("core.keymaps")
	require("core.autocmds")
	require("core.options")

	require("luasnip.loaders.from_vscode").load({ paths = "../snippets" })
	vim.api.nvim_command("set background=dark")
	vim.api.nvim_command("colorscheme tokyonight")
end

main()
