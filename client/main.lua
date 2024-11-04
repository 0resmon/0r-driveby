local peds = {}
local shooters = {}
local vehicle = nil

local selected_level = 1

CreateThread(function()
    local pedModel = GetHashKey(Config.MenuPed)
    RequestModel(pedModel)

    while not HasModelLoaded(pedModel) do
        Wait(0)
    end    
    menuped = CreatePed(0, pedModel, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z-1, Config.PedCoords.w, true, false)
    FreezeEntityPosition(menuped, true)
	SetEntityInvincible(menuped, true)
	SetBlockingOfNonTemporaryEvents(menuped, true)
	TaskStartScenarioInPlace(menuped, "WORLD_HUMAN_SMOKING", 0, true)

    local elements = {}
    for k,v in pairs(Config.Levels) do
        elements[#elements+1] = {
            title = "DriveBy Level "..k,
            description = "DriveBy Price $"..v.price,
            onSelect = function()
                TriggerEvent('0r-driveby-select', k)
            end
        }
    end
        
    lib.registerContext({
        id = '0r_driveby',
        title = 'DriveBy',
        options = elements
    })

    if Config.InteractType == 'drawtext' then
        while true do 
            local ms = 1000
            local ped = PlayerPedId()
            local pc = GetEntityCoords(ped)
            local dist = #(pc - vector3(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z))

            if dist < 2.0 then
                ms = 0 
                DrawText3D(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z+.9, '[~r~E~w~] Open DriveBy Menu')
                if IsControlJustPressed(0, 38) then
                    lib.showContext('0r_driveby')
                end
            end
            Wait(ms)
        end
    elseif Config.InteractType == 'qb-target' then
        exports['qb-target']:AddTargetEntity(menuped, {
            options = {
                {
                    label = 'DriveBy',
                    icon = 'fas fa-tasks',
                    action = function()
                        lib.showContext('0r_driveby')
                    end
                }
            },
            distance = 2.0
        })
    elseif Config.InteractType == 'ox_target' then
        exports.ox_target:addLocalEntity(menuped, {
			{
				name = '0r_driveby',
				onSelect = function()
                    lib.showContext('0r_driveby')
				end,
				icon = 'fas fa-tasks',
				label = 'DriveBy',
                distance = 2.0
			}
		})
    end
end)

