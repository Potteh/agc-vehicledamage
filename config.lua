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

Config.StateBagKey = 'agcMechanicalCondition'
Config.DefaultCondition = 100.0
Config.SyncChangeThreshold = 0.10

-- Phase 2.1: detect full repairs performed by QBCore/admin/native repair commands.
Config.EnableAutomaticRepairDetection = true
Config.RepairDetectionBodyHealth = 995.0
Config.RepairDetectionEngineHealth = 995.0
Config.RepairDetectionPetrolTankHealth = 995.0
Config.RepairDetectionWindowMs = 1500
Config.RepairDetectionCooldownMs = 2000

Config.ClassDurability = {
    [0]  = 0.90,
    [1]  = 1.00,
    [2]  = 1.20,
    [3]  = 0.95,
    [4]  = 1.00,
    [5]  = 0.90,
    [6]  = 0.85,
    [7]  = 0.75,
    [8]  = 0.60,
    [9]  = 1.30,
    [10] = 1.50,
    [11] = 1.40,
    [12] = 1.30,
    [13] = 1.00,
    [14] = 1.00,
    [15] = 1.00,
    [16] = 1.00,
    [17] = 1.25,
    [18] = 1.30,
    [19] = 1.60,
    [20] = 1.45,
    [21] = 1.00,
    [22] = 0.75
}
