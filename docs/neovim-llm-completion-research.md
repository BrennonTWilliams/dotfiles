# LLM-Driven Tab Completion for Neovim - Research Report

> Research conducted: January 2026

## Executive Summary

The LLM-powered code completion landscape for Neovim has matured significantly in 2025-2026. Key developments include:
- **blink.cmp** emerging as the performance leader over nvim-cmp
- **Supermaven sunset** after Cursor acquisition (Nov 2025)
- **minuet-ai.nvim** as the most flexible multi-provider solution
- Strong local LLM options via Ollama integration

---

## Top Recommendations

### Best Overall: GitHub Copilot
- **Quality**: Industry-leading 3.4% acceptance rate in blind trials
- **Pricing**: Free tier (2,000 completions/month), Pro $10/mo, Pro+ $39/mo
- **Free for**: Students, teachers, OSS maintainers
- **Plugin**: `zbirenbaum/copilot.lua` (Lua) or `github/copilot.vim`
- **Integration**: Native blink.cmp support via `fang2hou/blink-copilot`

### Best Free Cloud: Codeium/Windsurf
- **Pricing**: Forever free with unlimited autocomplete
- **Plugin**: `Exafunction/windsurf.nvim` or `monkoose/neocodeium`
- **Caveat**: Lower acceptance rate (0.5%) in blind testing vs competitors

### Most Flexible (BYOK): minuet-ai.nvim
- **Providers**: OpenAI, Claude, Gemini, Mistral, DeepSeek, Ollama, llama.cpp
- **Free models**: gemini-2.0-flash, codestral
- **Best quality**: deepseek-chat
- **Best local**: qwen-2.5-coder, deepseek-coder-v2 via Ollama
- **Stars**: 1.1k on GitHub

### Best Local/Privacy: minuet-ai.nvim + Ollama
- No code sent to external services
- Qwen-2.5-coder:1.5B runs on <8GB VRAM (quantized)
- 7B models need 8-12GB VRAM for good performance

---

## Completion Engine: blink.cmp vs nvim-cmp

### blink.cmp (Recommended)
- **Performance**: 0.5-4ms async vs nvim-cmp's 2-50ms hitches
- **Fuzzy matching**: Rust SIMD (frizbee) - 6x faster than fzf
- **Native ghost text**: Built-in support
- **Batteries-included**: LSP, buffer, path, snippets built-in
- **Adoption**: Now default in kickstart.nvim and LazyVim v14+

### Key Configuration Pattern
```lua
sources = {
  default = { "lsp", "path", "snippets", "buffer", "copilot" },
  providers = {
    copilot = {
      name = "copilot",
      module = "blink-copilot",
      async = true,
      score_offset = 100,  -- Prioritize AI suggestions
    },
  },
},
```

---

## Ghost Text vs Completion Menu

| Approach | Best For | Configuration |
|----------|----------|---------------|
| Ghost Text | Multi-line, method completions | `suggestion = { enabled = true }` in copilot.lua |
| Menu | Browsing options, comparing | `score_offset = 100` in blink.cmp source |
| Hybrid | Best of both worlds | Use `vim.g.ai_cmp` toggle pattern |

### Hybrid Pattern (from LazyVim)
```lua
-- Toggle AI in menu vs ghost text
vim.g.ai_cmp = false  -- false = ghost text mode

-- Copilot config responds to toggle
require("copilot").setup({
  suggestion = { enabled = not vim.g.ai_cmp },
  panel = { enabled = false },
})
```

---

## Plugin Comparison Matrix

| Plugin | Free? | Quality | Speed | Local? | Status |
|--------|-------|---------|-------|--------|--------|
| GitHub Copilot | Limited | Best | Good | No | Active |
| Codeium/Windsurf | Yes | Low | Good | No | Active |
| Supermaven | N/A | Medium | Best | No | **Sunset** |
| Tabnine | Limited | Medium | Good | Enterprise | Active |
| minuet-ai.nvim | BYOK | High | Varies | Yes | Active |
| codecompanion.nvim | BYOK | High | Varies | Yes | Active |
| avante.nvim | BYOK | High | Good | Yes | Beta |

---

## Detailed Plugin Profiles

### GitHub Copilot (copilot.vim / copilot.lua)

