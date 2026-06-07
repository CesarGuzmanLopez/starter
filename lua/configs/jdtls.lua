local M = {}

M.setup = function()
  local jdtls = require "jdtls"
  local home = os.getenv "HOME"
  local jdtls_path = home .. "/.local/share/jdtls"
  local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  local config_linux = jdtls_path .. "/config_linux"

  local function find_jdk(version)
    local candidates = {
      "/usr/lib/jvm/java-" .. version .. "-openjdk",
      "/usr/lib/jvm/java-" .. version .. "-openjdk-amd64",
      "/usr/lib/jvm/java-" .. version,
      "/Library/Java/JavaVirtualMachines/jdk-" .. version .. ".jdk/Contents/Home",
      os.getenv "JAVA_HOME",
    }
    for _, path in ipairs(candidates) do
      if path and vim.fn.isdirectory(path) == 1 then
        return path
      end
    end
    return nil
  end

  local jdk22 = find_jdk "22"
  local jdk21 = find_jdk "21"
  local jdk17 = find_jdk "17"

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
          runtimes = {},
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

  -- Insert detected JDK runtime args into cmd
  local runtime_args = {}
  if jdk22 then table.insert(runtime_args, "-Djava.configuration.runtimes.JAVA_22=" .. jdk22) end
  if jdk21 then table.insert(runtime_args, "-Djava.configuration.runtimes.JAVA_21=" .. jdk21) end
  if jdk17 then table.insert(runtime_args, "-Djava.configuration.runtimes.JAVA_17=" .. jdk17) end
  for i, arg in ipairs(runtime_args) do
    table.insert(config.cmd, 5 + i, arg)
  end

  -- Populate runtimes from detected JDKs
  local runtimes = {}
  if jdk22 then table.insert(runtimes, { name = "JavaSE-22", path = jdk22 .. "/" }) end
  if jdk21 then table.insert(runtimes, { name = "JavaSE-21", path = jdk21 .. "/" }) end
  if jdk17 then table.insert(runtimes, { name = "JavaSE-17", path = jdk17 .. "/" }) end
  config.settings.java.configuration.runtimes = runtimes

  jdtls.start_or_attach(config)
end

return M
