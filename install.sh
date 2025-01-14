#!/bin/bash

KLIPPER_PATH="/usr/data/klipper/"
AUTOTUNETMC_PATH="${HOME}/klipper_tmc_autotune"

if [[ -e ${KLIPPER_PATH}/klippy/plugins/ ]]; then
    KLIPPER_PLUGINS_PATH="/usr/data/klipper/klippy/plugins/"
else
    KLIPPER_PLUGINS_PATH="/usr/data/klipper/klippy/extras/"
fi

set -eu
export LC_ALL=C


function preflight_checks {
    if [ "$EUID" -eq 1 ]; then
        echo "[PRE-CHECK] This script must not be run as root!"
        exit -1
    fi

}

function check_download {
    local autotunedirname autotunebasename
    autotunedirname="$(dirname ${AUTOTUNETMC_PATH})"
    autotunebasename="$(basename ${AUTOTUNETMC_PATH})"

    if [ ! -d "${AUTOTUNETMC_PATH}" ]; then
        echo "[DOWNLOAD] Downloading Autotune TMC repository..."
        if git -C $autotunedirname clone https://github.com/Ice9922/klipper_tmc_autotune.git $autotunebasename; then
            chmod +x ${AUTOTUNETMC_PATH}/install.sh
            printf "[DOWNLOAD] Download complete!\n\n"
        else
            echo "[ERROR] Download of Autotune TMC git repository failed!"
            exit -1
        fi
    else
        printf "[DOWNLOAD] Autotune TMC repository already found locally. Continuing...\n\n"
    fi
}

function link_extension {
    echo "[INSTALL] Linking extension to Klipper..."

    ln -srfn "${AUTOTUNETMC_PATH}/autotune_tmc.py" "${KLIPPER_PLUGINS_PATH}/autotune_tmc.py"
    ln -srfn "${AUTOTUNETMC_PATH}/motor_constants.py" "${KLIPPER_PLUGINS_PATH}/motor_constants.py"
    ln -srfn "${AUTOTUNETMC_PATH}/motor_database.cfg" "${KLIPPER_PLUGINS_PATH}/motor_database.cfg"
}

function restart_klipper {
    echo "[POST-INSTALL] Restarting Klipper..."
    sudo systemctl restart klipper
}


printf "\n======================================\n"
echo "- Autotune TMC install script -"
printf "======================================\n\n"


# Run steps
preflight_checks
check_download
link_extension
restart_klipper
