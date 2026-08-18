# tecx_hybrid_am_ws

## TecX (Technology Engineering Computation Expansion ) Hybrid Additive Manufacturing Workspace

### Part 1: GitHub Repository Structural Architecture
To deploy a high-reliability system capable of real-time defect correction at 1kHz, the codebase must split responsibilities cleanly. High-level path-planning and model updates happen via ROS 2 and MuJoCo, your optimized TensorRT / NPU inferencing pipeline detects defects in raw structural elements, and a custom Real-Time Linux (PREEMPT_RT) C++ loop manages multi-axis actuation.Run these terminal commands to lay out your production-grade advanced manufacturing workspace:

```
# 1. Structure the architectural layout
mkdir -p hybrid_am_ws/src
cd hybrid_am_ws/src

# Create ROS 2 control, vision processing, NPU inference, and hardware communication stacks
mkdir -p am_machine_description/urdf am_machine_description/mujoco
mkdir -p am_realtime_core/src am_realtime_core/include
mkdir -p am_npu_inference/src am_npu_inference/models
mkdir -p am_rtf_logger/src am_rtf_logger/include

# 2. Initialize your custom tracking environment
cd ..
git init
echo "build/
install/
log/
.vscode/
*.pyc
*.bin
*.engine" > .gitignore

git add .
git commit -m "Initial commit: Production PREEMPT_RT + NPU Additive Manufacturing workspace finalized"
git branch -M main
# Link live to GitHub (Replace 'yourusername' with your actual username)
# git remote add origin https://github.com
```

Your final repository file tree will be structured exactly like this:

```
hybrid_am_ws/
├── .gitignore
├── src/
│   ├── am_machine_description/
│   │   ├── urdf/spatial_arm.urdf     <-- 6-DOF Robot + Deposition Head URDF
│   │   └── mujoco/am_scene.xml       <-- MuJoCo Real-Time Twin & Thermal Env
│   ├── am_realtime_core/
│   │   ├── src/preempt_rt_loop.cpp   <-- 1kHz Real-Time Core Loop (sched_setscheduler)
│   │   └── CMakeLists.txt
│   ├── am_npu_inference/
│   │   ├── src/npu_quant_engine.cpp  <-- INT8 Edge-NPU Defect Prediction Pipeline
│   │   └── CMakeLists.txt
│   └── am_rtf_logger/
│       ├── include/print_rtf.h       <-- RTF Structured Console Telemetry
│       └── src/print_rtf.cpp
```
### Part 2: Complete Package Source Files
#### File 1: src/am_machine_description/mujoco/am_scene.xml
The simulation scene maps out a 6-DOF industrial robotic system equipped with position servos and a material deposition tip.

#### File 2: src/am_rtf_logger/include/print_rtf.h
This logging framework uses explicit ANSI escape blocks to display structural error notifications across real-time diagnostic consoles.

#### File 3: src/am_npu_inference/src/npu_quant_engine.cpp
This class manages the low-latency visual inspection pipeline on your edge processor. It loads an INT8-quantized anomaly model via TensorRT to predict structural surface defects during production.

#### File 4: src/am_realtime_core/src/preempt_rt_loop.cpp

This script implements your high-reliability control loop. It locks memory pages using mlockall to eliminate memory swap delays, boosts process priority to SCHED_FIFO (99) to override standard OS tasks, and updates toolpath trajectories in real time based on defect inputs from the NPU.

### Part 3: Compile, Verify Real-Time Performance, and Deploy
Execute these steps in your Linux terminal to build your repository, verify that your kernel is properly configured for real-time task isolation, and push your final production-ready code live.

## 2. 
To achieve sub-millisecond synchronization and guarantee deterministic tracking performance for aerospace and critical components, we will add Real-Time Shared Memory (POSIX Shared Memory / shm_open) to completely eliminate IPC network latency between MuJoCo and ROS 2. We will also implement a cyclictest Profiling Script to measure and document your microsecond-level kernel scheduling latency.Here is the step-by-step process and the updated codebase to complete your production repository workspace.

### Part 1: Update Your Custom GitHub Repository Structural Layout
Run these commands in your workspace terminal to adjust your project scaffolding for the Shared Memory interface and the profiling test script:
```
# 1. Verify workspace tracking layout
git status

# 2. Generate a dedicated profiling subfolder for kernel benchmarking
mkdir -p scripts/profiling
touch scripts/profiling/run_cyclictest.sh
```
Your updated repository tree will match this structural layout:
```
hybrid_am_ws/
├── .gitignore
├── scripts/
│   └── profiling/
│       └── run_cyclictest.sh         <-- Automated Kernel Latency Profiler Script
├── src/
│   ├── am_machine_description/
│   │   └── mujoco/am_scene.xml
│   ├── am_realtime_core/
│   │   ├── src/preempt_rt_loop.cpp   <-- Updated 1kHz Loop with POSIX Shared Memory
│   │   └── CMakeLists.txt            <-- Linked with -lrt (Realtime Extensions)
│   ├── am_npu_inference/
│   │   └── src/npu_quant_engine.cpp
│   └── am_rtf_logger/
│       └── include/print_rtf.h
```
### Part 2: Complete Real-Time Sync & Latency Profiling Source Files
#### File 1: src/am_realtime_core/src/preempt_rt_loop.cpp
We rewrite the preempt_rt_loop.cpp file to open a high-reliability POSIX shared memory block (/am_mujoco_shm). The 1kHz execution loop now reads the simulated robot states and updates actuator references directly via physical pointer operations in RAM, avoiding the latency of network sockets.

#### File 2: src/am_realtime_core/CMakeLists.txt
To support low-latency memory pointer calls across process blocks, we update your compilation script to link against the standard Linux real-time extensions library (rt).

#### File 3: scripts/profiling/run_cyclictest.sh
This shell script automates system profiling under heavy processing loads. It locks thread assignments to designated processor cores (-t1 -a 1) and isolates maximum kernel delay steps down to microsecond intervals to validate hardware readiness for aerospace-grade manufacturing.

### Part 3: Deploy, Profile, and Push Your Repository LiveExecute these terminal commands to compile your shared memory system, profile your kernel's scheduling latency, and push your changes to GitHub.
