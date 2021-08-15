local ts_utils = require("nvim-treesitter.ts_utils")

local popup = require("snipe.popup")
local config = require("snipe.config")

local Snipe = {}

local active_id = nil
local active_signature = nil
local full = false

--- Merge ranges
local function merge_ts_ranges(start_row, end_row, child)
  local child_start_row, _, child_end_row, _ = ts_utils.get_node_range(child)
  if child_start_row > end_row then
    return start_row, end_row
  end
  if child_end_row > end_row then
    return start_row, child_end_row
  end
  return start_row, end_row
end

--- Gets the current signature. Will get the signature from the scope window,
--- if it exists.
local function get_current_signature(parent)
  -- Merge ranges with children
  local start_row, _, _ = parent:start()
  local end_row = start_row
  for _, child in ipairs(ts_utils.get_named_children(parent)) do
    if child:type() == "block" then
      break
    end
    start_row, end_row = merge_ts_ranges(start_row, end_row, child)
  end

  -- Return just the signature
  local lines = {}
  local signature = ts_utils.get_node_text(parent, 0)
  for i = 1, end_row - start_row + 1 do
    table.insert(lines, signature[i])
  end
  return lines
end

--- Return if the cursor is on top of the scope
local function cursor_on_scope(signature)
  return (vim.fn.winline() == 1 and not full) or (vim.fn.winline() <= #signature and full)
end

--- Parses a parent and shows its scope.
---
--- Returns true if the active window is valid. Otherwise, returns false and
--- expects the caller to try the parent of this node, or give up.
local function parse_parent(parent)
  local row, _, _ = parent:start()
  local signature = get_current_signature(parent)

  -- Don't show scope if cursor is on the scope
  if cursor_on_scope(signature) then
    return false
  end
  -- Only show scope if signature is above the screen
  local pos = vim.api.nvim_win_get_cursor(0)
  if pos[1] - vim.fn.winline() <= row then
    return false
  end

  -- Check if the signature is the same
  if active_id then
    local match = true
    if #active_signature == #signature then
      for i = 1, #signature do
        if string.gsub(active_signature[i], "^%s*(.-)%s*$", "%1") ~= signature[i] then
          match = false
        end
      end
      if match then
        return true
      end
    end
  end

  active_id = popup.create_popup(active_id, signature, full)
  active_signature = signature
  return true
end

--- Creates a popup window showing the parent scope. Will recursively look for
--- the first scope to show.
---
--- Returns true if the active window is valid. Otherwise, returns false and
--- expects the window to be closed by the caller.
local function show_scope()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return false
  end

  local parent = node:parent()
  if not parent then
    return false
  end

  while parent and not (parent:type() == "program") do
    if vim.tbl_contains(config.options.targets, parent:type()) then
      if parse_parent(parent) then
        return true
      end
    end
    parent = parent:parent()
  end
  return false
end

local function check_ft()
  local current_bufnr = vim.api.nvim_win_get_buf(0)
  if vim.api.nvim_buf_get_option(current_bufnr, "buftype") == "terminal" then
    return false
  end
  return true
end

local function close_popup()
  popup.close(active_id)
  active_id = nil
  active_signature = nil
end

local function maybe_close_popup()
  if active_signature and cursor_on_scope(active_signature) then
    popup.close(active_id)
    active_id = nil
    active_signature = nil
  end
end

function Snipe.setup(options)
  config.setup(options)
end

function Snipe.snipe()
  if not check_ft() then
    return
  end
  if not show_scope() then
    close_popup()
  end
end

function Snipe.toggle()
  if not check_ft() then
    return
  end
  full = not full
  if not show_scope() then
    close_popup()
  end
end

function Snipe.close()
  if not check_ft() then
    return
  end
  close_popup()
end

function Snipe.maybe_close()
  if not check_ft() then
    return
  end
  maybe_close_popup()
end

return Snipe
