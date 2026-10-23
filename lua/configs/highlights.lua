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

---Luminancia relativa (WCAG simplificada) 0..1.
local function luminance_hex(hex)
  hex = tostring(hex or ""):gsub("^#", "")
  if #hex < 6 then return nil end
  local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
  if not (r and g and b) then return nil end
  local function lin(c)
    c = c / 255
    return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
end

---Sube la luminosidad de un grupo hasta que sea legible en fondo oscuro.
---No toca bg, solo fg (los grupos treesitter se enlazan a Comment aparte).
local function brighten_fg(group, min_lum, step)
  local ok, cur = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if not ok or cur.fg == nil then return end
  local okc, colors = pcall(require, "base46.colors")
  if not okc or not colors or not colors.change_hex_lightness then return end
  local hex = string.format("#%06x", cur.fg)
  for _ = 1, 12 do
    local lum = luminance_hex(hex)
    if not lum or lum >= min_lum then break end
    hex = colors.change_hex_lightness(hex, step or 10)
  end
  cur.link = nil
  cur.fg = hex
  pcall(vim.api.nvim_set_hl, 0, group, cur)
end

---Transparencia activa en nvconfig (chadrc).
local function transparent()
  local ok, nv = pcall(require, "nvconfig")
  return ok and nv.base46 and nv.base46.transparency or false
end

---Quita el bg de un grupo conservando el resto de atributos (fg, bold...).
local function clear_bg(group)
  local ok, cur = pcall(vim.api.nvim_get_hl, 0, { name = group })
  if not ok or cur.bg == nil then
    return
  end
  cur.link = nil
  cur.bg = "NONE"
  cur.ctermbg = nil
  pcall(vim.api.nvim_set_hl, 0, group, cur)
end

function M.apply()
  -- blankline primero: :colorscheme borra IblChar/IblScopeChar (solo existen
  -- en el cache de base46) y el handler ColorScheme de ibl falla a medias
  -- dejando highlights.indent={} -> crash en virt_text.lua:95 en cada
  -- CursorMoved. Re-dofilear aqui (nuestro autocmd corre antes que el de ibl)
  -- evita el fallo; el schedule repara sesiones ya rotas.
  local cache = vim.g.base46_cache
  if cache then
    pcall(dofile, cache .. "blankline")
  end

  local dark = vim.o.background ~= "light"
  local transp = transparent()

  -- Renglon actual siempre con fondo: translucido no se nota,
  -- asi que va solido sutil aunque haya transparencia.
  vim.api.nvim_set_hl(0, "CursorLine", { bg = cursorline_bg(dark) })
  vim.api.nvim_set_hl(0, "CursorLineNr", { bold = true })

  -- Contraste minimo en oscuro: comentarios y grises que vienen casi negros
  -- (#4e4d5d, #474656...) son ilegibles sobre terminal oscura + transparencia.
  -- En claro no se toca (ahi se ve bien).
  if dark then
    -- Comentarios: el tema los trae casi negros (#4e4d5d). Color fijo legible;
    -- vale para bash/sh, python, c/cpp (gcc/g++), node/ts, lua: todos usan @comment.
    vim.api.nvim_set_hl(0, "Comment", { fg = "#a6adc8" })
    -- Palabras clave en comentarios: cada una su color (antes casi negras).
    vim.api.nvim_set_hl(0, "@comment.todo", { fg = "#f9e2af", bold = true })
    vim.api.nvim_set_hl(0, "@comment.note", { fg = "#89b4fa", bold = true })
    vim.api.nvim_set_hl(0, "@comment.warning", { fg = "#fab387", bold = true })
    vim.api.nvim_set_hl(0, "@comment.danger", { fg = "#f38ba8", bold = true })
    vim.api.nvim_set_hl(0, "@comment.error", { link = "@comment.danger" })
    for _, g in ipairs({
      "LineNr",
      "LineNrAbove",
      "LineNrBelow",
      "NonText",
      "EndOfBuffer",
      "Folded",
      "DiagnosticUnnecessary",
    }) do
      brighten_fg(g, 0.18, 10)
    end
    -- Treesitter sigue a Comment via link. Defer: algo (base46/treesitter)
    -- re-define @comment despues del apply inicial; al final del loop ganamos.
    vim.schedule(function()
      for _, g in ipairs({ "@comment", "@lsp.type.comment", "@string.documentation" }) do
        pcall(vim.api.nvim_set_hl, 0, g, { link = "Comment" })
      end
    end)
  end

  -- Notas virtuales de diagnostico (shellcheck "Note that...", etc.): color
  -- azulado propio + italica y sin fondo, para que no parezcan codigo.
  -- Solo Info/Hint (notas); Warn/Error conservan su color de alerta.
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#7fb5d5", bg = "NONE", italic = true })
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#7fb5d5", bg = "NONE", italic = true })

  -- Inlay hints (notas del LSP inline): color azulado propio + italica y sin
  -- fondo, para que no parezcan ni codigo ni comentarios grises.
  if dark then
    vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#7fb5d5", bg = "NONE", italic = true })
  else
    vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#3f6d96", bg = "NONE", italic = true })
  end

  -- Visual: invierte fg/bg sin depender del bg del tema (no se mezcla).
  vim.api.nvim_set_hl(0, "Visual", { reverse = true })

  -- Tabufline: base46 con transparency=true la deja en bg=NONE. Solo le
  -- devolvemos fondo solido en modo claro (terminal oscura detras = ilegible)
  -- o sin transparencia; en oscuro+transparente se restaura lo compilado.
  local c = base30()
  if c then
    if transp and dark and cache then
      pcall(dofile, cache .. "tbline")
    else
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

  -- 1. Sin fondo solido por default: con transparencia, cualquier
  -- :colorscheme (de base46 o crudo como :colorscheme catppuccin) que deje
  -- bg solido en el editor se transparenta. Solo bg; fg y estilos intactos.
  if transp then
    for _, g in ipairs {
      "Normal",
      "NormalNC",
      "SignColumn",
      "FoldColumn",
      "EndOfBuffer",
      "NonText",
      "LineNr",
      "LineNrAbove",
      "LineNrBelow",
      "WinSeparator",
      "MsgArea",
      "StatusLine",
      "StatusLineNC",
    } do
      clear_bg(g)
    end
  end

  -- 2. Iconos: un :colorscheme crudo borra los grupos St_* (statusline) y
  -- DevIcon* y los separadores/iconos se ven rotos. Se restauran del cache
  -- de base46 si faltan (vale para cualquier tema activo).
  if cache then
    if vim.fn.hlexists "St_NormalMode" == 0 then
      pcall(dofile, cache .. "statusline")
    end
    if vim.fn.hlexists "DevIconDefault" == 0 then
      pcall(dofile, cache .. "devicons")
    end
  end

  -- Repara tablas de ibl si un cambio de tema las dejo vacias. Schedule para
  -- correr despues del handler ColorScheme propio de ibl.
  vim.schedule(function()
    local ok_hl, hl = pcall(require, "ibl.highlights")
    if ok_hl and hl.setup then
      pcall(hl.setup)
    end
    local ok_ibl, ibl = pcall(require, "ibl")
    if ok_ibl and ibl.refresh_all then
      pcall(ibl.refresh_all)
    end
  end)
end

return M
