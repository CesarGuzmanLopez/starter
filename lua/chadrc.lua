-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "wallust",
	transparency = true,

	-- CursorLine/CursorLineNr se calculan en configs/highlights.lua a partir del
	-- fondo del tema (un tono apenas mas claro/oscuro, sin tapar los strings).
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

-- Herramientas extra que MasonInstallAll debe instalar (ademas de las que
-- detecta de lspconfig / conform / nvim-lint).
M.mason = {
	pkgs = {
		"stylua",
		"prettierd",
		"clang-format",
		"ktfmt",
		"google-java-format",
		"ruff",
		"mypy",
		"eslint_d",
		"htmlhint",
		"stylelint",
		"jsonlint",
		"markdownlint",
		"yamllint",
		"ktlint",
		"cmakelint",
	},
	skip = {},
}

return M
