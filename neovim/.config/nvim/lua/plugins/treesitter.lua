-- Pulled in as a dependency of markview and codecompanion. Pin to master:
-- upstream's default branch is now `main` (an incompatible rewrite), so fresh
-- clones would otherwise track it and flip the branch in lazy-lock.json.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
}