RegisterNetEvent('0r-driveby-select', function(level)
    selected_level = tonumber(level)

    local input = lib.inputDialog('Player ID', {
        {type = 'number', label = 'Player ID', description = 'Type Player ID', icon = 'user'}
    })

    if input then
        if input[1] then
            TriggerServerEvent('0r-driveby-check', input[1], selected_level)
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  
    if onScreen then
      SetTextScale(0.25, 0.25)
      SetTextFont(0)
      SetTextProportional(1)
      SetTextColour(255, 255, 255, 215)
      SetTextDropShadow()
      SetTextDropshadow(0, 0, 0, 255)
      SetTextEdge(2, 0, 0, 0, 150)
      SetTextDropShadow()
      SetTextOutline()
      SetTextEntry("STRING")
      SetTextCentre(1)
  
      AddTextComponentString(text)
      DrawText(_x, _y)
    end
end

function createDriveby(level)
    Wait(30000)
    local startTime = GetGameTimer()
    local data = Config.Levels[level]
    local duration = data.MaxDrivebyMinute * 60 * 1000

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local vehicleCoords
    local foundValidLocation = false
    local foundedZ = 10

    while not foundValidLocation do
        local randomX = playerCoords.x + math.random(-70, 70)
        local randomY = playerCoords.y + math.random(-70, 70)
        local randomZ = playerCoords.z + 1.0

        vehicleCoords = vector3(randomX, randomY, randomZ)
        

        local xx, groundZ = GetGroundZFor_3dCoord(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 5.0, false)

        if IsPointOnRoad(vehicleCoords.x, vehicleCoords.y, groundZ) then
            foundedZ = groundZ
            if groundZ then
                if groundZ >= vehicleCoords.z - 2.0 then
                    foundValidLocation = true
                end
            end
        end

        Wait(300)
    end

    local vehicleModel = GetHashKey(data.vehmodel)
    RequestModel(vehicleModel)

    while not HasModelLoaded(vehicleModel) do
        Wait(0)
    end
    
    vehicle = CreateVehicle(vehicleModel, vehicleCoords.x, vehicleCoords.y, foundedZ, GetEntityHeading(playerPed), true, false)
    SetVehicleOnGroundProperly(vehicle)
    RollDownWindows(vehicle)

    local pedModel = GetHashKey(Config.Peds[math.random(1, #Config.Peds)])
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(0)
    end
    local driverped = CreatePed(0, pedModel, vehicleCoords + vector3(0, 1, 0), GetEntityHeading(vehicle), true, false)
    TaskWarpPedIntoVehicle(driverped, vehicle, -1)
    peds[#peds+1] = driverped
    SetPedFleeAttributes(driverped, 0, false)
    SetPedFleeAttributes(driverped, 1, false)
    SetPedFleeAttributes(driverped, 2, false)
    SetPedCombatAttributes(driverped, 46, true)
    SetPedCombatAttributes(driverped, 5, false) 
    SetPedCombatMovement(driverped, 2)
    SetPedCombatRange(driverped, 2)
    SetPedSeeingRange(driverped, 100000000.0)
    SetPedHearingRange(driverped, 100000000.0)
    SetEntityAsMissionEntity(driverped, true, true)
    SetBlockingOfNonTemporaryEvents(driverped, true)
    SetEntityAsMissionEntity(driverped, true, true)

    local seat = 0
    for i=1, data.shooterpeds do
        local pedModel2 = GetHashKey(Config.Peds[math.random(1, #Config.Peds)])
        RequestModel(pedModel2)

        while not HasModelLoaded(pedModel2) do
            Wait(0)
        end
        
        local ped2 = CreatePed(0, pedModel2, vehicleCoords + vector3(0, 1, 0), GetEntityHeading(vehicle), true, false)
        SetPedFleeAttributes(ped2, 0, false)
        SetPedFleeAttributes(ped2, 1, true)
        SetPedCombatAttributes(ped2, 46, true)
        SetEntityAsMissionEntity(ped2, true, true)
        TaskWarpPedIntoVehicle(ped2, vehicle, seat)
        GiveWeaponToPed(ped2, GetHashKey(data.weapon), 255, true, true)
        shooters[#shooters+1] = ped2
        seat = seat + 1
        Wait(200)
    end
    local playerCoords = GetEntityCoords(playerPed)
    CreateThread(function()
        while true do
            local currentTime = GetGameTimer()
            local elapsedTime = currentTime - startTime
            if elapsedTime >= duration then
                TaskVehicleDriveWander(driverped, vehicle, 50.0, 6)
                Wait(10000)
                DeleteVehicle(vehicle)
                for _,ped in pairs(shooters) do
                    if ped then
                        DeleteEntity(ped)
                    end
                end
                for _,ped in pairs(peds) do
                    if ped then
                        DeleteEntity(ped)
                    end
                end
                
                peds = {}
                shooters = {}
                vehicle = nil
                break
            else
                if DoesEntityExist(playerPed) then
                    if IsPedInAnyVehicle(playerPed) then
                        ClearPedTasks(driverPed)
                        SetDriverAbility(driverped, 1.0)
                        TaskVehicleChase(driverped, playerPed)
                        SetPedFleeAttributes(driverped, 0, false)
                        SetPedFleeAttributes(driverped, 1, false)
                        SetPedFleeAttributes(driverped, 2, false)
                        SetPedCombatAttributes(driverped, 46, true)
                        SetPedCombatAttributes(driverped, 5, false) 
                        SetPedCombatMovement(driverped, 2)
                        SetPedCombatRange(driverped, 2)
                        SetPedSeeingRange(driverped, 100000000.0)
                        SetPedHearingRange(driverped, 100000000.0)
                        SetEntityAsMissionEntity(driverped, true, true)
                        SetBlockingOfNonTemporaryEvents(driverped, true)
                        for k,v in pairs(shooters) do
                            TaskVehicleShootAtPed(v, playerPed, 1)
                        end
                    else
                        TaskVehicleFollow(driverped, vehicle, playerPed, 25.0, 794628)
                        SetDriverAbility(driverped, 1.0)
                        SetDriverAggressiveness(driverped, 1.0)
                        for k,v in pairs(shooters) do
                            TaskVehicleShootAtPed(v, playerPed, 1)
                        end
                    end
                end
                if Config.IsDead() then
                    TaskVehicleDriveWander(driverped, vehicle, 50.0, 6)
                    Wait(10000)
                    DeleteVehicle(vehicle)
                    for _,ped in pairs(shooters) do
                        if ped then
                            DeleteEntity(ped)
                        end
                    end
                    for _,ped in pairs(peds) do
                        if ped then
                            DeleteEntity(ped)
                        end
                    end
                    
                    peds = {}
                    shooters = {}
                    vehicle = nil
                    break
                end
            end
            Wait(2000) 
        end
    end)
end

RegisterNetEvent('0r-driveby-attach', createDriveby)