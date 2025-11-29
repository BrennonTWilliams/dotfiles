# ==============================================================================
# Neovim Functions
# ==============================================================================

# Cheatsheet for custom Neovim keybindings
nvim-keys() {
    cat << 'EOF'
+============================================================+
|                  NEOVIM KEYBINDINGS                        |
|                    Leader = <Space>                        |
+============================================================+

  GENERAL
  -------
  <Space>w      Save file
  <Space>q      Quit
  <Esc>         Clear search highlighting

  FIND (Telescope)                    <Space>f...
  ---------------
  <Space>ff     Find files
  <Space>fg     Live grep (search text)
  <Space>fb     Buffers
  <Space>fr     Recent files
  <Space>fh     Help tags
  <Space>fk     Keymaps
  <Space>fd     Diagnostics
  <Space>fs     Document symbols
  <Space>fc     Commands

  LSP (Code Intelligence)
  -----------------------
  gd            Go to definition
  gD            Go to declaration
  gr            Go to references
  gi            Go to implementation
  K             Hover documentation
  <C-k>         Signature help
  <Space>ca     Code action
  <Space>rn     Rename symbol
  <Space>cf     Format buffer
  <Space>D      Type definition
  <Space>cd     Line diagnostics
  [d / ]d       Prev/next diagnostic

  FILE EXPLORER (Neo-tree)
  ------------------------
  <Space>e      Toggle explorer
  <Space>o      Focus explorer

  GIT (Gitsigns)                      <Space>h...
  --------------
  ]h / [h       Next/prev hunk
  <Space>hs     Stage hunk
  <Space>hr     Reset hunk
  <Space>hS     Stage buffer
  <Space>hu     Undo stage hunk
  <Space>hp     Preview hunk
  <Space>hb     Blame line (full)
  <Space>hd     Diff this
  <Space>hD     Diff this ~
  <Space>tb     Toggle line blame
  <Space>td     Toggle deleted

  COMPLETION (nvim-cmp)
  ---------------------
  <Tab>         Next item / expand snippet
  <S-Tab>       Prev item
  <C-j>/<C-k>   Next/prev item
  <CR>          Confirm selection
  <C-Space>     Trigger completion
  <C-e>         Abort

  EDITING
  -------
  gcc           Comment line
  gc            Comment selection (visual)
  gbc           Block comment line
  gb            Block comment selection
  cs"'          Change surround " to '
  ds"           Delete surrounding "
  ysiw"         Surround word with "

  WINDOW NAVIGATION
  -----------------
  <C-h/j/k/l>   Move between windows
  <C-arrows>    Resize windows
  <S-h>/<S-l>   Prev/next buffer

  TOGGLES                             <Space>t...
  -------
  <Space>tb     Toggle line blame
  <Space>td     Toggle deleted lines
  <Space>tc     Toggle smear cursor

  USEFUL COMMANDS
  ---------------
  :Lazy         Plugin manager
  :Mason        LSP server manager
  :checkhealth  Verify setup
  :Telescope    Fuzzy finder menu

+============================================================+
EOF
}
