-- Highlights de UI que deben adaptarse al modo claro/oscuro.
-- Se re-aplican despues de cada recarga de tema (base46).
local M = {}

---Fondo del tema actual (base_30.black o base_16.base00).
local function theme_bg()
  local ok, base46 = pcall(require, "base46")
  if not ok or not base46.get_theme_tb then
    return nil
  end
  local ok30, base30 = pcall(base46.get_theme_tb, "base_30")
  if ok30 and type(base30) == "table" and base30.black then
    return base30.black
  end
  local ok16, base16 = pcall(base46.get_theme_tb, "base_16")
  if ok16 and type(base16) == "table" and base16.base00 then
    return base16.base00
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
end

return M
