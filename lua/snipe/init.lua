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

function Snipe.snipe()
  if active_id then
    Window.try_close(active_id, false)
    Window.try_close(active_id+1, false) -- popup seems to create two windows
    active_id = nil
  end

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
      local _, _, col = parent:start()
      local signature = ts_utils.get_node_text(parent, 0)[1]
      -- TODO: Only show if signature is above the screen

      active_id, _ = popup.create(signature, {
        ['line'] = 1,
        -- TODO: Set col based on buffer
        ['col'] = 2,
        ['minheight'] = 0,
        ['minwidth'] = 0,
        ['maxheight'] = 1,
        ['maxwidth'] = col,
        ['border'] = {0, 0, 0, 1},
        ['borderchars'] = {'▏'},
        ['padding'] = {0, 1, 0, 1},
        ['enter'] = false,
      })
      return
    end
    parent = parent:parent()
  end
end

return Snipe

