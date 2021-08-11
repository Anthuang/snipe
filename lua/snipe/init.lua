local Window = require("plenary.window")
local ts_utils = require('nvim-treesitter.ts_utils')
local popup = require('popup')

local Snipe = {}

local active_id = nil
local targets = {
  'function',
  'method_declaration',
  'function_declaration',
  'function_definition',
  'class_declaration',
}

local function close()
  if active_id then
    Window.try_close(active_id, false)
    if active_id and vim.api.nvim_win_is_valid(active_id + 1) then
      Window.try_close(active_id + 1, false) -- popup seems to create two windows
    end
    active_id = nil
  end
end

function Snipe.snipe()
  close()

  local node = ts_utils.get_node_at_cursor();
  if not node then
    return
  end

  local parent = node:parent();
  if not parent then
    return
  end

  while parent and not (parent:type() == 'program') do
    if vim.tbl_contains(targets, parent:type()) then
      local row, _, col = parent:start()
      local signature = ts_utils.get_node_text(parent, 0)[1]

      -- Don't show scope if first line
      if vim.fn.winline() == 1 then
        return
      end
      -- Only show scope if signature is above the screen
      local pos = vim.api.nvim_win_get_cursor(0)
      if pos[1] - vim.fn.winline() <= row then
        return
      end

      local win_pos = vim.api.nvim_win_get_position(0)

      active_id, _ = popup.create(signature, {
        ['line'] = win_pos[1],
        ['col'] = win_pos[2] + 1,
        ['minheight'] = 0,
        ['minwidth'] = 0,
        ['maxheight'] = 1,
        ['maxwidth'] = col,
        ['border'] = {0, 0, 0, 1},
        ['borderchars'] = {'▏'},
        ['padding'] = {0, 1, 0, 1},
        ['enter'] = false,
      })
      vim.api.nvim_win_set_option(active_id, 'wrap', false)
      vim.api.nvim_win_set_option(active_id, 'number', false)
      -- TODO: add highlighting
      return
    end
    parent = parent:parent()
  end
end

function Snipe.close()
  close()
end

return Snipe
