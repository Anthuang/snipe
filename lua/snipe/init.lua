local ts_utils = require('nvim-treesitter.ts_utils')

local popup = require('snipe.popup')
local config = require('snipe.config')

local Snipe = {}

local active_id = nil


--- Gets the signature in the current scope window, if any
local function get_current_signature()
  local bufnr = vim.api.nvim_win_get_buf(active_id)
  return vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
end

--- Parses a parent and shows its scope.
---
--- Returns true if the active window is valid. Otherwise, returns false and
--- expects the caller to try the parent of this node, or give up.
local function parse_parent(parent)
  local row, _, _ = parent:start()
  local signature = ts_utils.get_node_text(parent, 0)[1]

  -- Don't show scope if first line
  if vim.fn.winline() == 1 then
    return false
  end
  -- Only show scope if signature is above the screen
  local pos = vim.api.nvim_win_get_cursor(0)
  if pos[1] - vim.fn.winline() <= row then
    return false
  end

  -- Check if the signature is the same
  if active_id then
    local current_signature = get_current_signature()
    current_signature = string.gsub(current_signature, '^%s*(.-)%s*$', '%1')
    if current_signature == signature then
      return true
    end
  end

  active_id = popup.create_popup(active_id, signature)
  return true
end

--- Creates a popup window showing the parent scope. Will recursively look for
--- the first scope to show.
---
--- Returns true if the active window is valid. Otherwise, returns false and
--- expects the window to be closed by the caller.
local function show_scope()
  local node = ts_utils.get_node_at_cursor();
  if not node then
    return false
  end

  local parent = node:parent();
  if not parent then
    return false
  end

  while parent and not (parent:type() == 'program') do
    if vim.tbl_contains(config.options.targets, parent:type()) then
      if parse_parent(parent) then
        return true
      end
    end
    parent = parent:parent()
  end
  return false
end

function Snipe.setup(options)
  config.setup(options)
end

function Snipe.snipe()
  if not show_scope() then
    active_id = popup.close(active_id)
  end
end

function Snipe.close()
  active_id = popup.close(active_id)
end

return Snipe

