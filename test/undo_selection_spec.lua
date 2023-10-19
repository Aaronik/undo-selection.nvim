---@diagnostic disable: undefined-global

describe("Undo Selection", function()
  local undo_selection = require("../lua/undo_selection")

  it("returns a table with the current visual selection", function()
    local selection = undo_selection.undo_selection()
    assert.same({start_line = 0, end_line = 0, start_column = 0, end_column = 0}, selection)
  end)
end)
