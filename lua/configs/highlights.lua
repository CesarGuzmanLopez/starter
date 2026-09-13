-- Highlights de UI que deben adaptarse al modo claro/oscuro.
-- Se re-aplican despues de cada recarga de tema (base46) para que un
-- override del chadrc no fuerce un color pensado solo para un modo.
local M = {}

---@param mode? "dark"|"light"|string
function M.apply(mode)
  local dark = mode ~= "light"

  -- CursorLine: en oscuro el tono original del usuario; en claro, uno que no
  -- opaque el fondo transparente con un color oscuro.
  vim.api.nvim_set_hl(0, "CursorLine", { bg = dark and "#3a3a4a" or "#e4e4ec" })

  -- Visual: invierte fg/bg sin depender del bg del tema (no se mezcla).
  vim.api.nvim_set_hl(0, "Visual", { reverse = true })
end

return M
