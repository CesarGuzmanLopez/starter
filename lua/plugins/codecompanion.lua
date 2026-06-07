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
            opts = {
              default_tools = {},
            },
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
