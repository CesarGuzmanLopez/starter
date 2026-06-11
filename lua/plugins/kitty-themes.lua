return {
  "odysseyalive/kitty-themes.nvim",
  lazy = true,
  cmd = { "KittyThemes", "KittyThemesList", "KittyThemesPreview", "KittyThemesRandom", "KittyThemesToggleTransparency" },
  config = function()
    require("kitty-themes").setup({
      transparent = true,
      term_colors = false,
    })
  end,
}
