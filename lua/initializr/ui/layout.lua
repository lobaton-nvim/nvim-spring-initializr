local Layout = require("nui.layout")
local Popup = require("nui.popup")
local radios = require("initializr.ui.radios")
local inputs = require("initializr.ui.inputs")
local deps = require("initializr.ui.deps")
local M = {}

-- Create the outer wrapper popup window
--
-- @return Popup: the main floating container
local function create_outer_popup()
	return Popup({
		border = {
			style = "rounded",
			text = { top = "[ Spring Initializr ]", top_align = "center" },
		},
		position = "50%",
		size = { width = "70%", height = "75%" },
		win_options = {
			winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
		},
	})
end

-- Format boot version list to remove ".RELEASE" suffix
--
-- @param values table: list of version entries
-- @return table: transformed list
local function format_boot_versions(values)
	return vim.tbl_map(function(v)
		return { name = v.name, id = v.id and v.id:gsub("%.RELEASE$", "") }
	end, values or {})
end

-- Create all radio components
--
-- @param metadata table
-- @param selections table
-- @return table of Layout.Box components
local function create_radio_controls(metadata, selections)
	return {
		radios.create_radio("Project Type", metadata.type.values, "project_type", selections),
		radios.create_radio("Language", metadata.language.values, "language", selections),
		radios.create_radio(
			"Spring Boot Version",
			format_boot_versions(metadata.bootVersion.values),
			"boot_version",
			selections
		),
		radios.create_radio("Packaging", metadata.packaging.values, "packaging", selections),
		radios.create_radio("Java Version", metadata.javaVersion.values, "java_version", selections),
	}
end

-- Create all input fields
--
-- @param selections table
-- @return table of Layout.Box components
local function create_input_controls(selections)
	return {
		inputs.create_input("Group", "groupId", "com.example", selections),
		inputs.create_input("Artifact", "artifactId", "demo", selections),
		inputs.create_input("Name", "name", "demo", selections),
		inputs.create_input("Description", "description", "Demo project for Spring Boot", selections),
		inputs.create_input("Package Name", "packageName", "com.example.demo", selections),
	}
end

-- Create the left-hand UI panel with all user-configurable fields
--
-- @param metadata table
-- @param selections table
-- @return Layout.Box
local function create_left_panel(metadata, selections)
	local children = {}
	vim.list_extend(children, create_radio_controls(metadata, selections))
	vim.list_extend(children, create_input_controls(selections))
	return Layout.Box(children, { dir = "col", size = "50%" })
end

-- Crea el botón "Create Project"
local function create_create_button()
	local popup = Popup({
		border = {
			style = "rounded",
			text = { top = "Create Project", top_align = "center" },
		},
		size = { height = 3, width = 40 },
		enter = true,
		win_options = {
			winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
		},
	})

	popup:map("n", "<CR>", function()
		vim.ui.input({ prompt = "Project path: ", default = vim.fn.getcwd() .. "/" }, function(input_path)
			if not input_path or input_path == "" then
				require("initializr.utils.message").warn("Project path is required.")
				return
			end

			-- Asegurarse de que el directorio existe o crearlo
			local dir = vim.fn.fnamemodify(input_path, ":p:h")
			if vim.fn.isdirectory(dir) == 0 then
				vim.fn.mkdir(dir, "p")
			end

			-- Llamar a la función para generar el proyecto en esa ruta
			require("initializr.core.core").generate_project(input_path, function()
				-- Cerrar UI
				require("initializr.ui.init").close()
				-- Cambiar al directorio del proyecto
				vim.cmd("cd " .. vim.fn.fnameescape(input_path))
				-- Opcional: abrir explorador de archivos
				-- vim.cmd("edit .")
			end)
		end)
	end, { noremap = true, nowait = true })

	require("initializr.ui.focus").register(popup)
	return Layout.Box(popup, { size = 3 })
end

-- Create the right-hand panel with dependency management and create button
--
-- @return Layout.Box
local function create_right_panel()
	return Layout.Box({
		Layout.Box(deps.create_button(deps.update_display), { size = "10%" }),
		Layout.Box(deps.create_remove_button(deps.update_display), { size = "10%" }),
		Layout.Box(deps.create_display(), { size = "60%" }),
		Layout.Box(create_create_button(), { size = "20%" }),
	}, { dir = "col", size = "50%" })
end

-- Build the entire Spring Initializr layout
--
-- @param metadata table: fetched Spring metadata
-- @param selections table: user selections state
-- @return table: contains the layout and the outer popup
function M.build_ui(metadata, selections)
	local outer_popup = create_outer_popup()
	local layout = Layout(
		outer_popup,
		Layout.Box({
			create_left_panel(metadata, selections),
			create_right_panel(),
		}, { dir = "row" })
	)
	return {
		layout = layout,
		outer_popup = outer_popup,
	}
end

return M
