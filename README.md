# AGC Realistic Vehicle Damage - Phase 4

Phase 4 builds component failures on the balanced Phase 3.3 collision model.

## Components
- Radiator: frontal impacts can damage cooling capacity.
- Temperature: warms while running; damaged radiators can cause overheating.
- Engine: severe frontal impacts can now cause additional engine damage even when GTA
  would otherwise leave native engine health near 100%.
- Transmission: hard impacts can damage it and reduce delivered torque.
- Oil system: severe impacts can damage it; critical oil condition causes continued
  engine and Mechanical deterioration.
- Fuel system: severe impacts can damage it; low condition leaks native fuel.
- Tires: sufficiently severe impacts have a configurable chance to burst a tire.

## Synchronization
Mechanical condition and the component table are synchronized through vehicle state bags.
The current driver is authoritative for live damage calculations.

## /vehstatus
Now reports:
Mechanical, Engine, Body, Radiator, Transmission, Oil, Fuel System, Temperature, Status.

## Repair
Existing QBCore `/fix` automatic repair compatibility is retained. An explicit repair via:

    exports['agc-vehicledamage']:RepairVehicle(vehicle)

also resets the Phase 4 components.

## Important implementation note
FiveM/GTA does not expose one simple, universally reliable collision-point native for
every vehicle impact. Phase 4 therefore approximates frontal impact severity using the
vehicle's motion and collision speed. This avoids hard-coding vehicle-model-specific
bonnet/engine geometry.

## Install
Replace the resource and run:

    restart agc-vehicledamage

## Suggested test sequence
1. `/fix`, then `/vehstatus`.
2. Light front impact.
3. Moderate front impact.
4. 60-75 MPH head-on impact.
5. Continue driving a vehicle with a damaged radiator and watch temperature.
6. Test repeated hard impacts for transmission/oil/fuel/tire failures.
7. `/fix` and confirm all systems reset.
