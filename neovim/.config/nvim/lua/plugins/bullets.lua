return {
  {
    "bullets-vim/bullets.vim",
    ft = {
      "markdown",
      "text",
    },
    init = function()
      vim.g.bullets_enabled_file_types = {
        "markdown",
        "text",
      }
      vim.g.bullets_outline_levels = { "num", "abc", "std" }
      vim.g.bullets_renumber_on_change = 1
      vim.g.bullets_checkbox_markers = " .oOX"
      vim.g.bullets_nested_checkboxes = 1
    end,
    keys = {
      { "<Leader>cb", "<Plug>(bullets-toggle-checkbox)", desc = "Toggle checkbox" },
    },
  },
}
