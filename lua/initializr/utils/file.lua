local Job = require("plenary.job")
local M = {}

function M.unzip(zip_path, destination, on_done)
	Job:new({
		command = "unzip",
		args = { "-o", zip_path, "-d", destination },
		on_exit = function(job, return_val)
			if return_val == 0 then
				os.remove(zip_path) -- Borra el zip
				require("initializr.utils.message").info("✅ Proyecto descomprimido en: " .. destination)
				vim.schedule(on_done)
			else
				local stderr = table.concat(job:stderr_result(), "\n")
				local msg = "❌ unzip falló: " .. stderr
				require("initializr.utils.message").error(msg)
			end
		end,
	}):start()
end

return M
