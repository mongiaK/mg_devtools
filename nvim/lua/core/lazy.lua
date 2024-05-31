local config = require("core.config")
local mg_datadir = config.mg_datadir
local vim = vim
local _M = {}

function _M:load_lazy()
	local lazypath = mg_datadir .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable",
			lazypath,
		})
	end

	local lazy_settings = {
		root = mg_datadir .. "lazy",
		install = {
			missing = true,
			colorscheme = { "tokyonight" },
		},
	}

	vim.opt.rtp:prepend(lazypath)
	require("lazy").setup("plugins", lazy_settings)
end

_M:load_lazy()
