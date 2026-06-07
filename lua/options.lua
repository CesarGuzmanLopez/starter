require "nvchad.options"

-- add yours here!

-- luarocks paths for image.nvim (magick)
local luarocks_path = vim.fn.expand "~/.local/share/lua/5.1/?.lua"
  .. ";"
  .. vim.fn.expand "~/.local/share/lua/5.1/?/init.lua"
package.path = luarocks_path .. ";" .. package.path

local luarocks_lib = vim.fn.expand "~/.local/lib/lua/5.1/?.so"
package.cpath = luarocks_lib .. ";" .. package.cpath

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
