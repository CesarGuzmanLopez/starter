return {
  "olimorris/codecompanion.nvim",
  cmd = {
    "CodeCompanion",
    "CodeCompanionChat",
    "CodeCompanionActions",
    "CodeCompanionCmd",
    "CodeCompanionCLI",
  },
  keys = {
    { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion: toggle chat" },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion: action palette" },
    { "<leader>ci", "<cmd>CodeCompanionChat Toggle<cr>", mode = "v", desc = "CodeCompanion: inline chat (visual)" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        http = {
          guzman = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "guzman",
              formatted_name = "Guzman Lopez",
              env = {
                url = "https://llm.guzman-lopez.com",
                api_key = "MINUET_API_KEY",
                chat_url = "/v1/chat/completions",
              },
              schema = {
                model = {
                  order = 1,
                  mapping = "parameters",
                  type = "enum",
                  default = "normal",
                  choices = { "normal", "flash" },
                  desc = "Model to use",
                },
                temperature = {
                  order = 2,
                  mapping = "parameters",
                  type = "number",
                  default = 0.1,
                },
              },
              handlers = {
                parse_message_meta = function(self, data)
                  local extra = data.extra
                  if extra and extra.reasoning_content then
                    data.output.reasoning = { content = extra.reasoning_content }
                    if data.output.content == "" then
                      data.output.content = nil
                    end
                  end
                  -- Strip tool calls from response (endpoint doesn't support them)
                  if data.output and data.output.tool_calls then
                    data.output.tool_calls = nil
                  end
                  return data
                end,
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          adapter = "guzman",
          tools = {
            grep_search = { enabled = true },
            file_search = { enabled = true },
            read_file = { enabled = true },
            insert_edit_into_file = { enabled = true },
            run_command = { enabled = false },
            web_search = { enabled = false },
            fetch_webpage = { enabled = false },
          },
        },
        inline = { adapter = "guzman" },
      },
      display = {
        chat = {
          show_reasoning = false,
          fold_reasoning = false,
        },
      },
    })
  end,
}
