return {
  "milanglacier/minuet-ai.nvim",
  version = "*",
  event = "InsertEnter",
  config = function()
    local llm_url = os.getenv "CESAR_LLM_URL"
    if not llm_url or llm_url == "" then
      vim.notify(
        "minuet: falta CESAR_LLM_URL en variables de entorno",
        vim.log.levels.WARN,
        { title = "minuet" }
      )
      return
    end

    require("minuet").setup {
      provider = "openai_compatible",
      request_timeout = 8,
      debounce = 600,
      throttle = 1500,
      min_length = 3,
      use_cmp = false,
      virtualtext = {
        auto_trigger_ft = {},
        keymap = {
          accept = "<A-CR>",
          next = "<A-y>",
          dismiss = "<C-]>",
        },
      },
      provider_options = {
        openai_compatible = {
          api_key = "CESAR_PROXY_KEY",
          end_point = llm_url .. "/chat/completions",
          model = "flash",
          name = "Proxy",
          stream = true,
          optional = {
            max_tokens = 256,
            top_p = 0.9,
          },
        },
      },
    }
  end,
}
