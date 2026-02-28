local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand(Config.Command, function()
    TriggerServerEvent('hayabusa-valet:server:GetVehicles')
end)

if Config.UseHotkey then
    RegisterKeyMapping(Config.Command, 'Open Valet Menu', 'keyboard', Config.Hotkey)
end

RegisterNetEvent('hayabusa-valet:client:ReceiveVehicles', function(vehicles)

    if #vehicles == 0 then
        QBCore.Functions.Notify('No stored vehicles found', 'error')
        return
    end

    local Menu = {
        {
            header = "🚗 Valet Service",
            isMenuHeader = true
        }
    }

    for _, v in pairs(vehicles) do

    local vehicleLabel

    if v.nickname and v.nickname ~= "" and v.nickname ~= "NULL" then
        vehicleLabel = v.nickname
    else
        vehicleLabel = v.vehicle
    end

    Menu[#Menu+1] = {
        header = vehicleLabel .. " [" .. v.plate .. "]",
        txt = "Click to call this vehicle ($" .. Config.ValetFee .. ")",
        params = {
            event = "hayabusa-valet:client:SelectVehicle",
            args = v.plate
        }
    }
end

    exports['qb-menu']:openMenu(Menu)
end)

RegisterNetEvent('hayabusa-valet:client:SelectVehicle', function(plate)
    TriggerServerEvent('hayabusa-valet:server:SpawnVehicle', plate)
end)

RegisterNetEvent('hayabusa-valet:client:SpawnVehicle', function(vehicleData)

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)

    local found, spawnCoords, spawnHeading = GetClosestVehicleNodeWithHeading(
        playerCoords.x + math.random(-15, 15),
        playerCoords.y + math.random(-15, 15),
        playerCoords.z,
        1,
        3.0,
        0
    )

    if not found then
        QBCore.Functions.Notify("Valet couldn't find a road nearby.", "error")
        return
    end

    QBCore.Functions.SpawnVehicle(vehicleData.vehicle, function(veh)

        SetVehicleNumberPlateText(veh, vehicleData.plate)

        -- 👇 Apply saved properties (mods, colors, extras, etc)
        if vehicleData.mods then
           local props = json.decode(vehicleData.mods)
           if props then
           QBCore.Functions.SetVehicleProperties(veh, props)
           end
      end

        SetEntityHeading(veh, spawnHeading)
        SetEntityAsMissionEntity(veh, true, true)

        -- valet ped
        local model = `s_m_m_valet_01`
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local valetPed = CreatePed(4, model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, true, false)

        SetPedIntoVehicle(valetPed, veh, -1)
        SetBlockingOfNonTemporaryEvents(valetPed, true)
        SetDriverAbility(valetPed, 1.0)
        SetDriverAggressiveness(valetPed, 0.0)

        local valetBlip = AddBlipForEntity(veh)
        SetBlipSprite(valetBlip, 225)
        SetBlipColour(valetBlip, 5)
        SetBlipScale(valetBlip, 0.85)
        SetBlipAsShortRange(valetBlip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Your Valet")
        EndTextCommandSetBlipName(valetBlip)

        QBCore.Functions.Notify("Your valet is on the way...", "primary")

        TaskVehicleDriveToCoordLongrange(
            valetPed,
            veh,
            playerCoords.x,
            playerCoords.y,
            playerCoords.z,
            25.0,
            447,
            5.0
        )

        CreateThread(function()
            while DoesEntityExist(veh) and #(GetEntityCoords(veh) - playerCoords) > 8.0 do
                Wait(1000)
            end

            if DoesBlipExist(valetBlip) then
                RemoveBlip(valetBlip)
            end

            TaskVehicleTempAction(valetPed, veh, 27, 3000)
            Wait(2500)

            TaskLeaveVehicle(valetPed, veh, 0)
            Wait(1500)

            TaskGoToEntity(valetPed, playerPed, -1, 2.0, 2.0, 0, 0)

            while #(GetEntityCoords(valetPed) - playerCoords) > 2.0 do
                Wait(500)
            end

            ClearPedTasks(valetPed)

            RequestAnimDict("mp_common")
            while not HasAnimDictLoaded("mp_common") do Wait(0) end

            TaskPlayAnim(valetPed, "mp_common", "givetake1_a", 8.0, -8, 2000, 0, 0, false, false, false)
            TaskPlayAnim(playerPed, "mp_common", "givetake1_b", 8.0, -8, 2000, 0, 0, false, false, false)

            Wait(2000)

            TriggerEvent("vehiclekeys:client:SetOwner", vehicleData.plate)

            QBCore.Functions.Notify("Your vehicle has arrived. Drive safe!", "success")

            TaskWanderStandard(valetPed, 10.0, 10)
            Wait(15000)
            DeletePed(valetPed)
        end)

    end, spawnCoords, true)
end)