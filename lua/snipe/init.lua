local ts_utils = require('nvim-treesitter.ts_utils')

local popup = require('snipe.popup')

local Snipe = {}

local active_id = nil
local targets = {
  'function',
  'method_declaration',
  'function_declaration',
  'function_definition',
  'local_function',
  'class_declaration',
  'class_definition',
}

--- Gets the signature in the current scope window, if any
local function get_current_signature()
  local bufnr = vim.api.nvim_win_get_buf(active_id)
  return vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
end

--- Creates a popup window showing the parent scope. Returns true if active
--- window is valid. Otherwise, returns false and expects the window to be
--- closed by the caller.
local function create_scope_popup()
  local node = ts_utils.get_node_at_cursor();
  if not node then
    return false
  end

  local parent = node:parent();
  if not parent then
    return false
  end

  while parent and not (parent:type() == 'program') do
    if vim.tbl_contains(targets, parent:type()) then
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

      active_id = popup.create_popup(signature)
      return true
    end
    parent = parent:parent()
  end
  return false
end

function Snipe.snipe()
  if not create_scope_popup() then
    active_id = popup.close(active_id)
  end
end

function Snipe.close()
  active_id = popup.close(active_id)
end

return Snipe
