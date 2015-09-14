#!/usr/bin/env bash
###
### test_helpers.sh -- Tests for convenience functions and setup

# Load the helpers.sh file
source "$(dirname $0)/../helpers.sh" || (echo "ERROR: helpers.sh not found!" ;exit 1)

### Master wrapper function for Testing
function test_wrapper () {
    TEST_LABEL=$1
    TEST_FUNCTION=$2
    note "Testing: ${TEST_LABEL}"
    ${TEST_FUNCTION} >/dev/null 2>&1 && note "Passed: ${TEST_LABEL}" || warn "Failed: ${TEST_LABEL}"
}

#TODO: Test the pretty output functions

function test_helpers_include () {
    local return_value
	include "test_helpers_include.sh"
    if [ ! -z "${__TEST_HELPERS_INCLUDE_FUNCTION}" ]; then
        return_value=0
    else
        return_value=1
    fi
    return ${retval}
}

test_wrapper "function include()" test_helpers_include
