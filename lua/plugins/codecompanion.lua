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
            })
          end,
        },
      },
      interactions = {
        chat = { adapter = "guzman" },
        inline = { adapter = "guzman" },
      },
      strategies = {
        chat = {
          tools = {
            grep_search = { enabled = true },
            file_search = { enabled = true },
            read_file = { enabled = true },
            insert_edit_into_file = { enabled = true },
            run_command = { enabled = false },
          },
        },
      },
    })
  end,
}
