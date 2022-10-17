function ShowNotification(text, type)
	if Config.Notify == 1 then
		SetNotificationTextEntry("STRING")
		AddTextComponentString(text)
		DrawNotification(false, false)
	elseif Config.Notify == 2 then
		if type == nil then
			type = "info"
		end
		ESX.ShowNotification(text, type, 5000)
	elseif Config.Notify == 3 then
		TriggerEvent("FlyJobs:Client:CustomNotify", text, type)
	end
end


fPlayer = {}
local MyPlayerPed = 0

CreateThread(function()
	while MyPlayerPed == 0 do
		MyPlayerPed = PlayerPedId()
		Wait(10)
	end
end)

RegisterNetEvent("FlyJobs:Client:RefreshData", function(data)
	fPlayer = data
	ESX.PlyerData = data
	MyPlayerPed = PlayerPedId()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	fPlayer = xPlayer
	Wait(3000)
	MyPlayerPed = PlayerPedId()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	fPlayer = {}
end)

function Contains(table, value)
	for k, v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

inZone, zoneType, jobZone = false, nil, nil
BossMenuOpen = false

CreateThread(function()
	local ped = PlayerPedId()
	while ped == 0 or not DoesEntityExist(ped) do
		local ped = PlayerPedId()
		Wait(10)
	end
    for k, v in pairs(Config.JobSettings) do
		if v.society.active then
			CreateThread(function()
				local sleep = 1000
				while true do
					playerCoords = GetEntityCoords(MyPlayerPed)
					local dist = #(v.bossmenu - playerCoords)
					if dist < 15.0 then
						sleep = 5
						Marker(v.bossmenu, 0, 255, 255, 2, 1.0, 1.0, 1.0)
						if dist < 1.0 then
							inZone = true
							zoneType = "bossMenu"
							jobZone = k
							if not BossMenuOpen then
								ESX.ShowHelpNotification(_U('open_bossmenu'))
							end
						elseif dist > 1.0 and inZone and zoneType == "bossMenu" and jobZone == k then
							inZone = false
							zoneType = nil
							jobZone = nil
							ESX.UI.Menu.CloseAll()
							BossMenuOpen = false
						end
					else
						sleep = 1000
					end
					Wait(sleep)
				end
			end)
		end
		if v.vehicle.active then
			CreateThread(function()
				local sleep = 1000
				while true do
					playerCoords = GetEntityCoords(MyPlayerPed)
					local dist = #(v.garage.marker - playerCoords)
					if dist < 15.0 then
						sleep = 5
						Marker(v.garage.marker, 0, 255, 255, 36, 1.0, 1.0, 1.0)
						if dist < 1.0 then
							inZone = true
							zoneType = "garage"
							jobZone = k
							if not GarageMenuOpen then
								ESX.ShowHelpNotification(_U('open_garage'))
							end
						elseif dist > 1.0 and inZone and zoneType == "garage" and jobZone == k then
							inZone = false
							zoneType = nil
							jobZone = nil
							ESX.UI.Menu.CloseAll()
							GarageMenuOpen = false
						end
					else
						sleep = 1000
					end
					Wait(sleep)
				end
			end)
		end
		CreateThread(function()
			if v.blip.active then
				local blip = AddBlipForCoord(v.blip.coords)
				SetBlipSprite(blip, v.blip.sprite)
				SetBlipScale(blip, v.blip.scale)
				SetBlipColour(blip, v.blip.color)
				SetBlipAsShortRange(blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(v.blip.name)
				EndTextCommandSetBlipName(blip)
			end
		end)
    end
end)


RegisterKeyMapping("FlyJobs:Command:Interact", "Interact", "keyboard", "e")
RegisterCommand("FlyJobs:Command:Interact", function(source, args)
	local ped = PlayerPedId()
	ESX.TriggerServerCallback("FlyJobs:Server:GetPlayer", function(data)
		fPlayer = data
		local xPlayer = fPlayer
		if inZone and jobZone == xPlayer.job.name and not IsPedInAnyVehicle(ped) then
			if zoneType == "bossMenu" then
				OpenBossMenuMain()
			elseif zoneType == "garage" then
				OpenGarageMenuMain()
			end
		end
	end)
end)

function OpenBossMenuMain()
	local xPlayer = fPlayer
	ESX.TriggerServerCallback("FlyJobs:Server:IsBoss", function(isBoss)
		if isBoss then
			ESX.UI.Menu.CloseAll()
			if Config.Debug then
				print("Open bossmenu")
			end
			local societyData = Config.JobSettings[xPlayer.job.name].society
			local element = {{label = _U('playerManagement'), value = "players"}}

			if societyData.weapons then
				table.insert(element, {label = _U('weaponManagement'), value = "weapons"})
			end

			if societyData.items then
				table.insert(element, {label = _U('itemManagement'), value = "items"})
			end

			if societyData.money then
				table.insert(element, {label = _U('moneyManagement'), value = "money"})
			end

			BossMenuOpen = true

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bossHome', {
				title = _U('bossMenu'),
				align = 'left',
				elements = element
			},
			function(data, menu)
				if data.current.value == "players" then
					if Config.Debug then
						print("PLAYERLIST")
					end
					OpenEmployeList()
				elseif data.current.value == "weapons" then
					OpenWeaponList()
					if Config.Debug then
						print("WEAPONLIST")
					end
				elseif data.current.value == "items" then
					OpenItemList()
					if Config.Debug then
						print("ITEMLIST")
					end
				elseif data.current.value == "money" then
					OpenMoney()
					if Config.Debug then
						print("MONEY")
					end
				end
				--select
			end,
			function(data, menu)
				menu.close()
				BossMenuOpen = false
				--Close
			end)

		else
			ShowNotification(_U('no_perms'))
		end
	end, jobZone)
