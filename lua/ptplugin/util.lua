---@class MyModule
local M = {}

---@param file_path string
---@return boolean
function M.file_exists(file_path)
  return vim.fn.glob(file_path) ~= ""
end

---@param t1 table
---@param t2 table
---@return table
function M.concat_unique(t1, t2)
  local result = vim.deepcopy(t1)

  for _, v2 in ipairs(t2) do
    local found = false

    for _, v1 in ipairs(t1) do
      if v1 == v2 then
        found = true
      end
    end

    if not found then
      table.insert(result, v2)
    end
  end

  return result
end

return M
