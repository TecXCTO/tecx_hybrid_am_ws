# Compile, Verify Real-Time Performance, and DeployExecute these steps in your Linux terminal to build your repository, verify that your kernel is properly configured for real-time task isolation, and push your final production-ready code live.

# 1. Verify your Ubuntu system kernel has the PREEMPT_RT patch enabled
uname -v | grep PREEMPT

# 2. Source your local system ROS 2 environment paths
source /opt/ros/jazzy/setup.bash

# 3. Build your real-time processing workspace
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

# 4. Source setup paths and run the executable with elevated real-time thread permissions (sudo)
source install/setup.bash
sudo ./build/am_realtime_core/am_preempt_rt_core

# 5. Push your completed production workspace live to GitHub
git add .
git commit -m "Deploy production 1kHz PREEMPT_RT core loop integrated with INT8 NPU real-time defect correction infrastructure"
git push origin main
