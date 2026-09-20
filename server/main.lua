local function ClampCondition(value)
    value = tonumber(value) or Config.DefaultCondition
    return math.max(0.0, math.min(value, 100.0))
end

local function GetValidatedDrivenVehicle(src, netId)
    netId = tonumber(netId)
    if not netId or netId <= 0 then return 0 end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return 0 end

    local ped = GetPlayerPed(src)
    if ped == 0 or not DoesEntityExist(ped) then return 0 end

    if GetVehiclePedIsIn(ped, false) ~= vehicle then return 0 end
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return 0 end

    return vehicle
end

RegisterNetEvent('agc-vehicledamage:server:setCondition', function(netId, condition)
    local src = source
    local vehicle = GetValidatedDrivenVehicle(src, netId)
    if vehicle == 0 then return end

    condition = ClampCondition(condition)
    Entity(vehicle).state:set(Config.StateBagKey, condition, true)
    TriggerClientEvent('agc-vehicledamage:client:conditionUpdated', -1, tonumber(netId), condition)
end)

RegisterNetEvent('agc-vehicledamage:server:repairVehicle', function(netId)
    local src = source
    local vehicle = GetValidatedDrivenVehicle(src, netId)
    if vehicle == 0 then return end

    local condition = Config.DefaultCondition
    Entity(vehicle).state:set(Config.StateBagKey, condition, true)
    TriggerClientEvent('agc-vehicledamage:client:conditionUpdated', -1, tonumber(netId), condition)
end)

-- Server export for trusted server-side integrations that already have an entity handle.
exports('RepairVehicle', function(vehicle)
    vehicle = tonumber(vehicle) or 0
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    Entity(vehicle).state:set(Config.StateBagKey, Config.DefaultCondition, true)

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId and netId > 0 then
        TriggerClientEvent('agc-vehicledamage:client:conditionUpdated', -1, netId, Config.DefaultCondition)
    end

    return true
end)
