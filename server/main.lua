function RefreshJobs()
    for k, v in pairs(Config.Jobs) do
        MySQL.Async.fetchAll("DELETE FROM job_grades WHERE job_name = @jobname", {["@jobname"] = k}, function(result)
            MySQL.Async.fetchAll("DELETE FROM jobs WHERE name = @jobname", {["@jobname"] = k}, function(result)
                MySQL.Async.fetchAll("INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES (@name, @label, @whitelist)", {["@name"] = k, ["@label"] = v.label, ["@whitelist"] = v.whitelist,}, function(result)
                    for grade, data in pairs(v.grades) do
                        MySQL.Async.fetchAll("INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES (NULL, @jobname, @rank, @grade_name, @grade_label, @sallary, '{}', '{}')", {["@jobname"] = k, ["@grade_name"] = data.name, ["@rank"] = grade, ["@grade_label"] = data.label, ["@sallary"] = data.salary,}, function(result)
                            if result ~= nil then
                                if Config.Debug then
                                    print("WORKED")
                                end
                            end
                        end)
                    end
                end)
            end)
        end)
    end
    Wait(3000)
    ESX.RefreshJobs()
end
RegisterNetEvent("FlyJobs:Server:RefreshJobs", function()
    RefreshJobs()
end)

function RefreshSociety()
    for k, v in pairs(Config.JobSettings) do
        if v.society then
            MySQL.Async.fetchAll('SELECT * FROM fly_society WHERE job = @jobName', {["@jobName"] = k}, function(result1)
                if result1 ~= nil then
                    if #result1 < 1 then
                        MySQL.Async.fetchAll('INSERT INTO fly_society (job, items, weapons, money) VALUES (@jobName, "{}", "{}", 0)', {["@jobName"] = k}, function(result)
                            
                        end)
                    end
                end
            end)
        end
    end
end
RegisterNetEvent("FlyJobs:Server:RefreshSociety", function()
    RefreshSociety()
end)

RegisterNetEvent("FlyJobs:Server:RefreshPlayer", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.triggerEvent("FlyJobs:Client:RefreshData", xPlayer)
end)

ESX.RegisterServerCallback("FlyJobs:Server:GetPlayer", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.triggerEvent("FlyJobs:Client:RefreshData", xPlayer)
    cb(xPlayer)    
end)

CreateThread(function()
    TriggerEvent("FlyJobs:Server:RefreshJobs")
    TriggerEvent("FlyJobs:Server:RefreshSociety")
end)

function GetWeaponIndex(table, weapon)
    for k, v in pairs(table) do
        if v.name == weapon then
            return k
        end
    end
    return false
end

