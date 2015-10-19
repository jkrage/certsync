#!/usr/bin/env bash
###
### test_openssl.sh -- Tests for openssl convenience functions

# Load the helpers.sh file
source "$(dirname $0)/../helpers.sh" || { echo "ERROR: helpers.sh not found!" ;exit 1 ; }
# Enforce being in the tests directory
[[ "$(dirname $0)" == "." ]] || { echo "ERROR: Please run this script directly from the tests/ directory." ; exit 1 ; }

### Master wrapper function for Testing
function test_wrapper () {
    local _INVERT=""
    if [ "$1" == "--invert" ]; then
        _INVERT="true"
        shift
    fi

    local TEST_LABEL=$1
    local TEST_FUNCTION=$2
    local PRESERVE_OUTPUT=$3
    local OUTPUT_OPTION=""

    debug "Testing: ${TEST_LABEL} using ${TEST_FUNCTION}"
    if [ ! -z "${PRESERVE_OUTPUT}" ]; then
        OUTPUT_OPTION=" >/dev/null 2>&1"
    fi
    if [ -z "${_INVERT}" ]; then
        ${TEST_FUNCTION}${OUTPUT_OPTION} && note "Passed: ${TEST_LABEL}" || error --noexit "Failed: ${TEST_LABEL}"
    else
        ${TEST_FUNCTION}${OUTPUT_OPTION} && error --noexit "Failed: ${TEST_LABEL}" || note "Passed: ${TEST_LABEL}"
    fi
}

function test_openssl_pem_to_der_01 () {
    return
}

function test_openssl_get_certinfo_01 () {
    return
}

# Prepare the testing environment
CMD_OPENSSL="/usr/bin/openssl"
include "../openssl.sh"
TEST_CERT_PEM="test_certificate.pem"
TEST_CERT_DER="test_certificate.cer"

test_wrapper "function test_openssl_pem_to_der()_01" test_openssl_pem_to_der_01

openssl_load_certinfo "${TEST_CERT_DER}"
cert_info_show
openssl_pem_to_der --suffix=der "${TEST_CERT_PEM}"
openssl_load_certinfo --type=PEM "${TEST_CERT_PEM}"
cert_info_show
openssl_pem_to_der --warnonly --suffix=der "does-not-exist"
