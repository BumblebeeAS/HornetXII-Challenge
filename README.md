# Hornet XII Candidate Challenge

Pick **one** of the challenges below and work on it. We will spend the interview
talking about what you did.

| Challenge | What it is | You would be working in |
|---|---|---|
| [**Bottom camera search**](bottom-camera-search/) | A working AUV simulation with no camera. Give the vehicle a way to see the seafloor, find a cube on it, and settle over it. | MATLAB, Simulink, Simscape Multibody |
| [**Mission debug tooling**](mission-debug-tooling/) | Our competition missions are behaviour trees we can barely see into. Build some of the debugging and visualization we do not have. | ROS 2, `py_trees`, Python, Foxglove |
| [**Real vehicle localisation**](real-vehicle-localisation/) | Real AUV rosbags with IMU, DVL, depth and bottom camera feeds. Fuse sensor data into a reliable state estimate and evaluate its drift. | ROS 2, Python / C++, Foxglove |

They are deliberately unalike: one is simulation, control and vision; another is developer tooling on a live robotics stack; and the last is sensor fusion and state estimation on real vehicle data. Choose the one you would rather spend a week on.

None is the harder one, and there are no points for attempting more than one.

## What applies to all of them

- **Tell us which one you picked**, up front.
- **Something working that you can explain beats something ambitious that you cannot.**
  We will ask why you made each choice, and "I ran out of time" is a fine answer where
  "I am not sure why that is there" is not.
- **Write a page or two.** What you built, what you tried that failed, what you would do
  with two more weeks. Each challenge's README says what else it wants.
- **Use whatever tools you like**, coding agents included. That is how we work. Just be
  able to account for what you shipped.

Each folder's README has the full brief, setup steps and requirements. Read the one you
picked before you start.

## Logistics & Submission

- **Submission Deadline & Form**: Candidates are to submit their work via the **workshop task submission form** (the same form used for Task 1 and Task 2) **before their interview**.
- **Interview Discussion**: Task 3 will be evaluated and discussed during your interview. Come prepared to walk through your code, show demos/results, and discuss your design choices, trade-offs, and learnings!

All the best!
