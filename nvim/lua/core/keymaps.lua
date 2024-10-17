local keyset = vim.keymap.set

local function init()
	vim.keymap.set("n", "<leader>M", "<cmd>Mason<cr>", { desc = "Mason" })
	vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })
	vim.keymap.set("n", "<leader>H", "<cmd>checkhealth<cr>", { desc = "Check Health" })
	--	vim.keymap.set("n", "<leader>Q", "<cmd>wq<cr>", { desc = "Quit(save)" })
	--	vim.keymap.set("n", "<leader>C", "<cmd>lclose<cr>", { desc = "Close Localist" })

	--	vim.keymap.set("n", "C-s", "<cmd>wa<cr>", { desc = "Save" })
	--
	vim.api.nvim_set_keymap("n", "<leader>F", "", {
		noremap = true,
		silent = true,
		callback = function()
			-- 获取当前文件的路径和文件名
			local current_file = vim.fn.expand("%:p")
			-- 构造目标文件路径
			local target_file
			if current_file:match("%.h$") then
				target_file = current_file:gsub("%.h$", ".cpp")
			elseif current_file:match("%.cpp$") then
				target_file = current_file:gsub("%.cpp$", ".h")
			else
				print("当前文件不是 .h 或 .cpp 文件")
				return
			end
			-- 检查目标文件是否存在
			if vim.fn.filereadable(target_file) == 1 then
				-- 在分屏中打开目标文件
				vim.cmd("sp " .. target_file)
			else
				-- 创建并在分屏中打开目标文件
				vim.cmd("sp " .. target_file)
				print("open: " .. target_file)
			end
		end,
		desc = "Open *.h/*.cpp",
	})
end

init()
