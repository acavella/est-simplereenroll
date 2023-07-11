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
basedir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tempdir=$(mktemp -d /tmp/est.XXXXXX)

# Script Variables
dtg=$(date '+%s')
cacert="${tempdir}/trust.pem"

# CA Details //User Defined
cafqdn="twsldc205.gray.bah-csfc.lab"
caprofile="eud"
publicport="443"
privateport="8443"
estpuburl="https://${cafqdn}:${publicport}/certagent/est/${caprofile}/"
estprivurl="https://${cafqdn}:${privateport}/certagent/est/${caprofile}/"

# Client Details 
clientcert="/path/to/user_cert.p12"  # User Defined
p12pw=${1:-} 
cnvalue=$(openssl x509 -noout -subject -in /home/acavella/stackexchange.pem -nameopt multiline | grep commonName | awk '{ print $3 }')

######## FUNCTIONS #########

show_variables() {
    echo ${estpuburl}
    echo ${estprivurl}
    echo ${cnvalue}
    echo ${p12pw}
    echo ${tempdir}
}

get_cacert() {
    curl --insecure ${cauri}/cacerts -v -o ${cacert}
}

submit_request() {
    openssl pkcs12 extract public cert
    openssl pkcs12 extract private key
    
}

show_variables
