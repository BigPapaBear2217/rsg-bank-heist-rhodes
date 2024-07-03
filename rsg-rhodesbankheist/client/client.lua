local RSGCore = exports['rsg-core']:GetCoreObject()
local lockdownSecondsRemaining = 0 -- done to zero lockdown on restart
local cooldownSecondsRemaining = 0 -- done to zero cooldown on restart
local CurrentLawmen = 0
local lockpicked = false
local dynamiteused = false
local vault1 = false
local vault2 = false
local robberystarted = false
local lockdownactive = false
blipEntries = {}
cache = cache or {}

------------------------------------------------------------------------------------------------------------------------

-- lock vault doors
Citizen.CreateThread(function()
    for k,v in pairs(Config.VaultDoors) do
        Citizen.InvokeNative(0xD99229FE93B46286,v,1,1,0,0,0,0)
        Citizen.InvokeNative(0x6BAB9442830C7F53,v,1)
    end
end)

------------------------------------------------------------------------------------------------------------------------

-- lockpick door
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local pos, awayFromObject = GetEntityCoords(PlayerPedId()), true
		local object = Citizen.InvokeNative(0xF7424890E4A094C0, 2058564250, 0)
		if object ~= 0 and lockdownSecondsRemaining == 0 and lockpicked == false then
			local objectPos = GetEntityCoords(object)
			if #(pos - objectPos) < 3.0 then
				awayFromObject = false
				DrawText3Ds(objectPos.x, objectPos.y, objectPos.z + 1.0, "Lockpick [J]")
				if IsControlJustReleased(0, RSGCore.Shared.Keybinds['J']) then
					RSGCore.Functions.TriggerCallback('rsg-lawman:server:getlaw', function(result)
						CurrentLawmen = result
						if CurrentLawmen >= Config.MinimumLawmen then
							local hasItem = RSGCore.Functions.HasItem('lockpick', 1)
							if hasItem then
								TriggerServerEvent('rsg-rhodesbankheist:server:removeItem', 'lockpick', 1)
								TriggerEvent('rsg-lockpick:client:openLockpick', lockpickFinish)
							else
                                RSGCore.Functions.Notify('you need a lockpick', 'error')
							end
						else
                            RSGCore.Functions.Notify('not enough lawmen on duty!', 'error')
						end
					end)
				end
			end
		end
		if awayFromObject then
			Wait(1000)
		end
	end
end)

function lockpickFinish(success)
    if success then
		local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        TriggerServerEvent("BANK:ALARM", coords, player)
        RSGCore.Functions.Notify('lockpick successful', 'success')
        Citizen.InvokeNative(0x6BAB9442830C7F53, 1340831050, 0)
		lockpicked = true
		robberystarted = true
		handleLockdown()
		lockdownactive = true
        TriggerServerEvent('rsg-lawman:server:lawmanAlert', 'Someone Robs the Rhodes Bank')
    else
        RSGCore.Functions.Notify('lockpick unsuccessful', 'error')
    end
end

-- lawman alert

