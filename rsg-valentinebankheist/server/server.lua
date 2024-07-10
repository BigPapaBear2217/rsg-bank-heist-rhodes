local RSGCore = exports['rsg-core']:GetCoreObject()

-- give reward
RegisterServerEvent('rsg-valentinebankheist:server:reward')
AddEventHandler('rsg-valentinebankheist:server:reward', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local chance = math.random(1,100)
    if chance <= 50 then
        local item1 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        local item2 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        local item3 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        -- add items
        Player.Functions.AddItem(item1, Config.SmallRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item1], "add")
        Player.Functions.AddItem(item2, Config.SmallRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item2], "add")
        Player.Functions.AddItem(item3, Config.SmallRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item3], "add")
		TriggerClientEvent('rNotify:NotifyLeft', src, "small loot", "nice work", "generic_textures", "tick", 4000)
    elseif chance >= 50 and chance <= 80 then -- medium reward
        local item1 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        local item2 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        local item3 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        -- add items
        Player.Functions.AddItem(item1, Config.MediumRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item1], "add")
        Player.Functions.AddItem(item2, Config.MediumRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item2], "add")
        Player.Functions.AddItem(item3, Config.MediumRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item3], "add")
		TriggerClientEvent('rNotify:NotifyLeft', src, "medium loot", "nice work", "generic_textures", "tick", 4000)
    elseif chance > 80 then -- large reward
        local item1 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        local item2 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        local item3 = Config.RewardItems[math.random(1, #Config.RewardItems)]
        -- add items
        Player.Functions.AddItem(item1, Config.LargeRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item1], "add")
        Player.Functions.AddItem(item2, Config.LargeRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item2], "add")
        Player.Functions.AddItem(item3, Config.LargeRewardAmount)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item3], "add")
        Player.Functions.AddMoney(Config.MoneyRewardType, Config.MoneyRewardAmount, "bank-heist")
		TriggerClientEvent('rNotify:NotifyLeft', src, "large loot", "nice work", "generic_textures", "tick", 4000)
        Wait(5000)
        TriggerClientEvent('rNotify:Notify', src, 'addtional '..Config.MoneyRewardAmount..' '..Config.MoneyRewardType..' looted!', 'primary')
    end
end)

-- remove item
RegisterNetEvent('rsg-valentinebankheist:server:removeItem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[item], "remove")
end)

local ALARMS = {}
RegisterServerEvent('BANK:ALARM')
AddEventHandler('BANK:ALARM', function(coords, player)
    if not ALARMS[player] then
        ALARMS[player] = true
        exports["xsound"]:PlayUrlPos(-1, "alarm2", Config.AlarmRing, Config.AlarmVolume, coords, true)
        exports["xsound"]:Distance(-1, "alarm2", Config.AlarmRadius) 
        Wait(Config.AlarmTime)
        exports["xsound"]:Destroy(-1, "alarm2")
        ALARMS[player] = nil
   end
end)