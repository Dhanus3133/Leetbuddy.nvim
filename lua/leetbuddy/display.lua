local M = {}
local utils = require("leetbuddy.utils")
local is_cn = require("leetbuddy.config").domain == "cn"

local cn = {
  exe = "执行中",
  res = "结果",
  pc = "通过案例数",
  acc = "公认",
  testc = "测试用例",
  totc = "案件总数",
  out = "输出",
  exp = "预期的",
  stdo = "标准输出",
  mem = "内存消耗",
  rt = "执行用时",
  r_err = "执行出错",
  tl_err = "超出时间限制",
  wrong_ans_err = "錯誤的答案",
  failed = "失败的",
  f_case_in = "失败案例输入",
  exp_out = "预期产出",
}

M.cn = cn

function get_status_msg(msg)
  if not is_cn then
    return msg
  end
  if msg == "Accepted" then
    return cn["acc"]
  elseif msg == "Runtime Error" then
    return cn["r_err"]
  elseif msg == "Time Limit Exceeded" then
    return cn["tl_err"]
  elseif msg == "Wrong Answer" then
    return cn["wrong_ans_err"]
  else
    return msg
  end
end

function M.display_results(is_executing, buffer, json_data, method, input_path)
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
    insert((is_cn and cn["exe"] or "Executing") .. "...")
  else
    insert(is_cn and cn["res"] or "Results")
    insert("")
    if method == "test" then
      if json_data["run_success"] then
        if json_data["correct_answer"] then
          insert((is_cn and cn["pc"] or "Passed Cases") .. ": " .. json_data["total_testcases"])
          insert((is_cn and cn["acc"] or "Accepted") .. " ✔️ ")
        else
          insert(
            (is_cn and cn["pc"] or "Passed Cases")
              .. ": "
              .. json_data["total_correct"]
              .. " / "
              .. (is_cn and cn["failed"] or "Failed")
              .. ": "
              .. json_data["total_testcases"] - json_data["total_correct"]
          )
          insert("")
          for i = 1, json_data["total_testcases"] do
            if json_data["code_answer"][i] ~= json_data["expected_code_answer"][i] then
              insert((is_cn and cn["testc"] or "Test Case") .. ": #" .. i .. " ❌ ")
              insert((is_cn and cn["out"] or "Output") .. ": " .. json_data["code_answer"][i])
              insert((is_cn and cn["exp"] or "Expected") .. ": " .. json_data["expected_code_answer"][i])
              local std = utils.split_string_to_table(json_data["std_output_list"][i])

              if #std > 0 then
                insert((is_cn and cn["stdo"] or "Std Output") .. ": ")
                insert_table(std)
              end
              insert("")
            end
          end
          insert("")
          for i = 1, json_data["total_testcases"] do
            if json_data["code_answer"][i] == json_data["expected_code_answer"][i] then
              insert(
                (is_cn and cn["testc"] or "Test Case")
                  .. ": #"
                  .. i
                  .. ": "
                  .. json_data["code_answer"][i]
                  .. " ✔️ "
              )
            end
          end
        end
        insert("")
        insert((is_cn and cn["mem"] or "Memory") .. ": " .. json_data["status_memory"])
        insert((is_cn and cn["rt"] or "Runtime") .. ": " .. json_data["status_runtime"])
      else
        insert(get_status_msg(json_data["status_msg"]))
        insert(json_data["runtime_error"])
        insert("")

        local std_output = json_data["std_output_list"]
        insert((is_cn and cn["testc"] or "Test Case") .. ": #" .. #std_output .. " ❌ ")

        local std = utils.split_string_to_table(std_output[#std_output])

        if #std > 0 then
          insert((is_cn and cn["stdo"] or "Std Output") .. ": ")
          insert_table(std)
        end
      end
      insert("")
    else
      -- Submit
      local success = json_data["total_correct"] == json_data["total_testcases"]

      if success then
        insert((is_cn and cn["pc"] or "Passed Cases") .. ": " .. json_data["total_correct"])
        insert((is_cn and cn["acc"] or "Accepted") .. " ✔️ ")
        insert("")
        insert((is_cn and cn["mem"] or "Memory") .. ": " .. json_data["status_memory"])
        insert((is_cn and cn["rt"] or "Runtime") .. ": " .. json_data["status_runtime"])
      else
        P(json_data)
        insert(get_status_msg(json_data["status_msg"]))

        if json_data["run_success"] then
          insert(
            (is_cn and cn["totc"] or "Total Cases")
              .. ": "
              .. json_data["total_testcases"]
              .. " / "
              .. (is_cn and cn["failed"] or "Failed")
              .. ": "
              .. json_data["total_testcases"] - json_data["total_correct"]
          )
          insert("")
        else
          insert(json_data["runtime_error"])
          insert("")
        end
        insert((is_cn and cn["f_case_in"] or "Failed Case Input") .. ": ")
        insert_table(utils.split_string_to_table(json_data["last_testcase"]))

        -- Add failed testcase to input.txt
        -- if input_path ~= nil then
        --   local input_file = io.open(input_path, "r")
        --   local fileContent = input_file:read("*a")
        --   input_file:close()
        --
        --   if not string.find(fileContent, json_data["last_testcase"]) then
        --     -- Append the string to the end of the file
        --     input_file = io.open(input_path, "a")
        --     input_file:write(json_data["last_testcase"])
        --     input_file:close()
        --     print(json_data["last_testcase"] .. " added to the test inputs")
        --   end
        -- end

        insert("")
        insert((is_cn and cn["exp_out"] or "Expected Output") .. ": " .. json_data["expected_output"])
        insert((is_cn and cn["out"] or "Output") .. ": " .. json_data["code_output"])

        local std = utils.split_string_to_table(json_data["std_output"])
        if #std > 0 then
          insert((is_cn and cn["stdo"] or "Std Output") .. ": ")
          insert_table(std)
        end
      end
    end
  end
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, results)
end

return M
