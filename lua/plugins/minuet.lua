return {
  "milanglacier/minuet-ai.nvim",
  version = "*",
  event = "InsertEnter",
  config = function()
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
          -- Minuet lee el NOMBRE de la env var, no el valor
          api_key = "CESAR_PROXY_KEY",
          end_point = (os.getenv("CESAR_PROXY_URL") or "") .. "/chat/completions",
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
