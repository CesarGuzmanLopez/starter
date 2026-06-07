require "nvchad.autocmds"

-------------------------------
-- Auto-reload files modified externally (opencode, git, etc.)
-------------------------------
vim.o.autoread = true

local reload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })

-- When Neovim gains focus, reload all changed files
vim.api.nvim_create_autocmd("FocusGained", {
  group = reload_group,
  callback = function()
    vim.cmd "checktime"
  end,
})

-- When a buffer is entered, check if the file changed on disk
vim.api.nvim_create_autocmd("BufEnter", {
  group = reload_group,
  callback = function(args)
    if vim.bo[args.buf].buftype == "" then
      vim.cmd "checktime"
    end
  end,
})

-- When a buffer loses focus, also check
vim.api.nvim_create_autocmd("BufLeave", {
  group = reload_group,
  callback = function(args)
    if vim.bo[args.buf].buftype == "" and vim.bo[args.buf].modified then
      vim.cmd "checktime"
    end
  end,
})

-- Handle file changed on disk: auto-reload if no local modifications
vim.api.nvim_create_autocmd("FileChangedShell", {
  group = reload_group,
  callback = function(args)
    vim.api.nvim_echo({
      { "File changed on disk: " .. vim.fn.fnamemodify(args.match, ":t"), "WarningMsg" },
    }, true, {})
    -- Automatically reload (discards no changes since we don't edit externally)
    vim.cmd "edit!"
  end,
})

-- Image viewer: intercept image files and display with kitten icat in a floating window
local image_group = vim.api.nvim_create_augroup("ImageViewer", { clear = true })

local image_extensions = { "png", "jpg", "jpeg", "gif", "webp", "avif", "bmp", "tiff", "ico" }
local image_pattern = "*." .. table.concat(image_extensions, ",*.")

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = image_group,
  pattern = image_pattern,
  callback = function(args)
    local file = args.match

    -- Disable treesitter for this buffer
    vim.bo[args.buf].filetype = ""
    pcall(vim.treesitter.stop, args.buf)

    -- Clear buffer
    vim.bo[args.buf].modifiable = false
    vim.bo[args.buf].readonly = true
    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, {})

    -- Create floating window
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
      title = " " .. vim.fn.fnamemodify(file, ":t") .. " ",
      title_pos = "center",
    })

    -- Display image with kitten icat
    vim.fn.jobstart({
      "kitten", "icat",
      "--place", tostring(width) .. "x" .. tostring(height - 2) .. "@0x0",
      "--transfer-mode=stream",
      file,
    }, { stdout_buffered = true })

    -- Close with q or Esc
    vim.keymap.set("n", "q", function()
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_buf_delete(buf, { force = true })
    end, { buffer = buf, nowait = true })

    vim.keymap.set("n", "<Esc>", function()
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_buf_delete(buf, { force = true })
    end, { buffer = buf, nowait = true })

    -- Set buffer name
    vim.api.nvim_buf_set_name(buf, file)
  end,
})

-- Also handle filetype detection for image files
vim.api.nvim_create_autocmd("BufEnter", {
  group = image_group,
  pattern = image_pattern,
  callback = function(args)
    vim.bo[args.buf].buftype = "nofile"
  end,
})
