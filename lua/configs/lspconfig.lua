require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "rust_analyzer",
  "clangd",
  "pyright",
  "ts_ls",
  "angularls",    -- Angular language server
  "cmake",        -- CMake language server
  -- "kotlin_language_server",  -- Kotlin (configurado aparte abajo)
  "intelephense", -- PHP
  "qmlls",        -- QML

  -- Frontend / general
  "jsonls",       -- JSON
  "yamlls",       -- YAML

  -- Backend nativo / scripting
  "lua_ls",       -- Lua (Neovim config)
  "bashls",       -- Bash/Shell
  "taplo",        -- TOML
  "marksman",     -- Markdown
  "dockerls",     -- Dockerfile
}

vim.lsp.enable(servers)

-- NOTA: kotlin-language-server 1.3.13 es incompatible con Neovim 0.12
-- (Error: Expected BEGIN_OBJECT but was BEGIN_ARRAY en workspace/configuration)
-- Solucion: esperar una version actualizada del server o usar vim.lsp.enable
-- vim.lsp.enable("kotlin_language_server")

-- read :h vim.lsp.config for changing options of lsp servers
