#!/usr/bin/env bash
###
### test-harness.sh -- Common test harness support functions
### Included by other scripts, such as through:
### source "$(dirname $0)/test-harness.sh" || { echo "ERROR: test-harness.sh not found!" ;exit 1 ; }

# Don't allow duplicate harness loading
if [ ! -z "${__TEST_HARNESS_CANARY}" ]; then
    echo "Test harness is already loaded. Not reloading."
    return
fi
__TEST_HARNESS_CANARY=true

# Set DEBUG to on if not already set
DEBUG=${DEBUG:-1}

# Load the helpers.sh file
source "$(dirname $0)/../helpers.sh" || { echo "ERROR: helpers.sh not found!" ;exit 1 ; }
# Enforce being in the tests directory
[[ "$(dirname $0)" == "." ]] || { echo "ERROR: Please run this script directly from the tests/ directory." ; exit 1 ; }

### Set up the testing environment
### We'll override some helper functions to simplify output
# cache_function_as original_function cached_function
# Allows caching (copying) of a specified function in a new NICKNAME
function cache_function_as () {
  test -n "$(declare -f $1)" || return
  eval "${_/$1/$2}"
}

# Cache the output functions
cache_function_as debug _debug
cache_function_as note _note
cache_function_as warn _warn
cache_function_as error _error

# Define replacement functions for the test harness
_INDENT="        "
function debug () {
    if [[ ${DEBUG} > 0 ]]; then
        echo -n "${_INDENT}"
    fi
    _debug "$@"
}

function note () {
    echo -n "${_INDENT}"
    _note "$@"
}

function warn () {
    echo -n "${_INDENT}"
    _warn "$@"
}

function error () {
    echo -n "${_INDENT}"
    _error "$@"
}

function _test_notice () {
    output "${_TXT_NOTE}""$@""${_TXT_RESET}"
}

### Test session utilities and settings
_LABEL_TEST="TEST  :"
_LABEL_PASS="passed:"
_LABEL_FAIL="failed:"

function _reset_test_count () {
    _TEST_COUNT=0
}

function _increment_test_count () {
    _TEST_COUNT=$((${_TEST_COUNT}+1))
}

function test_session_begin () {
    _test_notice "==> TEST BEGIN:" "$@"
    _reset_test_count
}

function test_session_end () {
    _test_notice "=== TEST" "COMPLETED"
    _test_notice "    with ${_TEST_COUNT} tests."
    _test_notice "<== Done."
}

### Master wrapper function for individual testing
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

    _note --label="${_LABEL_TEST}" "${TEST_LABEL} using ${TEST_FUNCTION}"
    _increment_test_count
    if [ ! -z "${PRESERVE_OUTPUT}" ]; then
        OUTPUT_OPTION=" >/dev/null 2>&1"
    fi
    if [ -z "${_INVERT}" ]; then
        ${TEST_FUNCTION}${OUTPUT_OPTION} && _note --label="${_LABEL_PASS}" "${TEST_LABEL}" || _error --noexit --label="${_LABEL_FAIL}" "${TEST_LABEL}"
    else
        ${TEST_FUNCTION}${OUTPUT_OPTION} && _error --noexit --label="${_LABEL_FAIL}" "${TEST_LABEL}" || _note --label="${_LABEL_PASS}" "${TEST_LABEL}"
    fi
}
