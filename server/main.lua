local function Clamp(value)
    value = tonumber(value) or 100.0
    return math.max(0.0, math.min(value, 100.0))
end

local function ClampTemperature(value)
    value = tonumber(value) or Config.DefaultComponents.temperature
    return math.max(0.0, math.min(value, Config.MaximumTemperature))
end

local function SanitizeComponents(data)
    data = type(data) == 'table' and data or {}
    return {
        radiator = Clamp(data.radiator or Config.DefaultComponents.radiator),
        transmission = Clamp(data.transmission or Config.DefaultComponents.transmission),
        oil = Clamp(data.oil or Config.DefaultComponents.oil),
        fuelSystem = Clamp(data.fuelSystem or Config.DefaultComponents.fuelSystem),
        temperature = ClampTemperature(data.temperature or Config.DefaultComponents.temperature)
    }
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
    local vehicle = GetValidatedDrivenVehicle(source, netId)
    if vehicle == 0 then return end
    condition = Clamp(condition)
    Entity(vehicle).state:set(Config.StateBagKey, condition, true)
    TriggerClientEvent('agc-vehicledamage:client:conditionUpdated', -1, tonumber(netId), condition)
end)

RegisterNetEvent('agc-vehicledamage:server:setComponents', function(netId, components)
    local vehicle = GetValidatedDrivenVehicle(source, netId)
    if vehicle == 0 then return end
    local clean = SanitizeComponents(components)
    Entity(vehicle).state:set(Config.ComponentStateKey, clean, true)
    TriggerClientEvent('agc-vehicledamage:client:componentsUpdated', -1, tonumber(netId), clean)
end)

RegisterNetEvent('agc-vehicledamage:server:repairVehicle', function(netId)
    local vehicle = GetValidatedDrivenVehicle(source, netId)
    if vehicle == 0 then return end
    local components = SanitizeComponents(Config.DefaultComponents)
    Entity(vehicle).state:set(Config.StateBagKey, Config.DefaultCondition, true)
    Entity(vehicle).state:set(Config.ComponentStateKey, components, true)
    TriggerClientEvent('agc-vehicledamage:client:conditionUpdated', -1, tonumber(netId), Config.DefaultCondition)
    TriggerClientEvent('agc-vehicledamage:client:componentsUpdated', -1, tonumber(netId), components)
end)

exports('RepairVehicle', function(vehicle)
    vehicle = tonumber(vehicle) or 0
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    local components = SanitizeComponents(Config.DefaultComponents)
    Entity(vehicle).state:set(Config.StateBagKey, Config.DefaultCondition, true)
    Entity(vehicle).state:set(Config.ComponentStateKey, components, true)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId and netId > 0 then
        TriggerClientEvent('agc-vehicledamage:client:conditionUpdated', -1, netId, Config.DefaultCondition)
        TriggerClientEvent('agc-vehicledamage:client:componentsUpdated', -1, netId, components)
    end
    return true
end)
