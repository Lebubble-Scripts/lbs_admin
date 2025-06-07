local QBCore = nil;
local playerRoles = {}
local utils = require('shared/utils')

if Config.Framework == 'qbx' then
    print('[LBS_ADMIN] Qbox detected')
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject();
    print('[LBS_ADMIN] QBCore detected')
else   
    print('^1[LBS_ADMIN] No supported framework detected. Ensure qbox or qbcore is running.^7')
end

local permissionsTable = {
    ['lbs_admin.group.helper'] = {"teleport", "spectate", "reports", "warn"},
    ['lbs_admin.group.mod'] = {'teleport', 'spectate',"reports", "warn",'kick'},
    ['lbs_admin.group.administrator'] = {'teleport', 'spectate', "reports","warn", 'kick', 'ban'}
}


------------------------------
-- FUNCTIONS
------------------------------
function send_to_discord_log(title, description, color)
    local webhook = Config.DiscordWebhook
    if (not webhook or webhook == '') then 
        utils.debugPrint("[Discord Log] No webhook URL set!")
        return 
    end
    utils.debugPrint("[Discord Log] Sending to Discord:", title, description)

    local embed = {
        {
            title = title, 
            description = description,
            color = color or 16753920,
            footer = {
                text = 'LBS Admin System'
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers)
        utls.debugPrint("[Discord Log] Response:", err, text)
    end, "POST", json.encode({
        username = 'LBS Admin Logs',
        embeds = embed
    }), {['Content-Type'] = "application/json"})

end

local function hasAdminPermissions(src)
    isAdmin = false 
    if IsPlayerAceAllowed(src, 'lbs_admin.group.administrator') then
        isAdmin = true
    elseif IsPlayerAceAllowed(src, 'lbs_admin.group.mod') then
        isAdmin = true
    elseif IsPlayerAceAllowed(src, 'lbs_admin.group.helper') then
        isAdmin = true
    end
    return isAdmin
    --return IsPlayerAceAllowed(src, 'command')
end



local function getPlayerGroup(src)
    if IsPlayerAceAllowed(src, 'lbs_admin.group.helper') then
        group = 'lbs_admin.group.helper' 
    elseif IsPlayerAceAllowed(src, 'lbs_admin.group.mod') then
        group = 'lbs_admin.group.mod'
    elseif IsPlayerAceAllowed(src, 'lbs_admin.group.administrator') then
        group = 'lbs_admin.group.administrator'
    end
    return group
end

RegisterCommand('checkAdminStatus', function(source, args, rawCommand)
    local src = source
    local group = getPlayerGroup(src)
    print(group)
end, false)

local function hasPermission(src, perm)
    local group = getPlayerGroup(src)
    if not group then return false end 

    for _, v in pairs(permissionsTable[group]) do 
        if v == perm then 
            return true
        end
    end
    return false 
end

local function getBanReason(reason, duration, durationUnit)
    if durationUnit == 's' then
        duration = tonumber(duration)
    elseif durationUnit == 'm' then
        duration = tonumber(duration) * 60
    elseif durationUnit == 'h' then
        duration = tonumber(duration) * 60 * 60
    elseif durationUnit == 'd' then 
        duration = tonumber(duration) * 24 * 60 * 60
    elseif durationUnit == 'M' then
        duration = tonumber(duration) * 30 * 24 * 60 * 60
    elseif durationUnit == 'y' then
        duration = tonumber(duration) * 365 * 24 * 60 * 60
    elseif durationUnit == 'p' then
        duration = 2147483647
    end
    local banTime = tonumber(os.time() + duration)
    if banTime > 2147483647 then
        banTime = 2147483647
    end
    local timeTable = os.date('*t', banTime)
    local discordLink = Config.DiscordLink
    reason = 'You were banned for: ' .. reason .. '\nYou are banned until: ' .. timeTable['month'] .. '/' .. timeTable['day'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] ..  '\nPlease Reread the Server Rules...' .. '\nCheck our Discord for more information: ' .. discordLink ..
    '\n\n'
    return reason, banTime
end

function getIdentifier(source, idtype)
    if GetConvarInt('sv_fxdkMode', 0) == 1 then return 'license:fxdk' end
    return GetPlayerIdentifierByType(source, idtype or 'license')
end

local function deleteBanRecord(identifier)

    local resourceName = GetCurrentResourceName()
    local filePath = 'bans.json'
    local fileContent = LoadResourceFile(resourceName, filePath)

    if not fileContent or fileContent == "" then
        debugPrint("[ERROR] bans.json is empty or could not be read.")
        return
    end


    local success, jsonTable = pcall(function() return json.decode(fileContent) end)
    if not success or type(jsonTable) ~= "table" then
        debugPrint("[ERROR] Failed to parse bans.json. Invalid JSON structure.")
        return
    end


    if jsonTable[identifier] then
        jsonTable[identifier] = nil
        if Config.EnableDebugMode then
            print(" Removed entry for identifier: " .. identifier)
        end
    else
        print("[ERROR] Identifier '" .. identifier .. "' not found in bans.json.")
        return
    end

    local reconstructedContent = "{\n"
    for key, value in pairs(jsonTable) do
        reconstructedContent = reconstructedContent .. string.format('    "%s": %s,\n', key, json.encode(value))
    end

    if reconstructedContent:sub(-2) == ",\n" then
        reconstructedContent = reconstructedContent:sub(1, -3) .. "\n"
    end
    reconstructedContent = reconstructedContent .. "}"

    SaveResourceFile(resourceName, filePath, reconstructedContent, -1)
    return true
end


------------------------------
--CALLBACKS
------------------------------
lib.callback.register('lbs_admin:server:isAdmin', function(source)
    return hasAdminPermissions(source)
end)

lib.callback.register('lbs_admin:server:checkPermission', function(source, action)
    return hasPermission(source, action)
end)

lib.callback.register('lbs_admin:server:getPlayerList', function()
    local players = {}
    if Config.Framework == 'qb' then 
        for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
            utils.debugPrint(string.format(" Player found: %s [%s]", player.PlayerData.name, player.PlayerData.source))
            table.insert(players, {
                id = player.PlayerData.source,
                name = player.PlayerData.name or 'Unknown'
            })
        end
        utils.debugPrint(' Sending player list with ' .. #players .. ' players')
    elseif Config.Framework == 'qbx' then
        for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
            utils.debugPrint(string.format(" Player found: %s [%s]", player.PlayerData.name, player.PlayerData.source))
            table.insert(players, {
                id = player.PlayerData.source, 
                name = player.PlayerData.name or 'Unknown'
            })
        end
        utils.debugPrint(' Sending player list with ' .. #players .. ' players')

    else 
        print('No Framework Found!')
    end

    return players

end)

lib.callback.register('lbs_admin:server:checkPlayerReports', function()
    local src = source
    local row = MySQL.single.await('SELECT * FROM `reports` where reporter_id = ?', {
        src
    })
    if not row then return false end
    return true
end)

lib.callback.register('lbs_admin:server:getReportList', function()
    local response = MySQL.query.await('SELECT * FROM  `reports`')

    local reports = {}

    if response then
        for i = 1, #response do
            local row = response[i]
            table.insert(reports, {
                id = row.reporter_id,
                name = GetPlayerName(row.reporter_id),
                reason = row.reason,
                status = row.status
            })
        end
    else
        utils.debugPrint('Failed to query reports table in database')
    end


    return reports
end)

lib.callback.register('lbs_admin:server:getBansList', function()
    local bans = {}


    local response = MySQL.query.await('SELECT * FROM `bans`')

    if response then
        for i = 1, #response do
            local row = response[i]
            table.insert(bans, {
                id = row.id,
                name=row.name,
                license=row.license,
                discord=row.discord,
                ip=row.ip,
                reason=row.reason,
                expire=row.expire,
                bannedby=row.bannedby
            })
        end
    end
    
    return bans
end)
------------------------------
--Events
------------------------------
---@param action string: specific actin taken on report modal
---@param target number: target player to get report for
RegisterNetEvent('lbs_admin:server:report_action', function(action, target)
    local src = source
    if not target then return end
    if action == 'close' then
        if hasPermission(src, 'reports') then
            local queries = {
                {query = 'DELETE FROM `reports` WHERE reporter_id = ?', values= {target}}
            }
            MySQL.transaction.await(queries)
            print('attempting to remove data')

            TriggerClientEvent('ox_lib:notify', src, {
                title='Ticket Closed',
                description='Successfully closed ticket',
                type='success'
            })

            TriggerClientEvent('ox_lib:notify', target, {
                title='Ticket Closed',
                description="Your ticket was closed by " .. GetPlayerName(src),
                type='success'
            })
        end
    end
end)

---@param action string: specific actin taken on player modal
---@param target number: target player action should be executed on
---@param reason?  string: for bans/kicks - reason player was banned/kicked
---@param duration? string: for bans/kicks - duration of ban/kick
---@param durationUnit? string: for bans/kick - allows us to convert whatever choice of unit they chose into seconds for the DropPlayer() native. 
RegisterNetEvent('lbs_admin:server:player_action', function(action, target, reason, duration, durationUnit)
    if not target then return end 
    local admin = GetPlayerName(source)
    local player = GetPlayerName(target)
    -- BAN ACTION
    if action == 'ban' then
        --log to discord
        if hasPermission(source, 'ban') then
            reason, banTime = getBanReason(reason, duration, durationUnit)
            send_to_discord_log("BAN Action", ("%s [%s] banned %s [%s] for: \n%s "):format(admin,source,player,target,reason), 255)
            MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?,?,?,?,?,?,?)',{
                GetPlayerName(target),
                getIdentifier(target, 'license'),
                getIdentifier(target, 'discord'),
                getIdentifier(target, 'ip'),
                reason,
                banTime,
                GetPlayerName(source)
            })
            DropPlayer(target, reason)
        end
    elseif action == 'teleport' then
        if hasPermission(source, 'teleport') then 
            local src = source 
            local coords = GetEntityCoords(GetPlayerPed(target))
            send_to_discord_log("Teleport Action", ("%s [%s] teleported to %s [%s]"):format(admin,source,player,target), 255)
            TriggerClientEvent('lbs_admin:client:teleport_to_coords', src, coords)
        end
    elseif action == 'bring' then
        if hasPermission(source, 'teleport') then 
            local src = source
            local coords = GetEntityCoords(GetPlayerPed(src))
            send_to_discord_log("Bring Action", ("%s [%s] teleported %s [%s]"):format(admin,source,player,target), 32896)
            TriggerClientEvent('lbs_admin:client:teleport_to_coords', target, coords)
        end
    elseif action == 'spectate' then
        if hasPermission(source, 'spectate') then
            if source == target then 
                TriggerClientEvent('ox_lib:notify', source , {
                    title = 'Error',
                    description = 'You cannot spectate yourself',
                    type='error'
                })
                return
            end
            send_to_discord_log("Spectate Action", ("%s [%s] spectated %s [%s]"):format(admin,source,player,target), 16766720)
            local targetPed = GetPlayerPed(target)
            local coords = GetEntityCoords(targetPed)
            TriggerClientEvent('lbs_admin:client:spectate', source, targetPed)
        end
    elseif action == 'kick' then
        if hasPermission(source, 'kick') then
            send_to_discord_log("Kick Action", ("%s [%s] kicked %s [%s] for: %s"):format(admin,source,player,target, reason), 16711680)
            local discordLink = Config.DiscordLink
            DropPlayer(target, "You were kicked for: \n" .. reason .. "\nJoin our Discord for more information: " .. discordLink)
        end
    end
end)

