-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local bind = require("core.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd

local core_map = {
	-- normal node
	["n|<leader>nn"] = map_cr("Neotree"):with_noremap():with_desc("tree open"),
	["n|<leader>nc"] = map_cr("NeoTreeClose"):with_noremap():with_desc("tree close"),
	["n|<leader>ff"] = map_cmd(":Telescope find_files<CR>"):with_noremap():with_desc("Telescope find files"),
	["n|<leader>fg"] = map_cmd(":Telescope live_grep<CR>"):with_noremap():with_desc("Telescope live grep"),
	["n|<leader>fb"] = map_cmd(":Telescope buffers<CR>"):with_noremap():with_desc("Telescope buffers"),
	["n|<leader>fh"] = map_cmd(":Telescope help_tags<CR>"):with_noremap():with_desc("Telescope help_tags"),
	-- Insert mode
	["i|<C-q>"] = map_cmd("<Esc>:wq<CR>"):with_desc("editi: Save file and quit"),
	-- Command mode
	["c|<C-d>"] = map_cmd("<Del>"):with_noremap():with_desc("editc: Delete"),
	-- Visual mode
	["v|J"] = map_cmd(":m '>+1<CR>gv=gv"):with_desc("editv: Move this line down"),
}

bind.nvim_load_mapping(core_map)
