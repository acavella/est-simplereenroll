#!/usr/bin/env bash

# est-reenroll: Client side script to perform EST simple reenroll request
# Version 0.0.1
# (c) 2021 Tony Cavella (https://github.com/acavella/est-simplereenroll)

# -e option instructs bash to immediately exit if any command [1] has a non-zero exit status
# -u option instructs bash to exit on unset variables (useful for debugging)
set -e
set -u

######## VARIABLES #########

# Base directories
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__certs=${__dir}/certs)

# Global Variables
VERSION="0.0.1"
DETECTED_OS=$(cat /etc/os-release | grep PRETTY_NAME | cut -d '=' -f2- | tr -d '"')

# Script Variables
dtg=$(date '+%s')
cacert="${__certs}/trust.pem"


# User Defined Variables
cauri="https://twsldc205.gray.bah-csfc.lab/certagent/est/ca7/"
cnvalue="DemoCN"

# Load variables from external config
#source ${__dir}/est.conf

######## FUNCTIONS #########
# All operations are built into individual functions for better readibility
# and management.  

show_version() {
    printf "EST-SimpleReenroll version ${VERSION}"
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

get_cacerts() {
    curl --insecure ${cauri}/cacerts -v -o ${cacert}
}


