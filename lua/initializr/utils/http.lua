local Job = require("plenary.job")
local M = {}

function M.download_file(url, output_path, on_success, on_error)
	Job:new({
		command = "curl",
		args = {
			"-L", -- Sigue redirecciones (MUY importante)
			"-f", -- Falla si el servidor devuelve error HTTP
			"-o",
			output_path,
			"--create-dirs", -- Crea directorios si no existen
			"-A",
			"nvim-spring-initializr", -- User-Agent
			"--silent", -- Menos ruido
			"--show-error", -- Muestra errores incluso con --silent
			url,
		},
		on_exit = function(job, return_val)
			if return_val == 0 then
				-- Descarga exitosa
				require("initializr.utils.message").info("✅ Descarga completada: " .. output_path)
				vim.schedule(on_success)
			else
				-- Captura errores de stderr
				local stderr = table.concat(job:stderr_result(), "\n")
				local msg_text = "❌ curl falló: " .. stderr .. " (código: " .. return_val .. ")"
				require("initializr.utils.message").error(msg_text)
				if on_error then
					vim.schedule(on_error)
				end
			end
		end,
	}):start()
end

return M
