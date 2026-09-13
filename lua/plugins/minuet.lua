return {
  "milanglacier/minuet-ai.nvim",
  version = "*",
  -- Cargar al inicio. Minuet registra un autocmd de FileType que habilita el
  -- ghost text por buffer; si carga en InsertEnter (despues del FileType del
  -- buffer) el auto-trigger nunca se activa en los archivos ya abiertos.
  lazy = false,
  config = function()
    -- Groq (API compatible con OpenAI). El modelo se resuelve asi:
    --   GROQ_MODEL    -> id del modelo (default: openai/gpt-oss-20b, "Groq 20B")
    --   GROQ_BASE_URL -> base URL de la API (default: https://api.groq.com/openai/v1)
    --   GROQ_API_KEY  -> API key (nombre de la env var que lee Minuet)
    local api_key_env = "GROQ_API_KEY"
    local base_url = os.getenv "GROQ_BASE_URL" or "https://api.groq.com/openai/v1"
    local model = os.getenv "GROQ_MODEL" or "openai/gpt-oss-20b"

    if not os.getenv(api_key_env) then
      vim.notify(
        ("minuet: falta %s en variables de entorno. Exportala y reinicia Neovim."):format(api_key_env),
        vim.log.levels.WARN,
        { title = "minuet" }
      )
    end

    require("minuet").setup {
      provider = "openai_compatible",
      request_timeout = 8,
      debounce = 600,
      throttle = 1500,
      min_length = 3,
      use_cmp = false, -- legacy: Minuet lo ignora (registra cmp y virtualtext)
      -- Cuantas opciones pide al modelo (el prompt solo lo sugiere; puede
      -- devolver mas o menos). El ghost text muestra "(n/total)".
      n_completions = 3,
      -- La IA va SOLO inline (ghost text). No se agrega como fuente de cmp:
      -- sus completions multi-linea no se ven completas en el menu y confunden.
      -- Si alguna vez la queres en el menu, agregala a opts.sources en
      -- lua/plugins/init.lua y activa aca enable_auto_complete.
      cmp = { enable_auto_complete = false },
      virtualtext = {
        auto_trigger_ft = { "*" },
        -- Se oculta cuando el menu de cmp esta abierto: evita solapamientos.
        show_on_completion_menu = false,
        keymap = {
          accept = "<A-CR>",
          -- Ciclar entre las sugerencias inline de la IA.
          next = "<A-n>",
          prev = "<A-p>",
          dismiss = "<C-]>",
        },
      },
      provider_options = {
        openai_compatible = {
          api_key = api_key_env,
          end_point = base_url .. "/chat/completions",
          model = model,
          name = "Groq",
          stream = true,
          optional = {
            -- gpt-oss-20b es un modelo de razonamiento: sin presupuesto
            -- suficiente gasta los tokens en "reasoning" y no emite "content".
            -- max_completion_tokens + reasoning_effort bajo evitan eso.
            max_completion_tokens = 1024,
            top_p = 0.9,
            reasoning_effort = "low",
          },
        },
      },
    }
  end,
}
