local M = {}

--- Sets highlight groups used by the plugin.
local function set_highlight_groups()
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "#777777" })
	vim.api.nvim_set_hl(0, "NuiMenuSel", { bg = "#44475a", fg = "#ffffff", bold = true })
end

--- Registers a ColorScheme autocmd to reapply highlights.
local function register_colorscheme_autocmd()
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = M.configure,
	})
end

--- Public method to configure all highlights and hooks.
function M.configure()
	set_highlight_groups()
	register_colorscheme_autocmd()
end

return M
