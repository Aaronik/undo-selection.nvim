---@class UndoSelectionModule
local M = {}

-- function that prints a table
local function print_table(t)
  for k, v in pairs(t) do
    if type(v) == "table" then
      vim.api.nvim_command("echo '" .. k .. ": '")
      print_table(v)
    else
      vim.api.nvim_command("echo '" .. k .. ": " .. tostring(v) .. "'")
    end
  end
  vim.api.nvim_command("echo 'Press any key to continue'")
  vim.api.nvim_command("silent! call getchar()")
end

M.undo_selection = function()
  local selection = M.get_visual_selection()
  print_table(selection)
  return selection
end

M.get_visual_selection = function()
  local selection = {}
  selection.start_line = vim.fn.getpos("'<")[2]
  selection.end_line = vim.fn.getpos("'>")[2]
  selection.start_column = vim.fn.getpos("'<")[3]
  selection.end_column = vim.fn.getpos("'>")[3]
  return selection
end

M.find_undo_history_for_selection = function(selection)
  local history = vim.fn['undotree']()
  local lines = {}

  print_table(history)

  for _, change in ipairs(history.entries) do
    if change.lnum >= selection.start_line and change.lnum <= selection.end_line then
      table.insert(lines, change)
    end
  end

  return lines
end

-- M.undo_lines = function(lines)
--   print_table(vim.fn)
--   for _, line in ipairs(lines) do
--     vim.fn['undo'](line)
--   end
-- end

M.undo_lines = function(lines)
  for _, line in ipairs(lines) do
    vim.api.nvim_buf_set_lines(0, line-1, line, false, {})
  end
end

-- * get the visual selection
-- * find the lines from the undo history
-- * undo just those lines

return M
