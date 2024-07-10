Config = {}

-- settings
Config.MinimumLawmen = 1 -- amount of lawman needed for heist
Config.BankLockdown = 300 -- amount of seconds until bank lockdown (300 = 5 mins)
Config.BankCooldown = 3600 -- amount of time in seconds until bank can be robbed again (3600 = 1hr)
Config.AlarmTime = 75000 -- ALARM TIM
Config.AlarmVolume = 0.2 -- ALARM VOLUME
Config.AlarmRadius = 100 -- ALARM RADIUS TO HEAR
Config.AlarmRing = "https://www.youtube.com/watch?v=qrNZrr9lD7k" -- ALARM LINK SOUND

-- lock bank doors
Config.VaultDoors = {
	2117902999, -- management door1 (lockpick)
	1462330364, -- vault door (use dynamite)
}

-- set the item rewards
Config.RewardItems = {
    'goldbar', -- example
    'goldwatch', -- example
    'moneybag', -- example
}

-- set item rewards amount
Config.SmallRewardAmount = 3
Config.MediumRewardAmount = 6
Config.LargeRewardAmount = 9

-- set the money award given for large reward amount
Config.MoneyRewardType = 'bloodmoney' -- cash or bloodmoney
Config.MoneyRewardAmount = math.random(600,800) -- amount of money to give player

Config.HeistNpcs = {
	[1] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(-825.88, -1279.15, 43.62 -0.8), ["Heading"] = 323.39672 },
	[2] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(-824.98, -1264.36, 43.6 -0.8), ["Heading"] = 306.5007 },
	[3] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(-843.52, -1282.91, 43.38 -0.8), ["Heading"] = 141.41909 },
	
}

-- -1 DOORSTATE_INVALID,
-- 0 DOORSTATE_UNLOCKED,
-- 1 DOORSTATE_LOCKED_UNBREAKABLE,
-- 2 DOORSTATE_LOCKED_BREAKABLE,
-- 3 DOORSTATE_HOLD_OPEN_POSITIVE,
-- 4 DOORSTATE_HOLD_OPEN_NEGATIVE