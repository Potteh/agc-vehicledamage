AGCDamage = {}

local MPH_MULTIPLIER = 2.236936

function AGCDamage.GetSpeedMPH(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0.0
    end
    return GetEntitySpeed(vehicle) * MPH_MULTIPLIER
end

function AGCDamage.GetDurability(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 1.0
    end
    return Config.ClassDurability[GetVehicleClass(vehicle)] or 1.0
end

function AGCDamage.CalculateImpact(vehicle, previousSpeed, currentSpeed, previousBody, currentBody, previousEngine, currentEngine)
    local speedDelta = math.max(previousSpeed - currentSpeed, 0.0)
    local bodyDelta = math.max(previousBody - currentBody, 0.0)
    local engineDelta = math.max(previousEngine - currentEngine, 0.0)

    if previousSpeed < Config.MinimumCollisionSpeed then
        return 0.0
    end

    if speedDelta < 3.0 and bodyDelta < 5.0 and engineDelta < 5.0 then
        return 0.0
    end

    local durability = math.max(AGCDamage.GetDurability(vehicle), 0.1)
    local speedDamage = math.pow(speedDelta, 1.18) * Config.SpeedDeltaMultiplier
    local gtaDamage = (bodyDelta * Config.BodyDamageMultiplier) + (engineDelta * Config.EngineDamageMultiplier)
    local totalDamage = ((speedDamage + gtaDamage) * Config.CollisionDamageMultiplier) / durability

    return math.max(0.0, math.min(totalDamage, Config.MaxDamagePerImpact))
end

function AGCDamage.GetTorqueMultiplier(condition)
    condition = math.max(0.0, math.min(condition, 100.0))

    if condition >= Config.PowerLossStart then
        return 1.0
    end

    if condition >= Config.SeverePowerLossStart then
        local range = Config.PowerLossStart - Config.SeverePowerLossStart
        if range <= 0.0 then return 0.65 end
        local percent = (condition - Config.SeverePowerLossStart) / range
        return 0.65 + (0.35 * percent)
    end

    if condition > Config.DisableThreshold then
        local divisor = math.max(Config.SeverePowerLossStart, 0.01)
        local percent = condition / divisor
        return Config.MinimumTorqueMultiplier + ((0.65 - Config.MinimumTorqueMultiplier) * percent)
    end

    return 0.0
end
