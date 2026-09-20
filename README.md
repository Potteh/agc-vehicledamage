# AGC Realistic Vehicle Damage - Phase 4.1

Phase 4.1 fixes component damage not triggering during high-speed crashes.

## Cause
Phase 4 used the speed difference observed on the exact update where GTA's body-health
change appeared. GTA can spread a collision across multiple frames. By the time body
damage was observed, the sampled speed delta could be small even after a 70 MPH crash.
As a result, Body changed while Radiator, Transmission, Oil and Fuel System stayed 100%.

## Fix
Component severity now uses the vehicle's recorded PRE-IMPACT speed when GTA confirms
that physical body/engine damage occurred.

The collision model still requires native physical damage, so merely braking hard from
70 MPH should not damage components.

## Expected behavior
- ~20 MPH light frontal hit: little/no drivetrain damage; radiator may take a very small hit.
- ~50 MPH frontal hit: radiator should begin showing noticeable damage; transmission may
  take a small amount depending on the collision.
- ~70 MPH head-on hit: radiator should take substantial damage, engine should take some
  additional frontal-impact damage, and transmission may also deteriorate.
- Oil/fuel systems remain biased toward more severe impacts.
- Temperature normally settles around 90 C. A damaged radiator should make temperature
  climb above normal while the engine continues running.

## Debugging
Run `/vehdamagedebug` to enable console logging. Component collisions now print:
pre-impact MPH, sampled speed delta, body loss, engine loss, and whether the impact was
classified as front-biased.

## Install
Replace the resource folder and run:

    restart agc-vehicledamage

Use `/fix` before each controlled crash test.
