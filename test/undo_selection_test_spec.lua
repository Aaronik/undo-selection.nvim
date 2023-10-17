describe("Undo Selection", function()
  local undo_selection = require("../lua/undo_selection")

  it("loads the method", function()
    -- Arrange
    local expected_result = "basic working"

    -- Act
    local result = undo_selection.undo_selection()

    -- Assert
    assert.are.equal(expected_result, result)
  end)
end)

