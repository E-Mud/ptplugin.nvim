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

---@param bufnr integer
---@return string?
local function get_project_path(bufnr)
  local path = fs.find(opts.root_markers, {
    upward = true,
    stop = vim.loop.os_homedir(),
    path = fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
  })[1]

  if path == nil then
    return nil
  end

  return fs.dirname(path)
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
