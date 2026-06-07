return {
  backend = "kitty",
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      filetypes = { "markdown", "vimwiki" },
    },
    neorg = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
    },
    html = {
      enabled = true,
    },
    css = {
      enabled = true,
    },
  },
  max_width = nil,
  max_height = nil,
  max_width_window_percentage = nil,
  max_height_window_percentage = 50,
  window_overlap_clear_enabled = false,
  window_overlap_clear_fg = "none",
  editor_only_render_when_focused = false,
  tmux_show_only_in_active_window = false,
  hijack_file_patterns = {},
}
