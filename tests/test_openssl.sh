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

function test_openssl_test_env_ready () {
    [ -f "${TEST_CERT_PEM}" ] && [ ! -f "${TEST_CERT_NONEXISTENT}" ]
}

function test_openssl_pem_to_der_01 () {
    # Expect failure, missing input file
    debug "Attemping to generate .der form of ${TEST_CERT_NONEXISTENT} (expecting failure)"
    local return_value=1
    openssl_pem_to_der --suffix=der "${TEST_CERT_NONEXISTENT}"
    return_value=$?
    return ${return_value}
}

function test_openssl_pem_to_der_02 () {
    # Expect failure, bad input file
    debug "Attemping to generate .der form of ${TEST_CERT_NOTACERT} (expecting failure)"
    local return_value=1
    openssl_pem_to_der --suffix=der "${TEST_CERT_NOTACERT}"
    return_value=$?
    return ${return_value}
}

function test_openssl_pem_to_der_03 () {
    # Expect success, nominal path
    debug "Generating .der form of ${TEST_CERT_PEM} (expecting ${TEST_CERT_DER})"
    local return_value=1
    openssl_pem_to_der --suffix=der "${TEST_CERT_PEM}"
    return_value=$?

    # If conversion succeeded, ensure the expected output file exists as well
    if [ ${return_value} == 0 ]; then
        if [ ! -f "${TEST_CERT_DER}" ]; then
            warn "Expected file ${TEST_CERT_DER} is missing."
            return_value=1
        fi
    fi
    return ${return_value}
}

function test_openssl_get_certinfo_01 () {
    openssl_load_certinfo "${TEST_CERT_DER}"
    cert_info_show
}

function test_openssl_get_certinfo_02 () {
    openssl_load_certinfo --type=PEM "${TEST_CERT_PEM}"
    cert_info_show
}

# Prepare the testing environment
CMD_OPENSSL="/usr/bin/openssl"
include "../openssl.sh"
TEST_CERT_PEM="test_certificate.pem"
TEST_CERT_DER="test_certificate.der"
TEST_CERT_CER="test_certificate.cer"
TEST_CERT_SERIAL="BADBADBAD"
TEST_CERT_NONEXISTENT="this-certificate-does-not-exist"
TEST_CERT_NOTACERT="test_openssl.config"

test_wrapper "environment: ensure ${TEST_CERT_PEM} exists and ${TEST_CERT_NONEXISTENT} does not exist" test_openssl_test_env_ready
test_wrapper --invert "function test_openssl_pem_to_der() 01 (missing input)" test_openssl_pem_to_der_01
test_wrapper --invert "function test_openssl_pem_to_der() 02 (bad input)" test_openssl_pem_to_der_02
test_wrapper "function test_openssl_pem_to_der() 03 (good input)" test_openssl_pem_to_der_03
test_wrapper "function openssl_get_certinfo 01" test_openssl_get_certinfo_01
test_wrapper "function openssl_get_certinfo 02" test_openssl_get_certinfo_02
