---@class CustomModule
local M = {}

-- function that prints a table
local function print_table(t)
  for k, v in pairs(t) do
    print(k .. ": " .. v)
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

return M
