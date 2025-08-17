local M = {}
local notify = vim.notify

-- @param msg string: message to display
M.info = function(msg)
	notify(msg, vim.log.levels.INFO)
end

-- @param msg string: message to display
M.warn = function(msg)
	notify(msg, vim.log.levels.WARN)
end

-- @param msg string: message to display
M.error = function(msg)
	notify(msg, vim.log.levels.ERROR)
end

-- @param msg string: message to display
M.debug = function(msg)
	notify(msg, vim.log.levels.DEBUG)
end

return M
