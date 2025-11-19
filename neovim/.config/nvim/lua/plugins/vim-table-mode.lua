return {
  {
    "dhruvasagar/vim-table-mode",
    cmd = {
      "TableModeToggle",
      "TableModeEnable",
      "Tableize",
    },
    ft = { "markdown" },
    init = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_separator = "|"
    end,
    keys = {
      { "<Leader>tm", "<cmd>TableModeToggle<CR>", desc = "Toggle table mode" },
      { "<Leader>tr", "<cmd>TableModeRealign<CR>", desc = "Realign table" },
    },
  },
}
