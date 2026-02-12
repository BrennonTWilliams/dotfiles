return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  config = function()
    require("gruvbox").setup({
      contrast = "hard",
      transparent_mode = false,
    })

    -- Detect macOS appearance and set background accordingly
    local function detect_appearance()
      local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
      if handle then
        local result = handle:read("*a")
        handle:close()
        if result:match("Dark") then
          return "dark"
        end
      end
      return "light"
    end

    vim.o.background = detect_appearance()
    vim.cmd("colorscheme gruvbox")

    -- Toggle light/dark with <leader>tb
    vim.keymap.set("n", "<leader>tb", function()
      if vim.o.background == "dark" then
        vim.o.background = "light"
      else
        vim.o.background = "dark"
      end
    end, { desc = "Toggle background light/dark" })
  end,
}
