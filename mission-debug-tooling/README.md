# HornetXII Challenge — mission debug tooling

**Stack:** ROS 2 Humble · `py_trees` / `py_trees_ros` · Foxglove
**Repo:** https://github.com/bumblebeeas/examples (BlueROV + ArduSub sim)

---

## The problem

Our missions are behaviour trees. When one misbehaves, the only view we have is
a console ASCII tree, and even that isn't wired into the examples today.

Look at the torpedo mission (`packages/bluerov_tasks/bluerov_tasks/torpedo/torpedo.py`).
It is wrapped in `FailureIsSuccess` decorators, `Retry` decorators, and a
top-level fallback selector that fires both torpedoes blind if anything upstream
fails. A run can report **SUCCESS** having silently skipped most of its logic: vision
never started, clustering never converged, the wrong template was picked. The
console gives you almost nothing to tell those cases apart.

There is a second axis: **mission time**. RoboSub gives us a tight run window, and
today we have no principled way to say where a mission's minutes actually went —
which stage, which retry, which realignment loop. We optimize by guessing.

Those are the gaps. Close some of them.

---

## What you're building

### Spine (required)

Get structured, per-tick mission state out of a running behaviour tree and into
Foxglove, and demonstrate it on a real mission run.

We are deliberately **not** telling you the schema, the transport, or the update
strategy. Those choices are the task.

### Then pick 2 (or 1, done deeply)

| Option | Sketch |
|---|---|
| **Tree state panel** | Live node status, active path, status transitions, time-in-node |
| **Mission-time profiler** | Per-stage tick and time accounting — how long did `cluster_and_goto_centre` hold the tree, and where did the mission's total time go? |
| **Blackboard panel** | Namespaced key tree (`/global/*`, `/bluerov/torpedo/*`) with change highlighting |
| **On-vehicle probe recorder** | A probe a developer drops into a tree in one line. It runs during real missions, unattended, and captures a bounded snapshot when its predicate fires — so a pool test or a competition run yields something triage-able without recording everything, and without a human watching |
| **Post-hoc stepper** | Step a recorded run event by event — by tick, and by tree-status change — with every panel and the log synced to that instant |

> **On the profiler — this is the option closest to a live pain point.**
> We need to know where mission time goes so we can cut it. Useful output looks like:
> *`cluster_and_goto_centre` held the tree for 412 ticks / 41 s across 3 attempts;
> `Goto torpedo vicinity` took 88 s of a 15-minute run.* What makes this non-trivial:
>
> - **There is no built-in notion of a "stage."** You decide how a subtree gets named and scoped for accounting — and how nested stages roll up without double-counting.
> - **`Retry` and `FailureIsSuccess` re-enter stages.** Separate *occupancy* from *attempts*, or the numbers lie.
> - **`memory=True` sequences skip completed children**, so tick counts are not proportional to position in the tree.
> - **Mission duration is sim time; your tool's overhead is wall time.** Don't mix them.

> **On the stepper — today we scrub a screen recording of the ASCII log.**
> We want to walk a recorded run the way you walk a debugger:
>
> - **Two step granularities.** Next tick, and next tree-status change (which may be many ticks later).
> - **Everything moves together.** When you land on an instant, the camera images, TF, plots and the log *for that instant* are all right there.
> - **Select and filter.** Pick a node or subtree and step only through its events. Write a predicate over status or blackboard and step only through its hits: a breakpoint you set after the run.
>
> How you hook this into Foxglove is yours to work out. We are fairly confident it is
> reachable — enough so that you shouldn't dismiss the option as impossible — but the
> recording format, what the tree has to emit for any of it to work, and where the
> event index gets computed are all open questions.

### Prior art, and why we want something different

