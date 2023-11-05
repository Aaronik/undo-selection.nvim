---@class UndoSelectionModule
local M = {}

local util = require('util')

-- Now you can use util.print_table instead of print_table

M.undo_selection = function()
  local selection = M.get_visual_selection()
  print('selection:')
  util.print_table(selection)

  print('ok')
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

  util.print_table(history)

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
