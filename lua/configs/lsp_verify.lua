-- Verificador de LSP al arranque: cubre todos los servers habilitados en
-- lua/configs/lspconfig.lua. Si falta el binario (Mason o sistema), lo
-- instala solo con :MasonInstall (asincrono, no bloquea). Avisa una vez por
-- sesion; al terminar, reabre el buffer para que el server arranque.
local M = {}

local REQUIRED = {
  -- nativos / lenguajes principales
  python = { pkg = "pyright", bins = { "pyright-langserver", "pyright" }, lsp = "pyright" },
  c = { pkg = "clangd", bins = { "clangd" }, lsp = "clangd" },
  cpp = { pkg = "clangd", bins = { "clangd" }, lsp = "clangd" },
  java = { pkg = "jdtls", bins = { "jdtls" }, lsp = "jdtls" },
  kotlin = { pkg = "kotlin-language-server", bins = { "kotlin-language-server" }, lsp = "kotlin_language_server" },
  rust = { pkg = "rust-analyzer", bins = { "rust-analyzer" }, lsp = "rust_analyzer" },
  cmake = { pkg = "neocmakelsp", bins = { "neocmakelsp" }, lsp = "neocmake" },
  -- web
  typescript = { pkg = "typescript-language-server", bins = { "typescript-language-server" }, lsp = "ts_ls" },
  javascript = { pkg = "typescript-language-server", bins = { "typescript-language-server" }, lsp = "ts_ls" },
  angular = { pkg = "angular-language-server", bins = { "ngserver" }, lsp = "angularls" },
  html = { pkg = "html-lsp", bins = { "vscode-html-language-server" }, lsp = "html" },
  css = { pkg = "css-lsp", bins = { "vscode-css-language-server" }, lsp = "cssls" },
  -- datos / config
  json = { pkg = "json-lsp", bins = { "vscode-json-language-server" }, lsp = "jsonls" },
  yaml = { pkg = "yaml-language-server", bins = { "yaml-language-server" }, lsp = "yamlls" },
  toml = { pkg = "taplo", bins = { "taplo" }, lsp = "taplo" },
  -- scripting / docs / otros
  lua = { pkg = "lua-language-server", bins = { "lua-language-server" }, lsp = "lua_ls" },
  bash = { pkg = "bash-language-server", bins = { "bash-language-server" }, lsp = "bashls" },
  markdown = { pkg = "marksman", bins = { "marksman" }, lsp = "marksman" },
  dockerfile = { pkg = "dockerfile-language-server", bins = { "docker-langserver" }, lsp = "dockerls" },
  php = { pkg = "intelephense", bins = { "intelephense" }, lsp = "intelephense" },
  qml = { pkg = "qmlls", bins = { "qmlls" }, lsp = "qmlls" },
  julia = { pkg = "julia-lsp", bins = { "julia-lsp" }, lsp = "julials" },
  d = { pkg = "serve-d", bins = { "serve-d" }, lsp = "serve_d" },
}

local function mason_bin_exists(bin)
  local p = vim.fn.stdpath "data" .. "/mason/bin/" .. bin
  return vim.fn.executable(p) == 1
end

function M.check()
  local missing, pkgs = {}, {}
  for lang, spec in pairs(REQUIRED) do
    local found = false
    for _, bin in ipairs(spec.bins) do
      if vim.fn.executable(bin) == 1 or mason_bin_exists(bin) then
        found = true
        break
      end
    end
    if not found then
      table.insert(missing, ("- %s: `%s`"):format(lang, spec.bins[1]))
      table.insert(pkgs, spec.pkg)
    end
  end
  if #missing == 0 then
    return
  end
  -- Autoinstalacion: MasonInstall es asincrono, no bloquea el arranque.
  local ok = pcall(vim.cmd, "MasonInstall " .. table.concat(pkgs, " "))
  if ok then
    vim.notify(
      "LSP instalando:\n" .. table.concat(missing, "\n") .. "\nReabre el buffer al terminar.",
      vim.log.levels.WARN,
      { title = "LSP: servers", timeout = 10000 }
    )
  else
    vim.notify(
      "LSP faltante (Mason no disponible):\n"
        .. table.concat(missing, "\n")
        .. "\nInstala a mano: :MasonInstall "
        .. table.concat(pkgs, " "),
      vim.log.levels.ERROR,
      { title = "LSP: servers", timeout = 10000 }
    )
  end
end

local once = false
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("LspVerify", { clear = true }),
  callback = function()
    if once then
      return
    end
    once = true
    -- Mason puede seguir montando PATH al inicio: chequeo diferido.
    vim.defer_fn(M.check, 2000)
  end,
})

-- Exportado para tests/inspeccion (:lua print(vim.inspect(require"configs.lsp_verify".REQUIRED)))
M.REQUIRED = REQUIRED

return M
