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

local json = require('json')

local QBCore = nil

if Config.Framework == 'qb' or Config.Framework == 'qbx' then 
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('[ERROR] NO FRAMEWORK DETECTED')
end




------------------------------
-- FUNCTIONS
------------------------------

function send_to_discord_log(title, description, color)
    local webhook = Config.DiscordWebhook
    if (not webhook or webhook == '') and Config.EnableDebugMode then 
        print("[Discord Log] No webhook URL set!")
        return 
    end
    if Config.EnableDebugMode then 
        print("[Discord Log] Sending to Discord:", title, description)
    end 

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


local function hasAdminPermissions(src)
    local admin_role = Config.AdminGroup
    local admin_status = IsPlayerAceAllowed(src, admin_role)
    return admin_status or IsPlayerAceAllowed(src, 'command')
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
    end


    return reports
end)

lib.callback.register('lbs_admin:server:getBansList', function()
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
        print('trying waveshiled')
        local resourceName = GetCurrentResourceName()
        local filePath = GetResourcePath(resourceName) .. '/bans.json' 

        local file = io.open(filePath, 'r')
        if not file then
            print('Failed to find bans.json')
            return
        end

        local fileContent = file:read('*a')
        file:close()

        --debugText('Raw file content: ' .. fileContent)
        
        local response = json.decode(fileContent)
        if not response then 
            print('Failed to parse bans.json')
            return
        end

        if response == nil then
            print('Bans is nil')
            return
        elseif next(response) == nil then
            print('Bans is an empty table')
            return
        end
        

        for key, ban in pairs(response) do
            print('printing ban')
            print('Key:', key) -- This is the unique ban ID (e.g., "waveshield_ban_529708")
            print('Ban Data:', ban)
        
            -- Extract identifiers
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
            
        
            -- Insert the ban into the table
            table.insert(bans, {
                id = key, -- Use the key as the unique ban ID
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
        if hasAdminPermissions(src) then

            local queries = {
                {query = 'DELETE FROM `reports` WHERE reporter_id = ?', values= {target}}
            }
            MySQL.transaction.await(queries)

            TriggerClientEvent('ox_lib:notify', src, {
                title='Closed',
                description='Ticket closed',
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
        if hasAdminPermissions(source) then
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
        local src = source 
        local coords = GetEntityCoords(GetPlayerPed(target))
        send_to_discord_log("Teleport Action", ("%s [%s] teleported to %s [%s]"):format(admin,source,player,target), 255)
        TriggerClientEvent('lbs_admin:client:teleport_to_coords', src, coords)
    elseif action == 'bring' then
        local src = source
        local coords = GetEntityCoords(GetPlayerPed(src))
        send_to_discord_log("Bring Action", ("%s [%s] teleported %s [%s]"):format(admin,source,player,target), 32896)
        TriggerClientEvent('lbs_admin:client:teleport_to_coords', target, coords)
    -- elseif action == 'warn' then
    --     local admin = GetPlayerName(source)
    --     local player = GetPlayerName(target)
    
    --     print(string.format('Admin %s froze player %s', admin, player))
    --     TriggerClientEvent('lbs_admin:client:freeze_player',target, true, reason)
    elseif action == 'spectate' then
        if hasAdminPermissions(source) then
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
        if hasAdminPermissions(source) then
            send_to_discord_log("Kick Action", ("%s [%s] kicked %s [%s] for: %s"):format(admin,source,player,target, reason), 16711680)
            local discordLink = Config.DiscordLink
            DropPlayer(target, "You were kicked for: \n" .. reason .. "\nJoin our Discord for more information: " .. discordLink)
        end
    end
end)


RegisterNetEvent('lbs_admin:server:teleport_marker', function()
    local src = source
    if Config.Framework == 'qb' or Config.Framework == 'qbx' then
        TriggerClientEvent('QBCore:Command:GoToMarker', src)
        send_to_discord_log("TPM Action", ("%s [%s] teleport to marker"):format(admin,source), 255)
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
end)


