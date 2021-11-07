local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

--- Merge ranges
function M.merge_ts_ranges(start_row, end_row, child)
  local child_start_row, _, child_end_row, _ = ts_utils.get_node_range(child)
  if child_start_row > end_row then
    return start_row, end_row
  end
  if child_end_row > end_row then
    return start_row, child_end_row
  end
  return start_row, end_row
end

return M
