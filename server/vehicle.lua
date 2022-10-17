ESX.RegisterServerCallback("FlyJobs:Server:GetSharedGarage", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identfier = xPlayer.getIdentifier()
end)