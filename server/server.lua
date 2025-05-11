local QBCore = nil;
--ensures consistent order of roles. (needs work for dynamic role setup)
local groupHierarchy = { 'god', 'admin', 'manager', 'helper'}
local utils = require('shared/utils')
local ESX = nil;

if Config.Framework == 'qbx' then
    print('[LBS_ADMIN] Qbox detected')
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject();
    print('[LBS_ADMIN] QBCore detected')
elseif Config.Framework == 'esx' then 
    print('[LBS_ADMIN] ESX_Legacy detected')
else   
    print('^1[LBS_ADMIN] No supported framework detected. Ensure qbox or qbcore is running.^7')
end
------------------------------
-- FUNCTIONS
------------------------------
function resolveGroupPermissions(group)
    local resolvedPerms = {}
    --function to process group, this will go through the role and inherited roles and return the distinct
    --permissions for each role
    local function processGroup(groupName)
        local groupData = Config.Groups[groupName]
        if not groupData then return end

        for _, perm in ipairs(groupData.permissions) do
            resolvedPerms[perm] = true
        end

        for _, inheritedGroup in ipairs(groupData.inherits or {}) do
            processGroup(inheritedGroup)
        end
    end
    
    processGroup(group)
    --debug print for resolved permissions.
    for perm, _ in pairs(resolvedPerms) do
        utils.debugPrint('Resolved Permission for ' .. source .. ' : ' .. perm)
    end
    return resolvedPerms
end

function sendToDiscordLog(title, description, color)
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
        print("[Discord Log] Response:", err, text)
    end, "POST", json.encode({
        username = 'LBS Admin Logs',
        embeds = embed
    }), {['Content-Type'] = "application/json"})

end

local function hasPermission(playerId)
    local playerGroup = nil;
    for _, group in ipairs(groupHierarchy) do
        if IsPlayerAceAllowed(playerId, 'lbs_admin.' .. group) then
            playerGroup = group
            break
        end
    end

    if playerGroup then
        local permissions = resolveGroupPermissions(playerGroup)
        return permissions, playerGroup 
    else
        return {}, nil
    end
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

local function deleteWSBanRecord(identifier)
    local resourceName = GetCurrentResourceName()
    local filePath = 'bans.json'
    local fileContent = LoadResourceFile(resourceName, filePath)

    if not fileContent or fileContent == "" then
        print("[ERROR] bans.json is empty or could not be read.")
        return
    end


    local success, jsonTable = pcall(function() return json.decode(fileContent) end)
    if not success or type(jsonTable) ~= "table" then
        print("[ERROR] Failed to parse bans.json. Invalid JSON structure.")
        return
    end


    if jsonTable[identifier] then
        jsonTable[identifier] = nil
        utils.debugPrint("Removed entry for identifier: " .. identifier)
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
lib.callback.register('lbs_admin:server:checkAdminStatus', function(src)
    local permissions, group = hasPermission(src)

    print('checking permissions server side')
    print(permissions)

    if not permissions then 
        print('failed permission check')
        return false end 
    return true
end)

lib.callback.register('lbs_admin:server:getPlayerList', function()
    local players = {}
    if Config.Framework == 'qb' then 
        for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
            utils.debugPrint(string.format("[DEBUG] Player found: %s [%s]", player.PlayerData.name, player.PlayerData.source))
            table.insert(players, {
                id = player.PlayerData.source,
                name = player.PlayerData.name or 'Unknown'
            })
        end
        utils.debugPrint('[DEBUG] Sending player list with ' .. #players .. ' players')
    elseif Config.Framework == 'qbx' then
        for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
            utils.debugPrint(string.format("[DEBUG] Player found: %s [%s]", player.PlayerData.name, player.PlayerData.source))
            table.insert(players, {
                id = player.PlayerData.source, 
                name = player.PlayerData.name or 'Unknown'
            })
        end
        utils.debugPrint('[DEBUG] Sending player list with ' .. #players .. ' players')
    -- elseif Config.Framework = 'esx' then
    --     for i, xPlayer in ipairs(ESX.GetExtendedPlayers())
    --         table.insert(players, {
    --             id = xPlayer.getIdentifier(),
    --             name = xPlayer.getName()
    --         })
    --     end
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
    local src = source
    local permissions, group = hasPermission(src)
    local reports = {}
    if permissions['reports'] then
        local response = MySQL.query.await('SELECT * FROM  `reports`')
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
            utils.debugPrint('[DEBUG] Failed to query reports table in database')
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title='LBS Admin',
            description='You do not have access to reports',
            type='error'
        })
    end
    return reports or {}
end)

