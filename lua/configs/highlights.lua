-- Highlights de UI que deben adaptarse al modo claro/oscuro.
-- Se re-aplican despues de cada recarga de tema (base46) para que un
-- override del chadrc no fuerce un color pensado solo para un modo.
local M = {}

function M.apply()
  -- La linea activa NO lleva fondo opaco: un bg solido (p. ej. #3a3a4a)
  -- tapa el color de los strings y se vuelven ilegibles. Con
  -- cursorlineopt=number se marca la linea con el numero (CursorLineNr).
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { bold = true })

  -- Visual: invierte fg/bg sin depender del bg del tema (no se mezcla).
  vim.api.nvim_set_hl(0, "Visual", { reverse = true })
end

return M
