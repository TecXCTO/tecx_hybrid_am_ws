// src/am_realtime_core/src/preempt_rt_loop.cpp
// This script implements your high-reliability control loop. It locks memory pages using mlockall to eliminate memory swap delays, boosts process priority to SCHED_FIFO (99) to override standard OS tasks, and updates toolpath trajectories in real time based on defect inputs from the NPU.

#include <iostream>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <sys/mman.h>
#include <sched.h>
#include <rclcpp/rclcpp.hpp>
#include <std_msgs/msg/float64_multi_array.hpp>
#include "print_rtf.h"
#include "../../am_npu_inference/src/npu_quant_engine.cpp"

#define CONTROL_PERIOD_NS 1000000 // Strict 1 millisecond execution frequency limit (1kHz)

class PreemptRtControlEngine : public rclcpp::Node {
public:
    PreemptRtControlEngine() : Node("am_preempt_rt_core") {
        command_pub_ = this->create_publisher<std_msgs::msg::Float64MultiArray>("/spatial_arm_joint_commands", 10);
        
        // Initialize the NPU inspection subsystem
        defect_predictor_ = std::make_unique<NpuDefectPredictor>();
        defect_predictor_->initialize("../am_npu_inference/models/defect_quant_int8.engine");
        
        RtfLogger::log_info("RT_CORE", "PREEMPT_RT Real-Time processing node active.");
    }

    void lock_and_execute_rt_loop() {
        struct sched_param param;
        param.sched_priority = 99; // Maximum priority for real-time threads

        // 1. Elevate thread scheduling priority to SCHED_FIFO to block normal OS tasks
        if (sched_setscheduler(0, SCHED_FIFO, &param) == -1) {
            RtfLogger::log_warn("RT_CORE", "Failed to set SCHED_FIFO scheduling priority. Run executable with sudo privileges!");
            return;
        }

        // 2. Lock current and future memory pages into RAM to completely eliminate page faults
        if (mlockall(MCL_CURRENT | MCL_FUTURE) == -1) {
            RtfLogger::log_critical("RT_CORE", "mlockall execution crashed! Hard memory constraints unfulfilled.");
            return;
        }

        RtfLogger::log_info("RT_CORE", "Memory space locked successfully. Hard real-time constraints active.");

        struct timespec next_wake;
        clock_gettime(CLOCK_MONOTONIC, &next_wake);

        std::vector<float> mock_sensor_frame(256, 0.5f);
        auto command_msg = std_msgs::msg::Float64MultiArray();
        command_msg.data.resize(6, 0.0);

        while (rclcpp::ok()) {
            // Compute the target time for the next 1kHz clock cycle
            next_wake.tv_nsec += CONTROL_PERIOD_NS;
            if (next_wake.tv_nsec >= 1000000000) {
                next_wake.tv_sec += 1;
                next_wake.tv_nsec -= 1000000000;
            }

            // 3. Process low-latency sensory data through the NPU matrix
            float defect_probability = defect_predictor_->run_realtime_inspection(mock_sensor_frame);

            // 4. Closed-loop adaptation: dynamically adjust the path if structural anomalies are found
            double adaptive_compensation_factor = 0.0;
            if (defect_probability > 0.70f) { // If anomaly detection confidence exceeds 70%
                RtfLogger::log_warn("RT_CORE", "Structural defect detected by NPU! Adapting printhead trajectory paths.");
                adaptive_compensation_factor = 0.004; // Micro-step shift to fix defects in real time
            }

            // Calculate tracking trajectories across all 6 spatial axes
            double time_stamp = this->now().seconds();
            command_msg.data[0] = 0.6 * sin(time_stamp * 0.4) + adaptive_compensation_factor;
            command_msg.data[1] = 0.3 * cos(time_stamp * 0.4);
            command_msg.data[2] = 0.2 * sin(time_stamp * 0.8);
            command_msg.data[3] = 0.0;
            command_msg.data[4] = 0.0;
            command_msg.data[5] = time_stamp * 0.05; // Continuous rotation for material deposition

            command_pub_->publish(command_msg);

            // 5. High-precision sleep function ensures the loop executes exactly at the 1ms mark
            clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &next_wake, NULL);
        }
    }

private:
    rclcpp::Publisher<std_msgs::msg::Float64MultiArray>::SharedPtr command_pub_;
    std::unique_ptr<NpuDefectPredictor> defect_predictor_;
};

int main(int argc, char **argv) {
    rclcpp::init(argc, argv);
    auto rt_node = std::make_shared<PreemptRtControlEngine>();
    
    // Execute the real-time processing loop inside a dedicated thread block
    std::thread rt_execution_thread(&PreemptRtControlEngine::lock_and_execute_rt_loop, rt_node);
    
    rclcpp::spin(rt_node);
    rt_execution_thread.join();
    rclcpp::shutdown();
    return 0;
}