RegisterNetEvent('rsg-lawman:client:lawmanAlert', function(coords, text)
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.type == "leo" then
            local blip = BlipAddForCoords(joaat('BLIP_STYLE_CREATOR_DEFAULT'), coords.x, coords.y, coords.z)
            local blip2 = BlipAddForCoords(joaat('BLIP_STYLE_COP_PERSISTENT'), coords.x, coords.y, coords.z)
            local blipText = Lang and Lang:t('lang12') .. '- %{text}' or 'Alert - %{text}', {value = text}
            SetBlipSprite(blip, joaat('blip_ambient_law'))
            SetBlipSprite(blip2, joaat('blip_overlay_ring'))
            BlipAddModifier(blip, joaat('BLIP_MODIFIER_AREA_PULSE'))
            BlipAddModifier(blip2, joaat('BLIP_MODIFIER_AREA_PULSE'))
            SetBlipScale(blip, 0.8)
            SetBlipScale(blip2, 2.0)
            SetBlipName(blip, blipText)
            SetBlipName(blip2, blipText)

            blipEntries[#blipEntries + 1] = {coords = coords, handle = blip}
            blipEntries[#blipEntries + 1] = {coords = coords, handle = blip2}

            -- Add GPS Route
            if Config.AddGPSRoute then
                StartGpsMultiRoute(`COLOR_GREEN`, true, true)
                AddPointToGpsMultiRoute(coords)
                SetGpsMultiRouteRender(true)
            end

            -- send notification
            if lib then
                lib.notify({ title = blipText, type = 'inform', duration = 7000 })
            else
                RSGCore.Functions.Notify(blipText, 'inform', 7000)
            end

			CreateThread(function()
				local playerPed = PlayerPedId()
				local playerCoords = GetEntityCoords(playerPed)
				local distance = #(coords - playerCoords)
				local timer = Config.AlertTimer or 0 -- Initialize timer with a default value
			
				while timer ~= 0 do
					Wait(180 * 4)
			
					if cache and cache.ped then
						local pcoord = GetEntityCoords(cache.ped)
						distance = #(coords - pcoord)
					else
						distance = #(coords - playerCoords)
					end
			
					timer = timer - 1 -- Perform arithmetic on timer
			
					if Config.Debug then
						print('Distance to Alert Blip: ' .. tostring(distance) .. ' metres')
					end
			
					if timer <= 0 or distance < 5.0 then
						for i = 1, #blipEntries do
							local blips = blipEntries[i]
							local bcoords = blips.coords
		
							if coords == bcoords then
								if Config.Debug then
									print('')
									print('Blip Coords: ' .. tostring(bcoords))
									print('Blip Removed: ' .. tostring(blipEntries[i].handle))
									print('')
								end
		
								RemoveBlip(blipEntries[i].handle)
							end
						end
		
						timer = Config.AlertTimer or 0 -- Reset timer with a default value
		
						if Config.AddGPSRoute then
							ClearGpsMultiRoute(coords)
						end
		
                        return
                    end
                end
            end)
        end
    end)
end)

-- blow vault prompt
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local pos, awayFromObject = GetEntityCoords(PlayerPedId()), true
		local object = Citizen.InvokeNative(0xF7424890E4A094C0, 3483244267, 0)
		if object ~= 0 and robberystarted == true and dynamiteused == false then
			local objectPos = GetEntityCoords(object)
			if #(pos - objectPos) < 3.0 then
				awayFromObject = false
				DrawText3Ds(objectPos.x, objectPos.y, objectPos.z + 1.0, "Place Dynamite [J]")
				if IsControlJustReleased(0, RSGCore.Shared.Keybinds['J']) then
					TriggerEvent('rsg-rhodesbankheist:client:boom')
				end
			end
		end
		if awayFromObject then
			Wait(1000)
		end
	end
end)

-- blow vault doors
RegisterNetEvent('rsg-rhodesbankheist:client:boom')
AddEventHandler('rsg-rhodesbankheist:client:boom', function()
	if robberystarted == true then
		local hasItem = RSGCore.Functions.HasItem('dynamite', 1)
		if hasItem then
			dynamiteused = true
			TriggerServerEvent('rsg-rhodesbankheist:server:removeItem', 'dynamite', 1)
			local playerPed = PlayerPedId()
			TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 5000, true, false, false, false)
			Wait(5000)
			ClearPedTasksImmediately(PlayerPedId())
			local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.5, 0.0))
			local prop = CreateObject(GetHashKey("p_dynamite01x"), x, y, z, true, false, true)
			SetEntityHeading(prop, GetEntityHeading(PlayerPedId()))
			PlaceObjectOnGroundProperly(prop)
			FreezeEntityPosition(prop,true)
			TriggerEvent('rNotify:NotifyLeft', "explosives set !", "hide or move away", "generic_textures", "tick", 4000)
			Wait(10000)
			AddExplosion(1282.2947, -1308.442, 77.03968, 25 , 5000.0 ,true , false , 27)
			DeleteObject(prop)
			Citizen.InvokeNative(0x6BAB9442830C7F53, 3483244267, 0)
			TriggerEvent('rsg-rhodesbankheist:client:policenpc')
			local alertcoords = GetEntityCoords(PlayerPedId())
			TriggerServerEvent('police:server:policeAlert', 'Rhodes Bank is being robbed')
		else
			TriggerEvent('rNotify:NotifyLeft', "you need dynamite !", "go buy some", "generic_textures", "tick", 4000)
		end
	else
		RSGCore.Functions.Notify('you can\'t do that right now', 'error')
	end
end)

------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	exports['rsg-core']:createPrompt('vault1', vector3(1288.6381, -1313.991, 77.039779), 0xF3830D8E, 'Loot Vault', {
		type = 'client',
		event = 'rsg-rhodesbankheist:client:checkvault1',
		args = {},
	})
