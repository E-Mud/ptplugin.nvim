# AGENTS.md - Neovim Plugin Development Guide

## Build/Test Commands
- `make test` - Run all tests using plenary.nvim and busted
- `stylua --check lua` - Check Lua formatting
- `stylua lua` - Format Lua files
- Tests use spec files in `spec/` directory with `describe()` and `it()` functions

## Code Style Guidelines

### Formatting (StyLua configuration)
- 2 spaces indentation
- 120 column width
- Double quotes preferred
- Unix line endings
- No call parentheses disabled

### Lua Conventions
- Use LuaCATS annotations
- Module pattern: return table with setup function

### Error Handling
- Use `vim.tbl_deep_extend('force', defaults, user_opts)` for config merging
- Check for nil values: `if path == nil then return nil end`

### Imports
- Standard pattern: `local fn = vim.fn`, `local fs = vim.fs`, `local api = vim.api`
- Group vim namespace imports together
