local currentVehicle = 0
local vehicleCondition = Config.DefaultCondition
local lastSyncedCondition = Config.DefaultCondition

local previousSpeed = 0.0
local previousBodyHealth = 1000.0
local previousEngineHealth = 1000.0
local previousTankHealth = 1000.0

local lastCollision = 0
local rolloverTimer = 0
local degradationTimer = 0
local initialized = false
local lastRepairAt = 0
local catastrophicFailure = false

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
    if netId == 0 then return end

    TriggerServerEvent('agc-vehicledamage:server:setCondition', netId, vehicleCondition)
    lastSyncedCondition = vehicleCondition
end

local function RepairMechanical(vehicle, notifyPlayer)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    vehicleCondition = Config.DefaultCondition
    lastSyncedCondition = Config.DefaultCondition
    catastrophicFailure = false
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

    if notifyPlayer then Notify('Mechanical condition restored to 100%.') end
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
    degradationTimer = 0
    lastCollision = 0
    catastrophicFailure = false
    initialized = true

    if Entity(vehicle).state[Config.StateBagKey] == nil then
        SyncCondition(vehicle, true)
    end
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
    degradationTimer = 0
    lastCollision = 0
    catastrophicFailure = false
end

local function ApplyMechanicalDamage(amount)
    if amount <= 0.0 then return end

    local oldCondition = vehicleCondition
    vehicleCondition = AGCDamage.ClampCondition(vehicleCondition - amount)

    if currentVehicle ~= 0 then SyncCondition(currentVehicle, true) end

    if oldCondition > Config.PowerLossStart and vehicleCondition <= Config.PowerLossStart then
        Notify('Mechanical damage detected. Engine performance is reduced.')
    elseif oldCondition > Config.SeverePowerLossStart and vehicleCondition <= Config.SeverePowerLossStart then
        Notify('Severe mechanical damage. Drive carefully.')
    elseif oldCondition > Config.StallThreshold and vehicleCondition <= Config.StallThreshold then
        Notify('Critical mechanical damage. The engine may stall.')
    elseif oldCondition > Config.DisableThreshold and vehicleCondition <= Config.DisableThreshold then
        Notify('The vehicle is mechanically disabled.')
    end
end

local function ApplySystemDamageToMechanical(currentBody, currentEngine)
    local bodyLoss = math.max(previousBodyHealth - currentBody, 0.0)
    local engineLoss = math.max(previousEngineHealth - currentEngine, 0.0)

    local wear =
        (bodyLoss * Config.BodyMechanicalDamageFactor) +
        (engineLoss * Config.EngineMechanicalDamageFactor)

    if wear > 0.0 then
        ApplyMechanicalDamage(wear)
    end
end

local function ApplyMechanicalConditionCeiling(bodyPercent, enginePercent)
    if not Config.EnableMechanicalConditionCeiling then return end

    -- Convert lost system health into a minimum amount of mechanical wear.
    -- Engine has a larger influence because it directly represents the powertrain.
    local enginePenalty = 0.0
    local bodyPenalty = 0.0

    if enginePercent < Config.MinimumEnginePenaltyThreshold then
        enginePenalty = (100.0 - enginePercent) * Config.EngineConditionInfluence
    end

    if bodyPercent < Config.MinimumBodyPenaltyThreshold then
        bodyPenalty = (100.0 - bodyPercent) * Config.BodyConditionInfluence
    end

    -- Use the stronger system penalty rather than adding both together.
    -- Collision-specific damage can still push Mechanical substantially lower.
    local requiredWear = math.max(enginePenalty, bodyPenalty)
    local maximumMechanical = AGCDamage.ClampCondition(100.0 - requiredWear)

    if vehicleCondition > maximumMechanical then
        local old = vehicleCondition
        vehicleCondition = maximumMechanical
        SyncCondition(currentVehicle, true)
        Debug(('Condition ceiling %.2f -> %.2f (Engine %.1f%% / Body %.1f%%)'):format(
            old, vehicleCondition, enginePercent, bodyPercent
        ))
    end
