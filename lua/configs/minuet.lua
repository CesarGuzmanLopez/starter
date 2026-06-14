local mc = require "minuet.config"

return {
  provider = "openai_compatible",
  context_window = 8192,
  request_timeout = 3,
  throttle = 1500,
  debounce = 600,
  notify = "warn",

  virtualtext = {
    auto_trigger_ft = { "*" },
    keymap = {
      accept = "<A-A>",
      accept_line = "<A-a>",
      accept_n_lines = "<A-z>",
      prev = "<A-[>",
      next = "<A-]>",
      dismiss = "<A-e>",
    },
  },

  provider_options = {
    openai_compatible = {
      api_key = function()
        local key = os.getenv "MINUET_API_KEY"
        if not key then
          vim.notify("Set MINUET_API_KEY env var for AI completion", vim.log.levels.WARN)
          return ""
        end
        return key
      end,
      name = "Guzman Lopez",
      end_point = "https://llm.guzman-lopez.com/v1/chat/completions",
      model = "flash",
      stream = true,
      optional = {
        max_tokens = 256,
        top_p = 0.9,
        reasoning_effort = "none",
        reasoning = { enabled = false },
      },
      model_options = {
        flash = {
          reasoning = { enabled = false },
        },
      },
      system = mc.default_system,
      few_shots = mc.default_few_shots,
      chat_input = mc.default_chat_input,
    },
  },
}
