local fn = vim.fn
local fs = vim.fs
local api = vim.api

---@class MyModule
local M = {}

local augroup = api.nvim_create_augroup("ProjectTypePlugin", { clear = true })


---@param root_dir string
---@return string
local function default_extractor(root_dir)
  return fn.fnamemodify(root_dir, ":t")
end

---@class Config
---@field root_markers string[]
---@field extractor fun(root_dir: string): string[]

---@type Config
local default_opts = {
  root_markers = { '.git' },
  extractor = default_extractor
}

---@type Config
local opts = vim.deepcopy(default_opts)

---@type { [string]: string[] }
local cached_project_types = {}

---@param file_path string
---@return boolean
local function file_exists(file_path)
  return fn.glob(file_path) ~= ""
end

---@param bufnr integer
---@param root_markers string[]
---@return string?
local function project_path_from_root_markers(bufnr, root_markers)
  local buf_file_path = api.nvim_buf_get_name(bufnr)

  if not file_exists(buf_file_path) then
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
local function get_project_path(bufnr)
  local project_path = project_path_from_root_markers(bufnr, opts.root_markers)

  if project_path == nil then
    project_path = vim.fn.getcwd()
  end

  return project_path
end

---@param project_path string
---@return string[]
local function get_project_types(project_path)
  if cached_project_types[project_path] == nil then
    cached_project_types[project_path] = opts.extractor(project_path)
  end
  return cached_project_types[project_path]
end

---@param project_types string[]
local function runtime_project_types(project_types)
  for _, project_type in pairs(project_types) do
    local new_paths = {
      string.format("ptplugin/%s[.]{{vim,lua}}", project_type),
      string.format("ptplugin/%s_*.{{vim,lua}}", project_type),
      string.format("ptplugin/%s/*.{{vim,lua}}", project_type),
    }
    vim.cmd("runtime! " .. table.concat(new_paths, " "))
  end
end

---@param ev { buf: integer }
local function handle_buffer_open(ev)
  local bufnr = ev.buf
  local project_path = get_project_path(bufnr)

  if project_path == nil then
    return
  end

  vim.b[bufnr].project_path = project_path

  local project_types = get_project_types(project_path)

  vim.b[bufnr].projecttypes = vim.deepcopy(project_types)

  runtime_project_types(project_types)
end

---@param user_opts? Config
function M.setup(user_opts)
  user_opts = user_opts or {}
  opts = vim.tbl_deep_extend('force', default_opts, user_opts)

  api.nvim_create_autocmd("BufReadPre",
    { group = augroup, callback = handle_buffer_open })
end

return M
