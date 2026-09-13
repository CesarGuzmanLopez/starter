require "nvchad.options"

-- add yours here!
-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- treesitter parsers install directory
vim.opt.rtp:append(vim.fn.stdpath "data" .. "/site")

-- luarocks paths for image.nvim (magick)
local luarocks_path = vim.fn.expand "~/.luarocks/share/lua/5.1/?.lua"
  .. ";"
  .. vim.fn.expand "~/.luarocks/share/lua/5.1/?/init.lua"
package.path = luarocks_path .. ";" .. package.path

local luarocks_lib = vim.fn.expand "~/.luarocks/lib/lua/5.1/?.so"
package.cpath = luarocks_lib .. ";" .. package.cpath

-- Resaltar la linea activa completa. El fondo de CursorLine se calcula en
-- configs/highlights.lua como "un poco mas claro que el fondo del tema" para
-- no tapar el color de los strings.
vim.opt.cursorlineopt = "line"

-- Click derecho (boton secundario): sin menu contextual de Neovim.
-- El comportamiento (copiar/pegar) se define en lua/mappings.lua.
vim.opt.mousemodel = "extend"

-- Opciones comunes
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.confirm = true -- pedir confirmacion al salir sin guardar
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.pumheight = 12
vim.opt.autoread = true
