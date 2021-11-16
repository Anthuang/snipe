local ts_utils = require("nvim-treesitter.ts_utils")

local config = require("snipe.config")
local popup = require("snipe.popup")
local util = require("snipe.util")

local M = {}

M.active_id = nil
M.active_signature = nil
M.full = false

--- Gets the signature that the cursor is on
function M.get_current_signature(parent)
  -- Merge ranges with children
  local start_row, _, _ = parent:start()
  local end_row = start_row
  for _, child in ipairs(ts_utils.get_named_children(parent)) do
    if child:type() == "block" then
      break
    end
    start_row, end_row = util.merge_ts_ranges(start_row, end_row, child)
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
function M.cursor_on_scope(signature)
  return (vim.fn.winline() == 1 and not M.full) or (vim.fn.winline() <= #signature and M.full)
end

--- Parses a parent and shows its scope.
---
--- Returns true if the active window is valid. Otherwise, returns false and
--- expects the caller to try the parent of this node, or give up.
function M.parse_parent(parent)
  local row, _, _ = parent:start()
  local signature = M.get_current_signature(parent)

  -- Don't show scope if cursor is on the scope
  if M.cursor_on_scope(signature) then
    return false
  end
  -- Only show scope if signature is above the screen
  local pos = vim.api.nvim_win_get_cursor(0)
  if pos[1] - vim.fn.winline() <= row then
    return false
  end

  -- Check if the signature is the same
  if M.active_id then
    local match = true
    if #M.active_signature == #signature then
      for i = 1, #signature do
        -- Trim whitespaces for both signatures
        if util.trim_string(M.active_signature[i]) ~= util.trim_string(signature[i]) then
          match = false
        end
      end
      if match then
        return true
      end
    end
  end

  M.active_id = popup.create_popup(M.active_id, signature, M.full)
  M.active_signature = signature
  return true
end

--- Creates a popup window showing the parent scope. Will recursively look for
--- the first scope to show.
---
--- Returns true if the active window is valid. Otherwise, returns false and
--- expects the window to be closed by the caller.
function M.show()
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
      if M.parse_parent(parent) then
        return true
      end
    end
    parent = parent:parent()
  end
  return false
end

return M
