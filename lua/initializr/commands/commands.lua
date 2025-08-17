local ui = require("initializr.ui.init")
local M = {}

--- Registers Neovim user commands for Spring Initializr.
function M.register()
	vim.api.nvim_create_user_command("SpringInitializr", function()
		ui.setup()
	end, { desc = "Open Spring Initializer UI" })
end

return M