end)
----------------------------------------------------
-- Locals
local callback

-- Function to start the safe cracking game
local function start_safe_crack(game_data, game_callback)
    if active then return end

    active = true
    callback = game_callback

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'start_minigame',
        game = 'safe_crack',
        data = {
            style = game_data.style,
            difficulty = game_data.difficulty
        }
    })
end

-- NUI callback to end the game
RegisterNUICallback('safe_crack_end', function(data)
    SetNuiFocus(false, false)
    active = false
    callback(data.success)
end)

-- Export the safe cracking game function
exports('safe_crack', start_safe_crack)

-----------------------------------------------------
-- loot vault1
RegisterNetEvent('rsg-rhodesbankheist:client:checkvault1', function()
    local player = PlayerPedId()
    SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
    if robberystarted == true and vault1 == false then
        exports['boii_minigames']:safe_crack({
            style = 'default', -- Style template
            difficulty = 2 -- Difficulty level (1-5 recommended)
        }, function(success)
            if success then
                local animDict = "script_ca@cachr@ig@ig4_vaultloot"
                local anim = "ig13_14_grab_money_front01_player_zero"
                RequestAnimDict(animDict)
                while (not HasAnimDictLoaded(animDict)) do
                    Wait(100)
                end
                TaskPlayAnim(player, animDict, anim, 8.0, -8.0, 10000, 1, 0, true, 0, false, 0, false)
                Wait(10000)
                ClearPedTasks(player)
                SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
                TriggerServerEvent('rsg-rhodesbankheist:server:reward')
                vault1 = true
            else
                TriggerEvent('rNotify:NotifyLeft', "cant loot vault !", "idiot", "generic_textures", "tick", 4000)
            end
        end)
    else
        TriggerEvent('rNotify:NotifyLeft', "cant loot vault !", "idiot", "generic_textures", "tick", 4000)
    end
end)


------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	exports['rsg-core']:createPrompt('vault2', vector3(1286.2711, -1315.305, 77.039764), 0xF3830D8E, 'Loot Vault', {
		type = 'client',
		event = 'rsg-rhodesbankheist:client:checkvault2',
		args = {},
	})
end)

-- loot vault2
RegisterNetEvent('rsg-rhodesbankheist:client:checkvault2', function()
	local player = PlayerPedId()
	SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
	if robberystarted == true and vault2 == false then
			local animDict = "script_ca@cachr@ig@ig4_vaultloot"
			local anim = "ig13_14_grab_money_front01_player_zero"
			RequestAnimDict(animDict)
            while ( not HasAnimDictLoaded(animDict) ) do
				Wait(100)
            end
            TaskPlayAnim(player, animDict, anim, 8.0, -8.0, 10000, 1, 0, true, 0, false, 0, false)
			Wait(10000)
			ClearPedTasks(player)
			SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
			TriggerServerEvent('rsg-rhodesbankheist:server:reward')
			vault2 = true
	else
		TriggerEvent('rNotify:NotifyLeft', "cant loot vault !", "idiot", "generic_textures", "tick", 4000)
	end
end)

------------------------------------------------------------------------------------------------------------------------

function modelrequest( model )
    Citizen.CreateThread(function()
        RequestModel( model )
    end)
end

-- start mission npcs
RegisterNetEvent('rsg-rhodesbankheist:client:policenpc')
AddEventHandler('rsg-rhodesbankheist:client:policenpc', function()
	for z, x in pairs(Config.HeistNpcs) do
	while not HasModelLoaded( GetHashKey(Config.HeistNpcs[z]["Model"]) ) do
		Wait(500)
		modelrequest( GetHashKey(Config.HeistNpcs[z]["Model"]) )
	end
	local npc = CreatePed(GetHashKey(Config.HeistNpcs[z]["Model"]), Config.HeistNpcs[z]["Pos"].x, Config.HeistNpcs[z]["Pos"].y, Config.HeistNpcs[z]["Pos"].z, Config.HeistNpcs[z]["Heading"], true, false, 0, 0)
	while not DoesEntityExist(npc) do
		Wait(300)
	end
	if not NetworkGetEntityIsNetworked(npc) then
		NetworkRegisterEntityAsNetworked(npc)
	end
	Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
	GiveWeaponToPed_2(npc, 0x64356159, 500, true, 1, false, 0.0)
	TaskCombatPed(npc, PlayerPedId())
	end
end)

------------------------------------------------------------------------------------------------------------------------

