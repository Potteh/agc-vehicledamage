# AGC Realistic Vehicle Damage - Phase 1

Standalone FiveM vehicle damage resource.

## Features
- Speed-sensitive collision damage
- Vehicle-class durability
- Progressive engine power loss
- Critical-condition engine stalling
- Mechanical vehicle disable state
- Rollover damage
- Configurable damage values
- /vehstatus command
- /vehdamagedebug command
- No QBCore dependency required

## Installation
1. Copy `agc-vehicledamage` into your server's resources directory.
2. Add the following to server.cfg:

   ensure agc-vehicledamage

3. Restart the server or run:

   ensure agc-vehicledamage

## Testing
Use `/vehstatus` while inside a vehicle to view:
- Mechanical condition
- GTA engine health
- GTA body health
- Current speed

Use `/vehdamagedebug` to enable/disable client console debug messages.

Phase 1 intentionally does not persist mechanical condition after leaving a vehicle.
Persistence/network synchronization can be added in Phase 2.
