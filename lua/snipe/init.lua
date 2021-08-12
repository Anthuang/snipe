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
  'local_function',
  'class_declaration',
  'class_definition',
}

--- Close current scope window, if any
local function close()
  if active_id then
    Window.try_close(active_id, false)
    if active_id and vim.api.nvim_win_is_valid(active_id + 1) then
      -- popup seems to create two windows
      Window.try_close(active_id + 1, false)
    end
    active_id = nil
  end
end

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

      local win_pos = vim.api.nvim_win_get_position(0)
      local width = vim.api.nvim_win_get_width(0)

      -- Close current active scope window before creating
      close()
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

      -- Add highlighting, using treesitter if possible
      local current_bufnr = vim.api.nvim_win_get_buf(0)
      local bufnr = vim.api.nvim_win_get_buf(active_id)
      local ft = vim.api.nvim_buf_get_option(current_bufnr, 'ft')

      local lang = ts_parsers.ft_to_lang(ft)
      if ts_parsers.has_parser(lang) then
        vim.treesitter.highlighter.new(ts_parsers.get_parser(bufnr, lang))
      end
      vim.api.nvim_buf_set_option(bufnr, 'syntax', ft)
      return true
    end
    parent = parent:parent()
  end
  return false
end

function Snipe.snipe()
  if not create_scope_popup() then
    close()
  end
end

function Snipe.close()
  close()
end

return Snipe
