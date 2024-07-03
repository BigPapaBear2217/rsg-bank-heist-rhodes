Config = {}

-- settings
Config.MinimumLawmen = 0 -- amount of lawman needed for heist
Config.BankLockdown = 300 -- amount of seconds until bank lockdown (300 = 5 mins)
Config.BankCooldown = 3600 -- amount of time in seconds until bank can be robbed again (3600 = 1hr)

Config.AlarmTime = 75000 -- ALARM TIM
Config.AlarmVolume = 0.2 -- ALARM VOLUME
Config.AlarmRadius = 100 -- ALARM RADIUS TO HEAR
Config.AlarmRing = "https://www.youtube.com/watch?v=qrNZrr9lD7k" -- ALARM LINK SOUND


-- lock bank doors
Config.VaultDoors = {
	1634148892, -- gate locked (no access)
	3142122679, -- backdoor locked (no access)
	2058564250, -- corridor door (use lockpick)
	3483244267, -- vault door (use dynamite)
}

-- set the item rewards
Config.RewardItems = {
    'goldbar', -- example
	'goldwatch', -- example
	--'moneybag', -- example
	--'ruby', -- example
	--'diamond', -- example
	--'emerald', -- example
}

-- set item rewards amount
Config.SmallRewardAmount = 1
Config.MediumRewardAmount = 2
Config.LargeRewardAmount = 3

-- set the money award gveing for large reward amount
Config.MoneyRewardType = 'bloodmoney' -- cash or bloodmoney
Config.MoneyRewardAmount = math.random(300,400) -- amount of money to give player

Config.HeistNpcs = {
	[1] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(1298.1922, -1298.921, 77.028564 -1), ["Heading"] = 323.39672 },
	[2] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(1291.1708, -1293.379, 76.439674 -1), ["Heading"] = 306.5007 },
	[3] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(1278.746, -1311.409, 76.929656 -1), ["Heading"] = 141.41909 },
	[4] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(1299.3488, -1299.0258, 77.0323 -1), ["Heading"] = 93.0116 },
	[5] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(1299.5575, -1293.8988, 76.3873 -1), ["Heading"] = 93.0116 },
}

-- -1 DOORSTATE_INVALID,
-- 0 DOORSTATE_UNLOCKED,
-- 1 DOORSTATE_LOCKED_UNBREAKABLE,
-- 2 DOORSTATE_LOCKED_BREAKABLE,
-- 3 DOORSTATE_HOLD_OPEN_POSITIVE,
-- 4 DOORSTATE_HOLD_OPEN_NEGATIVE