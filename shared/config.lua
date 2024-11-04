Config = {
    MenuPed = 'g_m_m_chicold_01',
    Framework = 'esx', -- [ 'qb' / 'esx' ]
    PedCoords = vector4(109.7, -1797.88, 27.08, 146.54),

    InteractType = 'ox_target', -- [ 'drawtext' / 'qb-target' / 'ox_target' ]

    Notify = function(text, type, server, src)
        if server then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Notification',
                description = text,
                type = type
            })
        else
            lib.notify({
                title = 'Notification',
                description = text,
                type = type
            })
        end
    end,

    IsDead = function()
        return IsPlayerDead(PlayerId())
        -- return exports['qb-ambulancejob']:isDead()
        -- return exports['ars_ambulancejob']:isDead()
    end,

    Levels = {
        [1] = {
            price = 1000,
            vehmodel = 'speedo',
            shooterpeds = 1, -- (minimum 1 - max 3) for tis level
            weapon = 'WEAPON_PISTOL',
            MaxDrivebyMinute = 1, -- 1 minute
        },
        [2] = {
            price = 2000,
            vehmodel = 'sultan',
            shooterpeds = 2, -- (minimum 1 - max 3) for tis level
            weapon = 'WEAPON_PISTOL',
            MaxDrivebyMinute = 2, -- 2 minute
        },
        [3] = {
            price = 5000,
            vehmodel = 'kuruma',
            shooterpeds = 3, -- (minimum 1 - max 3) for tis level
            weapon = 'WEAPON_MACHINEPISTOL',
            MaxDrivebyMinute = 3, -- 3 minute
        }
    },

    Peds = {
        'g_m_y_mexgoon_02',
        'g_m_y_mexgoon_03',
        'g_m_y_famfor_01',
        'g_m_y_armgoon_02',
        'g_m_importexport_01',
        'g_m_m_armboss_01'
    }
}