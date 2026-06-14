-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "wallust",
	transparency = true,

	hl_override = {
		CursorLine = { bg = "#3a3a4a" },
	},
}

-- NvChad custom statusline with opencode integration
M.ui = {
	statusline = {
		theme = "default",
		modules = {
			opencode = function()
				local ok, status = pcall(require, "opencode.status")
				if ok then
					local icon = status.icon()
					local text = status.statusline()
					if icon == "󱚧" then
						return "" -- disconnected, hide
					end
					return " " .. text .. " "
				end
				return ""
			end,
		},
		order = {
			"mode",
			"file",
			"git",
			"opencode",
			"%=",
			"lsp_msg",
			"%=",
			"diagnostics",
			"lsp",
			"cwd",
			"cursor",
		},
	},
}

return M
