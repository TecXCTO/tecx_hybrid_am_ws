# scripts/system_config/setup_grub_isolation.shTo eliminate scheduling latency spikes, this script updates your Linux kernel boot profile. It modifies GRUB parameters to completely isolate CPU cores 2 and 3 (isolcpus=2,3 rcu_nocbs=2,3 nohz_full=2,3), shielding them from kernel background interruptions and reserving them exclusively for your real-time control threads.


#!/usr/bin/env bash
# ---------------------------------------------------------------------------------
# PREEMPT_RT Linux Kernel CPU Core Isolation Provisioner Script
# ---------------------------------------------------------------------------------

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${YELLOW}[SYSTEM_CONFIG] Initializing Real-Time Task Core Isolation setup...${RESET}"

# 1. Extract and inspect current active GRUB configuration lines
GRUB_FILE="/etc/default/grub"
if [ ! -f "$GRUB_FILE" ]; then
    echo -e "${RED}[ERROR] Target GRUB boot configuration file not found at path: ${GRUB_FILE}${RESET}"
    exit 1
fi

# 2. Modify boot parameters to isolate CPU cores 2 and 3 from the generic OS scheduler
# - isolcpus: Removes cores from regular scheduling pools
# - nohz_full: Disables scheduling clock ticks on specified isolated cores
# - rcu_nocbs: Offloads Read-Copy Update callback routines to non-isolated processors
TARGET_PARAMS="isolcpus=2,3 rcu_nocbs=2,3 nohz_full=2,3"

if grep -q "isolcpus=" "$GRUB_FILE"; then
    echo -e "${YELLOW}[SYSTEM_CONFIG] Core isolation parameters already present. Updating settings...${RESET}"
    sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*/& ${TARGET_PARAMS}/" "$GRUB_FILE"
else
    echo -e "${GREEN}[SYSTEM_CONFIG] Appending isolation parameters directly into GRUB boot options...${RESET}"
    sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"${TARGET_PARAMS} /" "$GRUB_FILE"
fi

# 3. Regenerate and reload system boot configurations
echo -e "${YELLOW}[SYSTEM_CONFIG] Recompiling system GRUB bootloader parameters...${RESET}"
sudo update-grub

echo -e "\n================================================================="
echo -e "      HARDWARE CORES ISOLATION PROVISIONING COMPLETED           "
echo -e "================================================================="
echo -e "${GREEN}Configuration Applied: Dedicated CPU cores 2 & 3 isolated.${RESET}"
echo -e "${YELLOW}Action Required: Please restart your machine to apply the kernel updates!${RESET}"
echo -e "================================================================="
