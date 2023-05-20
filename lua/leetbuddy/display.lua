local M = {}
local utils = require("leetbuddy.utils")

function M.display_results(is_executing, buffer, json_data, method)
  local results = {}

  local function insert(output)
    table.insert(results, output)
  end

  local function insert_table(t)
    for i = 1, #t do
      insert(t[i])
    end
  end

  if is_executing then
    insert("Executing...")
  else
    insert("Results")
    insert("")
    if method == "test" then
      if json_data["run_success"] then
        if json_data["correct_answer"] then
          insert("Passed Cases: " .. json_data["total_testcases"])
          insert("Accepted" .. " ✔️ ")
        else
          insert(
            "Passed Cases: "
              .. json_data["total_correct"]
              .. " / Failed: "
              .. json_data["total_testcases"] - json_data["total_correct"]
          )
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
                insert_table(expected_std)
              end

              if #std > 0 then
                insert("Std Output: ")
                insert_table(std)
              end
              insert("")
            end
          end
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
    else
      -- Submit
      local success = json_data["total_correct"] == json_data["total_testcases"]

      if success then
        insert("Passed Cases: " .. json_data["total_correct"])
        insert("Accepted" .. " ✔️ ")
        insert("")
        insert("Memory: " .. json_data["status_memory"])
        insert("Runtime: " .. json_data["status_runtime"])
      else
        insert(json_data["status_msg"])

        if json_data["run_success"] then
          insert(
            "Total Cases: "
              .. json_data["total_testcases"]
              .. " / Failed: "
              .. json_data["total_testcases"] - json_data["total_correct"]
          )
          insert("")
          insert("Failed Case Input: ")
          insert_table(utils.split_string_to_table(json_data["input"]))
          insert("")
          insert("Expected Output: " .. json_data["expected_output"])
          insert("Output: " .. json_data["code_output"])
          local std = utils.split_string_to_table(json_data["std_output"])
          if #std > 0 then
            insert("Std Output: ")
            insert_table(std)
          end
        else
          insert(json_data["runtime_error"])
        end
      end
    end
  end
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, results)
end

return M
