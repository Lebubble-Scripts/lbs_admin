if Config.EnableDebugMode then
    print("[DEBUG] server/server.lua loaded")
    if Config.Framework == 'qb' then
        print('[DEBUG] QBCore Detected')
    elseif Config.Framework == 'qbx' then 
        print('[DEBUG] QBox Detected')
    else
        print('[DEBUG] No Framework Detected')
    end
end

local QBCore = nil

if Config.Framework == 'qb' or Config.Framework == 'qbx' then 
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('[ERROR] NO FRAMEWORK DETECTED')
end



------------------------------
--CALLBACKS
------------------------------
lib.callback.register('lbs_admin:server:check_permissions', function(src)
    local admin_role = Config.AdminGroup
    local admin_status = IsPlayerAceAllowed(src, admin_role)
    --should double check if they have command access ~_~
    return admin_status or IsPlayerAceAllowed(src, 'command')
end)

lib.callback.register('lbs_admin:server:getPlayerList', function()
    local players = {}
    if Config.Framework == 'qb' then 
        for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
            if Config.EnableDebugMode then
                print(string.format("[DEBUG] Player found: %s [%s]", player.PlayerData.name, player.PlayerData.source))
            end
            table.insert(players, {
                id = player.PlayerData.source,
                name = player.PlayerData.name or 'Unknown'
            })
        end
        if Config.EnableDebugMode then
            print('[DEBUG] Sending player list with ' .. #players .. ' players')
        end
    elseif Config.Framework == 'qbx' then
        for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
            if Config.EnableDebugMode then
                print(string.format("[DEBUG] Player found: %s [%s]", player.PlayerData.name, player.PlayerData.source))
            end
            table.insert(players, {
                id = player.PlayerData.source, 
                name = player.PlayerData.name or 'Unknown'
            })
        end
        if Config.EnableDebugMode then
            print('[DEBUG] Sending player list with ' .. #players .. ' players')
        end
    else 
        print('No Framework Found!')
    end

    return players

end)



------------------------------
--Events
------------------------------

---@param action string: specific actin taken on player modal
---@param target number: target player action should be executed on
---@param reason?  string: for bans/kicks - reason player was banned/kicked
---@param duration? string: for bans/kicks - duration of ban/kick
---@param durationUnit? string: for bans/kick - allows us to convert whatever choice of unit they chose into seconds for the DropPlayer() native. 
RegisterNetEvent('lbs_admin:server:player_action', function(action, target, reason, duration, durationUnit)
    if not target then return end 

    if action == 'ban' then
        local admin = GetPlayerName(source)
        local player = GetPlayerName(target)
        --log to discord
        if TriggerEvent('lbs_admin:server:check_permissions', source) then
            print('time before manipulation')
            print(duration)
            print(durationUnit)
            if durationUnit == 's' then
                duration = tonumber(duration)
            elseif durationUnit == 'm' then
                duration = tonumber(duration) * 60
            elseif durationUnit == 'h' then
                duration = tonumber(duration) * 60 * 60
            elseif durationUnit == 'd' then 
                duration = tonumber(duration) * 24 * 60 * 60
            elseif durationUnit == 'M' then
                -- Months: approximated by multiplying 30 days.
                duration = tonumber(duration) * 30 * 24 * 60 * 60
            elseif durationUnit == 'y' then
                duration = tonumber(duration) * 365 * 24 * 60 * 60
            elseif durationUnit == 'p' then
                duration = 2147483647
            end
            print('time after manipulation')
            print(duration)
            local banTime = tonumber(os.time() + duration)
            if banTime > 2147483647 then
                banTime = 2147483647
            end
            local timeTable = os.date('*t', banTime)
            print(reason .. '\n' .. timeTable['month'] .. '/' .. timeTable['day'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. '\nCheck our Discord for more information.')
        end
    end
end)


RegisterNetEvent('lbs_admin:server:teleport_marker', function()
    local src = source
    if Config.Framework == 'qb' or Config.Framework == 'qbx' then
        TriggerClientEvent('QBCore:Command:GoToMarker', src)
        --local admin = GetPlayerName(src)
        --discord log here
    end
end)