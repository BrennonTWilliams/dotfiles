return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup({
      delay = 300,
      icons = {
        breadcrumb = "",
        separator = "",
        group = " ",
      },
    })
    wk.add({
      { "<leader>f", group = "Find", icon = "" },
      { "<leader>h", group = "Git Hunk", icon = "" },
      { "<leader>c", group = "Code", icon = "" },
      { "<leader>t", group = "Toggle", icon = "" },
      { "<leader>w", desc = "Save file", icon = "" },
      { "<leader>q", desc = "Quit", icon = "" },
      { "<leader>e", desc = "File explorer", icon = "" },
      { "<leader>o", desc = "Focus explorer", icon = "" },
      { "<leader>r", group = "Refactor", icon = "" },
      { "<leader>D", desc = "Type definition", icon = "" },
    })
  end,
}
