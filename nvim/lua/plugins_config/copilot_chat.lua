local _M = {}

function _M.config()
	local chat = require("CopilotChat")
	local select = require("CopilotChat.select")

	chat.setup({
		debug = false,
		-- 聊天窗口配置
		window = {
			layout = "float", -- 'vertical', 'horizontal', 'float'
			width = 0.8,
			height = 0.8,
			border = "rounded",
		},
		-- 提示词配置
		prompts = {
			Explain = {
				prompt = "/COPILOT_EXPLAIN 详细解释这段代码的工作原理。",
			},
			Review = {
				prompt = "/COPILOT_REVIEW 审查这段代码并提出改进建议。",
				callback = function(response, source)
					-- 可以添加自定义处理
				end,
			},
			Fix = {
				prompt = "/COPILOT_GENERATE 这段代码有问题，请修复它。",
			},
			Optimize = {
				prompt = "/COPILOT_GENERATE 优化这段代码以提高性能和可读性。",
			},
			Docs = {
				prompt = "/COPILOT_GENERATE 为这段代码添加文档注释。",
			},
			Tests = {
				prompt = "/COPILOT_GENERATE 为这段代码生成单元测试。",
			},
			FixDiagnostic = {
				prompt = "请协助解决以下诊断问题：",
				selection = select.diagnostics,
			},
			Commit = {
				prompt = "为这次更改写一个提交消息，遵循常规提交规范。标题最多50个字符，如有必要可添加详细信息。",
				selection = select.gitdiff,
			},
			CommitStaged = {
				prompt = "为已暂存的更改写一个提交消息，遵循常规提交规范。标题最多50个字符，如有必要可添加详细信息。",
				selection = function(source)
					return select.gitdiff(source, true)
				end,
			},
		},
		-- 自动建议配置
		auto_follow_cursor = true,
		auto_insert_mode = false,
		clear_chat_on_new_prompt = false,
		-- 上下文配置
		context = "buffers", -- 'buffers', 'buffer', nil
		-- 模型配置
		model = "gpt-4", -- 可以选择 'gpt-3.5-turbo', 'gpt-4' 等
		temperature = 0.1,
	})
end

function _M.keys()
	return {
		-- 打开聊天窗口
		{
			"<leader>cc",
			function()
				require("CopilotChat").open()
			end,
			desc = "Copilot Chat - Open",
			mode = { "n", "v" },
		},
		-- 关闭聊天窗口
		{
			"<leader>cq",
			function()
				require("CopilotChat").close()
			end,
			desc = "Copilot Chat - Close",
		},
		-- 切换聊天窗口
		{
			"<leader>ct",
			function()
				require("CopilotChat").toggle()
			end,
			desc = "Copilot Chat - Toggle",
			mode = { "n", "v" },
		},
		-- 重置聊天
		{
			"<leader>cr",
			function()
				require("CopilotChat").reset()
			end,
			desc = "Copilot Chat - Reset",
		},
		-- 快速聊天
		{
			"<leader>cq",
			function()
				local input = vim.fn.input("Quick Chat: ")
				if input ~= "" then
					require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
				end
			end,
			desc = "Copilot Chat - Quick chat",
			mode = { "n", "v" },
		},
		-- 解释代码
		{
			"<leader>ce",
			function()
				require("CopilotChat").ask("请解释这段代码", {
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "Copilot Chat - Explain code",
			mode = "v",
		},
		-- 审查代码
		{
			"<leader>cv",
			function()
				require("CopilotChat").ask("请审查这段代码并提出改进建议", {
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "Copilot Chat - Review code",
			mode = "v",
		},
		-- 修复代码
		{
			"<leader>cf",
			function()
				require("CopilotChat").ask("请修复这段代码的问题", {
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "Copilot Chat - Fix code",
			mode = "v",
		},
		-- 优化代码
		{
			"<leader>co",
			function()
				require("CopilotChat").ask("请优化这段代码", {
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "Copilot Chat - Optimize code",
			mode = "v",
		},
		-- 生成文档
		{
			"<leader>cd",
			function()
				require("CopilotChat").ask("请为这段代码生成文档注释", {
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "Copilot Chat - Document code",
			mode = "v",
		},
		-- 生成测试
		{
			"<leader>ct",
			function()
				require("CopilotChat").ask("请为这段代码生成单元测试", {
					selection = require("CopilotChat.select").visual,
				})
			end,
			desc = "Copilot Chat - Generate tests",
			mode = "v",
		},
		-- 修复诊断问题
		{
			"<leader>cx",
			function()
				require("CopilotChat").ask("请帮我修复当前的诊断问题", {
					selection = require("CopilotChat.select").diagnostics,
				})
			end,
			desc = "Copilot Chat - Fix diagnostic",
		},
		-- 生成提交信息
		{
			"<leader>cm",
			function()
				require("CopilotChat").ask("请为当前的改动生成提交信息", {
					selection = require("CopilotChat.select").gitdiff,
				})
			end,
			desc = "Copilot Chat - Commit message",
		},
	}
end

return _M
