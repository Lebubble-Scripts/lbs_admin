--------------------
-- Variables
--------------------
local isSpectating = false
local lastSpectateCoord = nil
local imgurClientId = Config.ImgurAPIClientKey
local utils = require('shared/utils')
--------------------
-- Functions
--------------------
local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  utils.SendReactMessage('setVisible', shouldShow)
end

local function toggleNuiReportsFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  utils.SendReactMessage('reportMenu', shouldShow)
end

--------------------
-- Commands
--------------------
RegisterCommand('adminmenu', function()
  lib.callback('lbs_admin:server:isAdmin', false, function(isAdmin)
    if isAdmin then
      toggleNuiFrame(true)
      utils.debugPrint('Show NUI frame')
    else
      TriggerEvent('ox_lib:notify', {
        title='Access Denied',
        description='you are not an admin',
        type='error'
      })
    end
  end, true)
end, false)

RegisterCommand('reportmenu', function()
  lib.callback('lbs_admin:server:checkPlayerReports', false, function(hasReport)
    if hasReport then
      TriggerEvent('ox_lib:notify', {
        title='Reports',
        description = 'You already have an open report.',
        type='info'
      })
    else
      toggleNuiReportsFrame(true)
    end
  end, true)
end, false)

-------------------
-- Key Mappings
-------------------
RegisterKeyMapping('reportmenu', 'Open Report Menu', 'keyboard', 'F10')

RegisterKeyMapping('adminmenu', 'Open Admin Menu', 'keyboard', 'F3')
--------------------
-- EVENTS
--------------------
RegisterNetEvent('openmenu', function()
    toggleNuiFrame(true)
    utils.debugPrint('Show NUI Frame')
end)

RegisterNetEvent('lbs_admin:client:teleport_to_coords', function(coords)
  local ped = PlayerPedId()

  SetEntityCoords(ped, coords.x, coords.y, coords.z + 1.0)
end)

RegisterNetEvent('lbs_admin:client:spectate', function(targetPed)
  TriggerServerEvent('lbs_admin:server:isAdmin', function(isAdmin)
    if not isAdmin then return end
    local myPed = PlayerPedId()
    local targetPlayer = GetPlayerFromServerId(targetPed)
    local target = GetPlayerPed(targetPlayer)
    if not isSpectating then
      isSpectating = true
      SetEntityVisible(myPed, false)
      SetEntityCollision(myPed, false, false)
      SetEntityInvincible(myPed, true)
      NetworkSetEntityInvisibleToNetwork(myPed, true)
      lastSpectateCoord = GetEntityCoords(myPed)
      NetworkSetInSpectatorMode(true, target)
    else
      isSpectating = false
      NetworkSetInSpectatorMode(false, target)
      NetworkSetEntityInvisibleToNetwork(myPed, false)
      SetEntityCollision(myPed, true, true)
      SetEntityCoords(myPed, lastSpectateCoord)
      SetEntityVisible(myPed, true)
      SetEntityInvincible(myPed, false)
      lastSpectateCoord = nil
    end
  end)
end)

--------------------
--CALLBACKS
--------------------

RegisterNUICallback('unbanPlayer', function(data, cb)
  local banId = data.id
  TriggerServerEvent('lbs_admin:server:unbanPlayer', banId)
end)

RegisterNUICallback('hideAdminMenu', function(_, cb)
  toggleNuiFrame(false)
  utils.debugPrint('Hide NUI frame')
  cb({})
end)

RegisterNUICallback('hideReportMenu', function(_, cb)
  toggleNuiReportsFrame(false)
  utils.debugPrint('Hide Report Menu')
  cb({})
end)

RegisterNUICallback('hasPermissions', function(data, cb)
  local hasPerms = lib.callback.await('lbs_admin:server:checkPermission', false, data.action)
  if not hasPerms then 
    lib.notify({
      title = 'Access Denied',
      description = 'You do not have permission to perform this action.',
      type = 'error'
    })
  end
  cb({isAllowed = hasPerms})
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local model = data.model
    if not model then return end

    local isAllowed = lib.callback.await('lbs_admin:server:isAdmin', false)
    if not isAllowed then
      TriggerEvent('ox_lib:notify', {
        title='Access Denied',
        description='You do not have permission to spawn vehicles.',
        type='error'
      })
      return
    end

    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then 
      print('Invalid vehicle model', model)
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
      Wait(0)
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    if IsPedInAnyVehicle(playerPed, true) then 
      DeleteEntity(GetVehiclePedIsIn(playerPed, false))
    end
    
    local vehicle = CreateVehicle(model, playerCoords.x, playerCoords.y, playerCoords.z, GetEntityHeading(playerPed), true, false)

    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

    SetModelAsNoLongerNeeded(model)

    toggleNuiFrame(false)
    

    TriggerEvent('ox_lib:notify', {
      title='Vehicle Spawned',
      decsription='Vehicle has been spawned!',
      type='success'
    })

    cb({})
end)

RegisterNUICallback('getPlayerList', function(_, cb)
  lib.callback('lbs_admin:server:getPlayerList', false, function(players)
    cb(players)
  end)
end)

RegisterNUICallback('submitReport', function(data)
  print(data.message)
  TriggerServerEvent('lbs_admin:server:submitReport', data.message)
  toggleNuiReportsFrame(false)
end)


RegisterNUICallback('getReportList', function(_, cb)
  lib.callback('lbs_admin:server:getReportList', false, function(reports)
    cb(reports)
  end)
end)

RegisterNUICallback('getBansList', function(_, cb)
  lib.callback('lbs_admin:server:getBansList', false, function(bans)
    cb(bans)
  end)
end)

RegisterNUICallback('getVehiclesList', function(_,cb)
    local vehicles = {}
    local vehicleList = GetGamePool('CVehicle')

    for i = 1, #vehicleList do
        local vehicleModel = GetEntityModel(vehicleList[i])
        if vehicleModel then
            local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
            table.insert(vehicles, {
                model = vehicleModel,
                name = vehicleName
            })
        else
            print("Invalid vehicle model for entity:", vehicleList[i])
        end
    end
    cb(vehicles)
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

RegisterNUICallback('report_action', function(data, cb)
  local action = data.action
  local target = data.target
  TriggerServerEvent('lbs_admin:server:report_action', action, target)
  cb({})
end)