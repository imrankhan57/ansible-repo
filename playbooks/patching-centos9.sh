#!/bin/bash
#
# RHEL 7 Patching Script
#

LOG_DIR="/var/log/patching"
LOG_FILE="$LOG_DIR/patching_$(date +'%Y-%m-%d_%H-%M-%S').log"
REBOOT_REQUIRED=false
DRY_RUN=false

# ====== FUNCTIONS ======

usage() {
    echo "Usage: $0 [-d] [-r]"
    echo "  -d   Dry run (show updates, don’t apply)"
    echo "  -r   Reboot if kernel/security updates are applied"
    exit 1
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "❌ Please run as root or with sudo."
        exit 1
    fi
}

prepare_logs() {
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
}

dry_run_updates() {
    echo "🔍 Listing available updates (dry run mode)..." | tee -a "$LOG_FILE"
    yum list updates | tee -a "$LOG_FILE"
    echo "Dry run complete. Exiting." | tee -a "$LOG_FILE"
    exit 0
}

apply_patches() {
    echo "🚀 Applying patches..." | tee -a "$LOG_FILE"
    yum -y update >> "$LOG_FILE" 2>&1
}

check_reboot() {
    if $REBOOT_REQUIRED; then
        if needs-restarting -r >/dev/null 2>&1; then
            echo "🔄 Reboot required after patching." | tee -a "$LOG_FILE"
            reboot
        else
            echo "✅ No reboot required." | tee -a "$LOG_FILE"
        fi
    else
        echo "ℹ️ Reboot option not enabled. Skipping reboot." | tee -a "$LOG_FILE"
    fi
}

# ====== MAIN ======
while getopts "dr" opt; do
    case $opt in
        d) DRY_RUN=true ;;
        r) REBOOT_REQUIRED=true ;;
        *) usage ;;
    esac
done

check_root
prepare_logs

if $DRY_RUN; then
    dry_run_updates
else
    apply_patches
    check_reboot
    echo "✅ Patching completed. Log file: $LOG_FILE"
fi
