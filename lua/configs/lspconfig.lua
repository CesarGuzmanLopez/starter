require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "rust_analyzer",
  "clangd",
  "pyright",
  "ts_ls",
  "angularls", -- Angular language server
  "cmake", -- CMake language server
  -- "kotlin_language_server",  -- Kotlin (configurado aparte abajo)
  "intelephense", -- PHP
  "qmlls", -- QML

  -- Frontend / general
  "jsonls", -- JSON
  "yamlls", -- YAML

  -- Backend nativo / scripting
  "lua_ls", -- Lua (Neovim config)
  "bashls", -- Bash/Shell
  "taplo", -- TOML
  "marksman", -- Markdown
  "dockerls", -- Dockerfile
  "serve_d", -- D language
  "julials", -- Julia
}

vim.lsp.enable(servers)

-- ts_ls: si el proyecto trae un TypeScript sin tsserver.js (p. ej. TS 7 en
-- ~/.config/opencode), el server local falla en initialize en loop ("Could
-- not find a valid TypeScript installation"). Se fija un tsserver.path
-- valido: el TS empaquetado por Mason (verificado con tsserver.js).
do
  local ts_lib = vim.fn.stdpath "data" .. "/mason/packages/typescript-language-server/node_modules/typescript/lib"
  if vim.uv.fs_stat(ts_lib .. "/tsserver.js") then
    vim.lsp.config("ts_ls", {
      init_options = {
        tsserver = { path = ts_lib },
      },
    })
  end
end

-- NOTA: kotlin-language-server 1.3.13 es incompatible con Neovim 0.12
-- (Error: Expected BEGIN_OBJECT but was BEGIN_ARRAY en workspace/configuration)
-- Solucion: esperar una version actualizada del server o usar vim.lsp.enable
-- vim.lsp.enable("kotlin_language_server")

-- read :h vim.lsp.config for changing options of lsp servers