end

local function HandleCriticalDegradation(vehicle, bodyPercent, enginePercent)
    degradationTimer = degradationTimer + Config.UpdateInterval
    if degradationTimer < 1000 then return end
    degradationTimer = 0

    local loss = 0.0

    if enginePercent <= Config.EngineFailurePercent or bodyPercent <= Config.BodyFailurePercent then
        loss = Config.CatastrophicMechanicalLossPerSecond

        if not catastrophicFailure then
            catastrophicFailure = true
            Notify('Catastrophic vehicle failure. The vehicle is disabled.')
        end
    else
        if enginePercent <= Config.CriticalEnginePercent then
            loss = loss + Config.CriticalEngineMechanicalLossPerSecond
        end
        if bodyPercent <= Config.CriticalBodyPercent then
            loss = loss + Config.CriticalBodyMechanicalLossPerSecond
        end
    end

    if loss > 0.0 then ApplyMechanicalDamage(loss) end
end

local function HandleEngine(vehicle, bodyPercent, enginePercent)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local failed =
        vehicleCondition <= Config.DisableThreshold or
        enginePercent <= Config.EngineFailurePercent or
        bodyPercent <= Config.BodyFailurePercent

    if failed then
        SetVehicleEngineTorqueMultiplier(vehicle, 0.0)
        SetVehicleUndriveable(vehicle, true)
        SetVehicleEngineOn(vehicle, false, true, true)
        return
    end

    SetVehicleUndriveable(vehicle, false)

    if vehicleCondition <= Config.StallThreshold and GetIsVehicleEngineRunning(vehicle) then
        if math.random(1, 1000) <= 4 then
            SetVehicleEngineOn(vehicle, false, true, true)
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

    local healthy =
        body >= Config.RepairDetectionBodyHealth and
        engine >= Config.RepairDetectionEngineHealth and
        tank >= Config.RepairDetectionPetrolTankHealth

    if not healthy then return false end

    if (body - previousBodyHealth) >= 25.0
        or (engine - previousEngineHealth) >= 25.0
        or (tank - previousTankHealth) >= 25.0 then
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
        elseif not initialized or vehicle ~= currentVehicle then
            ResetVehicleState(vehicle)
        else
            -- The current driver is authoritative for live damage calculations.
            -- Do NOT continuously re-read the state bag here: state-bag replication can
            -- arrive one or more ticks after a client update and overwrite a freshly
            -- calculated lower mechanical condition with the previous value (often 100%).
            -- Server-confirmed changes are applied by conditionUpdated below.
            local currentSpeed = AGCDamage.GetSpeedMPH(vehicle)
            local currentBodyHealth = GetVehicleBodyHealth(vehicle)
            local currentEngineHealth = GetVehicleEngineHealth(vehicle)
            local currentTankHealth = GetVehiclePetrolTankHealth(vehicle)
            local bodyPercent = AGCDamage.HealthToPercent(currentBodyHealth)
            local enginePercent = AGCDamage.HealthToPercent(currentEngineHealth)
            local gameTimer = GetGameTimer()

            local repaired = DetectFullRepair(vehicle, currentBodyHealth, currentEngineHealth, currentTankHealth)

            if not repaired then
                ApplySystemDamageToMechanical(currentBodyHealth, currentEngineHealth)
                ApplyMechanicalConditionCeiling(bodyPercent, enginePercent)

                if HasEntityCollidedWithAnything(vehicle)
                    and (gameTimer - lastCollision) >= Config.CollisionCooldown then

                    local damage = AGCDamage.CalculateImpact(
                        vehicle, previousSpeed, currentSpeed,
                        previousBodyHealth, currentBodyHealth,
                        previousEngineHealth, currentEngineHealth
                    )

                    if damage > 0.0 then
                        ApplyMechanicalDamage(damage)
                        lastCollision = gameTimer
                    end
                end

                HandleRollover(vehicle)
                HandleCriticalDegradation(vehicle, bodyPercent, enginePercent)
                HandleEngine(vehicle, bodyPercent, enginePercent)

                if Config.ProtectEngineHealth
                    and currentEngineHealth < Config.MinimumProtectedEngineHealth
                    and enginePercent > Config.EngineFailurePercent
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
end)

