# Intro

Like `ftplugin`, but for projects.

- What's a project? `ptplugin` does not enforce any kind of project description/specification. A project is simply a folder, so every file in that folder belongs to that project.
- Then what's a project type? For simplicity, you can see types as tags, just arbitrary text. You can use them to denote specific frameworks, work projects...

This Neovim plugin automatically detects project types and loads project-specific configuration files based on the project's root directory. 

# 🚀 How It Works

1. **Project Detection**: When a buffer is opened, searches upward from the file's directory to find project root markers. The project path is added to `project_path` buffer variable for inspection. If not root directory is found, it will fallback to `cwd`.

2. **Type Extraction**: Extracts the project types based on dynamic extractor. By default it just uses the root directory name (e.g., `/path/to/my-react-app/` → `"my-react-app"`). This only happens once per project.

3. **Runtime Loading**: Automatically loads project-specific files from these patterns:
   - `ptplugin/{type}.{vim,lua}`
   - `ptplugin/{type}_*.{vim,lua}`
   - `ptplugin/{type}/*.{vim,lua}`

   This step runs for every project type **in the same order** as returned by type extraction.

4. **Buffer Variables**: Sets `projecttypes` buffer variable on each buffer with the detected project types

# 📁 File Organization

For a project named "django-blog", the plugin will load:

- `<runtimepath>/ptplugin/django-blog.lua`
- `<runtimepath>/ptplugin/django-blog_settings.vim`  
- `<runtimepath>/ptplugin/django-blog/keymaps.lua`
- `<runtimepath>/ptplugin/django-blog/autocmds.lua`

See `:h runtimepath` for more information about your runtimepath location, but in most cases we're talking about the directory where you have your neovim config:
```bash
:echo stdpath("config")
```

# 💡 Example Use Cases

- **Framework-specific settings**: Load React, Rails, or Laravel configurations automatically
- **Project keymaps**: Define project-specific key bindings
- **Tool integration**: Automatically configure LSP, linters, or formatters per project
- **Environment setup**: Load different settings for work vs personal projects

# 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'e-mud/ptplugin.nvim',
  config = function()
    require('ptplugin').setup()
  end
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'e-mud/ptplugin.nvim',
  config = function()
    require('ptplugin').setup()
  end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'e-mud/ptplugin.nvim'
```

```lua
require('ptplugin').setup()
```

# ⚙️ Configuration

### Default Configuration

```lua
require('ptplugin').setup({
  root_markers = { '.git' },
  extractor = {
    require('ptplugin.extractors').dir_name, -- takes the name of the root directory
  }
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `root_markers` | `string[]` | `{ '.git' }` | Files/directories that indicate project root |
| `extractor` | `function[]` | `{ default_extractor }` | List of functions to extract project type from root directory path. Each function is extractor must return a table with all the extracted project types. All the results are concatenated into one list, removing duplicates. |


### Custom Configuration Examples


```lua
require('ptplugin').setup({
  root_markers = { '.git', 'package.json', 'Cargo.toml', 'pyproject.toml' },
  extractor = {
    require('ptplugin.extractors').dir_name,
    function(root_dir)
      -- Use the last two directory components
      local parts = vim.split(root_dir, '/')
      return { table.concat({ parts[#parts-1], parts[#parts] }, '-') }
    end
  }
})
```
