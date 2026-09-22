local _M = {}

function _M.config()
	-- 禁用 Tab 键默认映射，避免与其他补全插件冲突
	vim.g.copilot_no_tab_map = true

	-- 禁用特定文件类型的 Copilot
	vim.g.copilot_filetypes = {
		["*"] = true,
		["gitcommit"] = false,
		["gitrebase"] = false,
		["markdown"] = true,
		["yaml"] = true,
	}

	-- 设置按键映射
	-- 使用 Ctrl+J 接受建议
	vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
		expr = true,
		replace_keycodes = false,
		silent = true,
	})

	-- 使用 Alt+] 查看下一个建议
	vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { silent = true })

	-- 使用 Alt+[ 查看上一个建议
	vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { silent = true })

	-- 使用 Alt+\ 触发 Copilot 建议
	vim.keymap.set("i", "<M-\\>", "<Plug>(copilot-suggest)", { silent = true })

	-- 使用 Ctrl+] 接受下一个单词
	vim.keymap.set("i", "<C-]>", "<Plug>(copilot-accept-word)", { silent = true })

	-- 使用 Ctrl+L 接受下一行
	vim.keymap.set("i", "<C-L>", "<Plug>(copilot-accept-line)", { silent = true })

	-- Copilot 切换命令
	vim.api.nvim_create_user_command("CopilotToggle", function()
		if vim.g.copilot_enabled == false then
			vim.g.copilot_enabled = true
			print("Copilot enabled")
		else
			vim.g.copilot_enabled = false
			print("Copilot disabled")
		end
	end, {})
end

return _M
