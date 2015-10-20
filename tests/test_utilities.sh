#!/usr/bin/env bash
###
### test_utilities.sh -- Tests for convenience functions and setup

# Load the test-harness.sh file
source "$(dirname $0)/test-harness.sh" || { echo "ERROR: test-harness.sh not found!" ;exit 1 ; }

#TODO: Test the pretty output functions

function test_utilities_include () {
    local return_value=0
	include "data_utilities_include.sh"
    if [ -z "${__TEST_UTILITIES_INCLUDE_FUNCTION}" ]; then
        return_value=1
    fi
    unset __TEST_UTILITIES_INCLUDE_FUNCTION
    return ${return_value}
}


function test_get_absolute_path_01 () {
    # Test file
    local return_value=0
    local _PWD=${PWD}
    local TEST_VALUE
    local TEST_FILE="test_utilities.sh"

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
    local TEST_FILE="${PWD}/test_utilities.sh"

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
    local TEST_FILE="../utilities.sh"

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

test_session_begin "helper functions and variables."
test_wrapper "function include()" test_utilities_include
test_wrapper "function get_absolute_path()_01 file" test_get_absolute_path_01
test_wrapper "function get_absolute_path()_02 ./file" test_get_absolute_path_02
test_wrapper "function get_absolute_path()_03 /path/file" test_get_absolute_path_03
test_wrapper "function get_absolute_path()_04 ../file" test_get_absolute_path_04
test_wrapper "variable UNAME_S" test_uname-s
test_session_end
