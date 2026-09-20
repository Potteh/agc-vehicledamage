local currentVehicle = 0
local vehicleCondition = Config.DefaultCondition
local lastSyncedCondition = Config.DefaultCondition

local previousSpeed = 0.0
local previousBodyHealth = 1000.0
local previousEngineHealth = 1000.0
local previousTankHealth = 1000.0

local lastCollision = 0
local rolloverTimer = 0
local initialized = false
local lastRepairAt = 0

local function Debug(message)
    if Config.Debug then print(('[agc-vehicledamage] %s'):format(message)) end
end

local function Notify(message)
    TriggerEvent('chat:addMessage', {
        color = {255, 180, 0},
        args = {'Vehicle Damage', message}
    })
end

local function ReadCondition(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return Config.DefaultCondition end
    local value = Entity(vehicle).state[Config.StateBagKey]
    if value == nil then return Config.DefaultCondition end
    return AGCDamage.ClampCondition(value)
end

local function SyncCondition(vehicle, force)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    vehicleCondition = AGCDamage.ClampCondition(vehicleCondition)

    if not force and math.abs(vehicleCondition - lastSyncedCondition) < Config.SyncChangeThreshold then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId == 0 then
        Debug('Unable to sync condition: no network ID.')
        return
    end

    TriggerServerEvent('agc-vehicledamage:server:setCondition', netId, vehicleCondition)
    lastSyncedCondition = vehicleCondition
end

local function RepairMechanical(vehicle, notifyPlayer)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    vehicleCondition = Config.DefaultCondition
    lastSyncedCondition = Config.DefaultCondition
    lastRepairAt = GetGameTimer()

    SetVehicleUndriveable(vehicle, false)

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId ~= 0 then
        TriggerServerEvent('agc-vehicledamage:server:repairVehicle', netId)
    end

    previousBodyHealth = GetVehicleBodyHealth(vehicle)
    previousEngineHealth = GetVehicleEngineHealth(vehicle)
    previousTankHealth = GetVehiclePetrolTankHealth(vehicle)
    previousSpeed = AGCDamage.GetSpeedMPH(vehicle)

    if notifyPlayer then
        Notify('Mechanical condition restored to 100%.')
    end

    Debug('Mechanical condition repaired to 100%.')
    return true
end

local function ResetVehicleState(vehicle)
    currentVehicle = vehicle
    vehicleCondition = ReadCondition(vehicle)
    lastSyncedCondition = vehicleCondition

    previousSpeed = AGCDamage.GetSpeedMPH(vehicle)
    previousBodyHealth = GetVehicleBodyHealth(vehicle)
    previousEngineHealth = GetVehicleEngineHealth(vehicle)
    previousTankHealth = GetVehiclePetrolTankHealth(vehicle)

    rolloverTimer = 0
    lastCollision = 0
    initialized = true

    if Entity(vehicle).state[Config.StateBagKey] == nil then
        SyncCondition(vehicle, true)
    end

    Debug(('Vehicle initialized: %s | condition %.2f'):format(vehicle, vehicleCondition))
end

local function LeaveVehicle()
    if initialized and currentVehicle ~= 0 and DoesEntityExist(currentVehicle) then
        SyncCondition(currentVehicle, true)
    end

    currentVehicle = 0
    initialized = false
    vehicleCondition = Config.DefaultCondition
    lastSyncedCondition = Config.DefaultCondition
    previousSpeed = 0.0
    previousBodyHealth = 1000.0
    previousEngineHealth = 1000.0
    previousTankHealth = 1000.0
    rolloverTimer = 0
    lastCollision = 0
end

local function ApplyMechanicalDamage(amount)
    if amount <= 0.0 then return end

    local oldCondition = vehicleCondition
    vehicleCondition = AGCDamage.ClampCondition(vehicleCondition - amount)

    Debug(('Damage %.2f | %.2f -> %.2f'):format(amount, oldCondition, vehicleCondition))

    if currentVehicle ~= 0 then SyncCondition(currentVehicle, true) end

    if oldCondition > Config.PowerLossStart and vehicleCondition <= Config.PowerLossStart then
        Notify('The vehicle has suffered mechanical damage. Engine performance is reduced.')
    elseif oldCondition > Config.SeverePowerLossStart and vehicleCondition <= Config.SeverePowerLossStart then
        Notify('Severe mechanical damage detected. Drive carefully.')
    elseif oldCondition > Config.StallThreshold and vehicleCondition <= Config.StallThreshold then
        Notify('Critical engine damage. The engine may stall.')
    elseif oldCondition > Config.DisableThreshold and vehicleCondition <= Config.DisableThreshold then
        Notify('The vehicle is mechanically disabled.')
    end
end

local function HandleEngine(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    if vehicleCondition <= Config.DisableThreshold then
        SetVehicleEngineTorqueMultiplier(vehicle, 0.0)
        SetVehicleUndriveable(vehicle, true)
        SetVehicleEngineOn(vehicle, false, true, true)
        return
    end

    SetVehicleUndriveable(vehicle, false)

    if vehicleCondition <= Config.StallThreshold and GetIsVehicleEngineRunning(vehicle) then
        if math.random(1, 1000) <= 4 then
            SetVehicleEngineOn(vehicle, false, true, true)
            Debug('Engine stalled.')
        end
    end
end

local function HandleRollover(vehicle)
    if not Config.EnableRolloverDamage then return end

    if math.abs(GetEntityRoll(vehicle)) > 75.0 then
        rolloverTimer = rolloverTimer + Config.UpdateInterval
        if rolloverTimer >= 1000 then
            ApplyMechanicalDamage(Config.RolloverDamagePerSecond)
            rolloverTimer = 0
        end
    else
        rolloverTimer = 0
    end
end

local function DetectFullRepair(vehicle, body, engine, tank)
    if not Config.EnableAutomaticRepairDetection then return false end
    if vehicleCondition >= 99.9 then return false end
    if (GetGameTimer() - lastRepairAt) < Config.RepairDetectionCooldownMs then return false end

    local nowHealthy =
        body >= Config.RepairDetectionBodyHealth and
        engine >= Config.RepairDetectionEngineHealth and
        tank >= Config.RepairDetectionPetrolTankHealth

    if not nowHealthy then return false end

    -- A repair command generally causes one or more native health values to jump
    -- substantially upward in a single update. This prevents normal healthy
    -- vehicles from silently clearing AGC damage.
    local bodyJump = body - previousBodyHealth
    local engineJump = engine - previousEngineHealth
    local tankJump = tank - previousTankHealth

    if bodyJump >= 25.0 or engineJump >= 25.0 or tankJump >= 25.0 then
        RepairMechanical(vehicle, false)
        return true
    end

    return false
end

CreateThread(function()
    math.randomseed(GetGameTimer())

    while true do
        Wait(Config.UpdateInterval)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then
            if initialized then LeaveVehicle() end
        else
            if not initialized or vehicle ~= currentVehicle then
                ResetVehicleState(vehicle)
            else
                local replicatedCondition = ReadCondition(vehicle)
                if math.abs(replicatedCondition - lastSyncedCondition) >= Config.SyncChangeThreshold then
                    vehicleCondition = replicatedCondition
                    lastSyncedCondition = replicatedCondition
                end

                local currentSpeed = AGCDamage.GetSpeedMPH(vehicle)
                local currentBodyHealth = GetVehicleBodyHealth(vehicle)
                local currentEngineHealth = GetVehicleEngineHealth(vehicle)
                local currentTankHealth = GetVehiclePetrolTankHealth(vehicle)
                local gameTimer = GetGameTimer()

                local repaired = DetectFullRepair(vehicle, currentBodyHealth, currentEngineHealth, currentTankHealth)

                if not repaired then
                    if HasEntityCollidedWithAnything(vehicle)
                        and (gameTimer - lastCollision) >= Config.CollisionCooldown then

                        local damage = AGCDamage.CalculateImpact(
                            vehicle,
                            previousSpeed,
                            currentSpeed,
                            previousBodyHealth,
                            currentBodyHealth,
                            previousEngineHealth,
                            currentEngineHealth
                        )

                        if damage > 0.0 then
                            ApplyMechanicalDamage(damage)
                            lastCollision = gameTimer
                        end
                    end

                    HandleRollover(vehicle)
                    HandleEngine(vehicle)

                    if Config.ProtectEngineHealth
                        and currentEngineHealth < Config.MinimumProtectedEngineHealth
                        and vehicleCondition > Config.DisableThreshold then
                        SetVehicleEngineHealth(vehicle, Config.MinimumProtectedEngineHealth)
                        currentEngineHealth = Config.MinimumProtectedEngineHealth
                    end
                end

                previousSpeed = currentSpeed
                previousBodyHealth = GetVehicleBodyHealth(vehicle)
                previousEngineHealth = GetVehicleEngineHealth(vehicle)
                previousTankHealth = GetVehiclePetrolTankHealth(vehicle)
            end
        end
    end
end)

CreateThread(function()
    while true do
        if initialized and currentVehicle ~= 0 and DoesEntityExist(currentVehicle) then
            local ped = PlayerPedId()
            if GetPedInVehicleSeat(currentVehicle, -1) == ped then
                SetVehicleEngineTorqueMultiplier(currentVehicle, AGCDamage.GetTorqueMultiplier(vehicleCondition))
                Wait(0)
            else
                Wait(250)
            end
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('agc-vehicledamage:client:conditionUpdated', function(netId, condition)
    local vehicle = NetToVeh(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    if initialized and vehicle == currentVehicle then
        vehicleCondition = AGCDamage.ClampCondition(condition)
        lastSyncedCondition = vehicleCondition
    end
end)

-- Public event for client resources that repair a vehicle.
RegisterNetEvent('agc-vehicledamage:client:repairVehicle', function(vehicle)
    vehicle = tonumber(vehicle) or 0
    if vehicle == 0 then
        local ped = PlayerPedId()
        vehicle = GetVehiclePedIsIn(ped, false)
    end

    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        RepairMechanical(vehicle, false)
    end
end)

RegisterCommand('vehstatus', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        Notify('You are not inside a vehicle.')
        return
    end

    local mechanical = ReadCondition(vehicle)
    if initialized and vehicle == currentVehicle then mechanical = vehicleCondition end

    Notify(('Mechanical: %.0f%% | Engine: %.0f | Body: %.0f | Speed: %.0f MPH'):format(
        mechanical,
        GetVehicleEngineHealth(vehicle),
        GetVehicleBodyHealth(vehicle),
        AGCDamage.GetSpeedMPH(vehicle)
    ))
end, false)

RegisterCommand('vehdamagedebug', function()
    Config.Debug = not Config.Debug
    Notify(('Debug mode: %s'):format(Config.Debug and 'ON' or 'OFF'))
end, false)

exports('GetVehicleMechanicalCondition', function(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    if initialized and vehicle == currentVehicle then return vehicleCondition end
    return ReadCondition(vehicle)
end)

exports('RepairVehicle', function(vehicle)
    return RepairMechanical(vehicle, false)
end)
