local Job = require("plenary.job")

local M = {}

-- @param return_val number
-- @param on_success function
-- @param on_error function
local function handle_download_exit(return_val, on_success, on_error)
	if return_val ~= 0 then
		vim.schedule(on_error)
	else
		vim.schedule(on_success)
	end
end

-- @param url string
-- @param output_path
-- @param on_success
-- @param on_error
function M.download_file(url, output_path, on_success, on_error)
	Job:new({
		command = "curl",
		args = { "-L", url, "-o", output_path },
		on_exit = function(_, return_val)
			handle_download_exit(return_val, on_success, on_error)
		end,
	}):start()
end

return M
