local CurrentActionData = {}
local HasAlreadyEnteredMarker, IsInMainMenu = false, false
local LastZone, CurrentAction, CurrentActionMsg
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- Current Balance Event
RegisterNetEvent('esx_advancedbanking:currentBalance')
AddEventHandler('esx_advancedbanking:currentBalance', function(balance)
	ESX.TriggerServerCallback('esx_advancedbanking:getCharData', function(data)
		if Config.ShowCharName then
			if Config.ShowFirstLast then
				playerName = data.firstname .. ' ' .. data.lastname
			else
				playerName = data.firstname
			end
		else
			playerName = GetPlayerName(source)
		end

		SendNUIMessage({
			type = "balanceHUD",
			balance = balance,
			player = playerName
		})
	end)
end)

-- Balance Callback
RegisterNUICallback('balance', function()
	TriggerServerEvent('esx_advancedbanking:balance')
end)

-- Deposit Callback
RegisterNUICallback('deposit', function(data)
	TriggerServerEvent('esx_advancedbanking:deposit', tonumber(data.amount))
	TriggerServerEvent('esx_advancedbanking:balance')
end)

-- Withdraw Callback
RegisterNUICallback('withdrawl', function(data)
	TriggerServerEvent('esx_advancedbanking:withdraw', tonumber(data.amountw))
	TriggerServerEvent('esx_advancedbanking:balance')
end)

-- Transfer Callback
RegisterNUICallback('transfer', function(data)
	TriggerServerEvent('esx_advancedbanking:transfer', data.target, data.amountt)
	TriggerServerEvent('esx_advancedbanking:balance')
end)

-- Close UI Callback
RegisterNUICallback('NUIFocusOff', function()
	closeUI()
end)

-- Open UI Function
function openUI()
	IsInMainMenu = true
	SetNuiFocus(true, true)
	SendNUIMessage({type = 'openGeneral'})
	TriggerServerEvent('esx_advancedbanking:balance')
end

-- Close UI Function
function closeUI()
	IsInMainMenu = false
	SetNuiFocus(false, false)
	SendNUIMessage({type = 'closeAll'})
end

-- Entered Marker
AddEventHandler('esx_advancedbanking:hasEnteredMarker', function(zone)
	if zone == 'ATMLocations' then
		CurrentAction = 'atm_menu'
		CurrentActionMsg = _U('press_access_atm')
		CurrentActionData = {}
	elseif zone == 'BankLocations' then
		CurrentAction = 'bank_menu'
		CurrentActionMsg = _U('press_access_bank')
		CurrentActionData = {}
	end
end)

-- Exited Marker
AddEventHandler('esx_advancedbanking:hasExitedMarker', function(zone)
	if not IsInMainMenu then
		closeUI()
	end

	CurrentAction = nil
end)

-- Resource Stop
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if IsInMainMenu then
			closeUI()
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	if Config.UseATMBlips then
		for k,v in pairs(Config.ATMLocations) do
			for i=1, #v.Coords, 1 do
				local blip = AddBlipForCoord(v.Coords[i])

				SetBlipSprite (blip, Config.ATMBlip.Sprite)
				SetBlipColour (blip, Config.ATMBlip.Color)
				SetBlipDisplay(blip, Config.ATMBlip.Display)
				SetBlipScale  (blip, Config.ATMBlip.Scale)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(_U('blip_atm'))
				EndTextCommandSetBlipName(blip)
			end
		end
	end

	if Config.UseBankBlips then
		for k,v in pairs(Config.BankLocations) do
			for i=1, #v.Coords, 1 do
				local blip = AddBlipForCoord(v.Coords[i])

				SetBlipSprite (blip, Config.BankBlip.Sprite)
				SetBlipColour (blip, Config.BankBlip.Color)
				SetBlipDisplay(blip, Config.BankBlip.Display)
				SetBlipScale  (blip, Config.BankBlip.Scale)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(_U('blip_bank'))
				EndTextCommandSetBlipName(blip)
			end
		end
	end
end)

-- Enter / Exit marker events & Draw Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, true

		for k,v in pairs(Config.ATMLocations) do
			for i=1, #v.Coords, 1 do
				local distance = #(playerCoords - v.Coords[i])

				if distance < Config.DrawDistance then
					letSleep = false

					if Config.ATMMarker.Type ~= -1 then
						DrawMarker(Config.ATMMarker.Type, v.Coords[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.ATMMarker.x, Config.ATMMarker.y, Config.ATMMarker.z, Config.ATMMarker.r, Config.ATMMarker.g, Config.ATMMarker.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < Config.ATMMarker.x then
						isInMarker, currentZone = true, 'ATMLocations'
					end
				end
			end
		end

		for k,v in pairs(Config.BankLocations) do
			for i=1, #v.Coords, 1 do
				local distance = #(playerCoords - v.Coords[i])

				if distance < Config.DrawDistance then
					letSleep = false

					if Config.BankMarker.Type ~= -1 then
						DrawMarker(Config.BankMarker.Type, v.Coords[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.BankMarker.x, Config.BankMarker.y, Config.BankMarker.z, Config.BankMarker.r, Config.BankMarker.g, Config.BankMarker.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < Config.BankMarker.x then
						isInMarker, currentZone = true, 'BankLocations'
					end
				end
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker, LastZone = true, currentZone
			LastZone = currentZone
			TriggerEvent('esx_advancedbanking:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_advancedbanking:hasExitedMarker', LastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end	
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and GetLastInputMethod(2) then
				if Config.UseAdvancedHoldup then
					if IsPedOnFoot(PlayerPedId()) then
						if CurrentAction == 'atm_menu' then
							openUI()
						elseif CurrentAction == 'bank_menu' then
							ESX.TriggerServerCallback('esx_advancedholdup:checkRob', function(success)
								if success then
									openUI()
								else
									ESX.ShowNotification(_U('error_robbery'))
								end
							end)
						end

						CurrentAction = nil
					else
						ESX.ShowNotification(_U('error_vehicle'))
					end
				else
					if IsPedOnFoot(PlayerPedId()) then
						if CurrentAction == 'atm_menu' then
							openUI()
						elseif CurrentAction == 'bank_menu' then
							openUI()
						end

						CurrentAction = nil
					else
						ESX.ShowNotification(_U('error_vehicle'))
					end
				end
			end
		else
			Citizen.Wait(500)
		end

		if IsControlJustReleased(0, 322) then
			closeUI()
		end
	end
end)
