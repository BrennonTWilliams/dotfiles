return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  keys = {
    { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle AI chat" },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "AI actions" },
    { "<leader>ci", "<cmd>CodeCompanion<cr>",            mode = { "n", "v" }, desc = "Inline AI assist" },
  },
  opts = {
    adapters = {
      -- Uses $ANTHROPIC_API_KEY — same credential as the claude CLI
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = { api_key = "ANTHROPIC_API_KEY" },
        })
      end,
      -- Mercury-2 via Inception Labs OpenAI-compatible API
      -- Uses $INCEPTION_API_KEY (set in ~/.zshrc.local)
      mercury = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          name = "mercury",
          formatted_name = "Mercury-2",
          env = {
            url = "https://api.inceptionlabs.ai",
            api_key = "INCEPTION_API_KEY",
          },
          schema = {
            model = {
              default = "mercury-2",
            },
          },
        })
      end,
    },
    strategies = {
      chat   = { adapter = "mercury" },
      inline = { adapter = "mercury" },
    },
  },
}
