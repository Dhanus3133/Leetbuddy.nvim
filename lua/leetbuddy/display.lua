local M = {}
local utils = require("leetbuddy.utils")

function M.display_results(json_data, buffer, method)
  local results = {}

  local function insert(output)
    table.insert(results, output)
  end

  insert("Results")
  insert("")
  if json_data["run_success"] then
    if json_data["correct_answer"] then
      insert("Passed Cases: " .. json_data["total_correct"])
      insert("Accepted" .. " ✔️ ")
    else
      insert("Failed Cases: " .. json_data["total_testcases"] - json_data["total_correct"])
      insert("")
      for i = 1, json_data["total_testcases"] do
        if json_data["code_answer"][i] ~= json_data["expected_code_answer"][i] then
          insert("Test Case: #" .. i .. " ❌ ")
          insert("Expected: " .. json_data["expected_code_answer"][i])
          insert("Output: " .. json_data["code_answer"][i])
          local std = utils.split_string_to_table(json_data["std_output"][i])
          local expected_std = utils.split_string_to_table(json_data["expected_std_output"][i])

          if #expected_std > 0 then
            insert("Expected Std Output: ")
            for j = 1, #expected_std do
              insert(expected_std[j])
            end
          end

          if #std > 0 then
            insert("Std Output: ")
            for j = 1, #std do
              insert(std[j])
            end
          end
          insert("")
        end
      end
      insert("Passed Cases: " .. json_data["total_correct"])
      insert("")
      for i = 1, json_data["total_testcases"] do
        if json_data["code_answer"][i] == json_data["expected_code_answer"][i] then
          insert("Test Case: #" .. i .. ": " .. json_data["code_answer"][i] .. " ✔️ ")
        end
      end
    end
    insert("")
    insert("Memory: " .. json_data["status_memory"])
    insert("Runtime: " .. json_data["status_runtime"])
  else
    insert(json_data["status_msg"])
    insert(json_data["runtime_error"])
  end
  insert("")
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, results)
end

return M
