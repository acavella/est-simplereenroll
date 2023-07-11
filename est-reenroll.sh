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
log="${basedir}/log/est${dtgf}.log"

# Script Variables
dtg=$(date '+%s')
catrust="${tempdir}/trust.pem"
esttrust="${tempdir}/est-trust.pem"

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

######## FUNCTIONS #########

show_variables() {
    # Variable debug output
    echo ${estpuburl}
    echo ${estprivurl}
    echo ${cnvalue}
    echo ${p12pw}
    echo ${tempdir}
}

get_esttrust() {
    echo "Retrieving EST Server Certificate"
    openssl s_client -connect "${cafqdn}:${publicport}" -showcerts </dev/null | openssl x509 -outform pem > "${esttrust}"
}

get_catrust() {
    echo "Retrieving CA Trust"
    curl --cacert ${esttrust} ${estpuburl}/cacerts -v -o ${catrust}
}

submit_request() {
    echo "Exporting Public Certificate"
    #Export cert and key file from original cert
    openssl pkcs12 -in ${clientcert} -out "${tempdir}/client.pem" -nodes -password pass:${p12pw}

    echo "Extracting CN value"
    cnvalue=$(openssl x509 -noout -subject -in ${tempdir}/client.pem -nameopt multiline | grep commonName | awk '{ print $3 }')

    echo "Exporting Private Key"
    openssl pkcs12 -in ${clientcert} -nocerts -out "${tempdir}/key.pem" -nodes -password pass:${p12pw}
    
    echo "Generating Certificate Signing Request"
    openssl req -new -subj "/C=US/CN=${cnvalue}" -key "${temp}/key.pem" -out "${tempdir}/req.pem"

    echo "Submitting Reenroll Request"
    curl --cacert "${esttrust}" ${estprivurl}/simplereenroll --cert "${tempdir}/client.pem" -v -o "${tempdir}/new_client.p7b" --data-binary @"${tempdir}/req.pem" -H "Content-Type: application/pkcs10" --tlsv1.2
}

convert_cert() {
    echo "Adding Proper PKCS Formatting"
    ret=$(cat "${tempdir}/new_client.p7b")
    cat <<EOF >"${tempdir}/client_formatted.p7b"
-----BEGIN PKCS7-----
$ret
-----END PKCS7-----
EOF

    echo "Generating PEM from PKCS#7"
    openssl pkcs7 -print_certs -in "${tempdir}/client_formatted.p7b" -out "${tempdir}/new_client.pem"

    echo "Generating PKCS#12 from PEM and Original Private Key"
    openssl pkcs12 -export -inkey "${tempdir}/key.pem" -in "${tempdir}/new_client.pem" -out "${basedir}/${cnvalue}_new.pfx" -password pass:${p12pw}

}

remove_temp() {
    echo "Deleting temporary directory and files"
    rm -rf ${tempdir}
}

main() {
    get_esttrust
    get_catrust
    submit_request
    convert_cert
    remote_temp
}

main