lib.callback.register('lbs_admin:server:getBansList', function()
    local src = source
    local permissions, group = hasPermission(src)
    if permissions['ban'] then 
        local bans = {}

        if Config.BanProvider == 'qb' then
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
        elseif Config.BanProvider == 'ws' then
            local resourceName = GetCurrentResourceName()
            local filePath = GetResourcePath(resourceName) .. '/bans.json' 

            local file = io.open(filePath, 'r')
            if not file then
                print('[ERROR] Failed to find bans.json')
                return
            end

            local fileContent = file:read('*a')
            file:close()

            --debugText('Raw file content: ' .. fileContent)
            
            local response = json.decode(fileContent)
            if not response then 
                print('[ERROR] Failed to parse bans.json')
                return
            end

            if response == nil then
                print('[ERROR] Bans is nil')
                return
            elseif next(response) == nil then
                print('[ERROR] Bans is an empty table')
                return
            end
            

            for key, ban in pairs(response) do
                local license = nil
                local discord = nil
                local ip = nil
            
                if ban.identifiers then
                    for identifier, _ in pairs(ban.identifiers) do
                        if identifier:find("license:") then
                            license = identifier
                        elseif identifier:find("discord:") then
                            discord = identifier
                        elseif identifier:find("ip:") then
                            ip = identifier
                        end
                    end
                end

                print(license)
                print(discord)
                print(ip)

                table.insert(bans, {
                    id = key, 
                    name = ban.name or "Unknown",
                    license = license or "N/A",
                    discord = discord or "N/A",
                    ip = ip or "N/A",
                    reason = ban.reason or "No reason provided",
                    expire = ban.expires or 0,
                    bannedby = "WaveShield"
                })
            end
        end
        return bans
    else 
        return nil
    end
end)

