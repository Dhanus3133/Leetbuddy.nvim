local curl = require("plenary.curl")
local sep = require("plenary.path").path.sep
local config = require("leetbuddy.config")
local headers = require("leetbuddy.headers")
local utils = require("leetbuddy.utils")
local split = require("leetbuddy.split")

local M = {}

local function show_daily_problem(problem)
	local question_slug = string.format("%04d-%s", problem["frontendQuestionId"], problem["titleSlug"])

	if not utils.find_file_inside_folder(config.directory, question_slug) then
		vim.api.nvim_command(":silent !mkdir " .. config.directory .. sep .. question_slug)
	end

	local file = config.directory .. sep .. question_slug .. sep .. question_slug .. "." .. config.language
	local input = config.directory .. sep .. question_slug .. sep .. "input" .. "." .. "txt"

	local qfound = utils.find_file_inside_folder(
		config.directory .. sep .. question_slug,
		question_slug .. "." .. config.language
	)

	if split.get_results_buffer() then
		vim.api.nvim_command("LBClose")
	end

	if not qfound then
		vim.api.nvim_command(":silent !touch " .. file)
		vim.api.nvim_command(":silent !touch " .. input)
		vim.api.nvim_command("edit! " .. file)
		vim.api.nvim_command("LBReset")
	else
		vim.api.nvim_command("edit! " .. file)
	end
	vim.api.nvim_command("LBSplit")
	vim.api.nvim_command("LBQuestion")
end

function M.getDailyQuestion()
	local query = [[
        query questionOfToday {
          todayRecord {
            date
            userStatus
            question {
              questionId
              frontendQuestionId: questionFrontendId
              difficulty
              title
              titleCn: translatedTitle
              titleSlug
              paidOnly: isPaidOnly
              freqBar
              isFavor
              acRate
              status
              solutionNum
              hasVideoSolution
              topicTags {
                name
                nameTranslated: translatedName
                id
              }
              extra {
                topCompanyTags {
                  imgUrl
                  slug
                  numSubscribed
                }
              }
            }
            lastSubmission {
              id
            }
          }
        }
    ]]
	local response = curl.post(config.graphql_endpoint, {
		headers = headers,
		body = vim.json.encode({ operationName = "questionOfToday", query = query, variables = {} }),
	})
	local todayRecord = vim.json.decode(response["body"])["data"]["todayRecord"]

	if todayRecord ~= vim.NIL and todayRecord[1] ~= vim.NIL then
		if todayRecord[1]["question"] ~= vim.NIL then
			show_daily_problem(todayRecord[1]["question"])
		end
	end
end

return M
