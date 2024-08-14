local source = {}

source.new = function()
  return setmetatable({}, { __index = source })
end

source.get_trigger_characters = function()
  return { '{', ':' }
end

local function get_norg_files()
  local files = {}
  local handle = io.popen 'ls *.norg 2>/dev/null'
  if handle then
    for file in handle:lines() do
      files[#files + 1] = file:gsub('%.norg$', '')
    end
    handle:close()
  end
  return files
end

source.complete = function(self, request, callback)
  local input = request.context.cursor_before_line or ''
  local trigger = '{:'
  if #input >= #trigger and string.sub(input, -#trigger) == trigger then
    local norg_files = get_norg_files()
    local items = {}
    for _, file in ipairs(norg_files) do
      items[#items + 1] = {
        label = file,
        insertText = file .. ':}',
        kind = require('cmp').lsp.CompletionItemKind.Text,
      }
    end
    callback {
      items = items,
      isIncomplete = false,
    }
  elseif string.sub(input, -1) == '{' then
    callback {
      items = {},
      isIncomplete = true,
    }
  else
    callback { items = {}, isIncomplete = true }
  end
end

return source
