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

function _test_reset_counts () {
    _TEST_COUNT_TRIED=0
    _TEST_COUNT_SUCCESS=0
    _TEST_COUNT_FAILURE=0
}

function _test_count_increment_tried () {
    _TEST_COUNT_TRIED=$((${_TEST_COUNT_TRIED}+1))
}

function test_session_begin () {
    _test_notice "==> TEST BEGIN:" "$@"
    _test_reset_counts
}

function test_session_end () {
    _test_notice "=== TEST" "COMPLETED"
    output "    Count of tests tried: ${_TEST_COUNT_TRIED}"
    output "       \--> ${_TXT_NOTE}tests passed: ${_TEST_COUNT_SUCCESS}${_TXT_RESET}"
    output "       \--> ${_TXT_ERROR}tests failed: ${_TEST_COUNT_FAILURE}${_TXT_RESET}"
    _test_notice "<== Done."
}

### Per-test functions
function _test_report_success () {
    _TEST_COUNT_SUCCESS=$((${_TEST_COUNT_SUCCESS}+1))
    _note --label="${_LABEL_PASS}" "$@"
}

function _test_report_failure () {
    _TEST_COUNT_FAILURE=$((${_TEST_COUNT_FAILURE}+1))
    _error --noexit --label="${_LABEL_FAIL}" "$@"
}

# Master wrapper function for individual testing
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
    _test_count_increment_tried
    if [ ! -z "${PRESERVE_OUTPUT}" ]; then
        OUTPUT_OPTION=" >/dev/null 2>&1"
    fi

    # Run the test, then report the results
    ${TEST_FUNCTION}${OUTPUT_OPTION}
    local _result=$?

    # Test the results of the command
    # If _INVERT is set, invert the resulting pass/fail report
    if [[ (( ${_result} -eq 0 )) && ((-z "${_INVERT}")) ]]; then
        # report normal success: zero-value return, normal (non-inverted) result
        _test_report_success "${TEST_LABEL}"
    elif [[ (( ${_result} -ne 0 )) && ((! -z "${_INVERT}")) ]]; then
        # report inverted success: non-zero return, inverted result
        _test_report_success "${TEST_LABEL}"
    else
        # report failure: non-zero return value, normal (non-inverted) result
        _test_report_failure "${TEST_LABEL}"
    fi
}
