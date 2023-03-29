-- Define the loading sign function with a stop condition
local function show_loading_sign(stop_condition)
  local bufnr = vim.api.nvim_get_current_buf()
  local line = math.floor(vim.api.nvim_win_get_height(0) / 2)
  local col = math.floor(vim.api.nvim_win_get_width(0) / 2)
  local spinner = {"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"} -- {"▖", "▘", "▝", "▗"}

  local i = 1
  local timer = vim.loop.new_timer()
  timer:start(100, 100, vim.schedule_wrap(function()
    local text = string.rep(" ", col-1) .. spinner[i] .. string.rep(" ", vim.api.nvim_win_get_width(0)-col)
    vim.api.nvim_buf_set_virtual_text(bufnr, -1, line, {{text, "CursorLine"}}, {})
    i = (i % #spinner) + 1

    if stop_condition() then
      timer:stop()
      vim.api.nvim_buf_clear_namespace(bufnr, 0, -1)
    end
  end))
end

-- Call the loading sign function with a stop condition
local is_loading = true
show_loading_sign(function() return not is_loading end)

-- Do some long-running task that sets is_loading to false when done
-- is_loading = false

