local M = {}

local defaults = {
  ['targets'] = {
    'function',
    'method_declaration',
    'function_declaration',
    'function_definition',
    'local_function',
    'class_declaration',
    'class_definition',
  }
}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return M

