Config = {}

Config.Debug = false
Config.UpdateInterval = 100
Config.MinimumCollisionSpeed = 8.0 -- MPH
Config.CollisionDamageMultiplier = 1.0
Config.SpeedDeltaMultiplier = 1.35
Config.BodyDamageMultiplier = 0.15
Config.EngineDamageMultiplier = 0.20
Config.MaxDamagePerImpact = 45.0
Config.CollisionCooldown = 650

Config.EnableRolloverDamage = true
Config.RolloverDamagePerSecond = 2.5

Config.PowerLossStart = 65.0
Config.SeverePowerLossStart = 35.0
Config.StallThreshold = 15.0
Config.DisableThreshold = 0.0
Config.MinimumTorqueMultiplier = 0.30

Config.ProtectEngineHealth = true
Config.MinimumProtectedEngineHealth = 300.0

Config.ClassDurability = {
    [0]  = 0.90, -- Compacts
    [1]  = 1.00, -- Sedans
    [2]  = 1.20, -- SUVs
    [3]  = 0.95, -- Coupes
    [4]  = 1.00, -- Muscle
    [5]  = 0.90, -- Sports Classics
    [6]  = 0.85, -- Sports
    [7]  = 0.75, -- Super
    [8]  = 0.60, -- Motorcycles
    [9]  = 1.30, -- Off-road
    [10] = 1.50, -- Industrial
    [11] = 1.40, -- Utility
    [12] = 1.30, -- Vans
    [13] = 1.00, -- Cycles
    [14] = 1.00, -- Boats
    [15] = 1.00, -- Helicopters
    [16] = 1.00, -- Planes
    [17] = 1.25, -- Service
    [18] = 1.30, -- Emergency
    [19] = 1.60, -- Military
    [20] = 1.45, -- Commercial
    [21] = 1.00, -- Trains
    [22] = 0.75  -- Open Wheel
}
