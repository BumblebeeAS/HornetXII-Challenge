# HornetXII Challenge — bottom camera search

An AUV simulation you are asked to extend. It is a working closed loop: a
cascaded controller drives an 8-thruster vehicle modelled in Simscape
Multibody, over a tiled seafloor, with a red cube sitting somewhere on it.

There is no camera. Adding one is the point.

## Setup

1. Open `HornetXIIChallenge.prj`.
2. Open `HornetXII_Challenge.slx` and press Run.

That's it. The project puts `lib/` on the path and loads the vehicle and
environment parameters into the base workspace for you.

If you ever get `Unrecognized function or variable 'Vehicle'`, run
`VehicleParameters` and try again.

**Requires** MATLAB, Simulink, Simscape, and Simscape Multibody. Saved in
R2026a. Nothing else — no toolbox installs, no external libraries. Whatever
you add is your call, but say in your write-up what it needs.

## What's in the box

```
HornetXII_Challenge.slx    the model
VehicleParameters.m        every tunable number, all of it
lib/quatern.m              quaternion kinematics (from Fossen's MSS, MIT)
lib/quat_from_u_to_v.m     rotation between two vectors
lib/smoothen_quat.m        slerp with hemisphere correction
```

Inside the model:

- **Controller** — cascade of position → velocity → acceleration → force and
  moment → thrust allocation. Takes a 7-element setpoint `[x y z, quaternion]`
  from `Constant1` at the top level.
- **Simulator** — the plant. `AUV model` holds inertia, thrusters,
  hydrodynamic damping and hydrostatics; `World` and `Tiled Seafloor` are the
  scene; `Cameras` is a set of *viewpoints* for Mechanics Explorer, not
  sensors. `Target Object` places the cube.

The seafloor is at NED z = 2 m (z is **down**). The cube is 0.3 m on a side and
rests on it. Move it by editing `Environment.target.xy` — no model edit needed.

## The challenge

**Make the vehicle find the cube and settle over it.** How you sense it is up
to you, and is most of what we want to talk about.

Two tracks. Either one alone is a real submission; joining them is the whole
mission.

**Sensing** — give the vehicle a way to see the seafloor, then find the cube in
what it sees. Getting pixels out of a physics simulation is not obvious and
there is more than one defensible answer. Pick one, make it work, and be ready
to explain why you picked it and what it costs you.

**Guidance** — hold depth, sweep the area in some sensible pattern, and centre
the vehicle over a target once something tells you where it is. `Constant1` is
where a mission layer would go.

Also worth doing, and quick: **read the model and tell us what's wrong with
it.** It was built in Hornet XI by a single person and is unfinished. There are real
mistakes in there. Finding them counts.

### What we're looking for

Something working that you can explain. Not completeness. A modest thing you
understand end to end beats an ambitious thing you can't defend, and we will
ask.

Tell us, in a page or two:

- what you built and how it works
- what you tried that didn't work
- what "found it and aligned" means in your solution — you define the
  condition, we want to see you make it precise
- what you'd do with two more weeks

### Notes from the field

- The simulation is slow: roughly 2 s of wall clock per second simulated.
  Budget for that, and keep a fast offline loop for anything you're iterating
  on.
- `Environment.target.seed` draws a random cube placement. A search that only
  finds the cube where you left it hasn't been tested.
- A Video Viewer block on an image signal will stop the simulation a fraction
  of a second in, with no error message. If that happens to you, that's why.
