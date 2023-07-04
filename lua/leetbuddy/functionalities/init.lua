local change_language = require("leetbuddy.functionalities.change_language")

vim.api.nvim_create_user_command("LBChangeLanguage", function(args)
  change_language.main(args)
end, {
  nargs = 1,
  complete = function(ArgLead)
    local langauges = change_language.get_languages()
    local filtered_languages = {}
    for _, completion in ipairs(langauges) do
      if string.find(completion, ArgLead) == 1 then
        table.insert(filtered_languages, completion)
      end
    end
    return filtered_languages
  end,
})
