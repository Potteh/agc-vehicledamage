# AGC Realistic Vehicle Damage - Phase 3

## New in Phase 3
- `/vehstatus` now displays Mechanical, Engine, and Body as 0-100%.
- Engine damage contributes to mechanical deterioration.
- Body damage contributes to mechanical deterioration.
- Critically damaged engine/body systems cause ongoing mechanical degradation.
- Engine at 0% disables the vehicle.
- Body at 0% disables the vehicle.
- Catastrophic engine/body failure rapidly deteriorates Mechanical toward 0%.
- Added `GetVehicleDamageStatus(vehicle)` export.
- Retains Phase 2.1 QBCore `/fix` compatibility and synchronized mechanical state.

Example:

    Mechanical: 64% | Engine: 51% | Body: 73% | Status: DAMAGED

## Installation
Replace your existing `agc-vehicledamage` folder.

Keep this in server.cfg:

    ensure agc-vehicledamage

Then restart the resource or server.

## Test
1. Spawn a normal sedan.
2. Run `/vehstatus`.
3. Crash it at several speeds and watch all three percentages.
4. Continue driving with a badly damaged engine/body and verify Mechanical gradually worsens.
5. If Engine or Body reaches 0%, the vehicle should become undriveable.
6. Use QBCore `/fix` and verify Mechanical returns to 100% along with native vehicle health.

## Exports
Client:

    exports['agc-vehicledamage']:GetVehicleMechanicalCondition(vehicle)

    exports['agc-vehicledamage']:GetVehicleDamageStatus(vehicle)

    exports['agc-vehicledamage']:RepairVehicle(vehicle)

`GetVehicleDamageStatus` returns:

    {
        mechanical = 100.0,
        engine = 100.0,
        body = 100.0
    }

## Next
The next component phase can add radiator temperature/overheating, transmission
condition, oil system damage, fuel leaks, tire/wheel damage, smoke/effects, and
mechanic repair workflows.
