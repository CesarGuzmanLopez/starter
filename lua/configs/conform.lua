local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    python = { "ruff_format" },
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    angular = { "prettierd" },
    html = { "prettierd" },
    css = { "prettierd" },
    json = { "prettierd" },
    yaml = { "prettierd" },
    markdown = { "prettierd" },
    kotlin = { "ktfmt" },
    java = { "google-java-format" },
    qml = { "qmlformat" },
  },

  formatters = {
    qmlformat = {
      command = "qmlformat",
      args = { "-i", "$FILENAME" },
    },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
