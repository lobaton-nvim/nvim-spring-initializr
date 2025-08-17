local Popup = require("nui.popup")
local Layout = require("nui.layout")
local focus = require("initializr.ui.focus")
local telescope_dep = require("initializr.telescope.telescope")
local msg = require("initializr.utils.message")

local M = {
	state = {
		dependencies_panel = nil,
	},
}

-- Returns the border config for the "Add Dependencies" button.
local function button_border()
	return {
		style = "rounded",
		text = { top = "Add Dependencies (Telescope)", top_align = "center" },
	}
end

-- Builds the configuration for the dependencies button popup.
local function button_popup_config()
	return {
		border = button_border(),
		size = { height = 3, width = 40 },
		enter = true,
		win_options = {
			winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
		},
	}
end

-- Binds the Enter key to open the Telescope dependency picker and update display.
local function bind_button_action(popup, on_update)
	popup:map("n", "<CR>", function()
		telescope_dep.pick_dependencies(nil, function()
			vim.schedule(on_update)
		end)
	end, { noremap = true, nowait = true })
end

--- Creates a popup button that triggers dependency selection.
--
-- @param update_display_fn function: callback to update the dependency display
-- @return Layout.Box: wrapped button in a layout box
function M.create_button(update_display_fn)
	local popup = Popup(button_popup_config())
	bind_button_action(popup, update_display_fn)
	focus.register(popup)
	return Layout.Box(popup, { size = 3 })
end

-- Returns the border config for the "Remove Dependency" button.
local function remove_button_border()
	return {
		style = "rounded",
		text = { top = "Remove Dependency", top_align = "center" },
	}
end

-- Builds the configuration for the remove button popup.
local function remove_button_popup_config()
	return {
		border = remove_button_border(),
		size = { height = 3, width = 40 },
		enter = true,
		win_options = {
			winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
		},
	}
end

--- Creates a popup button to remove a selected dependency.
--
-- @param on_update function: callback to refresh the dependency display
-- @return Layout.Box: wrapped button in a layout box
function M.create_remove_button(on_update)
	local popup = Popup(remove_button_popup_config())

	popup:map("n", "<CR>", function()
		local deps = telescope_dep.selected_dependencies
		if not deps or #deps == 0 then
			msg.warn("No dependencies to remove.")
			return
		end

		-- Crear lista para Telescope
		local items = {}
		for i, dep in ipairs(deps) do
			table.insert(items, {
				label = string.format("%d. %s", i, dep),
				id = dep,
			})
		end

		-- Mostrar selector
		require("telescope.pickers")
			.new({}, {
				prompt_title = "Select dependency to remove",
				finder = require("telescope.finders").new_table({
					results = items,
					entry_maker = function(entry)
						return {
							value = entry.id,
							display = entry.label,
							ordinal = entry.label,
						}
					end,
				}),
				sorter = require("telescope.config").values.generic_sorter(),
				attach_mappings = function(prompt_bufnr)
					require("telescope.actions").select_default:replace(function()
						local selection = require("telescope.actions.state").get_selected_entry()
						if selection then
							-- Eliminar la dependencia
							for i, dep in ipairs(telescope_dep.selected_dependencies) do
								if dep == selection.value then
									table.remove(telescope_dep.selected_dependencies, i)
									break
								end
							end
							msg.info("Dependency removed: " .. selection.value)
							vim.schedule(on_update) -- Actualizar UI
						end
						require("telescope.actions").close(prompt_bufnr)
					end)
					return true
				end,
			})
			:find()
	end, { noremap = true, nowait = true })

	focus.register(popup)
	return Layout.Box(popup, { size = 3 })
end

-- Returns the border config for the dependencies display panel.
local function display_border()
	return {
		style = "rounded",
		text = { top = "Selected Dependencies", top_align = "center" },
	}
end

-- Builds the configuration for the dependencies display popup.
local function display_popup_config()
	return {
		border = display_border(),
		size = { width = 40, height = 10 },
		buf_options = { modifiable = true, readonly = false },
		win_options = {
			winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
			wrap = true,
		},
	}
end

--- Creates a popup to display selected dependencies.
--
-- @return NuiPopup: popup for showing dependencies
function M.create_display()
	local popup = Popup(display_popup_config())
	M.state.dependencies_panel = popup
	return popup
end

-- Renders the currently selected dependencies as a list of lines.
--
-- @return table: list of formatted strings
local function render_dependency_list()
	local lines = { "Selected Dependencies:" }
	for i, dep in ipairs(telescope_dep.selected_dependencies or {}) do
		table.insert(lines, string.format("%d. %s", i, dep))
	end
	return lines
end

--- Updates the dependencies display with currently selected dependencies.
function M.update_display()
	local panel = M.state.dependencies_panel
	if not panel or not vim.api.nvim_buf_is_valid(panel.bufnr) then
		return
	end
	vim.api.nvim_buf_set_lines(panel.bufnr, 0, -1, false, render_dependency_list())
end

return M
