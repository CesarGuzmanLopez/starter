local M = {}

M.setup = function()
  local jdtls = require "jdtls"
  local home = os.getenv "HOME"
  -- Mason es la fuente principal; fallback al path manual antiguo.
  local mason_jdtls = home .. "/.local/share/nvim/mason/packages/jdtls"
  local jdtls_path = vim.fn.isdirectory(mason_jdtls) == 1 and mason_jdtls or (home .. "/.local/share/jdtls")
  local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  local config_linux = jdtls_path .. "/config_linux"
  if launcher == "" or vim.fn.isdirectory(config_linux) == 0 then
    vim.notify(
      "[jdtls] No encontrado en " .. jdtls_path .. " (:MasonInstall jdtls)",
      vim.log.levels.ERROR,
      { title = "LSP: java" }
    )
    return
  end

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

  local jdk27 = find_jdk "27"
  local jdk26 = find_jdk "26"
  local jdk25 = find_jdk "25"
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

  -- jdtls reciente exige JVM 25+ para el propio servidor: se usa el JDK
  -- mas nuevo disponible como ejecutable (los runtimes de proyecto van aparte).
  local jdk_newest = jdk27 or jdk26 or jdk25 or jdk22 or jdk21 or jdk17
  local java_bin = jdk_newest and (jdk_newest .. "/bin/java") or "java"

  -- Workspace por RAIZ del proyecto (no por cwd): dos sesiones sobre el
  -- mismo proyecto compartian `-data` y el segundo jdtls no lograba el lock
  -- (quedaba solo null-ls y `gd` fallaba). El basename se sanitiza.
  local root_markers = {
    "mvnw",
    "gradlew",
    "build.gradle",
    "build.gradle.kts",
    "pom.xml",
    ".git",
    "settings.gradle",
    "settings.gradle.kts",
  }
  local root_finder = require("lspconfig.util").root_pattern(unpack(root_markers))
  local bufname = vim.api.nvim_buf_get_name(0)
  local project_root = root_finder(bufname ~= "" and bufname or vim.fn.getcwd())
    or vim.fn.getcwd()
  local clean_root = project_root:gsub("/+$", "")
  local workspace_name = vim.fn.fnamemodify(clean_root, ":t"):gsub("[^%w_.-]", "_")
  if workspace_name == "" then
    workspace_name = "default"
  end

  local config = {
    cmd = {
      java_bin,
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      -- Lombok: sin el agente, jdtls no ve los getters/setters generados
      -- (@Data) y marca "The method getId() is undefined" en todo el codigo.
      "-javaagent:" .. jdtls_path .. "/lombok.jar",
      "-jar",
      launcher,
      "-configuration",
      config_linux,
      "-data",
      home .. "/.cache/jdtls/workspace/" .. workspace_name,
    },
    -- STRING, no funcion: vim.lsp.start exige root_dir resuelto para
    -- registrar el workspace folder. Con una funcion el folder quedaba
    -- vacio, jdtls no veia el pom.xml y marcaba el .java como
    -- "non-project file, only syntax errors are reported".
    root_dir = clean_root,
    -- language/status ("Importing Maven project 45%", "Ready"...) iba a :echo
    -- y se perdia; a vim.notify persiste en :messages y en Fidget.
    handlers = {
      ["language/status"] = function(_, result)
        if result and result.message and result.message ~= "" then
          vim.notify(
            result.message,
            result.type == "Error" and vim.log.levels.ERROR or vim.log.levels.INFO,
            { title = "jdtls" }
          )
        end
      end,
    },
    capabilities = capabilities,
    settings = {
      java = {
        configuration = {
          -- automatic: importa el proyecto Maven/Gradle sin prompt. Con
          -- "interactive" el import quedaba pendiente y el classpath vacio
          -- devolvia "no location found" en gd.
          updateBuildConfiguration = "automatic",
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
  if jdk27 then table.insert(runtime_args, "-Djava.configuration.runtimes.JAVA_27=" .. jdk27) end
  if jdk26 then table.insert(runtime_args, "-Djava.configuration.runtimes.JAVA_26=" .. jdk26) end
  if jdk25 then table.insert(runtime_args, "-Djava.configuration.runtimes.JAVA_25=" .. jdk25) end
  if jdk22 then table.insert(runtime_args, "-Djava.configuration.runtimes.JAVA_22=" .. jdk22) end
  if jdk21 then table.insert(runtime_args, "-Djava.configuration.runtimes.JAVA_21=" .. jdk21) end
  if jdk17 then table.insert(runtime_args, "-Djava.configuration.runtimes.JAVA_17=" .. jdk17) end
  -- Los -D son opciones de la JVM: van antes de -jar, no despues (antes se
  -- insertaban en la posicion 5+i, o sea detras de -jar, donde se ignoran).
  for i, arg in ipairs(runtime_args) do
    table.insert(config.cmd, 1 + i, arg)
  end

  -- Populate runtimes from detected JDKs
  local runtimes = {}
  if jdk27 then table.insert(runtimes, { name = "JavaSE-27", path = jdk27 .. "/" }) end
  if jdk26 then table.insert(runtimes, { name = "JavaSE-26", path = jdk26 .. "/" }) end
  if jdk25 then table.insert(runtimes, { name = "JavaSE-25", path = jdk25 .. "/" }) end
  if jdk22 then table.insert(runtimes, { name = "JavaSE-22", path = jdk22 .. "/" }) end
  if jdk21 then table.insert(runtimes, { name = "JavaSE-21", path = jdk21 .. "/" }) end
  if jdk17 then table.insert(runtimes, { name = "JavaSE-17", path = jdk17 .. "/" }) end
  config.settings.java.configuration.runtimes = runtimes

  jdtls.start_or_attach(config)

  -- start_or_attach solo adjunta el buffer actual, y el plugin carga una vez
  -- (lazy por ft): al abrir otro .java despues, el buffer quedaba solo con
  -- null-ls y gd respondia "definition not supported". Este autocmd
  -- re-adjunta cada buffer java reutilizando el cliente existente.
  if not M._ft_autocmd then
    M._ft_autocmd = true
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("JdtlsFileType", { clear = true }),
      pattern = "java",
      callback = function(args)
        vim.api.nvim_buf_call(args.buf, function()
          local ok, err = pcall(M.setup)
          if not ok then
            vim.notify("[jdtls] " .. tostring(err):sub(1, 200), vim.log.levels.ERROR, { title = "LSP: java" })
          end
        end)
      end,
    })
  end

  -- Si el archivo no esta en ningun sourcePath (proyecto sin importar),
  -- jdtls solo reporta "non-project file". Dispara el import una vez por
  -- sesion y avisa; el progreso se ve con fidget + :messages.
  if not _G._jdt_auto_import_setup then
    _G._jdt_auto_import_setup = true
    local function do_import(client)
      client:request("workspace/executeCommand", { command = "java.project.import" }, function(err)
        if err then
          vim.notify("JdtImport: " .. tostring(err.message or err.code), vim.log.levels.ERROR, { title = "jdtls" })
        else
          vim.notify("Importando proyecto Maven/Gradle… (fidget, abajo-derecha)", vim.log.levels.WARN, { title = "jdtls" })
        end
      end, 0)
    end
    local function import_cmd()
      local clients = vim.lsp.get_clients({ name = "jdtls" })
      if #clients == 0 then
        vim.notify("jdtls no activo", vim.log.levels.ERROR, { title = "jdtls" })
        return
      end
      do_import(clients[1])
    end
    pcall(vim.api.nvim_create_user_command, "JdtImport", import_cmd, { desc = "Importar proyecto Maven/Gradle en jdtls" })
    vim.defer_fn(function()
      if _G._jdt_auto_import_done then
        return
      end
      local buf = vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "java" then
        return
      end
      local clients = vim.lsp.get_clients({ name = "jdtls", bufnr = buf })
      if #clients == 0 then
        return
      end
      _G._jdt_auto_import_done = true
      clients[1]:request("workspace/executeCommand", {
        command = "java.project.getSettings",
        arguments = { vim.uri_from_bufnr(buf), { "org.eclipse.jdt.ls.core.sourcePaths" } },
      }, function(err, res)
        if err then
          return
        end
        local paths = res and res["org.eclipse.jdt.ls.core.sourcePaths"]
        if not paths or #paths == 0 then
          do_import(clients[1])
        end
      end, buf)
    end, 10000)
  end
end

return M
