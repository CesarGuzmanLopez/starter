require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "rust_analyzer",
  "clangd",
  "pyright",
  "ts_ls",
  "angularls",   -- Angular language server
  "cmake",       -- CMake language server
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
