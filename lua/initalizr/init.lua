local commands = require("initializr.commands.commands")

local M = {}

function M.setup()
	commands.register()
end

return M
