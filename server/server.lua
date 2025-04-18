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