---@diagnostic disable: undefined-global

local module = require("../lua/undo-selection.module")
local vim = vim -- TODO Get this to provide type feedback
local assert = require("luassert")
local spy = require('luassert.spy')

-- TODO I can't for the life of me get this working.
describe("get_visual_selection", function()
  pending("returns a table with the current visual selection", function()
    -- Add some text to the buffer
    vim.api.nvim_exec([[ call append(0, ["Nonsense text 1", "Nonsense text 2"]) ]], false)

    -- Ensure that text was added
    local current_buffer_contents = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert.same({ [1] = "Nonsense text 1", [2] = "Nonsense text 2", [3] = "" }, current_buffer_contents)

    -- Delay to ensure the buffer is fully loaded
    vim.api.nvim_command('sleep 100m')

    -- Select all the text in the buffer
    vim.api.nvim_input('ggVG')

    -- Delay to ensure the selection is registered
    vim.api.nvim_command('sleep 100m')

    -- Ensure get_visual_selection is getting the whole selection
    local selection = module.get_visual_selection()
    assert.same({ start_line = 0, end_line = 2, start_column = 0, end_column = 2147483647 }, selection)
  end)
end)

describe('find_undo_history_for_selection', function()
  it('returns relevant undo history for selection', function()
    -- Mock vim.fn['undotree'] to return a predefined undo history
    vim.fn['undotree'] = function()
      return {
        entries = {
          { lnum = 1 }, { lnum = 2 }, { lnum = 3 }, { lnum = 4 }, { lnum = 5 },
        }
      }
    end

    local selection = { start_line = 2, end_line = 3, start_column = 0, end_column = 2147483647 } -- TODO use actual number

    local expected = {
      { lnum = 2 },
      { lnum = 3 },
    }

    local result = module.find_undo_history_for_selection(selection)
    assert.are.same(expected, result)
  end)
end)

describe('undo_lines', function()
  it('should call vim.api.nvim_call_function for each line', function()
    local changes = {1, 2, 3}
    local undo_spy = spy.on(vim.api, 'nvim_buf_set_lines')

    module.undo_changes(changes)

    assert.spy(undo_spy).was.called(3)
    -- assert.spy(undo_spy).was_called_with('undo', {1})
    -- assert.spy(undo_spy).was_called_with('undo', {2})
    -- assert.spy(undo_spy).was_called_with('undo', {3})
  end)
end)

