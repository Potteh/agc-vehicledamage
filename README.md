# AGC Realistic Vehicle Damage - Phase 4.4

Phase 4.4 keeps the successful Phase 4.3 crash/component model and balances overheating.

## Progressive overheating
The previous system had a large damage jump at critical temperature. Phase 4.4 uses
three progressive stages:

- 105-114 C: high-temperature warning and slow deterioration
- 115-124 C: severe overheating and faster deterioration
- 125 C+: critical overheating and rapid deterioration

The driver now has substantially more time to notice the problem, stop the vehicle and
shut the engine down before catastrophic failure.

## Warnings
Notifications are rate-limited and escalate through:
- ENGINE TEMPERATURE HIGH
- ENGINE OVERHEATING
- CRITICAL ENGINE TEMPERATURE - STOP VEHICLE

## Effects
Steam/smoke effects begin as temperature becomes severe and intensify at critical
temperature. Engine 0% still results in the existing disabled/catastrophic behavior.

## Crash damage
Phase 4.3 crash/component tuning is intentionally unchanged.

## Test
Damage the radiator, continue driving under load, and periodically use `/vehstatus`.
Watch the progression through 105 C, 115 C and 125 C.

Also test pulling over and shutting the engine off during an overheat event. Temperature
should fall and continued overheat damage should stop as the vehicle cools.

Install:
    restart agc-vehicledamage
