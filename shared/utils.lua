local utils = {}


--- A simple wrapper around SendNUIMessage that you can use to
--- dispatch actions to the React frame.
---
---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function utils.SendReactMessage(action, data)
  SendNUIMessage({
    action = action,
    data = data
  })
end

local currentResourceName = GetCurrentResourceName()

local debugIsEnabled = GetConvarInt(('%s-debugMode'):format(currentResourceName), 0) == 1

--- A simple debug print function that is dependent on a convar
--- will output a nice prettfied message if debugMode is on
function utils.debugPrint(...)
  if not Config.EnableDebugMode then return end
  local args <const> = { ... }

  local appendStr = ''
  for _, v in ipairs(args) do
    appendStr = appendStr .. ' ' .. tostring(v)
  end
  local msgTemplate = '^5[%s]^7%s'
  local finalMsg = msgTemplate:format('DEBUG', appendStr)
  print(finalMsg)
end

return utils

