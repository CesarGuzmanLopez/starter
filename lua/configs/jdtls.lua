local M = {}

M.setup = function()
  local jdtls = require "jdtls"
  local home = os.getenv "HOME"
  local jdtls_path = home .. "/.local/share/jdtls"
  local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  local config_linux = jdtls_path .. "/config_linux"

  local bundles = {}
  -- Kotlin support via kotlin-language-server
  local kotlin_lsp = vim.fn.glob(home .. "/.local/share/kotlin-language-server/bin/kotlin-language-server")
  if kotlin_lsp ~= "" then
    -- jdtls bundles can be extended with kotlin support if needed
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
      },
    },
  }

  local config = {
    cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Djava.configuration.runtimes.JAVA_22=/usr/lib/jvm/java-22-openjdk",
      "-Djava.configuration.runtimes.JAVA_17=/usr/lib/jvm/java-17-openjdk",
      "-Djava.configuration.runtimes.JAVA_21=/usr/lib/jvm/java-21-openjdk",
      "-jar",
      launcher,
      "-configuration",
      config_linux,
      "-data",
      home .. "/.cache/jdtls/workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
    },
    root_dir = require("lspconfig.util").root_pattern(
      "build.gradle",
      "build.gradle.kts",
      "pom.xml",
      ".git",
      "settings.gradle",
      "settings.gradle.kts"
    ),
    capabilities = capabilities,
    settings = {
      java = {
        configuration = {
          updateBuildConfiguration = "interactive",
          runtimes = {
            {
              name = "JavaSE-22",
              path = "/usr/lib/jvm/java-22-openjdk/",
            },
          },
        },
        maven = {
          downloadSources = true,
        },
        referencesCodeLens = {
          enabled = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        format = {
          enabled = true,
        },
        signatureHelp = {
          enabled = true,
        },
        completion = {
          favoriteStaticMembers = {
            "org.junit.Assert.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
          },
          importOrder = {
            "java",
            "javax",
            "com",
            "org",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 5,
            staticStarThreshold = 3,
          },
        },
      },
    },
    init_options = {
      bundles = bundles,
    },
  }

  jdtls.start_or_attach(config)
end

return M
