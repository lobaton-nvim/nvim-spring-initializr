local ui = require("initializr.ui.init")
-- local msg = require("initializr.utils.message")
local deps = require("initializr.telescope.telescope")
local url_utils = require("initializr.utils.url")
local http_utils = require("initializr.utils.http")
local file_utils = require("initializr.utils.file")
local SPRING_DOWNLOAD_URL = "https://start.spring.io/starter.zip"

local M = {}

local function collect_params()
	local s = ui.state.selections
	return {
		type = s.project_type,
		language = s.language,
		bootVersion = s.boot_version,
		groupId = s.groupId,
		artifactId = s.artifactId,
		name = s.name,
		description = s.description,
		packageName = s.packageName,
		packaging = s.packaging,
		javaVersion = s.java_version,
		dependencies = table.concat(deps.selected_dependencies or {}, ","),
	}
end

local function make_download_url(params)
	return SPRING_DOWNLOAD_URL .. "?" .. url_utils.encode_query(params)
end

-- local function notify_success(cwd)
-- 	ui.close()
-- 	msg.info("🎉 ¡Proyecto Spring Boot creado en: " .. cwd)
-- end

function M.generate_project(project_path, on_success)
	local params = collect_params()
	local url = make_download_url(params)
	local cwd = project_path or vim.fn.getcwd()
	local zip_path = cwd .. "/spring-init.zip"

	-- ✅ Todos los msg.* deben estar dentro de vim.schedule si se llaman desde Job
	require("initializr.utils.message").info("🔗 Descargando desde: " .. url)
	require("initializr.utils.message").info("📁 Ruta: " .. cwd)

	http_utils.download_file(url, zip_path, function()
		require("initializr.utils.message").info("📦 Descarga completada. Descomprimiendo...")
		file_utils.unzip(zip_path, cwd, function()
			require("initializr.utils.message").info("🎉 Proyecto creado en: " .. cwd)
			if on_success then
				on_success()
			end
		end)
	end, function()
		require("initializr.utils.message").error("❌ Falló la descarga.")
	end)
end

return M
