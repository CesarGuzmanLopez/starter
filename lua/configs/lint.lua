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
  linters = {
    ruff = { args = { "check", "--output-format", "json", "--stdin-filename", "$FILENAME", "-" } },
    mypy = { args = { "--no-color-output" } },
    eslint_d = { args = { "--stdin", "--stdin-filename", "$FILENAME", "--format", "json" } },
    clangtidy = { args = { "--quiet", "--use-color", "-" } },
  },
}
