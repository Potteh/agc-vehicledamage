Config = {}

Config.Debug = false
Config.UpdateInterval = 100

-- Collision detection
Config.MinimumCollisionSpeed = 8.0 -- MPH
Config.CollisionCooldown = 650

-- Phase 3.3 collision model:
-- speed determines impact severity, but native body/engine loss determines how much
-- actual mechanical damage occurred. This prevents a speed drop alone from destroying
-- the drivetrain.
Config.ImpactSpeedReference = 45.0
Config.MaximumImpactSeverity = 1.50
Config.BodyLossToMechanical = 0.08
Config.EngineLossToMechanical = 0.35
Config.MinimumNativeDamageForImpact = 2.0
Config.MaxMechanicalDamagePerImpact = 18.0

-- A genuinely violent impact may still cause a small amount of mechanical shock even
-- if GTA reports mostly body damage, but this is deliberately capped.
Config.EnableImpactShockDamage = true
Config.ImpactShockStartMPH = 35.0
Config.ImpactShockMultiplier = 0.035
Config.MaxImpactShockDamage = 3.0

-- Rollover
Config.EnableRolloverDamage = true
Config.RolloverDamagePerSecond = 1.25

-- Mechanical condition / power loss
Config.PowerLossStart = 65.0
Config.SeverePowerLossStart = 35.0
Config.StallThreshold = 15.0
Config.DisableThreshold = 0.0
Config.MinimumTorqueMultiplier = 0.30

Config.ProtectEngineHealth = true
Config.MinimumProtectedEngineHealth = 50.0

-- Network state
Config.StateBagKey = 'agcMechanicalCondition'
Config.DefaultCondition = 100.0
Config.SyncChangeThreshold = 0.10

-- GTA health normalization
Config.NativeFullHealth = 1000.0

-- Current-condition ceiling.
Config.EnableMechanicalConditionCeiling = true
Config.EngineConditionInfluence = 0.70
Config.BodyConditionInfluence = 0.20
Config.MinimumBodyPenaltyThreshold = 80.0
Config.MinimumEnginePenaltyThreshold = 98.0

-- Critical degradation
Config.CriticalEnginePercent = 25.0
Config.CriticalBodyPercent = 20.0
Config.CriticalEngineMechanicalLossPerSecond = 0.75
Config.CriticalBodyMechanicalLossPerSecond = 0.35
Config.EngineFailurePercent = 0.0
Config.BodyFailurePercent = 0.0
Config.CatastrophicMechanicalLossPerSecond = 15.0

-- Repair detection
Config.EnableAutomaticRepairDetection = true
Config.RepairDetectionBodyHealth = 995.0
Config.RepairDetectionEngineHealth = 995.0
Config.RepairDetectionPetrolTankHealth = 995.0
Config.RepairDetectionCooldownMs = 2000

Config.ClassDurability = {
    [0]=0.90,[1]=1.00,[2]=1.20,[3]=0.95,[4]=1.00,[5]=0.90,
    [6]=0.85,[7]=0.75,[8]=0.60,[9]=1.30,[10]=1.50,[11]=1.40,
    [12]=1.30,[13]=1.00,[14]=1.00,[15]=1.00,[16]=1.00,[17]=1.25,
    [18]=1.30,[19]=1.60,[20]=1.45,[21]=1.00,[22]=0.75
}