McGill Robotics published a Foxglove panel for py_trees:
[foxglove-py-trees-viewer](https://github.com/mcgill-robotics/foxglove-py-trees-viewer).
Read it before you start. It is about 900 lines of ReactFlow + Dagre and it already
solves real problems: click-to-focus a path, latched SUCCESS so completed work stays
visible under `memory=True` sequences, and a blackboard sidebar.

Two things to know about it:

- **It will not work against our trees as they stand.** It subscribes to a `py_trees_ros`
  snapshot stream on a hardcoded topic, which our trees do not publish. Working out why,
  and what it would take, is a good first hour.
- **It draws a fixed top-down org chart.** Fine for a teaching-sized tree. Our competition
  trees are much bigger <!-- TODO: real node count -->, and rendered that way they become a
  wall you pan around at 20% zoom hunting for the one amber node.

Use it as reference, or as a starting point if you like, but **we care more about a view
that stays legible at our scale.** The indented ASCII tree we have today is genuinely good
at density. Something with that density but interactive would beat a
prettier org chart. Directions worth weighing, though pick your own:

- Collapse and expand subtrees; auto-collapse whatever finished long ago
- Filter to the visited path, or to a single stage, and put everything else away
- Sticky ancestors or breadcrumbs, so you always know where you are in the tree
- Search and jump to a node by name
- A history strip rather than only the present instant

If you reuse McGill's panel, tell us what you changed and why. If you start fresh, tell us
what you took from it.

Tell us up front which you picked and why. The reasoning matters as much as the code.

---

## Milestones

0. **Run the square mission end-to-end.** No vision, no GPU inference: pure environment sanity check.
1. **Attach the existing `LoggingSnapshotVisitor`** (`mission_planner_2/common/core/visitors.py`; currently unused by the examples). Write down **three concrete things it cannot tell you.**
2. **Publish structured tick state on a ROS topic** and view it in Foxglove using stock panels. This proves the data path.
3. **Build the view that beats stock:** a custom panel, or a genuinely well-designed layout over a well-designed schema.
4. **Use your own tool on a bin or torpedo run** and report a finding you could not easily have gotten otherwise — which stage ate the most mission time, or which retry fired silently.

**Milestone 4 carries the most weight.** Building the tool is half of it; the other
half is that the tool actually earned its place.

---

## Ground rules

- **Do not change mission behaviour.** Your tooling must be opt-in (visitor, decorator, handler), and every tree must run identically with it disabled.
- **Respect `use_sim_time`.** Everything runs under simulated time and Gazebo does not run at real-time factor 1. Mission-duration numbers belong on the sim clock; your tooling's own overhead belongs on the wall clock. Mixing them silently produces plausible-looking nonsense.
- **Document your schema.** A short section in `docs/`; `docs/architecture.md` is the house style to match.
- **Match existing idiom.** The codebase already has conventions (e.g. the `check_func` predicate style in `checked_service`). Fit in rather than inventing a parallel universe.

---

## Deliverables

1. A PR against your fork of `examples` (and `mission_planner_release` if you touched it).
2. **`DESIGN.md`** (one page). What you built, what you chose *not* to build, the trade-offs you made, and what breaks first if we scale this up.
3. A short screen recording or GIF of the tool in use. The repo README already embeds mission demo videos; same spirit.
4. Your milestone-1 list and your milestone-4 finding, written out.

---

## Environment tiers

Pick whichever your hardware supports. **Tier B and C are not penalized.**

- **Tier A — full sim.** Bin and torpedo missions. Needs an NVIDIA GPU, Gazebo, and Git LFS for the ML models. Setup is in the repo README.
- **Tier B — square mission plus recorded data.** No vision or ML. Use the square mission for the live loop and the rosbag we provide for milestone 4. <!-- TODO: host and link the bag -->
- **Tier C — synthetic tree.** No sim at all. Build your own tree that reproduces the shape of ours: deep nesting, retries, and `FailureIsSuccess` decorators masking failures.

---

## On Foxglove panels and TypeScript

Custom Foxglove panels are TypeScript extensions. **You are not expected to have a
TypeScript background, and we are not evaluating your TypeScript.**

Use a coding agent (Claude Code, Codex, Cursor, or whatever you like) to prototype the
panel. This is how we work, and we would rather see you use the tools well than
avoid the option because the language is unfamiliar. Just be able to explain what
your panel does and why it is built that way.

If a custom panel doesn't come together, a thoughtful schema plus a stock-panel
Foxglove layout (Plot, State Transitions, Table, Log) is a complete milestone 3.
Existing layouts live at
[BumblebeeAS/controlkitv3](https://github.com/BumblebeeAS/controlkitv3/tree/main/foxglove_layouts).
Note that they cover cameras and 3D only, so there is nothing here to duplicate.

Useful starting point: `ros-humble-py-trees-ros` is already installed in the image,
so `py_trees_ros_interfaces` message types are available at no cost if you
want them.

---

## Logistics

- todo, handover to Kieran
