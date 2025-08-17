local layout_builder = require("initializr.ui.layout")
local focus = require("initializr.ui.focus")
local highlights = require("initializr.utils.highlights")
local metadata = require("initializr.metadata.metadata")
local deps = require("initializr.ui.deps")
local win = require("initializr.utils.window")
local msg = require("initializr.utils.message")

local M = {
	state = {
		layout = nil,
		outer_popup = nil,
		selections = { dependencies = {} },
	},
}

--- Applies highlight configuration and sets up autocmd for theme changes.
local function setup_highlights()
	highlights.configure()
end

--- Logs an error message if metadata fetch fails.
--
-- @param err string: error message to show to the user
local function handle_metadata_error(err)
	msg.error("Failed to load metadata: " .. (err or "unknown error"))
end

--- Saves fetched metadata to module state.
--
-- @param data table: metadata object
local function store_metadata(data)
	M.state.metadata = data
end

--- Builds and stores the UI layout and popup in module state.
--
-- @param data table: metadata used for building the UI
local function setup_layout(data)
	local ui = layout_builder.build_ui(data, M.state.selections)
	M.state.layout = ui.layout
	M.state.outer_popup = ui.outer_popup
end

--- Mounts the layout, sets focus behavior and updates dependency display.
local function activate_ui()
	M.state.layout:mount()
	focus.enable()
	deps.update_display()
end

--- Orchestrates layout setup using fetched metadata.
--
-- @param data table: the metadata used to drive UI creation
local function mount_ui(data)
	store_metadata(data)
	setup_layout(data)
	activate_ui()
end

--- Public setup function that initializes the full UI system.
-- Loads metadata, builds layout, and shows the form.
function M.setup()
	setup_highlights()

	metadata.fetch_metadata(function(data, err)
		if err or not data then
			handle_metadata_error(err)
			return
		end

		vim.schedule(function()
			mount_ui(data)
		end)
	end)
end

--- Cleans up all active layout and popup UI components.
-- Resets internal state and focus tracking.
function M.close()
	if M.state.layout then
		pcall(function()
			M.state.layout:unmount()
		end)
		M.state.layout = nil
	end

	win.safe_close(M.state.outer_popup and M.state.outer_popup.winid)
	M.state.outer_popup = nil

	focus.reset()
end

return M
