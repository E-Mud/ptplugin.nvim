local fs = vim.fs
local api = vim.api
local util = require('ptplugin.util')

---@class MyModule
local M = {}


---@param bufnr integer
---@param root_markers string[]
---@return string?
local function project_path_from_root_markers(bufnr, root_markers)
  local buf_file_path = api.nvim_buf_get_name(bufnr)

  if not util.file_exists(buf_file_path) then
    return nil
  end

  local path = fs.find(root_markers, {
    upward = true,
    stop = vim.loop.os_homedir(),
    path = fs.dirname(buf_file_path),
  })[1]

  if path == nil then
    return nil
  end

  return fs.dirname(path)
end

---@param bufnr integer
---@return string?
---@param root_markers string[]
function M.get_project_path(bufnr, root_markers)
  local project_path = project_path_from_root_markers(bufnr, root_markers)

  if project_path == nil then
    project_path = vim.fn.getcwd()
  end

  return project_path
end

return M
