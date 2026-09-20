# AGC Realistic Vehicle Damage - Phase 3.3

Phase 3.3 corrects the overly aggressive mechanical collision model.

## What changed
Previously, a sudden speed drop could contribute an enormous amount of Mechanical damage.
That allowed results such as:

    Mechanical: 8% | Engine: 100% | Body: 89%

Phase 3.3 no longer treats speed loss itself as major drivetrain damage.

Mechanical impact damage now comes primarily from the BODY and ENGINE health actually
lost during the collision. Impact speed acts as a severity multiplier instead.

Engine damage is weighted much more heavily than body damage.

A very hard impact can add a small capped "mechanical shock" penalty, but speed alone
can no longer destroy the vehicle mechanically.

## Body relationship
Body condition now has a softer mechanical ceiling:
- body damage below 80% begins limiting pristine Mechanical condition;
- body influence defaults to 0.20;
- Engine influence remains much stronger at 0.70.

Therefore light/moderate cosmetic damage should not destroy the drivetrain.

## Important
The Phase 3.2 synchronization fix remains in place.
QBCore `/fix` compatibility remains in place.
Engine or Body reaching 0% still disables the vehicle.
Critical Engine/Body health still causes progressive deterioration.

## Install
Replace the resource folder and run:

    restart agc-vehicledamage

## Recommended test
Repair a vehicle first and verify:

    Mechanical 100% | Engine 100% | Body 100%

Then perform:
1. a light crash,
2. a moderate crash,
3. a hard crash.

Check `/vehstatus` after each one. Mechanical should decline progressively rather than
dropping from 100% to near zero after a single impact.
