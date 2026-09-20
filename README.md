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

## Phase 5.2.1 developer-command fix

The developer command itself was setting the requested component correctly. The
automatic `/fix` detector then saw healthy native Body/Engine/Tank values and treated
the intentionally damaged custom component as a repair candidate, immediately restoring
it to 100%.

Developer-set component damage now suppresses automatic repair detection while testing.
The override lasts up to 10 minutes or until `/vehdamage reset`.

Test:

    /vehdamage transmission 55
    /vehstatus

Transmission should remain at 55% while you drive and test its symptoms.

When finished:

    /vehdamage reset

## Phase 5.3 transmission symptom retune

Transmission damage is now deliberately obvious during testing:

- 60% and below: noticeable acceleration loss
- 30% and below: severe acceleration loss and intermittent slipping
- 12% and below: critical limp mode, approximately 28 MPH maximum
- 5% and below: near-failure mode, approximately 12 MPH maximum

Use:

    /vehdamage transmission 55
    /vehdamage transmission 25
    /vehdamage transmission 10
    /vehdamage transmission 4

Run `/vehdamage reset` afterward.

## Phase 5.4
Retunes oil starvation after live testing.
- 20-12% oil: slow wear
- 12-6% oil: substantial starvation damage
- <=6% oil: rapid engine failure

Oil leakage itself remains unchanged.
Recommended: reset, set oil to 19%, and check /vehstatus near 15%, 10%, and 5%.

## Phase 5.5 balance pass

Based on live testing:

Transmission:
- <=60% torque stage strengthened from 0.72 to 0.55.
- <=30% torque stage strengthened from 0.42 to 0.28.
- <=30% also receives a 65 MPH maximum-speed ceiling.
- Severe slipping pulse strengthened.
- <=12% 28 MPH limp mode is unchanged.
- <=5% 12 MPH near-failure mode is unchanged.

Fuel:
- Severe leak multiplier increased from 2x to 4x.
- Critical leak multiplier increased from 4x to 8x.
- Fuel-system condition itself remains fixed until further physical damage occurs;
  the damaged system leaks the gasoline stored in the tank.

Unchanged:
- Phase 5.4 oil-starvation tuning
- radiator/temperature tuning
- collision/component impact tuning
- critical transmission behavior
