#!/usr/bin/env bash

# netcm: Syncs appliance running configs via SNMPv3 and commits them to git
# Version 0.0.1
# (c) 2021 Tony Cavella (https://github.com/altCipher/netcm)
# This script acts as the server; syncs within an online repository
# and prepares incremental updates for transfer to offline client.
#
# This file is copyright under the latest version of the GPLv3.
# Please see LICENSE file for your rights under this license.

# -e option instructs bash to immediately exit if any command [1] has a non-zero exit status
# -u option instructs bash to exit on unset variables (useful for debugging)
set -e
set -u

######## VARIABLES #########
# For better maintainability, we store as much information that can change in variables
# These variables should all be GLOBAL variables, written in CAPS
# Local variables will be in lowercase and will exist only within functions

# Base directories
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__db="${__dir}/db"

# Script Variables
DG=$(date '+%Y%m%d')
MANIFEST="${__db}/manifest.txt"
MANIFEST_TMP="${__db}/manifest_TMP.txt"
MANIFEST_DIFF="${__db}/manifest_${DG}.txt"
DB="${__db}/repr.db"
TMP_DIR=$(mktemp -d /tmp/repo.XXXXXXXXX)
VERSION="1.0.0-beta.5d"
DETECTED_OS=$(cat /etc/os-release | grep PRETTY_NAME | cut -d '=' -f2- | tr -d '"') # Full OS name with version

# Load variables from external config
source ${__dir}/rs-server.conf

# Color Table
COL_NC='\e[0m' # No Color
COL_LIGHT_GREEN='\e[1;32m'
COL_LIGHT_RED='\e[1;31m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]"
INFO="[i]"
# shellcheck disable=SC2034
DONE="${COL_LIGHT_GREEN} done!${COL_NC}"
OVER="\\r\\033[K"

######## FUNCTIONS #########
# All operations are built into individual functions for better readibility
# and management.  

show_ascii_logo() {
    echo -e "
    repr // generate incremental yum updates
    "
}

show_version() {
    printf "NetCM version ${VERSION}"
    printf "Bash  version ${BASH_VERSION}"
    printf "${DETECTED_OS}"
    exit 0
}

show_help() {
    echo -e "
    Usage: ./repr.sh [OPTION]
    Syncs with remote RPM repo and creates incremental update packages for use with an offline repository.
        -u, --update        execute standard update process
            --help          display this help and exit
            --version       output version information and exit
    Examples:
        ./repr -u  Downloads latest RPMs and creates a tarball.
    "
    exit 0
}

is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"

    command -v "${check_command}" >/dev/null 2>&1
}

get_package_manager() {
    # Check for common package managers per OS
    if is_command dnf ; then
        PKG_MGR="dnf" # set to dnf
        printf "  %b Package manager: %s\\n" "${TICK}" "${PKG_MGR}"
    elif is_command yum ; then
        PKG_MGR="yum" # set to yum
        printf "  %b Package manager: %s\\n" "${TICK}" "${PKG_MGR}"
    else
        # unable to detect a common yum based package manager
        printf "  %b %bSupported package manager not found%b\\n" "${CROSS}" "${COL_LIGHT_RED}" "${COL_NC}"
    fi
}

first_run() {
    if [ ! -f  ]; then
        echo "File not found!"
    fi
}

## First run / Startup Checks
# Dependencies: git, snmpv3
# Build initial git repo structure

## Pull latest configs (SNMPv3 read)
# Loop through inventory
# Download running config to temp directory
# diff new config vs git config (branch master)
# if changed copy from temp to git (need to switch branch to develop)

## Git Commit
# 
