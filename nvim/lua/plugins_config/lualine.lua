return function()
  local ll = require("lualine")
  local opts = {
    options = { theme = "catppuccin" },
    extensions = { "neo-tree", "quickfix" },
  }
  ll.setup(opts)
end