-- bank lockdown timer
function handleLockdown()
    lockdownSecondsRemaining = Config.BankLockdown
    Citizen.CreateThread(function()
        while lockdownSecondsRemaining > 0 do
            Wait(1000)
            lockdownSecondsRemaining = lockdownSecondsRemaining - 1
        end
    end)
end

-- bank lockdown and reset after cooldown
Citizen.CreateThread(function()
	while true do
		Wait(1000)
		if robberystarted == true and lockdownactive == true then
			exports['rsg-core']:DrawText('Bank Lockdown in '..lockdownSecondsRemaining..' seconds!', 'left')
		end
		if lockdownSecondsRemaining == 0 and robberystarted == true and lockdownactive == true then
			-- lock doors
			for k,v in pairs(Config.VaultDoors) do
				Citizen.InvokeNative(0xD99229FE93B46286,v,1,1,0,0,0,0)
				Citizen.InvokeNative(0x6BAB9442830C7F53,v,1)
			end
			-- disable vault looting / trigger cooldown
			vault1 = true
			vault2 = true
			exports['rsg-core']:HideText()
			lockdownactive = false
			handleCooldown()
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------

-- cooldown timer
function handleCooldown()
    cooldownSecondsRemaining = Config.BankCooldown
    Citizen.CreateThread(function()
        while cooldownSecondsRemaining > 0 do
            Wait(1000)
            cooldownSecondsRemaining = cooldownSecondsRemaining - 1
        end
    end)
end

-- reset bank so it can be robbed again
Citizen.CreateThread(function()
	while true do
		Wait(1000)
		if lockdownactive == false and cooldownSecondsRemaining == 0 and robberystarted == true then
			-- confirm doors are locked
			for k,v in pairs(Config.VaultDoors) do
				Citizen.InvokeNative(0xD99229FE93B46286,v,1,1,0,0,0,0)
				Citizen.InvokeNative(0x6BAB9442830C7F53,v,1)
			end
			-- reset bank robbery
			robberystarted = false
			lockpicked = false
			dynamiteused = false
			vault1 = false
			vault2 = false
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------

function DrawText3Ds(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	exports['rsg-core']:createPrompt('rhopolicelock', vector3(1295.91, -1304.38, 77.04), RSGCore.Shared.Keybinds['J'], 'Emergency Menu', {
		type = 'client',
		event = 'rsg-rhodesbankheist:client:bankmenu',
		args = {},
	})
end)

-- emergency menu
RegisterNetEvent('rsg-rhodesbankheist:client:bankmenu', function()
    exports['rsg-menu']:openMenu({
        {
            header = 'Emergency Menu',
            isMenuHeader = true,
        },
        {
            header = "Lock Bank",
            txt = "used by law enforcement to lock bank in an emergency",
			icon = "fas fa-lock",
            params = {
                event = 'rsg-rhodesbankheist:client:policelock',
				isServer = false,
            }
        },
        {
            header = "Unlock Bank",
            txt = "used by law enforcement to unlock bank in an emergency",
			icon = "fas fa-lock-open",
            params = {
                event = 'rsg-rhodesbankheist:client:policeunlock',
				isServer = false,
            }
        },
        {
            header = "Close Menu",
            txt = '',
            params = {
                event = 'rsg-menu:closeMenu',
            }
        },
    })
end)

RegisterNetEvent('rsg-rhodesbankheist:client:policelock', function()
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.type == "police" then
			-- lock doors
			for k,v in pairs(Config.VaultDoors) do
				Citizen.InvokeNative(0x6BAB9442830C7F53,v,1)
			end
			TriggerEvent('rNotify:NotifyLeft', "emergency doors locked!", "success", "generic_textures", "tick", 4000)
        else
			TriggerEvent('rNotify:NotifyLeft', "law enforcement only!", "noob", "generic_textures", "tick", 4000)
		end
    end)
end)

RegisterNetEvent('rsg-rhodesbankheist:client:policeunlock', function()
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.type == "police" then
			-- lock doors
			for k,v in pairs(Config.VaultDoors) do
				Citizen.InvokeNative(0x6BAB9442830C7F53,v,0)
			end
			TriggerEvent('rNotify:NotifyLeft', "emergency doors unlocked!", "success", "generic_textures", "tick", 4000)
        else
			TriggerEvent('rNotify:NotifyLeft', "law enforcement only!", "noob", "generic_textures", "tick", 4000)
		end
    end)
end)

------------------------------------------------------------------------------------------------------------------------
