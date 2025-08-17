local Popup = require("nui.popup")
local Layout = require("nui.layout")

local focus = require("initializr.ui.focus")
local msg = require("initializr.utils.message")

local M = {}

--- Normalize a value entry into a radio item format.
--
-- @param value table with `name` and `id`
-- @return table: formatted with `label` and `value`
local function normalize_item(value)
	return { label = value.name, value = value.id }
end

--- Convert list of value tables into normalized radio items.
--
-- @param values table: list of tables with `name` and `id`
-- @return table: list of normalized items
local function build_items(values)
	local items = {}
	for _, value in ipairs(values or {}) do
		if type(value) == "table" then
			table.insert(items, normalize_item(value))
		end
	end
	return items
end

--- Format a single item line for display with a selection marker.
--
-- @param item table: radio item
-- @param is_selected boolean: whether the item is selected
-- @return string: formatted line
local function render_item_line(item, is_selected)
	local prefix = is_selected and "(x)" or "( )"
	return string.format("%s %s", prefix, item.label)
end

--- Render all radio items to the popup buffer.
--
-- @param popup Popup: nui popup instance
-- @param items table: list of items
-- @param selected_index number: currently selected item index
local function render_all_items(popup, items, selected_index)
	local lines = {}
	for i, item in ipairs(items) do
		table.insert(lines, render_item_line(item, i == selected_index))
	end
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
end

--- Schedule the initial render of the items in the popup.
--
-- @param popup Popup
-- @param items table
-- @param selected_index number
local function schedule_initial_render(popup, items, selected_index)
	vim.schedule(function()
		render_all_items(popup, items, selected_index)
	end)
end

--- Handle selection confirmation with <CR>.
--
-- @param items table
-- @param selected_index number
-- @param title string
-- @param key string
-- @param selections table: global selection state
local function handle_enter(items, selected_index, title, key, selections)
	selections[key] = items[selected_index].value
	msg.info(string.format("%s: %s", title, items[selected_index].label))
end

--- Move down in the list.
--
-- @param items table
-- @param selected_index number
-- @return number: new index
local function handle_move_down(items, selected_index)
	return math.min(selected_index + 1, #items)
end

--- Move up in the list.
-- @param selected_index number
-- @return number: new index
local function handle_move_up(selected_index)
	return math.max(selected_index - 1, 1)
end

--- Map <CR> key to selection handler.
local function map_enter_key(popup, state)
	popup:map("n", "<CR>", function()
		handle_enter(state.items, state.selected[1], state.title, state.key, state.selections)
	end, { nowait = true, noremap = true })
end

--- Map "j" key to move down handler.
local function map_down_key(popup, state)
	popup:map("n", "j", function()
		state.selected[1] = handle_move_down(state.items, state.selected[1])
		state.selections[state.key] = state.items[state.selected[1]].value
		render_all_items(popup, state.items, state.selected[1])
	end, { nowait = true, noremap = true })
end

--- Map "k" key to move up handler.
local function map_up_key(popup, state)
	popup:map("n", "k", function()
		state.selected[1] = handle_move_up(state.selected[1])
		state.selections[state.key] = state.items[state.selected[1]].value
		render_all_items(popup, state.items, state.selected[1])
	end, { nowait = true, noremap = true })
end

--- Attach all key mappings for interaction.
local function map_keys(popup, state)
	map_enter_key(popup, state)
	map_down_key(popup, state)
	map_up_key(popup, state)
end

--- Create the popup UI element for the radio.
--
-- @param title string: title for popup border
-- @param item_count number: used for height
-- @return Popup
local function create_radio_popup(title, item_count)
	return Popup({
		border = {
			style = "rounded",
			text = { top = title, top_align = "center" },
		},
		size = { width = 30, height = item_count + 2 },
		enter = true,
		focusable = true,
		win_options = {
			winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
		},
	})
end

--- Create a radio component as a layout box.
--
-- @param title string: label/title of the radio group
-- @param values table: available radio options
-- @param key string: key to store the selection in state
-- @param selections table: global state
-- @return Layout.Box
function M.create_radio(title, values, key, selections)
	local items = build_items(values)
	local selected = { 1 }

	selections[key] = items[selected[1]].value

	local popup = create_radio_popup(title, #items)
	local state = {
		title = title,
		items = items,
		key = key,
		selections = selections,
		selected = selected,
	}

	map_keys(popup, state)
	schedule_initial_render(popup, items, selected[1])
	focus.register(popup)

	return Layout.Box(popup, { size = #items + 2 })
end

return M
