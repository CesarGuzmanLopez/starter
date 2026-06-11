return {
  "mikesmithgh/kitty-scrollback.nvim",
  lazy = true,
  cmd = {
    "KittyScrollbackGenerateKittens",
    "KittyScrollbackCheckHealth",
    "KittyScrollbackGenerateCommandLineEditing",
  },
  event = { "User KittyScrollbackLaunch" },
  config = function()
    require("kitty-scrollback").setup({
      {
        status_window = {
          autoclose = true,
        },
      },
      ksb_builtin_get_text_all = {
        kitty_get_text = {
          ansi = true,
        },
      },
    })
  end,
}
