require "nvchad.options"

-- add yours here!

-- treesitter parsers install directory
vim.opt.rtp:append(vim.fn.stdpath "data" .. "/site")

-- luarocks paths for image.nvim (magick)
local luarocks_path = vim.fn.expand "~/.luarocks/share/lua/5.1/?.lua"
  .. ";"
  .. vim.fn.expand "~/.luarocks/share/lua/5.1/?/init.lua"
package.path = luarocks_path .. ";" .. package.path

local luarocks_lib = vim.fn.expand "~/.luarocks/lib/lua/5.1/?.so"
package.cpath = luarocks_lib .. ";" .. package.cpath

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