------------------------------
--Events
------------------------------
---@param action string: specific actin taken on report modal
---@param target number: target player to get report for
RegisterNetEvent('lbs_admin:server:report_action', function(action, target)
    local src = source
    local permissions, group = hasPermission(src)
    if not target then return end
    if action == 'close' then
        if permissions['reports'] then
            local queries = {
                {query = 'DELETE FROM `reports` WHERE reporter_id = ?', values= {target}}
            }
            MySQL.transaction.await(queries)

            TriggerClientEvent('ox_lib:notify', src, {
                title='LBS Admin',
                description='Successfully closed ticket',
                type='success'
            })

            TriggerClientEvent('ox_lib:notify', target, {
                title='LBS Admin',
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
    local src = source
    local admin = GetPlayerName(src)
    local player = GetPlayerName(target)
    local permissions, group = hasPermission(src)
    -- BAN ACTION
    if action == 'ban' then
        --log to discord
        if permissions['ban'] then
            reason, banTime = getBanReason(reason, duration, durationUnit)
            sendToDiscordLog("BAN Action", ("%s [%s] banned %s [%s] for: \n%s "):format(admin,src,player,target,reason), 255)
            MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?,?,?,?,?,?,?)',{
                GetPlayerName(target),
                getIdentifier(target, 'license'),
                getIdentifier(target, 'discord'),
                getIdentifier(target, 'ip'),
                reason,
                banTime,
                GetPlayerName(src)
            })
            DropPlayer(target, reason)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title='LBS Admin',
                description = 'You do not have permissions to ' .. action,
                type='error'
            })
        end
    elseif action == 'teleport' then
        if permissions['teleport'] then 
            local coords = GetEntityCoords(GetPlayerPed(target))
            sendToDiscordLog("Teleport Action", ("%s [%s] teleported to %s [%s]"):format(admin,src,player,target), 255)
            TriggerClientEvent('lbs_admin:client:teleport_to_coords', src, coords)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title='LBS Admin',
                description = 'You do not have permissions to ' .. action,
                type='error'
            })
        end
    elseif action == 'bring' then
        if permissions['teleport'] then 
            local src = source
            local coords = GetEntityCoords(GetPlayerPed(src))
            sendToDiscordLog("Bring Action", ("%s [%s] teleported %s [%s]"):format(admin,src,player,target), 32896)
            TriggerClientEvent('lbs_admin:client:teleport_to_coords', target, coords)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title='LBS Admin',
                description = 'You do not have permissions to ' .. action,
                type='error'
            })
        end
    elseif action == 'spectate' then
        if permissions['spectate'] then
            if src == target then 
                TriggerClientEvent('ox_lib:notify', src , {
                    title = 'Error',
                    description = 'You cannot spectate yourself',
                    type='error'
                })
                return
            end
            sendToDiscordLog("Spectate Action", ("%s [%s] spectated %s [%s]"):format(admin,src,player,target), 16766720)
            local targetPed = GetPlayerPed(target)
            local coords = GetEntityCoords(targetPed)
            TriggerClientEvent('lbs_admin:client:spectate', source, targetPed)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title='LBS Admin',
                description = 'You do not have permissions to ' .. action,
                type='error'
            })
        end
    elseif action == 'kick' then
        if permissions['kick'] then
            sendToDiscordLog("Kick Action", ("%s [%s] kicked %s [%s] for: %s"):format(admin,src,player,target, reason), 16711680)
            local discordLink = Config.DiscordLink
            DropPlayer(target, "You were kicked for: \n" .. reason .. "\nJoin our Discord for more information: " .. discordLink)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title='LBS Admin',
                description = 'You do not have permissions to ' .. action,
                type='error'
            })
        end
    end
end)

RegisterNetEvent('lbs_admin:server:teleport_marker', function()
    local src = source
    local permissions, group = hasPermission(src)
    if permissions['teleport'] then
        if Config.Framework == 'qb' or Config.Framework == 'qbx' then
            TriggerClientEvent('lbs_admin:client:goToMarker', src)
            sendToDiscordLog("TPM Action", ("%s [%s] teleport to marker"):format(admin,src), 255)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title='LBS Admin',
                description = 'You do not have permissions to ' .. action,
                type='error'
            })
        end
    end
end)

RegisterNetEvent('lbs_admin:server:submitReport', function(message)
    local src = source

    MySQL.insert('INSERT INTO `reports` (reporter_id, reason, timestamp, status) VALUES (?, ?, ?, ?)', {
        src, message, os.date('%Y-%m-%d %H:%M:%S'), 'open'
    })

    TriggerClientEvent('ox_lib:notify', src, {
        title='LBS Admin',
        description = 'Report successfully submitted!',
        type='success'
    })
    sendToDiscordLog("Report Submitted", ("%s [%s] submitted a report with message: \n  %s"):format(GetPlayerName(src),src,message), 255)
end)

RegisterNetEvent('lbs_admin:server:unbanPlayer', function(banId)
    local permissions, group = hasPermission(source)
    if permissions['ban'] and Config.BanProvider == 'ws' then 
        if not banId then return end
        deleteWSBanRecord(banId)
        local admin = GetPlayerName(source)
        sendToDiscordLog("Unban Action", ("%s [%s] unbanned ban ID: %s "):format(admin,source,banId), 255)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title='LBS Admin',
            description = 'You do not have permissions to ' .. action,
            type='error'
        })
    end
end)