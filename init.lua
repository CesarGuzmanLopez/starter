vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
local ok1, _ = pcall(dofile, vim.g.base46_cache .. "defaults")
local ok2, _ = pcall(dofile, vim.g.base46_cache .. "statusline")
-- base46 cache se regenera al abrir nvim con NvChad, no es crítico si falta

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Expose Neovim socket for MCP Neovim Server (opencode ↔ Neovim)
-- Si ya hay un servidor activo en el socket, solo avisa sin error
local ok, err = pcall(vim.fn.serverstart, "/tmp/nvim")
if not ok then
  vim.notify("[init.lua] Servidor Neovim ya iniciado en /tmp/nvim", vim.log.levels.WARN)
end
