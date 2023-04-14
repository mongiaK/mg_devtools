return {
  {
    "nvim-neo-tree/neo-tree.nvim", --目录树
    cmd = "Neotree",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = require("plugins_config.neo"),
  },
  {
    "nvim-lualine/lualine.nvim",
    lazy = true,
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    config = require("plugins_config.lualine"),
  },
  {
    "folke/which-key.nvim", -- 快捷键提示
    lazy = true,
    event = { "CursorHold", "CursorHoldI" },
    config = require("plugins_config.wk"),
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = true,
    event = { "BufReadPost", "BufNewFile" },
    config = require("plugins_config.indent"),
  },

  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    config = function(_, opts)
      require("mini.pairs").setup(opts)
    end,
  },
}
