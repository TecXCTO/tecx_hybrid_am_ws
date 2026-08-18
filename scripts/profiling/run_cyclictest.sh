# scripts/profiling/run_cyclictest.shThis shell script automates system profiling under heavy processing loads. It locks thread assignments to designated processor cores (-t1 -a 1) and isolates maximum kernel delay steps down to microsecond intervals to validate hardware readiness for aerospace-grade manufacturing.
#!/usr/bin/env bash
# ---------------------------------------------------------------------------------
# PREEMPT_RT Real-Time Microsecond Kernel Jitter Latency Profiler Script
# ---------------------------------------------------------------------------------

# ANSI Color Output formatting definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${YELLOW}[PROFILER] Initializing PREEMPT_RT Hardware Suitability Benchmark...${RESET}"

# 1. Verify rt-tests utility suite is installed on the host operating system
if ! command -v cyclictest &> /dev/null; then
    echo -e "${YELLOW}[PROFILER] cyclictest utility missing. Auto-installing dependencies...${RESET}"
    sudo apt-get update && sudo apt-get install -y rt-tests
fi

echo -e "${GREEN}[PROFILER] Executing 10,000 cycle loop benchmark on isolated CPU core 1...${RESET}"
echo -e "${YELLOW}[PROFILER] Crucial: For mission-critical production, peak latency spikes must remain under 50us.${RESET}"

# 2. Run high-priority cyclictest sequence:
# -p 99: Elevate priority to 99
# -t1: Spawn exactly one testing thread
# -a 1: Pin testing process affinity directly to CPU core 1
# -n: Use clock_nanosleep operations
# -l 10000: Run for 10,000 measurement loops
sudo cyclictest -p 99 -t1 -a 1 -n -l 10000 -h 100 -q > latency_report.txt

# 3. Parse and evaluate max latency results from the output report
MAX_LATENCY=$(grep -oP 'Max Latency:\s+\K[0-9]+' latency_report.txt | sort -rn | head -n 1)

if [ -z "$MAX_LATENCY" ]; then
    # Fallback parsing strategy for variations in terminal log formatting versions
    MAX_LATENCY=$(awk '/Max:/ {print $4}' latency_report.txt | sed 's/[^0-9]//g')
fi

echo -e "\n=================================================="
echo -e "         REAL-TIME KERNEL LATENCY REPORT          "
echo -e "=================================================="
echo -e "Peak Latency Spike Recorded: ${YELLOW}${MAX_LATENCY} microseconds${RESET}"

if [ "$MAX_LATENCY" -lt 50 ]; then
    echo -e "Validation Status: ${GREEN}PASSED - Aerospace Quality Determinism Confirmed.${RESET}"
else
    echo -e "Validation Status: ${RED}FAILED - Jitter exceeds hard real-time parameters. Isolate CPU cores via GRUB.${RESET}"
fi
echo -e "=================================================="
