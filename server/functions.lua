function ServerNotify(message, type, id)
    if Config.Notify == 'ox' then 
        TriggerClientEvent('ox_lib:notify', id, {
            title = 'Admin Action',
            description = message,
            type = type
        })
    elseif Config.Notify == 'qb' then
        TriggerClientEvent('QBCore:Notify', id, message, type)
    end

end