local api = vim.api
local extract = require('ptplugin.extract')
local extractors = require('ptplugin.extractors')
local project_path = require('ptplugin.project_path')

---@class MyModule
local M = {}

local augroup = api.nvim_create_augroup("ProjectTypePlugin", { clear = true })

---@class Config
---@field root_markers string[]
---@field extractor (fun(root_dir: string): string[])[]

---@type Config
local default_opts = {
  root_markers = { '.git' },
  extractor = { extractors.dir_name }
}

---@type Config
local opts = vim.deepcopy(default_opts)

---@type { [string]: string[] }
local cached_project_types = {}

---@param path string
---@return string[]
local function get_project_types(path)
  if cached_project_types[path] == nil then
    cached_project_types[path] = extract.extract_project_types(path, opts.extractor)
  end
  return cached_project_types[path]
end

---@param project_types string[]
local function runtime_project_types(project_types)
  for _, project_type in ipairs(project_types) do
    local new_paths = {
      string.format("ptplugin/%s[.]{{vim,lua}}", project_type),
      string.format("ptplugin/%s_*.{{vim,lua}}", project_type),
      string.format("ptplugin/%s/*.{{vim,lua}}", project_type),
    }
    vim.cmd("runtime! " .. table.concat(new_paths, " "))
  end
end

---@param bufnr integer
---@param path string
local function set_project_path(bufnr, path)
  vim.b[bufnr].project_path = path
end

---@param bufnr integer
---@param project_types string[]
local function set_project_types(bufnr, project_types)
  vim.b[bufnr].projecttypes = vim.deepcopy(project_types)
  runtime_project_types(project_types)
end

---@param bufnr integer
local function detect_project_types(bufnr)
  local path = project_path.get_project_path(bufnr, opts.root_markers)

  if path == nil then
    return
  end

  set_project_path(bufnr, path)

  local project_types = get_project_types(path)

  set_project_types(bufnr, project_types)
end

---@param user_opts? Config
function M.setup(user_opts)
  user_opts = user_opts or {}
  opts = vim.tbl_deep_extend('force', default_opts, user_opts)

  api.nvim_create_autocmd(
    "BufReadPre",
    {
      group = augroup,
      callback = function (ev)
        detect_project_types(ev.buf)
      end
    }
  )
end

return M
