-- Utility functions
local M = {}

-- function that prints a table
function M.print_table(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    if type(v) == "table" then
      vim.api.nvim_command("echo '" .. string.rep(" ", indent) .. k .. ": '")
      M.print_table(v, indent + 2)
    else
      vim.api.nvim_command("echo '" .. string.rep(" ", indent) .. k .. ": " .. tostring(v) .. "'")
    end
  end
end

return M
