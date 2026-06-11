return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  config = function()
    require("dressing").setup({
      input = {
        enabled = true,
        default_prompt = "➤ ",
        prompt_align = "left",
        insert_only = false,
        start_in_insert = true,
        -- Use telescope-style border
        border = "rounded",
        win_options = {
          winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
        },
      },
      select = {
        enabled = true,
        -- Use telescope as the backend (must be installed)
        backend = { "telescope", "fzf", "fzf_lua", "builtin" },
        trim_prompt = true,
        telescope = {
          layout_config = {
            prompt_position = "top",
          },
        },
      },
    })
  end,
}
