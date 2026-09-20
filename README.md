# AGC Realistic Vehicle Damage - Phase 4.2

This build addresses both test failures found in Phase 4.1.

## 1. Very high-speed crashes sometimes caused no component damage
A 90 MPH head-on collision could reduce Body health but leave Radiator/Engine/
Transmission untouched. GTA can apply its native body-health change several frames
after the largest deceleration.

Phase 4.2 keeps a short pre-impact memory of:
- vehicle speed
- vehicle velocity/direction
- time of the sharp deceleration

When physical damage appears shortly afterward, the component system uses the cached
pre-impact data. A 90 MPH impact therefore cannot be accidentally evaluated as a much
slower collision merely because the body-health update arrived late.

## 2. /fix sometimes left Radiator damaged
Repair now explicitly resets and immediately synchronizes the Phase 4 component table.
A short repair-authority window also prevents delayed/stale component state from
re-applying old damage immediately after `/fix`.

## Testing
Use `/fix` before every isolated test and verify every component reads 100%.

Suggested tests:
- 30-35 MPH frontal
- 50-60 MPH frontal
- 70-90 MPH head-on

Then continue driving after a damaged radiator to test overheating.

For diagnostics:
    /vehdamagedebug

The F8 `Component impact:` line should now show the cached pre-impact speed for crashes
where GTA delays its health update.

## Install
Replace the resource folder and run:

    restart agc-vehicledamage
