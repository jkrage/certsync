#!/usr/bin/env bash
###
### test_helpers.sh -- Tests for convenience functions and setup

# Load the helpers.sh file
source "$(dirname $0)/../helpers.sh" || { echo "ERROR: helpers.sh not found!" ;exit 1 ; }
# Enforce being in the tests directory
[[ "$(dirname $0)" == "." ]] || { echo "ERROR: Please run this script directly from the tests/ directory." ; exit 1 ; }

### Master wrapper function for Testing
function test_wrapper () {
    local TEST_LABEL=$1
    local TEST_FUNCTION=$2
    local PRESERVE_OUTPUT=$3
    local OUTPUT_OPTION=""
    debug "Testing: ${TEST_LABEL} using ${TEST_FUNCTION}"
    if [ ! -z "${PRESERVE_OUTPUT}" ]; then
        OUTPUT_OPTION=" >/dev/null 2>&1"
    fi
    ${TEST_FUNCTION}${OUTPUT_OPTION} && note "Passed: ${TEST_LABEL}" || error --noexit "Failed: ${TEST_LABEL}"
}

#TODO: Test the pretty output functions

function test_helpers_include () {
    local return_value=0
	include "data_helpers_include.sh"
    if [ -z "${__TEST_HELPERS_INCLUDE_FUNCTION}" ]; then
        return_value=1
    fi
    unset __TEST_HELPERS_INCLUDE_FUNCTION
    return ${return_value}
}


function test_get_absolute_path_01 () {
    # Test file
    local return_value=0
    local _PWD=${PWD}
    local TEST_VALUE
    local TEST_FILE="test_helpers.sh"

    TEST_VALUE=$(get_absolute_path ${TEST_FILE})
    note "${TEST_FILE} -> ${TEST_VALUE}"
    if [ "${TEST_VALUE}" != "${_PWD}" ]; then
        warn "Value ${TEST_VALUE} does not match ${_PWD} from input ${TEST_FILE}"
        return_value=1
    fi
    return ${return_value}
}

function test_get_absolute_path_02 () {
    # Test ./file
    local return_value=0
    local _PWD=${PWD}
    local TEST_VALUE
    local TEST_FILE="${0}"

    TEST_VALUE=$(get_absolute_path ${TEST_FILE})
    note "${TEST_FILE} -> ${TEST_VALUE}"
    if [ "${TEST_VALUE}" != "${_PWD}" ]; then
        warn "Value ${TEST_VALUE} does not match ${_PWD} from input ${0}"
        return_value=1
    fi
    return ${return_value}
}

function test_get_absolute_path_03 () {
    # Test /path/file
    local return_value=0
    local _PWD=${PWD}
    local TEST_VALUE
    local TEST_FILE="${PWD}/test_helpers.sh"

    TEST_VALUE=$(get_absolute_path ${TEST_FILE})
    if [ "${TEST_VALUE}" != "${_PWD}" ]; then
        warn "Value ${TEST_VALUE} does not match ${_PWD} from input ${TEST_FILE}"
        return_value=1
    fi
    return ${return_value}
}

function test_get_absolute_path_04 () {
    #Test ../file path
    local return_value=0
    local _PWD=${PWD}
    local TEST_VALUE
    local TEST_FILE="../helpers.sh"

    TEST_VALUE=$(get_absolute_path ${TEST_FILE})
    if [ "${TEST_VALUE}" != "${_PWD}" ]; then
        warn "Value ${TEST_VALUE} does not match ${_PWD} from input ${TEST_FILE}"
        return_value=1
    fi
    return ${return_value}
}

function test_uname-s () {
    if [ -z "${UNAME_S}" ]; then
        return 1
    fi
}

test_wrapper "function include()" test_helpers_include
test_wrapper "function get_absolute_path()_01 file" test_get_absolute_path_01
test_wrapper "function get_absolute_path()_02 ./file" test_get_absolute_path_02
test_wrapper "function get_absolute_path()_03 /path/file" test_get_absolute_path_03
test_wrapper "function get_absolute_path()_04 ../file" test_get_absolute_path_04
test_wrapper "variable UNAME_S" test_uname-s
