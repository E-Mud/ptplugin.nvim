local util = require('ptplugin.util')

---@class MyModule
local M = {}

---@param project_path string
---@param extractors (fun(root_dir: string): string[])[]
---@returns string[]?
function M.extract_project_types(project_path, extractors)
  local result = {}

  for _, extractor in ipairs(extractors) do
    local extracted = extractor(project_path)

    if type(extracted) == "table" then
      result = util.concat_unique(result, extracted)
    end
  end

  return result
end

return M
