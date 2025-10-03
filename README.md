# ptplugin.nvim

Like `ftplugin`, but for projects.

- What's a project? `ptplugin` does not enforce any kind of project description/specification. A project is simply a folder, so every file in that folder belongs to that project.
- Then what's a project type? For simplicity, you can see types as tags, just arbitrary text. You can use them to denote specific frameworks, work projects...

This Neovim plugin automatically detects project types and loads project-specific configuration files based on the project's root directory. 

## 🚀 How It Works

1. **Project Detection**: When a buffer is opened, searches upward from the file's directory to find project root markers

2. **Type Extraction**: Extracts the project type from the root directory name (e.g., `/path/to/my-react-app/` → `"my-react-app"`)

3. **Runtime Loading**: Automatically loads project-specific files from these patterns:
   - `ptplugin/{type}.{vim,lua}`
   - `ptplugin/{type}_*.{vim,lua}`
   - `ptplugin/{type}/*.{vim,lua}`

4. **Buffer Variables**: Sets `vim.b.projecttypes` on each buffer with the detected project types

## 📁 File Organization

For a project named "django-blog", the plugin will load:
- `~/.config/nvim/ptplugin/django-blog.lua`
- `~/.config/nvim/ptplugin/django-blog_settings.vim`  
- `~/.config/nvim/ptplugin/django-blog/keymaps.lua`
- `~/.config/nvim/ptplugin/django-blog/autocmds.lua`

## 💡 Example Use Cases

- **Framework-specific settings**: Load React, Rails, or Laravel configurations automatically
- **Project keymaps**: Define project-specific key bindings
- **Tool integration**: Automatically configure LSP, linters, or formatters per project
- **Environment setup**: Load different settings for work vs personal projects

## 📦 Installation

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

## ⚙️ Configuration

### Default Configuration

```lua
require('ptplugin').setup({
  root_markers = { '.git' },
  extractor = function(root_dir)
    return vim.fn.fnamemodify(root_dir, ':t')
  end
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `root_markers` | `string[]` | `{ '.git' }` | Files/directories that indicate project root |
| `extractor` | `function` | `default_extractor` | Function to extract project type from root directory path |

### Custom Configuration Examples

#### Multiple Root Markers

```lua
require('ptplugin').setup({
  root_markers = { '.git', 'package.json', 'Cargo.toml', 'pyproject.toml' }
})
```

#### Custom Project Type Extractor

```lua
require('ptplugin').setup({
  extractor = function(root_dir)
    -- Use the last two directory components
    local parts = vim.split(root_dir, '/')
    return table.concat({ parts[#parts-1], parts[#parts] }, '-')
  end
})
```
