# HornetXII Challenge — vehicle localisation

**Stack:** ROS 2 Humble · Python / C++ · State Estimation · Foxglove / RViz / Matplotlib

---

## The problem

Underwater, there is no GPS. Light attenuates rapidly, acoustic sensors suffer from reflections and dropouts, and raw dead reckoning drifts over time.

Accurate state estimation is what keeps autonomous missions alive. To navigate, the vehicle relies on multiple onboard sensors running at vastly different rates and with distinct error characteristics:
- An **IMU** 
- A **Doppler Velocity Log (DVL)** 
- A **Pressure Sensor** 
- A **Downward-Facing Camera** viewing the pool floor.

Individually, none of these sensors tell the whole story. Your task is to take recorded vehicle sensor data, fuse it into a consistent state estimate, and evaluate the quality of your odometry.

---

## The datasets

We provide two recorded ROS 2 bags (`.db3`) captured from our vehicle under different operational profiles:

1. **Stationkeep (`stationkeep_test_basket_0`)**: The vehicle attempts to hold a fixed position and depth in the water.
2. **Movement (`ascent_descent_basket`)** 

### What's in the box

- [`extrinsics.yaml`](extrinsics.yaml): Spatial transforms $(x, y, z, \text{roll}, \text{pitch}, \text{yaw})$ of each sensor frame relative to `auv5/base_link`.
- [`bot_cam.yaml`](bot_cam.yaml): Bottom camera intrinsics, projection matrix, and lens distortion parameters.
- [`bin.sdf](bin.sdf): Model of the bin used in the bags

---

## What you're building

### Spine (required)

1. **Sensor Fusion Pipeline**: Produce a fused state estimate published as an odometry stream (`nav_msgs/msg/Odometry` or `/tf` transform `odom -> base_link`) combining the sensor data from the bags.
2. **Verification & Trajectory Analysis**: Demonstrate and plot your estimated 3D position $(x, y, z)$ and orientation (roll, pitch, yaw) over time for both the stationkeep and movement datasets.
3. **Validation**: How do you know your estimated state is physically reasonable? Formulate metrics or sanity checks to evaluate the quality and drift of your solution.

You are free to choose your architecture — whether leveraging standard ROS packages (such as `robot_localization`), writing a custom Kalman Filter (EKF/UKF), or building a factor graph. Those choices are yours to justify.

---

### Extensions (pick what interests you)

Pick one or two directions to explore more deeply:

- **Target / Object Localisation**:
  - Detect the target basket and estimate the basket's 3D position relative to the camera frame.
  - Chain your sensor extrinsics and fused odometry to estimate the static global 3D position of the basket in the world/map frame. Does the estimated global basket location remain stationary as the vehicle moves?
- **Sensor Characterization & Covariance Tuning**: How did you determine your process and measurement noise covariances ($Q$ and $R$)? Quantify the drift rate (e.g. meters/minute) during stationkeep and analyze the frequency mismatch between the 1 kHz IMU and the slower DVL/Depth sensors.
- **Visual Odometry (VO)**: Implement a vision-based displacement estimator using the bottom camera (`/auv5/bot_cam/image_raw/compressed` + `bot_cam.yaml`). Compare your visual displacement estimates against the acoustic DVL measurements.
- **Fault Detection & Outlier Rejection**: How does your estimator behave if DVL bottom lock drops out or a sensor produces noisy outliers? Propose or implement strategies to detect and reject bad sensor measurements.

---

## What to submit

1. **Code & Launch Files**: Your ROS 2 package, nodes, or analysis scripts with clear build/run instructions.
2. **Write-Up (1–2 pages)**:
   - **Architecture**: What fusion approach did you choose, and why?
   - **Plots & Results**: Trajectory and state plots for both datasets, showing position, velocity, and orientation over time.
   - **Trade-Offs & Learnings**: What hurdles did you encounter (e.g. frame transformations, noise, time synchronization)? What are the limitations of your solution, and what would you improve with more time?
