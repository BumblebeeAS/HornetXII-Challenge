# HornetXII Challenge: bottom camera search

An AUV simulation you are asked to extend. It is a working closed loop: a
cascaded controller drives an 8-thruster vehicle modelled in Simscape
Multibody, over a tiled seafloor, with a red cube sitting somewhere on it.

There is no camera. Adding one is the point.

## Prerequisites

### What you need

Built and tested on **MATLAB R2026a**. The model is saved in that release, so
R2026a or newer will open it, earlier releases will not. Your NUS licence
covers R2026a, so installing it is the path we recommend and the only one we
have actually tested.

Four products, and nothing beyond them:

- MATLAB
- Simulink
- Simscape
- Simscape Multibody

No add-ons, no external libraries, no other toolboxes. The quaternion helpers
in `lib/` are bundled precisely so you don't have to install anything else. If
your solution ends up needing something more, that's fine, just say so in your
write-up.

### Getting MATLAB

NUS holds a Total Academic Headcount licence, so all of the above is free for
you as a student:

<https://www.mathworks.com/academia/tah-portal/national-university-of-singapore-31340264.html>

Sign in with your NUS email, create a MathWorks account, and download the
installer. When it asks which products to install, tick the four listed above —
selecting everything works but is a very large download. Allow an hour or so
for the install.

### If you already have an older MATLAB

There is a downgraded copy of the model, `HornetXII_Challenge_R2024b.slx`,
exported for R2024b. **It is untested.** Simulink warns that exporting to an
earlier release is not supported for models containing Simscape blocks, and we
have no R2024b install to check it on, all we can say is that the export
reported no dropped blocks and the result behaves identically in R2026a.

The MATLAB project may also refuse to open in an older release. If it does,
skip it and set things up by hand:

```matlab
addpath(genpath(pwd))
VehicleParameters
open_system('HornetXII_Challenge_R2024b')
```

If that works for you, tell us, it saves the next person an hour. If it
doesn't, install R2026a; that is the supported route and it is free.

### If you're new to this stack

MathWorks Onramps are free, run interactively in the browser or a local MATLAB installation, and take about 0.5~1.5 hours each, depending on your speed.
Do them in order; each assumes the one before it.

1. [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted)
   — skip this if an NUS module already covered MATLAB basics (MA1508E or
   similar).
2. [Simulink Onramp](https://matlabacademy.mathworks.com/details/simulink-onramp/simulink)
3. [Simscape Onramp](https://matlabacademy.mathworks.com/details/simscape-onramp/simscape)
4. [Multibody Simulation Onramp](https://matlabacademy.mathworks.com/details/multibody-simulation-onramp/ormb)
5. [Design, Modeling and Simulation of Autonomous Underwater Vehicles](https://www.mathworks.com/videos/design-modeling-and-simulation-of-autonomous-underwater-vehicles-1619636864529.html)
   — a MathWorks talk rather than a course, and the closest thing to a
   reference for what this model is trying to be. Worth watching before you
   start.

You don't need to finish all of these before touching the model. Onramps 1 and
2 are enough to open it and follow what's happening; pick up 3 and 4 when you
start changing the physics.

## Setup

1. Open `HornetXIIChallenge.prj`.
2. Open `HornetXII_Challenge.slx` and press Run.

That's it. The project puts `lib/` on the path and loads the vehicle and
environment parameters into the base workspace for you.

If you ever get `Unrecognized function or variable 'Vehicle'`, run
`VehicleParameters` and try again.

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
