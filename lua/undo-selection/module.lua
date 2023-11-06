---@class UndoSelectionModule
local M = {}

local util = require('util')

-- Now you can use util.print_table instead of print_table

M.undo_selection = function()
  local selection = M.get_visual_selection()
  print('selection:')
  util.print_table(selection)

  local undo_history = M.find_undo_history_for_selection(selection)
  print('undo_history')
  util.print_table(undo_history)
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

  -- This is the kind of thing we get from vim.fn['undotree']().entries
  -- 8:
  --   save: 7
  --   seq: 19
  --   time: 1699231991
  --   newhead: 1
  --   alt:
  --     1:
  --       time: 1699231974
  --       seq: 14
  --     2:
  --       time: 1699231974
  --       seq: 15
  --     3:
  --       time: 1699231974
  --       seq: 16
  --     4:
  --       time: 1699231974
  --       seq: 17
  --     5:
  --       time: 1699231974
  --       seq: 18

  print('history\n')
  util.print_table(history)

  for _, change in ipairs(history.entries) do
    print('change\n')
    util.print_table(change, 2)

    if change.lnum >= selection.start_line and change.lnum <= selection.end_line then
      table.insert(lines, change)
    end
  end

  return lines
end

M.undo_lines = function(lines)
  for _, line in ipairs(lines) do
    vim.api.nvim_buf_set_lines(0, line-1, line, false, {})
  end
end

-- * get the visual selection
-- * find the lines from the undo history
-- * undo just those lines

return M
