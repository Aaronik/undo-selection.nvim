---@class CustomModule
local M = {}

-- function that prints a table
local function print_table(t)
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(k .. ": ")
      print_table(v)
    else
      print(k .. ": " .. tostring(v))
    end
  end
end

M.get_visual_selection = function()
  local selection = {}
  selection.start_line = vim.fn.getpos("'<")[2]
  selection.end_line = vim.fn.getpos("'>")[2]
  selection.start_column = vim.fn.getpos("'<")[3]
  selection.end_column = vim.fn.getpos("'>")[3]
  return selection
end

M.undo_selection = function()
  local selection = M.get_visual_selection()
  print_table(selection)
  return selection
end

M.find_undo_history_for_selection = function(selection)
  local history = vim.fn['undotree']()
  local relevant_history = {}

  for _, change in ipairs(history.entries) do
    if change.lnum >= selection.start_line and change.lnum <= selection.end_line then
      table.insert(relevant_history, change)
    end
  end

  return relevant_history
end

return M
