-- Verificador de LSP al arranque: python/c++/kotlin/cmake/java/rust.
-- Si falta el binario (Mason o sistema), lo instala solo con :MasonInstall
-- (asincrono, no bloquea). Avisa una vez por sesion; al terminar, reabre
-- el buffer para que el server arranque.
local M = {}

local REQUIRED = {
  python = { pkg = "pyright", bins = { "pyright-langserver", "pyright" }, lsp = "pyright" },
  ["c++"] = { pkg = "clangd", bins = { "clangd" }, lsp = "clangd" },
  kotlin = { pkg = "kotlin-language-server", bins = { "kotlin-language-server" }, lsp = "kotlin_language_server" },
  cmake = { pkg = "cmake-language-server", bins = { "cmake-language-server" }, lsp = "cmake" },
  java = { pkg = "jdtls", bins = { "jdtls" }, lsp = "jdtls" },
  rust = { pkg = "rust-analyzer", bins = { "rust-analyzer" }, lsp = "rust_analyzer" },
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

return M
