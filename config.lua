Config = {}

Config.Locale = 'de'

Config.Debug = true

Config.Notify = 2 --1: Native Notify; 2: ESX Notify; 3: Custom Notify

Config.Jobs = {
    ["lcn"] = {
        label = "LCN",
        whitelist = true,
        grades = {
            [10] = {label = "CO. Don", name = "2", salary = 100},
            [50] = {label = "DON", name = "1", salary = 100},
        }
    },
    ["ballers"] = {
        label = "LCN",
        whitelist = true,
        grades = {
            [1] = {label = "CO. Don", name = "2", salary = 100},
            [2] = {label = "DON", name = "1", salary = 100},
        }
    }
}

Config.JobSettings = {
--    job
    ["lcn"] = {

        blip = {
            active = false,
            name = "LCN",
            coords = vector3(3181.0, 3511.0, 70.50),
            sprite = 108,
            color = 1,
            scale = 0.9
        },


        society = {
            active = true,
            weapons = false,
            items = false,
            money = true
        },
        bossmenu = vector3(3181.0, 3511.0, 70.50), -- Only when society is active

        vehicle = {
            active = false,
            unlimited = false, -- No price to park out a vehicle
            maxParkout = 3, -- Max vehicles to park out
            tuning = { -- default tuning (https://docs.esx-framework.org/legacy/Client/functions/game/setvehicleproperties)
                color1 = 12, -- Color list at pastebin.com/pwHci0xK
                color2 = 131,
                plate = "LCN"
            },
            societyMoney = false, -- Use societyMoney to buy vehicles (only when unlimited = false)
            public = false, -- Share vehicle in job
            tunable = false
        },

        garage = {
            marker = vector3(3173.5, 3511.19, 71.24), -- Only when vehicle is active

            inShop = vector3(3173.5, 3511.19, 71.24), -- Only when unlimited = false
            inHeading = 212.23,

            outShop = vector3(3173.5, 3511.19, 71.24),
            outHeading = 212.23,

            parkIn = vector3(3173.5, 3511.19, 71.24),
            parkOut = vector3(3173.5, 3511.19, 71.24),
        }
    }
}

Config.Weapons = {
--    job
    ["lcn"] = {
--      Grade
        [50] = {
        --          Weapon            Price
            ["WEAPON_ADVANCEDRIFLE"] = 10
        },

        [30] = {
        --          Weapon            Price
            ["WEAPON_ADVANCEDRIFLE"] = 10
        }
    }
}

Config.Items = {
--    job
    ["lcn"] = {
--      Grade  
        [50] = {
        --    Item     Price
            ["water"] = 10
        }
    }
}

Config.Vehicles = {
    ["lcn"] = {
        [50] = {
            ["adder"] = 10,
            ["police"] = 10,
        }
    }
}