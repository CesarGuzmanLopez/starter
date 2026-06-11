return {
  "MunsMan/kitty-navigator.nvim",
  lazy = true,
  -- Copia los Python scripts a ~/.config/kitty/ al instalar/actualizar
  build = {
    "cp navigate_kitty.py ~/.config/kitty",
    "cp pass_keys.py ~/.config/kitty",
  },
  keys = {
    -- hjkl (default)
    { "<C-h>", function() require("kitty-navigator").navigateLeft() end, desc = "Navigate left",  mode = { "n", "t" } },
    { "<C-j>", function() require("kitty-navigator").navigateDown() end, desc = "Navigate down",  mode = { "n", "t" } },
    { "<C-k>", function() require("kitty-navigator").navigateUp() end,   desc = "Navigate up",    mode = { "n", "t" } },
    { "<C-l>", function() require("kitty-navigator").navigateRight() end, desc = "Navigate right", mode = { "n", "t" } },
    -- flechas ↑↓←→ (adicionales)
    { "<C-Up>",   function() require("kitty-navigator").navigateUp() end,    desc = "Navigate up",    mode = { "n", "t" } },
    { "<C-Down>", function() require("kitty-navigator").navigateDown() end,  desc = "Navigate down",  mode = { "n", "t" } },
    { "<C-Left>", function() require("kitty-navigator").navigateLeft() end,  desc = "Navigate left",  mode = { "n", "t" } },
    { "<C-Right>",function() require("kitty-navigator").navigateRight() end, desc = "Navigate right", mode = { "n", "t" } },
  },
  opts = { keybindings = {} },
}
