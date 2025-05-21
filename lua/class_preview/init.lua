-- lua/class_preview/init.lua
local M = {}

M.open_definition_in_preview = function()
    local source_bufnr = vim.api.nvim_get_current_buf() -- Renamed for clarity
    local clients = vim.lsp.get_active_clients({bufnr = source_bufnr})

    if #clients == 0 then
        print("No active LSP client found for this buffer.")
        return
    end

    local original_win = vim.api.nvim_get_current_win() -- Store original window
    local pos = vim.api.nvim_win_get_cursor(original_win) -- Use original_win

    local params = {
        textDocument = { uri = vim.uri_from_bufnr(source_bufnr) },
        position = { line = pos[1] - 1, character = pos[2] } 
    }

    vim.lsp.buf_request(source_bufnr, 'textDocument/definition', params, function(err, result, ctx, config)
        if err or not result or #result == 0 then
            local err_msg = "Definition not found."
            if err then
                err_msg = "Error fetching definition: " .. vim.inspect(err)
            end
            vim.schedule(function() -- Schedule UI updates to avoid issues
                print(err_msg)
            end)
            return
        end

        local location_item = result[1]
        local definition_uri
        local definition_range

        if location_item.targetUri then -- Likely LocationLink
            definition_uri = location_item.targetUri
            definition_range = location_item.targetSelectionRange or location_item.targetRange
        elseif location_item.uri then -- Likely Location
            definition_uri = location_item.uri
            definition_range = location_item.range
        else
            vim.schedule(function()
                print("Could not determine definition URI or range from LSP result.")
            end)
            return
        end
        
        if not definition_uri or not definition_range then
            vim.schedule(function()
                print("Definition URI or range is missing in the result.")
            end)
            return
        end

        local start_line_0_indexed = definition_range.start.line
        local file_path = vim.uri_to_fname(definition_uri)
        
        if not vim.fn.filereadable(file_path) then
            vim.schedule(function()
                print("Definition file path is not readable: " .. file_path)
            end)
            return
        end
        
        local file_lines = vim.fn.readfile(file_path)
        if file_lines == nil or #file_lines == 0 then -- readfile can return nil on error
            vim.schedule(function()
                print("Could not read definition file or file is empty: " .. file_path)
            end)
            return
        end

        -- Ensure start_line_0_indexed is within bounds (0 to #file_lines - 1)
        if start_line_0_indexed < 0 or start_line_0_indexed >= #file_lines then
            vim.schedule(function()
                print("Definition start line (" .. start_line_0_indexed .. ") is out of bounds for file: " .. file_path .. " (total lines: " .. #file_lines .. ")")
            end)
            return
        end
        
        local end_line_1_indexed = math.min(start_line_0_indexed + 10, #file_lines)
        
        local content_to_display = {}
        -- file_lines is 1-indexed, start_line_0_indexed needs +1 for lua tables
        for i = start_line_0_indexed + 1, end_line_1_indexed do
            table.insert(content_to_display, file_lines[i])
        end

        if #content_to_display == 0 then
            vim.schedule(function()
                print("No content to display for definition.")
            end)
            return
        end

        -- Schedule UI operations to ensure they run on the main thread
        vim.schedule(function()
            -- Preview Window Setup
            local preview_bufnr = vim.api.nvim_create_buf(false, true) -- not listed, scratch
            vim.api.nvim_buf_set_option(preview_bufnr, 'buftype', 'nofile')
            vim.api.nvim_buf_set_option(preview_bufnr, 'bufhidden', 'wipe')
            vim.api.nvim_buf_set_option(preview_bufnr, 'swapfile', false)
            vim.api.nvim_buf_set_option(preview_bufnr, 'readonly', true) -- Set readonly before modifiable false
            vim.api.nvim_buf_set_option(preview_bufnr, 'modifiable', false) 

            local source_ft = vim.bo[source_bufnr].filetype
            if source_ft and source_ft ~= '' then
                vim.api.nvim_buf_set_option(preview_bufnr, 'filetype', source_ft)
            end

            vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, content_to_display)

            vim.api.nvim_set_current_win(original_win)
            vim.cmd('vsplit') 
            local new_win_id = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(new_win_id, preview_bufnr)
            
            -- The content displayed starts from start_line_0_indexed of the original file,
            -- which is line 1 in our preview_bufnr.
            -- So, if we want to position the cursor relative to the definition's start
            -- within the snippet, it would be line 1.
            vim.api.nvim_win_set_cursor(new_win_id, {1, 0}) 
            
            -- Optional: Set preview window specific options
            -- vim.api.nvim_win_set_option(new_win_id, 'number', false)
            -- vim.api.nvim_win_set_option(new_win_id, 'relativenumber', false)
            -- vim.api.nvim_win_set_option(new_win_id, 'foldenable', false)
        end)
    end)
end

return M
