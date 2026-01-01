return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      modes = { "n", "no", "c" },
      hybrid_modes = { "n" },
      callbacks = {
        on_enable = function(_, win)
          vim.wo[win].conceallevel = 2
          vim.wo[win].concealcursor = "c"
        end,
      },
      headings = {
        enable = true,
        shift_width = 0,
      },
      code_blocks = {
        enable = true,
        style = "language",
        pad_amount = 2,
        min_width = 60,
      },
      list_items = {
        enable = true,
        shift_width = 2,
        indent_size = 2,
      },
      checkboxes = {
        enable = true,
        checked = {
          text = "󰱒",
        },
        unchecked = {
          text = "󰄱",
        },
      },
    },
  },
}
