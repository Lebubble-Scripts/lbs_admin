local utils = {}

local roles = {
  god = 'lbs_admin.god',
  admin = 'lbs_admin.admin',
  manager = 'lbs_admin.manager',
  helper = 'lbs_admin.helper'
}

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

function utils.debugPrint(...)
  if not Config.EnableDebugMode then return end
  local args <const> = { ... }

  local appendStr = ''
  for _, v in ipairs(args) do
    appendStr = appendStr .. ' ' .. tostring(v)
  end
  local msgTemplate = '^3[%s]^0%s'
  local finalMsg = msgTemplate:format('[DEBUG]', appendStr)
  print(finalMsg)
end

return utils

