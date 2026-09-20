# AGC Realistic Vehicle Damage - Phase 4.3

Phase 4.3 fixes the two issues confirmed by the Phase 4.2.1 road tests.

## `/fix` and radiator-only damage
Automatic repair detection previously required Mechanical to be below 100%. That meant
a vehicle with Mechanical 100% and Radiator 93% could be ignored by the repair detector.

The repair detector now considers Radiator, Transmission, Oil, and Fuel System damage.
A QBCore `/fix` can therefore reset custom components even when Mechanical never dropped.

## High-speed impacts
GTA can clear its collision flag before the native Body-health reduction is visible.
The previous code therefore sometimes saw a 55-90 MPH crash only as a Body change and
never ran component damage.

Phase 4.3 accepts a delayed native health reduction when it occurs inside the cached
pre-impact window. The cached impact is then consumed so the same collision is not
double-counted.

## Test
Restart the resource, `/fix`, and verify all custom components show 100%.

Then test:
- ~40 MPH frontal
- `/fix` and verify Radiator returns to 100%
- ~55 MPH frontal
- `/fix`
- ~80-90 MPH head-on

Use `/vehdamagedebug` if needed; `Component impact:` should appear for the physical
impact even when GTA reports Body damage a few frames late.
