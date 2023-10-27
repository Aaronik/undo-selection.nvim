---@diagnostic disable: undefined-global

-- TODO get global vim type hints

describe("Undo Selection", function()
  local undo_selection = require("../lua/undo_selection")

  it("returns a table with the current visual selection", function()
    -- Simulate a user making a visual selection
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {"This is a test", "Another line", "Yet another line"})
    vim.api.nvim_feedkeys('ggVG', 'n', false)

    local selection = undo_selection.undo_selection()
    assert.same({start_line = 0, end_line = 2, start_column = 0, end_column = 0}, selection)
  end)
end)
