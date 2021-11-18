local popup = require("snipe.popup")
local config = require("snipe.config")
local scope = require("snipe.scope")

local Snipe = {}

local function check_ft()
  local current_bufnr = vim.api.nvim_win_get_buf(0)
  if vim.api.nvim_buf_get_option(current_bufnr, "buftype") == "terminal" then
    return false
  end
  return true
end

local function maybe_close_popup()
  if scope.active_signature and scope.cursor_on_scope(scope.active_signature) then
    popup.close(scope.active_id)
    scope.active_id = nil
    scope.active_signature = nil
  end
end

function Snipe.setup(options)
  config.setup(options)
end

function Snipe.snipe()
  if not check_ft() then
    return
  end
  if not scope.show() then
    scope.hide()
  end
end

function Snipe.toggle()
  if not check_ft() then
    return
  end
  scope.full = not scope.full
  if not scope.show() then
    scope.hide()
  end
end

function Snipe.close()
  if not check_ft() then
    return
  end
  scope.hide()
end

function Snipe.maybe_close()
  if not check_ft() then
    return
  end
  maybe_close_popup()
end

return Snipe
