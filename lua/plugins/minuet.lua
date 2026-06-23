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
      request_timeout = 3,
      debounce = 600,
      throttle = 1500,
      min_length = 3,
      use_cmp = false,
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          accept = "<A-CR>",
          next = "<A-y>",
          dismiss = "<C-]>",
        },
      },
      provider_options = {
        openai_compatible = {
          api_key = "CESAR_PROXY_KEY",
          end_point = llm_url,
          model = "flash",
          name = "Proxy",
          optional = {
            max_tokens = 128,
            top_p = 0.9,
          },
        },
      },
    }
  end,
}
