local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  SendReactMessage('setVisible', shouldShow)
end

-- Commands
RegisterCommand('adminmenu', function()
  lib.callback('lbs_admin:server:check_permissions', false, function(isAdmin)
    if isAdmin then
      toggleNuiFrame(true)
      debugPrint('Show NUI frame')
    else
      TriggerEvent('ox_lib:notify', {
        title='Access Denied',
        description='you are not an admin',
        type='error'
      })
    end
  end, true)

 
  
end, true)



-- Callbacks
RegisterNUICallback('hideFrame', function(_, cb)
  toggleNuiFrame(false)
  debugPrint('Hide NUI frame')
  cb({})
end)


RegisterNUICallback('getPlayerList', function(_, cb)
  lib.callback('lbs_admin:server:getPlayerList', false, function(players)
    cb(players)
  end)
end)


--Admin Options Buttons
RegisterNUICallback('heal_self', function(_, cb)
  local ped = PlayerPedId()
  SetEntityHealth(ped, GetEntityMaxHealth(ped))
  SetPedArmour(ped,100)
  --log to discord here

  TriggerEvent('ox_lib:notify',{
    title='Admin Action',
    description = 'You\'ve been healed',
    type='success'
  })

  cb({})
end)

RegisterNuiCallback('revive_self', function(_, cb)
  if Config.Framework == 'qb' then
    TriggerEvent('hospital:client:Revive', PlayerPedId())
  elseif Config.Framework == 'qbx' then
    TriggerEvent('qbx_medical:client:playerRevived', PlayerPedId())
  end
  --log to discord here
  TriggerEvent('ox_lib:notify',{
    title='Admin Action',
    description='You\'ve been revived',
    type='success'
  })
  cb({})
end)

RegisterNUICallback('get_vec3', function(_,cb)
  local ped = PlayerPedId()
  local coords = GetEntityCoords(ped)
  cb({ x=coords.x, y=coords.y, z=coords.z })
  TriggerEvent('ox_lib:notify',{
    title='Copied',
    desription='vec3 coords copied',
    type='success'
  })
end)

RegisterNUICallback('get_vec4', function(_,cb)
  local ped = PlayerPedId()
  local coords = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)
  cb({ x=coords.x, y=coords.y, z=coords.z, w=heading })
  TriggerEvent('ox_lib:notify',{
    title='Copied',
    desription='vec4 coords copied',
    type='success'
  })
end)


RegisterNUICallback('get_heading', function(_, cb)
  local ped = PlayerPedId()
  local heading = GetEntityHeading(ped)
  cb({heading = heading})
  TriggerEvent('ox_lib:notify', {
    title= 'Copied',
    description='heading copied',
    type='success'
  })
end)

RegisterNUICallback('teleport_to_marker', function(_,cb)
  TriggerServerEvent('lbs_admin:server:teleport_marker')
  cb({})
end)

-- Player Management Buttons
---@param action action associated with pressed button
---@param target id of target player action has been requested for
RegisterNUICallback('player_action', function(data, cb)
  local action = data.action 
  local target = data.target
  local reason = data.reason
  local duration = data.duration
  local durationUnit = data.durationUnit
  TriggerServerEvent('lbs_admin:server:player_action', action, target, reason, duration, durationUnit)
  cb({})
end)