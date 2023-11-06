---@class UndoSelectionModule
local M = {}

local util = require('util')

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

  -- history will look like:
  -- seq_cur: 103
  -- save_cur: 36
  -- seq_last: 103
  -- time_cur: 1699232889
  -- save_last: 36
  -- change
  --   time: 1699226596
  --   seq: 1
  --   seq_last: 107
  -- entries:
  --   1:
  --     time: 1699226596
  --     seq: 1
  --   2:
  --     time: 1699226659
  --     seq: 2
  --   3:
  --     time: 1699226715
  --     seq: 3
  --   4:
  --     time: 1699226716
  --     seq: 4
  --     save: 1
  --   5:
  --     time: 1699226726
  --     seq: 5
  --     save: 2
  --   6:
  --     time: 1699226998
  --     seq: 6
  --   7:
  --     time: 1699227000
  --     seq: 7

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
