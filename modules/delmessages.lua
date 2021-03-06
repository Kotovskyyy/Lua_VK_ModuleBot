local config = ...

if not config.delete then addToConfig('delete', nil, {}) end

local deleteTrigger = config.delete.trigger or addToConfig('delete', 'trigger', 'ой')
local deleteTriggerAll = config.delete.triggerAll or addToConfig('delete', 'triggerAll', '/delall')
local deleteEditTo = config.delete.editTo or addToConfig('delete', 'editTo', 'ᅠ')

local obj = {}

-- Main function

function obj.func(msg)
  if(msg.out and (msg.body:lower():find('^' .. deleteTrigger ..'([%-0-9]*)$') or msg.body:lower():find('^' .. deleteTriggerAll ..'([%-0-9]*)$'))) then
    local res, num, isEdit, i = vk.call('messages.getHistory', { peer_id = msg.peer_id, count = 150 }, true), nil, 'false', 1
    if res.items == nil or res.count == 0 then return end

    if msg.body:lower():find('^' .. deleteTriggerAll .. '([%-0-9]*)$') then num = 150
    else num = msg.body:lower():match('^' .. deleteTrigger .. '([%-0-9]+)$') end
    num = tonumber(num == '-' and -1 or num) or 1

    if num < 0 then isEdit = 'true' num = num * -1 end

    local idsToDel = {tonumber(msg.id)}
    while(#idsToDel <= num + 1 and i <= #res.items) do
      if res.items[i].out == 1 then table.insert(idsToDel, res.items[i].id) end
      i = i + 1
    end
    idsToDel = table.concat(idsToDel, ',')

    if isEdit == 'true' then
      local code = [[ var arr = [%s], i = 1; while(i < arr.length) { if(arr[i] != %s) API.messages.edit({ peer_id: %s, message_id: arr[i], message: '%s' }); i = i + 1; } ]]
      code = code:format(idsToDel, msg.id, msg.peer_id, deleteEditTo);

      vk.call('execute', { code = code })
    end

    vk.call('messages.delete', { delete_for_all = '1', message_ids = idsToDel })
  end
end

return obj
