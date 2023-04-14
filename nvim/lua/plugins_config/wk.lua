local keymaps = {
    ["<leader>n"] = { name = "+neotree" },
    ["<leader>nn"] = { name = "tree open" },
    ["<leader>nc"] = { name = "tree close" },


    ["<leader>f"] = { name = "+telescope" },
    ["<leader>ff"] = { name = "find files" },
    ["<leader>fg"] = { name = "live grep" },
    ["<leader>fb"] = { name = "buffers" },
    ["<leader>fh"] = { name = "help_tags" },

}

return function()
    local wk = require("which-key")
    local opts = {
        plugins = { spelling = true }
    }
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    wk.setup(opts)
    wk.register(keymaps)
end
