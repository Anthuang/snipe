local Window = require("plenary.window")
local popup = require('popup')
local ts_utils = require('nvim-treesitter.ts_utils')
local ts_parsers = require('nvim-treesitter.parsers')

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
      local width = vim.api.nvim_win_get_width(0)

      active_id, _ = popup.create(signature, {
        ['line'] = win_pos[1],
        ['col'] = win_pos[2] + 1,
        ['minheight'] = 0,
        ['minwidth'] = width - 1,
        ['maxheight'] = 1,
        ['maxwidth'] = width - 1,
        ['border'] = {0, 0, 0, 1},
        ['borderchars'] = {'▏'},
        ['padding'] = {0, 1, 0, 1},
        ['enter'] = false,
      })
      vim.api.nvim_win_set_option(active_id, 'wrap', false)
      vim.api.nvim_win_set_option(active_id, 'number', false)

      -- Add highlighting
      local current_bufnr = vim.api.nvim_win_get_buf(0)
      local bufnr = vim.api.nvim_win_get_buf(active_id)
      local ft = vim.api.nvim_buf_get_option(current_bufnr, 'ft')

      local lang = ts_parsers.ft_to_lang(ft)
      if ts_parsers.has_parser(lang) then
        vim.treesitter.highlighter.new(ts_parsers.get_parser(bufnr, lang))
      end
      vim.api.nvim_buf_set_option(bufnr, 'syntax', ft)
      return
    end
    parent = parent:parent()
  end
end

function Snipe.close()
  close()
end

return Snipe
