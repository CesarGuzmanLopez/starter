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
  "kotlin_language_server",  -- Kotlin
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

-- read :h vim.lsp.config for changing options of lsp servers
