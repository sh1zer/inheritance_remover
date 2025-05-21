# Neovim Class Definition Preview (Alpha)

A Neovim plugin to quickly preview LSP definitions in a separate window, aiming to reduce the need for excessive go-to-definition hopping.

This is an early version focusing on opening the definition in a new split.

## Installation

You can install this plugin using your favorite Neovim plugin manager.

**Packer.nvim:**
```lua
use 'your-username/class-preview-nvim' -- TODO: Update with actual repository path
```

**vim-plug:**
```vim
Plug 'your-username/class-preview-nvim' " TODO: Update with actual repository path
```

Remember to source your configuration or run the plugin manager's install command.

## Usage

1. Ensure you have an LSP server attached and active for your current buffer (e.g., for Python, `pylsp` or `pyright`; for Lua, `lua_ls`).
2. Place your cursor on a symbol (class name, function name, variable, etc.) for which you want to see the definition.
3. Run the command:
   ```vim
   :OpenClassDefPreview
   ```
   This will open a new vertical split window showing the definition of the symbol. The preview will show approximately 10 lines from the definition's location.

## Features (Current)
*   Opens the LSP definition of a symbol in a new vertical preview window.
*   Uses a scratch buffer for the preview (no file modifications, easy to close).
*   Sets the filetype of the preview window to match the source file.

## Future Ideas
(This section is for potential future enhancements)
-   Configuration for preview window type (vertical split, horizontal split, floating window).
-   Option to control the number of lines displayed in the preview.
-   Smarter context extraction (e.g., whole function body, class definition).
-   Keymapping for easier access.
-   Highlighting the exact definition range within the preview.
