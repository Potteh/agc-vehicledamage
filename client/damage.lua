AGCDamage = {}

local MPH_MULTIPLIER = 2.236936

function AGCDamage.GetSpeedMPH(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return 0.0 end
    return GetEntitySpeed(vehicle) * MPH_MULTIPLIER
end

function AGCDamage.GetDurability(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return 1.0 end
    return Config.ClassDurability[GetVehicleClass(vehicle)] or 1.0
end

function AGCDamage.ClampCondition(value)
    value = tonumber(value) or Config.DefaultCondition
    return math.max(0.0, math.min(value, 100.0))
end

function AGCDamage.HealthToPercent(nativeHealth)
    nativeHealth = tonumber(nativeHealth) or 0.0
    return math.max(0.0, math.min((nativeHealth / Config.NativeFullHealth) * 100.0, 100.0))
end

function AGCDamage.CalculateImpact(vehicle, previousSpeed, currentSpeed, previousBody, currentBody, previousEngine, currentEngine)
    local speedDelta = math.max(previousSpeed - currentSpeed, 0.0)
    local bodyLoss = math.max(previousBody - currentBody, 0.0)
    local engineLoss = math.max(previousEngine - currentEngine, 0.0)
    local nativeLoss = bodyLoss + engineLoss

    if previousSpeed < Config.MinimumCollisionSpeed then return 0.0 end
    if nativeLoss < Config.MinimumNativeDamageForImpact then return 0.0 end

    -- Severity scales the damage GTA actually recorded. Speed no longer becomes
    -- mechanical damage by itself.
    local severity = math.min(
        math.max(previousSpeed / math.max(Config.ImpactSpeedReference, 1.0), 0.25),
        Config.MaximumImpactSeverity
    )

    local durability = math.max(AGCDamage.GetDurability(vehicle), 0.1)
    local damage = (
        (bodyLoss * Config.BodyLossToMechanical) +
        (engineLoss * Config.EngineLossToMechanical)
    ) * severity / durability

    if Config.EnableImpactShockDamage and speedDelta >= Config.ImpactShockStartMPH then
        local shock = (speedDelta - Config.ImpactShockStartMPH) * Config.ImpactShockMultiplier
        damage = damage + math.min(shock, Config.MaxImpactShockDamage)
    end

    return math.max(0.0, math.min(damage, Config.MaxMechanicalDamagePerImpact))
end

function AGCDamage.GetTorqueMultiplier(condition)
    condition = AGCDamage.ClampCondition(condition)
    if condition >= Config.PowerLossStart then return 1.0 end

    if condition >= Config.SeverePowerLossStart then
        local range = Config.PowerLossStart - Config.SeverePowerLossStart
        local percent = range > 0.0 and ((condition - Config.SeverePowerLossStart) / range) or 0.0
        return 0.65 + (0.35 * percent)
    end

    if condition > Config.DisableThreshold then
        local percent = condition / math.max(Config.SeverePowerLossStart, 0.01)
        return Config.MinimumTorqueMultiplier + ((0.65 - Config.MinimumTorqueMultiplier) * percent)
    end

    return 0.0
end
