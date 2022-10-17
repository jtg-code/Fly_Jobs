activeVehicles = {}
currentPreview = 0

function OpenGarageMenuMain()
    GarageMenuOpen = true
    if Config.Debug then
        print("Open Garage Menu")
    end

    local vehicleConfig = Config.JobSettings[fPlayer.job.name].vehicle

    if vehicleConfig.unlimited then
        UnlimitedVehicleMenu()
    else
        if vehicleConfig.public then
            SharedVehicleMenu()
        end
    end

    ESX.TriggerServerCallback("FlyJobs:Server:GetVehicle", function() 
        
    end, args)


end

function UnlimitedVehicleMenu()
    local vehicleConfig = Config.JobSettings[fPlayer.job.name]
    local xPlayer = fPlayer
    local allCars = {}
    local ped = PlayerPedId()

    for k, v in pairs(Config.Vehicles[xPlayer.job.name]) do
        for vehicle, cost in pairs(v) do
            if not ContainVehicle(allCars, vehicle) then
                table.insert(allCars, {label = GetDisplayNameFromVehicleModel(GetHashKey(vehicle)),car = vehicle, price = cost})
            end
        end
    end

    if DoesEntityExist(currentPreview) then
        ESX.Game.DeleteVehicle(currentPreview)
    end
    ESX.Game.SpawnLocalVehicle(allCars[1].car, vehicleConfig.garage.inShop, vehicleConfig.garage.inHeading, function(veh) 
        ESX.Game.SetVehicleProperties(veh, vehicleConfig.vehicle.tuning)
        FreezeEntityPosition(veh, true)
        SetPedIntoVehicle(ped, veh, -1)
        currentPreview = veh
    end)

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garageUnlimited', {
        title = _U('garage'),
        align = 'left',
        elements = allCars
    },
    function(data, menu)
        if #activeVehicles >= vehicleConfig.vehicle.maxParkout and #activeVehicles > 0 then
            for k, v in pairs(activeVehicles) do
                if not DoesEntityExist(v) then
                    table.remove(activeVehicles, k)
                end
            end
        end

        if #activeVehicles >= vehicleConfig.vehicle.maxParkout then
            ShowNotification(_U('no_perms'), "error")
        else
            if DoesEntityExist(currentPreview) then
                ESX.Game.DeleteVehicle(currentPreview)
            end
            ESX.Game.SpawnVehicle(data.current.car, vehicleConfig.garage.outShop, vehicleConfig.garage.outHeading, function(veh)
                SetPedIntoVehicle(ped, veh, -1)
                SetVehicleColours(veh, vehicleConfig.vehicle.tuning.color1, vehicleConfig.vehicle.tuning.color2)
                ESX.Game.SetVehicleProperties(veh, vehicleConfig.vehicle.tuning)
                GarageMenuOpen = false
                table.insert(activeVehicles, veh)
                menu.close()
                ShowNotification(_U('parked_out', #activeVehicles, vehicleConfig.vehicle.maxParkout), "success")
            end)
        end
    end,
    function(data, menu)
        menu.close()
        if DoesEntityExist(currentPreview) then
            ESX.Game.DeleteVehicle(currentPreview)
        end
        SetEntityCoords(ped, vehicleConfig.garage.marker)
        GarageMenuOpen = false
        --Close
    end, 
    function(data, menu)
        if DoesEntityExist(currentPreview) then
            ESX.Game.DeleteVehicle(currentPreview)
        end
        ESX.Game.SpawnLocalVehicle(data.current.car, vehicleConfig.garage.inShop, vehicleConfig.garage.inHeading, function(veh) 
            ESX.Game.SetVehicleProperties(veh, vehicleConfig.vehicle.tuning)
            currentPreview = veh
            FreezeEntityPosition(veh, true)
            SetPedIntoVehicle(ped, veh, -1)
        end)
    end)
end

function SharedVehicleMenu()
    local vehicleConfig = Config.JobSettings[fPlayer.job.name]
    local xPlayer = fPlayer
    local allCars = {}
    local ped = PlayerPedId()

    ESX.TriggerServerCallback("FlyJobs:Server:GetSharedGarage", function(garage)
        
    end)

    for k, v in pairs(Config.Vehicles[xPlayer.job.name]) do
        for vehicle, cost in pairs(v) do
            if not ContainVehicle(allCars, vehicle) then
                table.insert(allCars, {label = GetDisplayNameFromVehicleModel(GetHashKey(vehicle)),car = vehicle, price = cost})
            end
        end
    end

    if DoesEntityExist(currentPreview) then
        ESX.Game.DeleteVehicle(currentPreview)
    end
    ESX.Game.SpawnLocalVehicle(allCars[1].car, vehicleConfig.garage.inShop, vehicleConfig.garage.inHeading, function(veh) 
        ESX.Game.SetVehicleProperties(veh, vehicleConfig.vehicle.tuning)
        FreezeEntityPosition(veh, true)
        SetPedIntoVehicle(ped, veh, -1)
        currentPreview = veh
    end)

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garageUnlimited', {
        title = _U('garage'),
        align = 'left',
        elements = allCars
    },
    function(data, menu)
        if #activeVehicles >= vehicleConfig.vehicle.maxParkout and #activeVehicles > 0 then
            for k, v in pairs(activeVehicles) do
                if not DoesEntityExist(v) then
                    table.remove(activeVehicles, k)
                end
            end
        end

        if #activeVehicles >= vehicleConfig.vehicle.maxParkout then
            ShowNotification(_U('no_perms'), "error")
        else
            if DoesEntityExist(currentPreview) then
                ESX.Game.DeleteVehicle(currentPreview)
            end
            ESX.Game.SpawnVehicle(data.current.car, vehicleConfig.garage.outShop, vehicleConfig.garage.outHeading, function(veh)
                SetPedIntoVehicle(ped, veh, -1)
                SetVehicleColours(veh, vehicleConfig.vehicle.tuning.color1, vehicleConfig.vehicle.tuning.color2)
                ESX.Game.SetVehicleProperties(veh, vehicleConfig.vehicle.tuning)
                GarageMenuOpen = false
                table.insert(activeVehicles, veh)
                menu.close()
                ShowNotification(_U('parked_out', #activeVehicles, vehicleConfig.vehicle.maxParkout), "success")
            end)
        end
    end,
    function(data, menu)
        menu.close()
        if DoesEntityExist(currentPreview) then
            ESX.Game.DeleteVehicle(currentPreview)
        end
        SetEntityCoords(ped, vehicleConfig.garage.marker)
        GarageMenuOpen = false
        --Close
    end, 
    function(data, menu)
        if DoesEntityExist(currentPreview) then
            ESX.Game.DeleteVehicle(currentPreview)
        end
        ESX.Game.SpawnLocalVehicle(data.current.car, vehicleConfig.garage.inShop, vehicleConfig.garage.inHeading, function(veh) 
            ESX.Game.SetVehicleProperties(veh, vehicleConfig.vehicle.tuning)
            currentPreview = veh
            FreezeEntityPosition(veh, true)
            SetPedIntoVehicle(ped, veh, -1)
        end)
    end)
end

function ContainVehicle(table, value)
    for k, v in pairs(table) do
        if v.car == value then
            return true
        end
    end
    return false
end