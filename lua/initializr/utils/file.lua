local Job = require("plenary.job")
local M = {}

function M.unzip(zip_path, destination, on_done)
	Job:new({
		command = "unzip",
		args = { "-o", zip_path, "-d", destination },
		on_exit = function(job, return_val)
			if return_val == 0 then
				os.remove(zip_path) -- Borrar zip
				-- ✅ Usar schedule
				vim.schedule(function()
					require("initializr.utils.message").info("✅ Proyecto descomprimido en: " .. destination)
					if on_done then
						on_done()
					end
				end)
			else
				-- ✅ Capturar y mostrar error con schedule
				local stderr = table.concat(job:stderr_result(), "\n")
				vim.schedule(function()
					require("initializr.utils.message").error("❌ unzip failed: " .. stderr)
				end)
			end
		end,
	}):start()
end

return M
