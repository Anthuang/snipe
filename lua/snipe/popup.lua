local Window = require("plenary.window")
local popup = require("popup")
local ts_parsers = require("nvim-treesitter.parsers")

local M = {}

--- Close current scope window, if any
function M.close(win_id)
  if win_id then
    Window.try_close(win_id, false)
    if win_id and vim.api.nvim_win_is_valid(win_id + 1) then
      -- popup seems to create two windows
      Window.try_close(win_id + 1, false)
    end
    return nil
  end
  return win_id
end

function M.create_popup(win_id, signature, full)
  local win_pos = vim.api.nvim_win_get_position(0)
  local width = vim.api.nvim_win_get_width(0)

  -- Close current active scope window before creating
  M.close(win_id)

  local height = #signature
  if not full then
    height = 1
  end
  local new_win_id, _ = popup.create(signature, {
    line = win_pos[1],
    col = win_pos[2] + 1,
    minheight = 0,
    minwidth = width - 1,
    maxheight = height,
    maxwidth = width - 1,
    border = { 0, 0, 0, 1 },
    borderchars = { "▏" },
    padding = { 0, 1, 0, 1 },
    enter = false,
  })
  vim.api.nvim_win_set_option(new_win_id, "wrap", false)
  vim.api.nvim_win_set_option(new_win_id, "number", false)

  -- Add highlighting, using treesitter if possible
  local current_bufnr = vim.api.nvim_win_get_buf(0)
  local bufnr = vim.api.nvim_win_get_buf(new_win_id)
  local ft = vim.api.nvim_buf_get_option(current_bufnr, "ft")

  local lang = ts_parsers.ft_to_lang(ft)
  if ts_parsers.has_parser(lang) then
    vim.treesitter.highlighter.new(ts_parsers.get_parser(bufnr, lang))
  end
  vim.api.nvim_buf_set_option(bufnr, "syntax", ft)

  return new_win_id
end

return M