ESX.RegisterServerCallback("FlyJobs:Server:IsBoss", function(source, cb, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    local maxGrade = nil
    for k, v in pairs(Config.Jobs[job].grades) do
        if maxGrade == nil then
            maxGrade = k
        else
            if maxGrade < k then
                maxGrade = k
            end
        end
    end
    local boss = Config.Jobs[job].grades[maxGrade].name
    local playerJob = xPlayer.getJob()
    if playerJob.name == job and playerJob.grade_name == boss then
        cb(true)
        if Config.Debug then
            print("YES BOSS")
        end
    else
        cb(false)
        if Config.Debug then
            print("NO BOSS")
        end
    end
    xPlayer.triggerEvent("FlyJobs:Client:RefreshData", xPlayer)
end)

ESX.RegisterServerCallback("FlyJobs:Server:GetEmploye", function(source, cb)
    local players = {}
    local xSource = ESX.GetPlayerFromId(source)
    local playerJob = xSource.getJob()
    local xPlayers = ESX.GetExtendedPlayers("job", playerJob.name)
    for k, xPlayer in pairs(xPlayers) do
        table.insert(players, 
        {
            name = xPlayer.getName(),
            identifier = xPlayer.getIdentifier(),
            job = xPlayer.getJob()
        })
    end
    cb(players)
end)


RegisterNetEvent("FlyJobs:Server:Promote", function(identifier)
    local src = source
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local job = xPlayer.getJob().name
    local grade = xPlayer.getJob().grade
    local targetGrade = grade
    local higherGrades = {}

    
    for k, v in pairs(Config.Jobs[job].grades) do
        if k > grade then
            table.insert(higherGrades, k)
        end
    end

    
    if #higherGrades > 0 then
        local highLowGrade = nil
        for k, v in pairs(higherGrades) do
            if highLowGrade == nil then
                highLowGrade = v
                targetGrade = v
            else
                if v < highLowGrade then
                    highLowGrade = v
                    targetGrade = v
                end
            end
        end

        xPlayer.setJob(job, targetGrade)
        xPlayer.triggerEvent("FlyJobs:Client:Notify", _U('got_promote'))
        local xTarget = ESX.GetPlayerFromId(src)
        xTarget.triggerEvent("FlyJobs:Client:Close", _U('you_promote', xPlayer.getName()))

    else
        local xTarget = ESX.GetPlayerFromId(src)
        xTarget.triggerEvent("FlyJobs:Client:Close", _U('already_boss', xPlayer.getName()))
    end
end)

RegisterNetEvent("FlyJobs:Server:Fire", function(identifier)
    local src = source
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    xPlayer.setJob("unemployed", 0)

    xPlayer.triggerEvent("FlyJobs:Client:Notify", _U('got_fire'))
    local xTarget = ESX.GetPlayerFromId(src)
    xTarget.triggerEvent("FlyJobs:Client:Close", _U('you_fire', xPlayer.getName()))
end)

RegisterNetEvent("FlyJobs:Server:Degrade", function(identifier)
    local src = source
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local job = xPlayer.getJob().name
    local grade = xPlayer.getJob().grade
    local targetGrade = grade
    local lowerGrades = {}

    
    for k, v in pairs(Config.Jobs[job].grades) do
        if k < grade then
            table.insert(lowerGrades, k)
        end
    end


    
    if #lowerGrades > 0 then
        local lowHighGrade = nil
        for k, v in pairs(lowerGrades) do
            if lowHighGrade == nil then
                lowHighGrade = v
                targetGrade = v
            else
                if v > lowHighGrade then
                    lowHighGrade = v
                    targetGrade = v
                end
            end
        end

        xPlayer.setJob(job, targetGrade)
        xPlayer.triggerEvent("FlyJobs:Client:Notify", _U('got_degrade'))
        local xTarget = ESX.GetPlayerFromId(src)
        xTarget.triggerEvent("FlyJobs:Client:Close", _U('you_degrade', xPlayer.getName()))

    else
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
        xPlayer.setJob("unemployed", 0)
    
        xPlayer.triggerEvent("FlyJobs:Client:Notify", _U('got_fire'))
        local xTarget = ESX.GetPlayerFromId(src)
        xTarget.triggerEvent("FlyJobs:Client:Close", _U('you_fire', xPlayer.getName()))
    end
end)

ESX.RegisterServerCallback("FlyJobs:Server:GetWeapons", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob()
    MySQL.Async.fetchAll('SELECT * FROM fly_society WHERE job = @jobName', {["@jobName"] = job.name}, function(result)
        local weaponList = result[1].weapons
        weaponList = json.decode(weaponList)
        if Config.Debug then
            print(ESX.DumpTable(weaponList))
        end
        cb(weaponList)
    end)
end)

ESX.RegisterServerCallback("FlyJobs:Server:GetItems", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob()
    MySQL.Async.fetchAll('SELECT * FROM fly_society WHERE job = @jobName', {["@jobName"] = job.name}, function(result)
        local itemList = result[1].items
        itemList = json.decode(itemList)
        if Config.Debug then
            print(ESX.DumpTable(itemList))
        end
        cb(itemList)
    end)
end)

function GetItemIndex(table, item)
    for k, v in pairs(table) do
        if v.name == item then
            return k
        end
    end
    return false
end

RegisterNetEvent("FlyJobs:Server:BuyWeapon", function(weapon, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local job = xPlayer.getJob()
    MySQL.Async.fetchAll('SELECT * FROM fly_society WHERE job = @jobName', {["@jobName"] = job.name}, function(result)
        local weaponList = result[1].weapons
        weaponList = json.decode(weaponList)
        if Config.Debug then
            print(ESX.DumpTable(weaponList))
        end

        if weaponList[GetWeaponIndex(weaponList, weapon)] ~= nil then
            weaponList[GetWeaponIndex(weaponList, weapon)].count = weaponList[GetWeaponIndex(weaponList, weapon)].count + 1
        else
            table.insert(weaponList, {name = weapon, count = 1})
        end

        if Config.Debug then
            print(ESX.DumpTable(weaponList))
        end

        weaponList = json.encode(weaponList)

        MySQL.Async.fetchAll('UPDATE fly_society SET weapons = @table WHERE job = @job', {["@job"] = job.name, ["@table"] = weaponList}, function(result2)
            xPlayer.removeMoney(price)
            xPlayer.triggerEvent("FlyJobs:Client:Close", _U('bought_weapon', ESX.GetWeaponLabel(weapon)))
        end)
    end)
end)

RegisterNetEvent("FlyJobs:Server:SellWeapon", function(weapon, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local job = xPlayer.getJob()
    MySQL.Async.fetchAll('SELECT * FROM fly_society WHERE job = @jobName', {["@jobName"] = job.name}, function(result)
        local weaponList = result[1].weapons
        weaponList = json.decode(weaponList)
        if Config.Debug then
            print(ESX.DumpTable(weaponList))
        end

        if weaponList[GetWeaponIndex(weaponList, weapon)] ~= nil then
            if weaponList[GetWeaponIndex(weaponList, weapon)].count - 1 >= 0 then
                weaponList[GetWeaponIndex(weaponList, weapon)].count = weaponList[GetWeaponIndex(weaponList, weapon)].count - 1
            else
                xPlayer.triggerEvent("FlyJobs:Client:Close", _U('no_perms'), "error")
                return
            end
        end

        if Config.Debug then
            print(ESX.DumpTable(weaponList))
        end

        weaponList = json.encode(weaponList)
        MySQL.Async.fetchAll('UPDATE fly_society SET weapons = @table WHERE job = @job', {["@job"] = job.name, ["@table"] = weaponList}, function(result2)
            xPlayer.addAccountMoney('money', price)
            xPlayer.triggerEvent("FlyJobs:Client:Close", _U('sold_weapon', ESX.GetWeaponLabel(weapon)))
        end)
    end)
end)


RegisterNetEvent("FlyJobs:Server:BuyItem", function(item, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local job = xPlayer.getJob()
    MySQL.Async.fetchAll('SELECT * FROM fly_society WHERE job = @jobName', {["@jobName"] = job.name}, function(result)
        local itemList = result[1].items
        itemList = json.decode(itemList)
        if Config.Debug then
            print(ESX.DumpTable(itemList))
        end

        if itemList[GetItemIndex(itemList, item)] ~= nil then
            itemList[GetItemIndex(itemList, item)].count = itemList[GetItemIndex(itemList, item)].count + 1
        else
            table.insert(itemList, {name = item, count = 1})
        end

        if Config.Debug then
            print(ESX.DumpTable(itemList))
        end

        itemList = json.encode(itemList)

        MySQL.Async.fetchAll('UPDATE fly_society SET items = @table WHERE job = @job', {["@job"] = job.name, ["@table"] = itemList}, function(result2)
            xPlayer.removeMoney(price)
            xPlayer.triggerEvent("FlyJobs:Client:Close", _U('bought_item', ESX.GetItemLabel(item)))
        end)
    end)
end)

RegisterNetEvent("FlyJobs:Server:SellItem", function(item, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local job = xPlayer.getJob()
    MySQL.Async.fetchAll('SELECT * FROM fly_society WHERE job = @jobName', {["@jobName"] = job.name}, function(result)
        local itemList = result[1].items
        itemList = json.decode(itemList)
        if Config.Debug then
            print(ESX.DumpTable(itemList))
        end

        if itemList[GetItemIndex(itemList, item)] ~= nil then
            if itemList[GetItemIndex(itemList, item)].count - 1 >= 0 then
                itemList[GetItemIndex(itemList, item)].count = itemList[GetItemIndex(itemList, item)].count - 1
            else
                xPlayer.triggerEvent("FlyJobs:Client:Close", _U('no_perms'), "error")
                return
            end
        end

        if Config.Debug then
            print(ESX.DumpTable(itemList))
        end

        itemList = json.encode(itemList)
        MySQL.Async.fetchAll('UPDATE fly_society SET items = @table WHERE job = @job', {["@job"] = job.name, ["@table"] = itemList}, function(result2)
            xPlayer.addAccountMoney('money', price)
            xPlayer.triggerEvent("FlyJobs:Client:Close", _U('sold_item', ESX.GetItemLabel(item)))
        end)
    end)
end)

RegisterNetEvent("FlyJobs:Server:Withdraw", function(amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local job = xPlayer.getJob()
    MySQL.Async.fetchAll('SELECT * FROM fly_society WHERE job = @jobName', {["@jobName"] = job.name}, function(result)
        if result ~= nil then
            local money = tonumber(result[1].money)
            if money - amount < 1 then
                xPlayer.triggerEvent("FlyJobs:Client:Close", _U('no_perms'))
            else
                MySQL.Async.fetchAll('UPDATE fly_society SET money = @value WHERE job = @job', {["@job"] = job.name, ["@value"] = money - amount}, function(_result)
                    if _result ~= nil then
                        xPlayer.addMoney(amount)
                        if Config.Debug then
                            print("WORKED")
                        end
                    else
                        if Config.Debug then
                            print("ERROR")
                        end
                    end
                end)
            end
        end
    end)
end)

RegisterNetEvent("FlyJobs:Server:Deposit", function(amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local job = xPlayer.getJob()
    local money = xPlayer.getMoney()
    if money < amount then
        xPlayer.triggerEvent("FlyJobs:Client:Close", _U('no_perms'))
    else
        MySQL.Async.fetchAll('UPDATE fly_society SET money = @value WHERE job = @job', {["@job"] = job.name, ["@value"] = money + amount}, function(result)
            if result ~= nil then
                xPlayer.removeMoney(amount)
                if Config.Debug then
                    print("WORKED")
                end
            end
        end)
    end
end)