end

function OpenEmployeList()
	local xPlayer = fPlayer

	ESX.TriggerServerCallback("FlyJobs:Server:GetEmploye", function(players)
		local element = {
			head = {_U('employee'), _U('grade'), _U('action')},
			rows = {}
		}
		for k, v in pairs(players) do
			local gradelabel = (v.job.grade_label.."|"..v.job.grade)
			table.insert(element.rows, {
				data = v,
				cols = {
					v.name,
					gradelabel,
					'{{' .. _U('promote') .. '|promote}} {{' .. _U('fire') .. '|fire}} {{' .. _U('degrade') .. '|degrade}}'
				}
			})
		end

		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'employee_list_' .. xPlayer.job.name, element, function(data, menu)
			local employee = data.data

			if data.value == 'promote' then
				if Config.Debug then
					print("PROMOTE")
				end
				TriggerServerEvent("FlyJobs:Server:Promote", employee.identifier)
			elseif data.value == 'fire' then
				if Config.Debug then
					print("FIRED")
				end
				TriggerServerEvent("FlyJobs:Server:Fire", employee.identifier)
			elseif data.value == 'degrade' then
				if Config.Debug then
					print("DEGRADE")
				end
				TriggerServerEvent("FlyJobs:Server:Degrade", employee.identifier)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end
RegisterNetEvent("FlyJobs:Client:Close", function(reason, type)
	ShowNotification(reason, type)
	ESX.UI.Menu.CloseAll()
end)
RegisterNetEvent("FlyJobs:Client:Notify", function(text, type)
	ShowNotification(text, type)
end)

RegisterCommand("helpBox", function(source, args)
	ESX.UI.Menu.CloseAll()
	for k, v in pairs(ESX.Game.GetVehicles()) do
		DeleteEntity(v)
	end

end)

function Contains2(table, value)
	for k, v in pairs(table) do
		if v.name == value then
			return true
		end
	end
	return false
end

function OpenWeaponList()
	local xPlayer = fPlayer
	ESX.TriggerServerCallback("FlyJobs:Server:GetWeapons", function(CBWeapons)
		local allWeapons = {}

		for k, v in pairs(Config.Weapons[xPlayer.job.name]) do
			for weapon, cost in pairs(v) do
				if not Contains2(allWeapons, weapon) then
					local c = CBWeapons[GetWeaponIndex(CBWeapons, weapon)]
					if c ~= nil then
						table.insert(allWeapons, {name = weapon, count = c.count, price = cost})
					else
						table.insert(allWeapons, {name = weapon, count = 0, price = cost})
					end
				end
			end
		end

		local element = {
			head = {_U('weapon'), _U('count'), _U('price'), _U('action')},
			rows = {}
		}
		for k, v in pairs(allWeapons) do
			local label = ESX.GetWeaponLabel(v.name)
			local count = tostring(v.count)
			local price = _U('currency', v.price)
			table.insert(element.rows, {
				data = v,
				cols = {
					label,
					count,
					price,
					'{{' .. _U('buy') .. '|buy}} {{' .. _U('sell') .. '|sell}}'
				}
			})
		end

		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'weapon_list_' .. xPlayer.job.name, element, function(data, menu)

			if data.value == 'buy' then
				TriggerServerEvent("FlyJobs:Server:BuyWeapon", data.data.name, data.data.price)
			elseif data.value == 'sell' then
				TriggerServerEvent("FlyJobs:Server:SellWeapon", data.data.name, data.data.price)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function GetWeaponIndex(table, weapon)
    for k, v in pairs(table) do
        if v.name == weapon then
            return k
        end
    end
    return false
end


function GetItemIndex(table, item)
    for k, v in pairs(table) do
        if v.name == item then
            return k
        end
    end
    return false
end

function OpenItemList()
	local xPlayer = fPlayer
	ESX.TriggerServerCallback("FlyJobs:Server:GetItems", function(CBItems)
		local allItems = {}

		for k, v in pairs(Config.Items[xPlayer.job.name]) do
			for item, cost in pairs(v) do
				if not Contains2(allItems, item) then
					local c = CBItems[GetItemIndex(CBItems, item)]
					if c ~= nil then
						table.insert(allItems, {name = item, count = c.count, price = cost})
					else
						table.insert(allItems, {name = item, count = 0, price = cost})
					end
				end
			end
		end

		local element = {
			head = {_U('item'), _U('count'), _U('price'), _U('action')},
			rows = {}
		}
		for k, v in pairs(allItems) do
			local label = v.name
			local count = tostring(v.count)
			local price = _U('currency', v.price)
			table.insert(element.rows, {
				data = v,
				cols = {
					label,
					count,
					price,
					'{{' .. _U('buy') .. '|buy}} {{' .. _U('sell') .. '|sell}}'
				}
			})
		end

		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'item_list_' .. xPlayer.job.name, element, function(data, menu)

			if data.value == 'buy' then
				TriggerServerEvent("FlyJobs:Server:BuyItem", data.data.name, data.data.price)
			elseif data.value == 'sell' then
				TriggerServerEvent("FlyJobs:Server:SellItem", data.data.name, data.data.price)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenMoney()
	local xPlayer = fPlayer
	local element = {
		{label = _U('withdraw'), value = "withdraw"},
		{label = _U('deposit'), value = "deposit"},
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'moneyBoss', {
		title = _U('moneyMenu'),
		align = 'left',
		elements = element
	},
	function(data, menu)
		if data.current.value == "withdraw" then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'moneyTake', {
				title = _U('withdraw'),
				align = 'left',
				elements = {
					{label = _U('value'), name = "value", type = "slider", min = 1, max = tonumber(xPlayer.money), value = tonumber(xPlayer.money)},
					{label = _U('withdraw'), name = "withdraw"}
				}
			},
			function(data2, menu2)
				if data2.current.value == "withdraw" then
					local slider_value = tonumber(data.elements[1].value)
					TriggerServerEvent("FlyJobs:Server:Withdraw")
				end
			end,
			function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == "deposit" then
			if xPlayer.money > 0 then
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'moneyBring', {
					title = _U('deposit'),
					align = 'left',
					elements = {
						{label = _U('value'), name = "value", type = "slider", min = 1, max = xPlayer.money, value = xPlayer.money},
						{label = _U('deposit'), name = "deposit"}
					}
				},
				function(data2, menu2)
					if data2.current.value == "deposit" then
						local slider_value = tonumber(data.elements[1].value)
						TriggerServerEvent("FlyJobs:Server:Deposit")
					end
				end,
				function(data2, menu2)
					menu2.close()
				end)
			end

		end
	end,
	function(data, menu)
		menu.close()
		--Close
	end)
end


function Marker(pos, r, g, b, type, scaleX, scaleY, scaleZ)
    DrawMarker(
	type, 
	pos, 
	0.0, 
	0.0, 
	0.0, 
	0.0, 
	0.0, 
	0.0, 
	scaleX, 
	scaleY, 
	scaleZ, 
	r, 
	g, 
	b, 
	100, 
	false, 
	false, 
	2, 
	false, 
	nil, 
	nil, 
	false)
end