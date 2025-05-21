-- plugin/class_preview.lua

-- Require the core logic module
local class_preview = require('class_preview')

-- Define the user command
vim.api.nvim_create_user_command(
    'OpenClassDefPreview', -- Command name
    function()
        -- Call the function from our module
        class_preview.open_definition_in_preview()
    end,
    {
        nargs = 0, -- This command takes no arguments
        desc = 'Opens LSP definition preview in a new window' -- Description for the command
    }
)
