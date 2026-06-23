return {
  "milanglacier/minuet-ai.nvim",
  version = "*",
  event = "InsertEnter",
  config = function()
    local api_key = vim.fn.environ()["CESAR_PROXY_KEY"]
    local end_point = vim.fn.environ()["CESAR_PROXY_URL"]
    if not api_key or api_key == "" or not end_point or end_point == "" then
      vim.notify(
        "Minuet: faltan CESAR_PROXY_KEY y/o CESAR_PROXY_URL",
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
      -- Activar ghost text automatico para TODOS los filetypes
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          accept = "<A-CR>",
          accept_line = "<M-CR>s",
          dismiss = "<C-]>",
        },
      },
      provider_options = {
        openai_compatible = {
          api_key = api_key,
          end_point = end_point .. "/chat/completions",
          model = "flash",
          name = "Proxy",
          optional = {
            max_tokens = 128,
            top_p = 0.9,
          },
        },
      },
    }

    -- Registrar <A-y> para completado manual
    vim.keymap.set("i", "<A-y>", function()
      require("minuet").complete()
    end, { desc = "Minuet: manual completion" })
  end,
}