CreateThread(function()
    while true do
        if initialized and currentVehicle ~= 0 and DoesEntityExist(currentVehicle) then
            local ped = PlayerPedId()
            if GetPedInVehicleSeat(currentVehicle, -1) == ped then
                local bodyPercent = AGCDamage.HealthToPercent(GetVehicleBodyHealth(currentVehicle))
                local enginePercent = AGCDamage.HealthToPercent(GetVehicleEngineHealth(currentVehicle))

                if bodyPercent <= Config.BodyFailurePercent
                    or enginePercent <= Config.EngineFailurePercent
                    or vehicleCondition <= Config.DisableThreshold then
                    SetVehicleEngineTorqueMultiplier(currentVehicle, 0.0)
                else
                    SetVehicleEngineTorqueMultiplier(currentVehicle, AGCDamage.GetTorqueMultiplier(vehicleCondition))
                end
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
    if vehicle == 0 or not DoesEntityExist(vehicle) or not initialized or vehicle ~= currentVehicle then
        return
    end

    condition = AGCDamage.ClampCondition(condition)

    -- Damage only moves downward during normal operation. Ignore a delayed/stale
    -- server echo that would raise the driver's freshly calculated condition.
    -- Repairs are handled explicitly by RepairMechanical(), which sets local state
    -- to 100 before the server broadcasts the repaired state.
    if condition <= vehicleCondition then
        vehicleCondition = condition
    end

    lastSyncedCondition = vehicleCondition
end)

RegisterNetEvent('agc-vehicledamage:client:repairVehicle', function(vehicle)
    vehicle = tonumber(vehicle) or 0
    if vehicle == 0 then vehicle = GetVehiclePedIsIn(PlayerPedId(), false) end
    if vehicle ~= 0 and DoesEntityExist(vehicle) then RepairMechanical(vehicle, false) end
end)

RegisterCommand('vehstatus', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if vehicle == 0 then
        Notify('You are not inside a vehicle.')
        return
    end

    local mechanical = ReadCondition(vehicle)
    if initialized and vehicle == currentVehicle then mechanical = vehicleCondition end

    local enginePercent = AGCDamage.HealthToPercent(GetVehicleEngineHealth(vehicle))
    local bodyPercent = AGCDamage.HealthToPercent(GetVehicleBodyHealth(vehicle))

    local status = 'DRIVEABLE'
    if mechanical <= Config.DisableThreshold
        or enginePercent <= Config.EngineFailurePercent
        or bodyPercent <= Config.BodyFailurePercent then
        status = 'DISABLED'
    elseif mechanical <= Config.StallThreshold
        or enginePercent <= Config.CriticalEnginePercent
        or bodyPercent <= Config.CriticalBodyPercent then
        status = 'CRITICAL'
    elseif mechanical <= Config.SeverePowerLossStart then
        status = 'SEVERE'
    elseif mechanical <= Config.PowerLossStart then
        status = 'DAMAGED'
    end

    Notify(('Mechanical: %.0f%% | Engine: %.0f%% | Body: %.0f%% | Status: %s'):format(
        mechanical, enginePercent, bodyPercent, status
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

exports('GetVehicleDamageStatus', function(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    return {
        mechanical = (initialized and vehicle == currentVehicle) and vehicleCondition or ReadCondition(vehicle),
        engine = AGCDamage.HealthToPercent(GetVehicleEngineHealth(vehicle)),
        body = AGCDamage.HealthToPercent(GetVehicleBodyHealth(vehicle))
    }
end)

exports('RepairVehicle', function(vehicle)
    return RepairMechanical(vehicle, false)
end)
