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


# Phase 5.1 developer testing controls

The `/vehdamage` command lets the driver force individual systems to a chosen condition
so every Phase 5 symptom can be tested without repeatedly crashing a vehicle.

Examples:

    /vehdamage transmission 20
    /vehdamage oil 15
    /vehdamage radiator 30
    /vehdamage fuel 10
    /vehdamage engine 25
    /vehdamage body 40
    /vehdamage mechanical 40
    /vehdamage temp 120
    /vehdamage reset

`reset` restores native Engine/Body/Tank health, Mechanical condition and all custom
components.

## Suggested test sequence

Transmission:
    /vehdamage transmission 55
    /vehdamage transmission 25
    /vehdamage transmission 10

Oil:
    /vehdamage oil 40
    /vehdamage oil 20
    /vehdamage oil 10

Fuel:
    /vehdamage fuel 35
    /vehdamage fuel 15
    /vehdamage fuel 5

Cooling:
    /vehdamage radiator 30
    /vehdamage temp 110
    /vehdamage temp 118
    /vehdamage temp 127

Run `/vehdamage reset` between independent tests.

## Phase 5.2 hotfix

Fixes `/vehdamage` component values immediately reverting to 100%.

Developer component changes are now applied locally to the vehicle state immediately,
synchronized to the server, and protected from stale state echoes for three seconds.

Test:

    /vehdamage transmission 55
    /vehstatus

Transmission should now report 55%.
