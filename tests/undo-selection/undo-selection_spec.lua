-- local undo_selection = require("../lua/undo-selection")
local vim = vim -- TODO Get this to provide type feedback
local assert = require("luassert")

---@diagnostic disable: undefined-global

-- function that prints a table
local function print_table(t)
  for k, v in pairs(t) do
    print(k .. ": " .. v)
  end
end

describe("get_visual_selection", function()
  it("returns a table with the current visual selection", function()
    -- Add some text to the buffer
    vim.api.nvim_exec([[ call append(0, ["Nonsense text 1", "Nonsense text 2"]) ]], false)

    -- Ensure that text was added
    local current_buffer_contents = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert.same({ [1] = "Nonsense text 1", [2] = "Nonsense text 2", [3] = "" }, current_buffer_contents)

    -- Select all the text in the buffer
    -- vim.cmd([[ normal! ggVG ]], false)
    vim.api.nvim_input('ggVG')

    -- Delay to ensure the selection is registered
    vim.api.nvim_command('sleep 100m')

    -- Ensure get_visual_selection is getting the whole selection
    local selection = require("../lua/undo-selection/module").get_visual_selection()
    assert.same({ start_line = 0, end_line = 2, start_column = 0, end_column = 15 }, selection)
  end)
end)
