# AGC Realistic Vehicle Damage - Phase 3.2

This release fixes the synchronization race discovered during Phase 3.1 testing.

## Symptom fixed
A vehicle could report values such as:

    Mechanical: 100% | Engine: 92% | Body: 33%

even though Phase 3.1 calculated a lower mechanical ceiling.

## Cause
The driver calculated and synchronized the lower Mechanical value, but the replicated
state bag could still contain the previous value (often 100%) for a short time. On the
next 100 ms update, the client read that stale state and restored Mechanical to 100%.

## Phase 3.2 behavior
- The current driver remains authoritative for live damage calculations.
- The main damage loop no longer re-imports delayed state-bag values every tick.
- Server-confirmed damage updates can still lower the driver's condition.
- Stale network echoes cannot raise Mechanical.
- Entering/re-entering a vehicle still loads its synchronized Mechanical condition.
- Another driver still receives the synchronized condition.
- `/fix` still explicitly restores Mechanical to 100%.
- The Phase 3.1 current-condition ceiling remains enabled.

With defaults, Body at 33% creates 26.8 points of required mechanical wear, so even
with Engine at 92%, Mechanical should be no higher than about 73% before any additional
collision damage is considered.

## Install
Replace the existing resource folder and run:

    restart agc-vehicledamage

## Test
1. Start with a repaired vehicle.
2. Confirm `/vehstatus` is approximately 100/100/100.
3. Crash until Body is substantially damaged.
4. Run `/vehstatus`.
5. Mechanical should now drop and remain below its calculated ceiling.
6. Exit and re-enter; confirm the lower Mechanical value remains.
7. Run QBCore `/fix`; confirm Mechanical, Engine and Body return to 100%.
