local QBCore = nil;

if Config.Framework == 'qbx' then
    print('[LBS_ADMIN] Qbox detected')
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject();
     print('[LBS_ADMIN] QBCore detected')
else   
    print('^1[LBS_ADMIN] No supported framework detected. Ensure qbox or qbcore is running.^7')
end


GetPlayers = function()
    if Config.Framework == 'qbx' then
        return exports.qbx_core:GetQBPlayers()
    elseif Config.Framework == 'qb' then
        return QBCore.Functions.GetQBPlayers()
    end
end

