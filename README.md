# AGC Realistic Vehicle Damage - Phase 2.1

Phase 2.1 adds repair compatibility to the synchronized Phase 2 damage system.

## New in 2.1
- Detects full native vehicle repairs while the player is driving.
- QBCore/admin repair commands that restore engine/body/tank health can now also
  restore AGC mechanical condition to 100%.
- Client export: `exports['agc-vehicledamage']:RepairVehicle(vehicle)`
- Client event: `TriggerEvent('agc-vehicledamage:client:repairVehicle', vehicle)`
- Server export for trusted server resources.
- Mechanical repair state is synchronized to other clients.

## Install
Replace the old `agc-vehicledamage` folder with this folder.

Keep:

    ensure agc-vehicledamage

Then restart the resource/server.

## Test QBCore /fix
1. Damage a vehicle until `/vehstatus` shows Mechanical below 100%.
2. Use your existing QBCore `/fix`.
3. Wait about one second.
4. Run `/vehstatus`.
5. Mechanical should now show 100%.

## Explicit integration
For any client-side admin/mechanic repair script, after it repairs the GTA vehicle:

    exports['agc-vehicledamage']:RepairVehicle(vehicle)

or:

    TriggerEvent('agc-vehicledamage:client:repairVehicle', vehicle)

This is preferable when you control the repair script because it does not rely
on automatic repair detection.

## Notes
Phase 2.1 still stores mechanical condition for the lifetime of the spawned
network vehicle entity. Database/garage persistence is a later phase.
