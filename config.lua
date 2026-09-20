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


-- Phase 4 component system
Config.ComponentStateKey = 'agcVehicleComponents'
Config.ComponentSyncThreshold = 0.25
Config.ComponentSyncInterval = 750

Config.DefaultComponents = {
    radiator = 100.0,
    transmission = 100.0,
    oil = 100.0,
    fuelSystem = 100.0,
    temperature = 35.0
}

-- Front-impact approximation. GTA does not expose a simple reliable collision point,
-- so frontal severity is estimated from impact velocity along the vehicle's forward axis.
Config.FrontalImpactMinimumMPH = 18.0
Config.FrontalImpactRadiatorFactor = 0.32
Config.FrontalImpactEngineFactor = 0.13
Config.MaxRadiatorDamagePerImpact = 28.0
Config.MaxExtraEngineDamagePerImpact = 12.0

-- General component impact damage
Config.TransmissionImpactStartMPH = 42.0
Config.TransmissionImpactFactor = 0.065
Config.MaxTransmissionDamagePerImpact = 10.0
Config.OilImpactStartMPH = 55.0
Config.OilImpactFactor = 0.035
Config.MaxOilDamagePerImpact = 7.0
Config.FuelImpactStartMPH = 60.0
Config.FuelImpactFactor = 0.025
Config.MaxFuelSystemDamagePerImpact = 6.0

-- Cooling / overheating
Config.NormalOperatingTemperature = 90.0
Config.MaximumTemperature = 130.0
Config.OverheatStartTemperature = 105.0
Config.CriticalTemperature = 120.0
Config.BaseWarmupPerSecond = 1.2
Config.BaseCoolingPerSecond = 0.65
Config.RadiatorHeatMultiplier = 3.2
Config.OverheatEngineDamagePerSecond = 2.5
Config.CriticalOverheatEngineDamagePerSecond = 7.0
Config.OverheatMechanicalDamagePerSecond = 0.35

-- Transmission penalties
Config.TransmissionPowerLossStart = 60.0
Config.TransmissionCritical = 20.0
Config.MinimumTransmissionTorque = 0.45

-- Oil system
Config.OilLeakStart = 45.0
Config.OilLossPerSecond = 0.18
Config.OilCritical = 15.0
Config.OilEngineDamagePerSecond = 4.0
Config.OilMechanicalDamagePerSecond = 0.55

-- Fuel system. Uses native fuel level so it remains standalone.
Config.FuelLeakStart = 40.0
Config.FuelLeakPerSecond = 0.20

-- Tire damage
Config.EnableImpactTyreDamage = true
Config.TyreDamageMinimumMPH = 50.0
Config.TyreBurstChanceAtMinimum = 4
Config.TyreBurstChanceAtExtreme = 28
Config.TyreExtremeImpactMPH = 85.0
