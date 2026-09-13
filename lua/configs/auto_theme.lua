-- auto_theme.lua — Tema claro/oscuro segun el fondo real de la terminal.
--
-- Orden de deteccion:
--   1. $NVIM_THEME_MODE (light|dark)  -> override manual / tests
--   2. kitty: `kitten @ get-colors`   -> color de fondo real del terminal
--   3. Portal XDG (gdbus) color-scheme -> 1=dark, 2=light
--   4. vim.o.background                -> ultimo recurso
--
-- No toca KDE: si KDE cambia el esquema, kitty cambia su fondo y esto lo sigue.
local M = {}

local DARK_THEME = vim.env.NVIM_DARK_THEME or "wallust"
local LIGHT_THEME = vim.env.NVIM_LIGHT_THEME or "one_light"

local last_check = 0

local function linear(c)
  return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
end

---Luminancia relativa (WCAG) de un color "#rrggbb".
local function luminance(hex)
  hex = tostring(hex):gsub("^#", "")
  if #hex < 6 then
    return nil
  end
  local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
  if not (r and g and b) then
    return nil
  end
  return 0.2126 * linear(r / 255) + 0.7152 * linear(g / 255) + 0.0722 * linear(b / 255)
end

local function mode_from_bg(hex)
  local l = luminance(hex)
  if not l then
    return nil
  end
  return l > 0.5 and "light" or "dark"
end

---Fondo real del terminal via kitty remote control.
local function detect_kitty()
  local listen = vim.env.KITTY_LISTEN_ON
  if not listen or listen == "" then
    local runtime = vim.env.XDG_RUNTIME_DIR
    if runtime and runtime ~= "" then
      listen = "unix:" .. runtime .. "/kitty"
    end
  end
  if not listen or vim.fn.executable "kitten" ~= 1 then
    return nil
  end

  local out = vim.fn.system { "kitten", "@", "--to", listen, "get-colors" }
  if vim.v.shell_error ~= 0 or type(out) ~= "string" then
    return nil
  end
  local bg = out:match "background%s+(#%x%x%x%x%x%x)"
  return bg and mode_from_bg(bg) or nil
end

---Preferencia de color del SO via portal XDG (misma fuente que usa kitty).
local function detect_portal()
  if vim.fn.executable "gdbus" ~= 1 then
    return nil
  end

  local out = vim.fn.system {
    "gdbus", "call", "--session",
    "--dest", "org.freedesktop.portal.Desktop",
    "--object-path", "/org/freedesktop/portal/desktop",
    "--method", "org.freedesktop.portal.Settings.Read",
    "org.freedesktop.appearance", "color-scheme",
  }
  if vim.v.shell_error ~= 0 then
    return nil
  end

  local v = tonumber(out:match "uint32%s+(%d+)")
  if v == 1 then
    return "dark"
  elseif v == 2 then
    return "light"
  end
  return nil
end

---Devuelve "light" o "dark".
function M.detect()
  if vim.env.NVIM_THEME_MODE == "light" or vim.env.NVIM_THEME_MODE == "dark" then
    return vim.env.NVIM_THEME_MODE
  end
  return detect_kitty() or detect_portal() or (vim.o.background == "light" and "light" or "dark")
end

---Aplica el tema del modo indicado. Devuelve true si cambio.
function M.apply(mode, force)
  local theme = mode == "light" and LIGHT_THEME or DARK_THEME
  local nvconfig = require "nvconfig"

  if not force and nvconfig.base46.theme == theme then
    vim.o.background = mode
    require("configs.highlights").apply(mode)
    return false
  end

  nvconfig.base46.theme = theme
  require("base46").load_all_highlights()
  require("configs.highlights").apply(mode)
  return true
end

---Detecta y aplica. Devuelve modo y si hubo cambio.
---Solo re-aplica cuando el modo de la terminal cambia (o con force), para no
---pisar una eleccion manual de tema hecha con el selector de NvChad.
function M.sync(opts)
  opts = opts or {}
  local mode = M.detect()

  if not opts.force and M._mode == mode then
    return mode, false
  end

  M._mode = mode
  return mode, M.apply(mode, opts.force)
end

---Fuerza el modo opuesto al actual.
function M.toggle()
  local mode = vim.o.background == "light" and "dark" or "light"
  M.apply(mode, true)
  vim.notify("auto-theme: " .. mode, vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_user_command("AutoTheme", function()
    local mode, changed = M.sync { force = true }
    vim.notify("auto-theme: " .. mode .. (changed and " (aplicado)" or " (sin cambios)"), vim.log.levels.INFO)
  end, { desc = "Aplica tema claro/oscuro segun el fondo de la terminal" })

  vim.api.nvim_create_user_command("AutoThemeToggle", M.toggle, {
    desc = "Fuerza el tema claro/oscuro opuesto",
  })

  -- Aplicar apenas el event loop lo permita: setup() ya corre despues de
  -- require("lazy").setup(), o sea NvChad/base46 ya estan cargados.
  -- force=true recompila los highlights una vez: el cache de base46 puede
  -- venir con Normal opaco (sin transparencia) de una corrida anterior.
  vim.schedule(function()
    M.sync { force = true }
  end)

  -- Respaldo por si el schedule inicial corre demasiado temprano.
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(function()
        M.sync()
      end)
    end,
  })

  -- Re-detectar al recuperar foco (p. ej. al cambiar el tema de kitty/KDE).
  vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
      local now = vim.uv.now()
      if now - last_check < 1500 then
        return
      end
      last_check = now
      vim.schedule(function()
        M.sync()
      end)
    end,
  })
end

return M
