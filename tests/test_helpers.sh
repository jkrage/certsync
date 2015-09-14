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
    ${TEST_FUNCTION}${OUTPUT_OPTION} && note "Passed: ${TEST_LABEL}" || warn "Failed: ${TEST_LABEL}"
}

#TODO: Test the pretty output functions

function test_helpers_include () {
    local return_value=0
	include "test_helpers_include.sh"
    if [ -z "${__TEST_HELPERS_INCLUDE_FUNCTION}" ]; then
        return_value=1
    fi
    unset __TEST_HELPERS_INCLUDE_FUNCTION
    return ${return_value}
}

test_wrapper "function include()" test_helpers_include
