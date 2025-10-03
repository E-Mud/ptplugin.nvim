local fn = vim.fn

---@class MyModule
local M = {}

---@param root_dir string
---@return string
function M.dir_name(root_dir)
  return fn.fnamemodify(root_dir, ":t")
end

return M
