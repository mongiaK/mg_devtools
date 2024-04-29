local function init()
	vim.keymap.set("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Mason" })
	vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
	vim.keymap.set("n", "<leader>H", "<cmd>checkhealth<cr>", { desc = "Check Health" })
	vim.keymap.set("n", "<leader>Q", "<cmd>wq<cr>", { desc = "Quit(save)" })
	vim.keymap.set("n", "C-s", "<cmd>wa<cr>", { desc = "Save" })
end

init()
