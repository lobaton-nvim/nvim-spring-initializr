local Job = require("plenary.job")
local M = {}

function M.download_file(url, output_path, on_success, on_error)
	Job:new({
		command = "curl",
		args = {
			"-L", -- Sigue redirecciones
			"-f", -- Falla si HTTP no es 2xx
			"-o",
			output_path,
			"--create-dirs",
			"-A",
			"nvim-spring-initializr",
			"--silent",
			"--show-error",
			url,
		},
		on_exit = function(job, return_val)
			if return_val == 0 then
				-- ✅ Usar vim.schedule para no romper el contexto
				vim.schedule(function()
					if on_success then
						on_success()
					end
				end)
			else
				-- ✅ Capturar stderr y mostrar error con schedule
				local stderr = table.concat(job:stderr_result(), "\n")
				vim.schedule(function()
					local msg = "❌ curl failed: " .. stderr
					require("initializr.utils.message").error(msg)
					if on_error then
						on_error()
					end
				end)
			end
		end,
	}):start()
end

return M
