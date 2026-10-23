require "nvchad.options"

-- Providers: NvChad los desactiva (loaded_*=0). Los reactivamos porque los
-- clientes estan instalados (pynvim, neovim npm, neovim gem). Perl queda
-- desactivado: no hay plugins remotos perl y Neovim::Ext no esta en @INC.
vim.g.loaded_node_provider = nil
vim.g.loaded_python3_provider = nil
vim.g.loaded_ruby_provider = nil
vim.g.loaded_perl_provider = 0

-- Hosts explicitos: evita la busqueda via pyenv (raiz inexistente) y expone
-- neovim-ruby-host (gem --user-install) al PATH interno de Neovim.
-- Las rutas del gem varian (GEM_HOME, XDG, version de ruby): se prueban candidatas.
vim.g.python3_host_prog = "/usr/bin/python3"
do
  local cands = {}
  if vim.env.GEM_HOME and vim.env.GEM_HOME ~= "" then
    table.insert(cands, vim.env.GEM_HOME .. "/bin")
  end
  if vim.env.XDG_DATA_HOME and vim.env.XDG_DATA_HOME ~= "" then
    for _, d in ipairs(vim.fn.glob(vim.env.XDG_DATA_HOME .. "/gem/ruby/*/bin", true, true)) do
      table.insert(cands, d)
    end
  end
  for _, d in ipairs(vim.fn.glob(vim.fn.expand "~/.local/share/gem/ruby/*/bin", true, true)) do
    table.insert(cands, d)
  end
  for _, d in ipairs(vim.fn.glob(vim.fn.expand "~/.gem/ruby/*/bin", true, true)) do
    table.insert(cands, d)
  end
  for _, d in ipairs({ vim.fn.expand "~/.juliaup/bin" }) do
    table.insert(cands, d)
  end
  for _, d in ipairs(cands) do
    if vim.fn.isdirectory(d) == 1 and not string.find(":" .. vim.env.PATH .. ":", ":" .. d .. ":", 1, true) then
      vim.env.PATH = d .. ":" .. vim.env.PATH
    end
  end
end

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
