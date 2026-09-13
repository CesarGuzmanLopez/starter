-- Highlights de UI que deben adaptarse al modo claro/oscuro.
-- Se re-aplican despues de cada recarga de tema (base46).
local M = {}

---Tabla base_30 del tema actual.
local function base30()
  local ok, base46 = pcall(require, "base46")
  if not ok or not base46.get_theme_tb then
    return nil
  end
  local ok2, tb = pcall(base46.get_theme_tb, "base_30")
  if ok2 and type(tb) == "table" then
    return tb
  end
  return nil
end

---Fondo del tema actual (base_30.black o base_16.base00).
local function theme_bg()
  local tb = base30()
  if tb and tb.black then
    return tb.black
  end
  local ok, base46 = pcall(require, "base46")
  if ok and base46.get_theme_tb then
    local ok2, b16 = pcall(base46.get_theme_tb, "base_16")
    if ok2 and type(b16) == "table" then
      return b16.base00
    end
  end
  return nil
end

---Fondo de la linea activa: apenas mas claro (oscuro) o mas oscuro (claro)
---que el fondo del tema, para que no tape el color de los strings.
local function cursorline_bg(dark)
  local ok, colors = pcall(require, "base46.colors")
  local bg = theme_bg()

  if ok and colors and bg then
    -- +6% de luminosidad en oscuro, -6% en claro
    return colors.change_hex_lightness(bg, dark and 6 or -6)
  end
  return dark and "#12141a" or "#e4e4ec"
end

function M.apply()
  local dark = vim.o.background ~= "light"

  vim.api.nvim_set_hl(0, "CursorLine", { bg = cursorline_bg(dark) })
  vim.api.nvim_set_hl(0, "CursorLineNr", { bold = true })

  -- Visual: invierte fg/bg sin depender del bg del tema (no se mezcla).
  vim.api.nvim_set_hl(0, "Visual", { reverse = true })

  -- Tabufline: con transparency=true, base46 la deja en bg=NONE y en modo
  -- claro se ve el terminal oscuro detras. Le devolvemos el fondo del tema
  -- (claro en claro, oscuro en oscuro) manteniendo el resto transparente.
  local c = base30()
  if c then
    vim.api.nvim_set_hl(0, "Tabline", { bg = c.black2 })
    vim.api.nvim_set_hl(0, "TbFill", { bg = c.black2 })
    vim.api.nvim_set_hl(0, "TbBufOn", { bg = c.black, fg = c.white })
    vim.api.nvim_set_hl(0, "TbBufOff", { bg = c.black2, fg = c.light_grey })
    vim.api.nvim_set_hl(0, "TbBufOnClose", { bg = c.black, fg = c.red })
    vim.api.nvim_set_hl(0, "TbBufOffClose", { bg = c.black2, fg = c.light_grey })
    vim.api.nvim_set_hl(0, "TbBufOnModified", { bg = c.black, fg = c.green })
    vim.api.nvim_set_hl(0, "TbBufOffModified", { bg = c.black2, fg = c.red })
  end
end

return M
