print("CLIENT SPAWN TRIGGERED")

local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('hayabusa-valet:server:GetVehicles', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT * FROM player_vehicles WHERE citizenid = ? AND in_garage = ?', {
    citizenid,
    1
}, function(result)
        TriggerClientEvent('hayabusa-valet:client:ReceiveVehicles', src, result)
    end)
end)

RegisterNetEvent('hayabusa-valet:server:SpawnVehicle', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cleanPlate = string.gsub(plate, "%s+", "")

    MySQL.single('SELECT * FROM player_vehicles WHERE REPLACE(plate, " ", "") = ? AND state = 1', {
        cleanPlate
    }, function(vehicle)
        if not vehicle then
            TriggerClientEvent('QBCore:Notify', src, 'Vehicle not found or not stored!', 'error')
            return
        end

        if Player.Functions.RemoveMoney('bank', Config.ValetFee) then
            TriggerClientEvent('hayabusa-valet:client:SpawnVehicle', src, vehicle)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Not enough money!', 'error')
        end
    end)
end)