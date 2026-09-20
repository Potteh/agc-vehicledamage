local currentVehicle = 0
local vehicleCondition = 100.0

local previousSpeed = 0.0
local previousBodyHealth = 1000.0
local previousEngineHealth = 1000.0

local lastCollision = 0
local rolloverTimer = 0
local initialized = false

local function Debug(message)
    if Config.Debug then
        print(('[agc-vehicledamage] %s'):format(message))
    end
end

local function Notify(message)
    TriggerEvent('chat:addMessage', {
        color = {255, 180, 0},
        args = {'Vehicle Damage', message}
    })
end

local function ResetVehicleState(vehicle)
    currentVehicle = vehicle
    vehicleCondition = 100.0
    previousSpeed = AGCDamage.GetSpeedMPH(vehicle)
    previousBodyHealth = GetVehicleBodyHealth(vehicle)
    previousEngineHealth = GetVehicleEngineHealth(vehicle)
    rolloverTimer = 0
    lastCollision = 0
    initialized = true
    Debug(('Vehicle initialized: %s'):format(vehicle))
end

local function LeaveVehicle()
    currentVehicle = 0
    initialized = false
    vehicleCondition = 100.0
    previousSpeed = 0.0
    previousBodyHealth = 1000.0
    previousEngineHealth = 1000.0
    rolloverTimer = 0
    lastCollision = 0
end

local function ApplyMechanicalDamage(amount)
    if amount <= 0.0 then return end

    local oldCondition = vehicleCondition
    vehicleCondition = math.max(0.0, vehicleCondition - amount)

    Debug(('Damage %.2f | %.2f -> %.2f'):format(amount, oldCondition, vehicleCondition))

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

    local roll = GetEntityRoll(vehicle)
    local upsideDown = math.abs(roll) > 75.0

    if upsideDown then
        rolloverTimer = rolloverTimer + Config.UpdateInterval
        if rolloverTimer >= 1000 then
            ApplyMechanicalDamage(Config.RolloverDamagePerSecond)
            rolloverTimer = 0
        end
    else
        rolloverTimer = 0
    end
end

CreateThread(function()
    math.randomseed(GetGameTimer())

    while true do
        Wait(Config.UpdateInterval)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then
            if initialized then
                LeaveVehicle()
            end
        else
            if not initialized or vehicle ~= currentVehicle then
                ResetVehicleState(vehicle)
            else
                local currentSpeed = AGCDamage.GetSpeedMPH(vehicle)
                local currentBodyHealth = GetVehicleBodyHealth(vehicle)
                local currentEngineHealth = GetVehicleEngineHealth(vehicle)
                local gameTimer = GetGameTimer()

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

                previousSpeed = currentSpeed
                previousBodyHealth = currentBodyHealth
                previousEngineHealth = currentEngineHealth
            end
        end
    end
end)

-- GTA resets the torque multiplier, so apply it every frame while driving.
CreateThread(function()
    while true do
        if initialized and currentVehicle ~= 0 and DoesEntityExist(currentVehicle) then
            local ped = PlayerPedId()

            if GetPedInVehicleSeat(currentVehicle, -1) == ped then
                SetVehicleEngineTorqueMultiplier(
                    currentVehicle,
                    AGCDamage.GetTorqueMultiplier(vehicleCondition)
                )
                Wait(0)
            else
                Wait(250)
            end
        else
            Wait(500)
        end
    end
end)

RegisterCommand('vehstatus', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        Notify('You are not inside a vehicle.')
        return
    end

    local mechanical = vehicleCondition
    if not initialized or vehicle ~= currentVehicle then
        mechanical = 100.0
    end

    Notify(
        ('Mechanical: %.0f%% | Engine: %.0f | Body: %.0f | Speed: %.0f MPH')
        :format(
            mechanical,
            GetVehicleEngineHealth(vehicle),
            GetVehicleBodyHealth(vehicle),
            AGCDamage.GetSpeedMPH(vehicle)
        )
    )
end, false)

RegisterCommand('vehdamagedebug', function()
    Config.Debug = not Config.Debug
    Notify(('Debug mode: %s'):format(Config.Debug and 'ON' or 'OFF'))
end, false)