**Repository**: [github/copilot.vim](https://github.com/github/copilot.vim) (11.2k stars)

**Alternative**: [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua) - 100% Lua implementation with better nvim-cmp/blink.cmp integration

**Pricing**:
- Free Tier: 2,000 code completions + 50 premium requests/month
- Pro: $10/month (300 premium requests)
- Pro+: $39/month (1,500 premium requests)
- Free for verified students, teachers, and popular open-source maintainers

**Features**:
- Industry-leading completion quality
- Supports multiple models: GPT-5, Claude Opus 4.1, Gemini 2.5 Pro
- Inline suggestions with tab completion

**Requirements**: Neovim 0.6+, Node.js 18+

### Codeium/Windsurf (windsurf.nvim / neocodeium)

**Official Repository**: [Exafunction/windsurf.nvim](https://github.com/Exafunction/windsurf.nvim) (1.2k stars)

**Community Alternative**: [monkoose/neocodeium](https://github.com/monkoose/neocodeium)

**Pricing**:
- Free: Forever free for individuals with unlimited autocomplete
- Pro: $15/month

**Features**:
- Browser-based chat interface via `:Codeium Chat`
- Virtual text and completion menu integration
- Extensive customization options

### minuet-ai.nvim (Multi-Provider)

**Repository**: [milanglacier/minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim) (1.1k stars)

**Pricing**: Free - bring your own API keys

**Supported Providers**:
- OpenAI (GPT models)
- Anthropic Claude
- Google Gemini
- Mistral Codestral
- DeepSeek
- Ollama (local models)
- Llama.cpp (local inference)
- Any OpenAI-compatible API

**Features**:
- No proprietary binaries - just curl and your LLM provider
- Both chat-based and fill-in-the-middle (FIM) completion
- Streaming support for slower models
- Multiple frontend options: virtual text, nvim-cmp, blink.cmp

**Requirements**: Neovim 0.10+, plenary.nvim

**Recommended Models** (as of Jan 2026):
- Free & fast: gemini-2.0-flash, codestral
- Highest quality: deepseek-chat (slower)
- Local: qwen-2.5-coder or deepseek-coder-v2 via Ollama

### Supermaven (SUNSET)

**Repository**: [supermaven-inc/supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim) (1.4k stars)

**Status**: **SUNSET as of November 2025** after acquisition by Cursor

**What Happened**:
- Acquired by Anysphere (Cursor) in November 2024
- Shutdown announced November 2025
- Features moved into Cursor Tab
- **Recommendation**: Consider alternatives

### avante.nvim (Cursor Alternative)

**Repository**: [yetone/avante.nvim](https://github.com/yetone/avante.nvim)

**Type**: Cursor-style IDE experience in Neovim (not just completion)

**Features**:
- Emulates Cursor AI IDE behavior
- AI-driven code suggestions with instant apply
- Model Context Protocol (MCP) integration support
- Agentic coding capabilities

**Status**: Still maturing - "workflow is not perfect yet"

### codecompanion.nvim (Agentic Workflows)

**Repository**: [olimorris/codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)

**Pricing**: Free - bring your own API keys

**Features**:
- Agentic workflows (v12.0.0+) - automated coding loops with tool use
- Inline assistant with variables (#buffer, #chat)
- Agent Client Protocol (ACP) support
- Widest provider support

**Requirements**: Neovim 0.11.0+, curl library

---

## Local LLM Hardware Requirements

| Model Size | VRAM | Example GPUs | Performance |
|------------|------|--------------|-------------|
| 1.5-3B | 4-6GB | GTX 1660, RTX 3050 | Fast, good for tab completion |
| 7B | 8-12GB | RTX 3060, RTX 4060 | Sweet spot: 40+ tok/s |
| 14B | 12-16GB | RTX 3080, RTX 4070 | Good quality, slower |
| 32B+ | 24GB+ | RTX 4090, A100 | Best quality, needs patience |

### Recommended Local Models
1. **Fastest**: qwen-2.5-coder:1.5B (Q8_0)
2. **Best balance**: qwen-2.5-coder:7B (Q4_K_M)
3. **Highest quality**: deepseek-coder-v2:16B

### Quantization Impact
- **Q4_K_M quantization**: Reduces VRAM by ~75% compared to FP16
- Example: 8B model uses 5-6GB instead of 16GB
- Maintains excellent output quality
- Recommended for consumer hardware

---

## Configuration Examples

### Option A: Copilot + blink.cmp (Menu Mode)
```lua
return {
  {
    "saghen/blink.cmp",
    dependencies = { "fang2hou/blink-copilot" },
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            async = true,
            score_offset = 100,
          },
        },
      },
      completion = {
        menu = { auto_show = true },
        ghost_text = { enabled = false },
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
}
```

### Option B: Copilot Ghost Text (Inline Mode)
```lua
return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          accept_word = "<C-Right>",
          accept_line = "<C-Down>",
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },  -- No copilot source
      },
    },
  },
}
```

With autocmd to prevent conflicts:
```lua
vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpCompletionMenuOpen',
  callback = function()
    require("copilot.suggestion").dismiss()
    vim.b.copilot_suggestion_hidden = true
  end,
})
```

### Option C: Local LLM with minuet-ai
```lua
return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        provider = "ollama",
        provider_options = {
          ollama = {
            model = "qwen2.5-coder:7b",
            end_point = "http://localhost:11434/api/generate",
          },
        },
        request_timeout = 5,  -- Longer timeout for local
        context_window = 512,  -- Start conservative
        n_completions = 1,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "minuet" },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            async = true,
            timeout_ms = 5000,
            score_offset = 50,
          },
        },
      },
      completion = { trigger = { prefetch_on_insert = false } },
    },
  },
}
```

### Option D: Multi-LLM with Cloud APIs
```lua
return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        provider = "gemini",  -- Free tier available
        -- Or: "claude", "openai", "codestral"
        request_timeout = 3,
      })
    end,
  },
}
```

---

## Key Integration Plugins

| Purpose | Plugin | GitHub |
|---------|--------|--------|
| Copilot + blink.cmp | blink-copilot | fang2hou/blink-copilot |
| Copilot (Lua rewrite) | copilot.lua | zbirenbaum/copilot.lua |
| Multi-LLM completion | minuet-ai.nvim | milanglacier/minuet-ai.nvim |
| Codeium (free) | neocodeium | monkoose/neocodeium |
| Cursor-like experience | avante.nvim | yetone/avante.nvim |
| Agentic workflows | codecompanion.nvim | olimorris/codecompanion.nvim |
| HuggingFace integration | llm.nvim | huggingface/llm.nvim |
| Ollama-specific | Ollama-Copilot | Jacob411/Ollama-Copilot |

---

## Performance Considerations

### Cloud vs Local Trade-offs

**Cloud-Based (Copilot, Codeium)**:
- Latency: <1 second time-to-first-token
- Throughput: >100 tokens/second
- Quality: Best-in-class models
- Trade-off: Code sent to external servers

**Local (Ollama, llama.cpp)**:
- Latency: 1-5+ seconds (hardware dependent)
- Throughput: 10-50 tokens/second typical
- Quality: Approaching cloud parity with good models
- Benefits: Complete privacy, no ongoing costs

### Optimization Tips

1. **Debounce tuning**: 200ms default, adjust based on preference
2. **Async always**: Set `async = true` for all AI sources
3. **Score offsets**: Copilot at 100, LSP at 0 (default)
4. **Selective triggering**: Use `prefetch_on_insert = false` to reduce API calls
5. **Single provider**: Don't run multiple AI providers simultaneously

---

## Sources

### Primary Research
- [GitHub Copilot Plans](https://github.com/features/copilot/plans)
- [blink.cmp Documentation](https://cmp.saghen.dev/)
- [minuet-ai.nvim GitHub](https://github.com/milanglacier/minuet-ai.nvim)
- [LazyVim AI Configuration](https://lazyvim-ambitious-devs.phillips.codes/course/chapter-16/)
- [AstroNvim AI Recipes](https://docs.astronvim.com/recipes/ai/)

### Comparisons
- [LLM Code Completion Showdown (Blind Trial)](https://kitemetric.com/blogs/llm-code-completion-showdown-a-blind-trial)
- [blink.cmp vs nvim-cmp](https://gist.github.com/Saghen/e731f6f6e30a4c01f6bc7cdaa389d463)
- [Copilot vs Windsurf Technical Analysis](https://dev.to/jonatas-sas/inline-ai-suggestions-in-neovim-github-copilot-vs-windsurf-codeium-a-technical-comparative-4b7l)

### Local LLM Resources
- [Ollama VRAM Requirements](https://localllm.in/blog/ollama-vram-requirements-for-local-llms)
- [Qwen Coder Models Guide](https://support.tools/qwen-coder-models-guide/)
- [Self-hosted Copilot Alternatives](https://www.virtualizationhowto.com/2025/05/best-self-hosted-github-copilot-ai-coding-alternatives/)

### Plugin Lists
- [Neovim AI Plugins](https://github.com/ColinKennedy/neovim-ai-plugins)
- [NeovimCraft Plugin Directory](https://neovimcraft.com/)
