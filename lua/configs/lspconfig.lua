require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "rust_analyzer",
  "clangd",
  "pyright",
  "ts_ls",
  "angularls", -- Angular language server
  -- CMake: cmake-language-server (Mason) trae pygls>=1 incompatible
  -- ("cannot import name LanguageServer"). neocmake = binario nativo
  -- (neocmakelsp), sin Python.
  "neocmake", -- CMake
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

-- Kotlin: kotlin-language-server 1.3.13 rompia en Neovim 0.11+ con
-- "Expected BEGIN_OBJECT but was BEGIN_ARRAY" en workspace/configuration.
-- Workaround: anunciar que NO soportamos workspace/configuration para que
-- el server no la pida. Si Mason no lo tiene instalado, el verificador
-- (configs.lsp_verify) avisa al arrancar con :MasonInstall.
do
  local ok, cmp_caps = pcall(require, "cmp_nvim_lsp")
  local caps = vim.lsp.protocol.make_client_capabilities()
  if ok and cmp_caps and cmp_caps.default_capabilities then
    caps = cmp_caps.default_capabilities(caps)
  end
  caps.workspace = caps.workspace or {}
  caps.workspace.configuration = false
  vim.lsp.config("kotlin_language_server", { capabilities = caps })
  vim.lsp.enable "kotlin_language_server"
end

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

-- angularls: prefiere el ngserver DEL PROYECTO (node_modules/.bin/ngserver)
-- cuando existe, porque su major coincide con @angular/core del proyecto.
-- El ngserver global de Mason (v22) sobre un proyecto v21 rompe el gd en
-- expresiones de plantillas (isAlertActive, router.url, pipes). Con el
-- binario local, cualquier proyecto Angular usa su propia versión.
do
  vim.lsp.config("angularls", {
    cmd = function(dispatchers, config)
      local fs, uv, fn = vim.fs, vim.uv, vim.fn
      local root_dir = (config and config.root_dir) or fn.getcwd()
      local node_paths = {}
      local project_node = fs.joinpath(root_dir, "node_modules")
      if uv.fs_stat(project_node) then table.insert(node_paths, project_node) end
      local exe = fn.exepath "ngserver"
      if exe and #exe > 0 then
        local real = uv.fs_realpath(exe) or exe
        local candidate = fs.normalize(fs.joinpath(fs.dirname(real), "../../.."))
        if uv.fs_stat(candidate) then table.insert(node_paths, candidate) end
      end
      local ng_probe = table.concat(
        vim
          .iter(node_paths)
          :map(function(p) return fs.joinpath(p, "@angular/language-server/node_modules") end)
          :totable(),
        ","
      )
      local bin = fs.joinpath(project_node, ".bin/ngserver")
      if not uv.fs_stat(bin) then bin = "ngserver" end
      local version = ""
      local ok, content = pcall(fn.readblob, fs.joinpath(root_dir, "package.json"))
      if ok and content then
        local json = vim.json.decode(content) or {}
        local v = ((json.dependencies or {})["@angular/core"])
          or ((json.devDependencies or {})["@angular/core"])
          or ""
        version = v:match "%d+%.%d+%.%d+" or ""
      end
      return vim.lsp.rpc.start({
        bin,
        "--stdio",
        "--tsProbeLocations",
        table.concat(node_paths, ","),
        "--ngProbeLocations",
        ng_probe,
        "--angularCoreVersion",
        version,
      }, dispatchers)
    end,
  })
end

-- NOTA: kotlin-language-server se habilita abajo con workaround
-- workspace.configuration=false (ver bloque kotlin). Si falla, el verificador
-- configs.lsp_verify avisa al arrancar.
-- read :h vim.lsp.config for changing options of lsp servers

-- Verificador de arranque: si falta server/binario de
-- python/c++/kotlin/cmake/java/rust, lo instala solo (:MasonInstall).
-- No rompe el arranque, solo notifica una vez por sesion.
pcall(require, "configs.lsp_verify")
