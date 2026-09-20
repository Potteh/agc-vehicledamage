# AGC Realistic Vehicle Damage - Phase 5

Phase 5 adds player-facing symptoms to the component system while retaining the
Phase 4.3 collision tuning and Phase 4.4 progressive overheating model.

## Transmission
Transmission condition now affects delivered torque below 60%.
At severe/critical condition the transmission intermittently slips, producing brief
additional reductions in acceleration rather than simply changing a percentage.

Warnings:
- TRANSMISSION DAMAGED
- TRANSMISSION SEVERELY DAMAGED
- TRANSMISSION FAILURE IMMINENT

## Oil system
Existing oil leakage/starvation remains. Low oil now produces escalating driver
warnings, and severe oil-system damage can produce visible engine-area smoke while
the engine is running.

Warnings:
- OIL SYSTEM DAMAGED
- LOW OIL PRESSURE / SEVERE LEAK
- CRITICAL OIL SYSTEM FAILURE

## Fuel system
Fuel leaks now become progressively faster as fuel-system condition deteriorates.

Warnings:
- FUEL SYSTEM DAMAGED
- SEVERE FUEL LEAK
- CRITICAL FUEL SYSTEM LEAK

The script continues to use native vehicle fuel level, keeping the core resource
standalone. qb-fuel-specific integration can be added separately if desired.

## Cooling
Damaged/critical radiator condition now has cooling-system warnings in addition to
the temperature warnings introduced in Phase 4.4.

## Repair
`/fix` detection and explicit repair reset all custom components and warning state.

## Install
Replace the resource folder and run:

    restart agc-vehicledamage

## Testing
Normal crash testing may take a while to push Transmission/Oil/Fuel into their severe
ranges. `/vehstatus` remains the detailed diagnostic view. The next development step
can add mechanic/admin diagnostic setters so each component can be tested directly
without repeatedly crashing a vehicle.
