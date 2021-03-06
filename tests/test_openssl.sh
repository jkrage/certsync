#!/usr/bin/env bash
###
### test_openssl.sh -- Tests for openssl convenience functions

# Load the test-harness.sh file
source "$(dirname $0)/test-harness.sh" || { echo "ERROR: test-harness.sh not found!" ;exit 1 ; }

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
    debug "Generating .cer form of ${TEST_CERT_PEM} (expecting ${TEST_CERT_CER})"
    local return_value=1
    openssl_pem_to_der "${TEST_CERT_PEM}"
    return_value=$?

    # If conversion succeeded, ensure the expected output file exists as well
    if [ ${return_value} == 0 ]; then
        if [ ! -f "${TEST_CERT_CER}" ]; then
            warn "Expected file ${TEST_CERT_CER} is missing."
            return_value=1
        fi
    fi
    return ${return_value}
}

function test_openssl_pem_to_der_04 () {
    # Expect success, nominal path (.der)
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
    # Test we loaded the expected .cer certificate by checking the serial number
    debug "Checking serial number of ${TEST_CERT_CER}, expecting ${TEST_CERT_SERIAL}"
    cert_info_init
    openssl_load_certinfo "${TEST_CERT_CER}"
    [ "${CERT_SERIAL}" == "${TEST_CERT_SERIAL}" ]
}

function test_openssl_get_certinfo_02 () {
    # Test we loaded the expected .pem certificate by checking the serial number
    debug "Checking serial number of ${TEST_CERT_PEM}, expecting ${TEST_CERT_SERIAL}"
    cert_info_init
    openssl_load_certinfo --type=PEM "${TEST_CERT_PEM2}"
    [ "${CERT_SERIAL}" == "${TEST_CERT_SERIAL}" ]
}

# Prepare the testing environment
CMD_OPENSSL="/usr/bin/openssl"
include "../openssl.sh"
TEST_CERT_PEM="certificate_for_testing.pem"
TEST_CERT_DER="certificate_for_testing.der"
TEST_CERT_CER="certificate_for_testing.cer"
TEST_CERT_SERIAL="0BADBADBAD"
TEST_CERT_NONEXISTENT="this-certificate-does-not-exist"
TEST_CERT_NOTACERT="test_openssl.config"

test_session_begin "OpenSSL support using a generate test certificate."
test_wrapper "environment: ensure ${TEST_CERT_PEM} exists and ${TEST_CERT_NONEXISTENT} does not exist" test_openssl_test_env_ready
test_wrapper --invert "function test_openssl_pem_to_der() 01 (missing input)" test_openssl_pem_to_der_01
test_wrapper --invert "function test_openssl_pem_to_der() 02 (bad input)" test_openssl_pem_to_der_02
test_wrapper "function test_openssl_pem_to_der() 03 (good input, .cer)" test_openssl_pem_to_der_03
test_wrapper "function test_openssl_pem_to_der() 03 (good input, .der)" test_openssl_pem_to_der_04
test_wrapper "function openssl_get_certinfo 01" test_openssl_get_certinfo_01
test_wrapper "function openssl_get_certinfo 02" test_openssl_get_certinfo_02
test_session_end