RegisterNetEvent('lbs_admin:server:teleport_marker', function()
    local src = source
    if hasPermission(src, 'teleport') then
        if Config.Framework == 'qb' then
            TriggerClientEvent('QBCore:Command:GoToMarker', src)
            send_to_discord_log("TPM Action", ("%s [%s] teleport to marker"):format(admin,source), 255)
        end
    end
end)

RegisterNetEvent('lbs_admin:server:submitReport', function(message)
    local src = source

    MySQL.insert('INSERT INTO `reports` (reporter_id, reason, timestamp, status) VALUES (?, ?, ?, ?)', {
        src, message, os.date('%Y-%m-%d %H:%M:%S'), 'open'
    })

    TriggerClientEvent('ox_lib:notify', src, {
        title='Reports',
        description = 'Report successfully submitted!',
        type='success'
    })
    send_to_discord_log("Report Submitted", ("%s [%s] submitted a report with message: \n  %s"):format(GetPlayerName(source),source,message), 255)
end)

RegisterNetEvent('lbs_admin:server:unbanPlayer', function(banId)
    if hasPermission(source, 'ban') then 
        if not banId then return end
        deleteBanRecord(banId)
        local admin = GetPlayerName(source)
        send_to_discord_log("Unban Action", ("%s [%s] unbanned ban ID: %s "):format(admin,source,banId), 255)
    end
end)