return {
  -- Linters by filetype
  linters_by_ft = {
    c = { "clangtidy" },
    cpp = { "clangtidy" },
    python = { "ruff", "mypy" },
    javascript = { "eslint_d" },
    typescript = { "eslint_d" },
    angular = { "eslint_d" },
    html = { "htmlhint" },
    css = { "stylelint" },
    json = { "jsonlint" },
    markdown = { "markdownlint" },
    yaml = { "yamllint" },
    kotlin = { "ktlint" },
    cmake = { "cmakelint" },
  },

  -- Linter configurations
  -- OJO: nvim-lint NO expande "$FILENAME" (eso es de null-ls/conform).
  -- El nombre del archivo debe darse con una función o el override
  -- *.ts no calza y el .ts se parsea como JS ("Parsing error: 'import'").
  linters = {
    ruff = { args = { "check", "--output-format", "json", "--stdin-filename", function() return vim.api.nvim_buf_get_name(0) end, "-" } },
    mypy = { args = { "--no-color-output" } },
    eslint_d = { args = { "--stdin", "--stdin-filename", function() return vim.api.nvim_buf_get_name(0) end, "--format", "json" } },
    clangtidy = { args = { "--quiet", "--use-color", "-" } },
  },
}
