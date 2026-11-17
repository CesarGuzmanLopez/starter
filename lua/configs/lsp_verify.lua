-- Verificador de LSP al arranque: python/c++/kotlin/cmake/java/rust.
-- Si falta el binario (Mason o sistema), error visible una vez por sesion
-- con el :MasonInstall correspondiente. No bloquea el arranque.
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
  local missing = {}
  for lang, spec in pairs(REQUIRED) do
    local found = false
    for _, bin in ipairs(spec.bins) do
      if vim.fn.executable(bin) == 1 or mason_bin_exists(bin) then
        found = true
        break
      end
    end
    if not found then
      table.insert(missing, ("- %s: `%s` no ejecutable → :MasonInstall %s"):format(lang, spec.bins[1], spec.pkg))
    end
  end
  if #missing > 0 then
    vim.notify(
      "LSP faltante:\n" .. table.concat(missing, "\n"),
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
