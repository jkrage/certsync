#!/usr/bin/env bash
###
### helpers.sh -- Convenience functions and setup
###
### Included by other scripts, such as through:
### source "$(dirname $0)/helpers.sh" || { echo "ERROR: helpers.sh not found!" ;exit 1 ; }

#
# Internal Variables
#
# DEBUG of 0 to disable debug messages, 1 to enable
DEBUG=1

# Find a useful tput
CMD_TPUT=$(which tput)
if [ -x "${CMD_TPUT}" ]; then
	_TXT_RESET="$(${CMD_TPUT} sgr0)"
	_TXT_BOLD="$(${CMD_TPUT} bold)"
	_TXT_ERROR="${_TXT_BOLD}$(${CMD_TPUT} setaf 1)"
	_TXT_WARN="${_TXT_BOLD}$(${CMD_TPUT} setaf 3)"
	_TXT_NOTE="${_TXT_BOLD}$(${CMD_TPUT} setaf 2)"
	_TXT_DEBUG="${_TXT_BOLD}$(${CMD_TPUT} setaf 4)"
else
	_TXT_RESET=""
	_TXT_BOLD=""
	_TXT_ERROR=""
	_TXT_WARN=""
	_TXT_NOTE=""
	_TXT_DEBUG=""
fi

#
# Internal Functions
#
function output () {
	echo "$@"
}

function note () {
	output "${_TXT_NOTE}NOTE:${_TXT_RESET} " "$@"
}

function error () {
	output "${_TXT_ERROR}ERROR:${_TXT_RESET} " "$@"
	exit 1
}

function warn () {
	output "${_TXT_WARN}WARNING:${_TXT_RESET} " "$*"
}

function debug () {
	if [[ ${DEBUG} ]]; then
		output "${_TXT_DEBUG}DEBUG:${_TXT_RESET} " "$@"
	fi
}

function get_absolute_path () {
	### Returns best-effort absolute path of $1
	### $1 = file/directory
	### Presumes $PWD has not changed since the original
	### value for $1 was established

	# Establish an initial directory, possibly a relative path
	local DIR
	if [ -f $1 ]; then
		DIR=$(dirname $1)
	else
		DIR=$1
	fi

	# Check first character:
	#   . indicates relative path from current directory, so trim
	#   / indicates absolute path, so do nothing
	#   anything else indicates relative path, so prepend $PWD
	local FIRSTCHAR=${DIR:0:1}
	if [ "${FIRSTCHAR}" == "." ]; then
		DIR="${PWD}${DIR:1}"
	elif [ "${FIRSTCHAR}" != "/" ]; then
		DIR="${PWD}/${DIR}"
	fi
	echo "${DIR}"
}

function include () {
	### source the provided script into the current environment
	### after error-checking, and provide debug tracking.
	if [ -f "$1" ]; then
		debug "Sourcing ${2:-content} from $1"
		source "$1"
	else
		# Any 3rd argument suppresses the warning
		if [ -z "$3" ]; then
			warn "Include file $1 was skipped (not a file)"
		fi
		return -1
	fi
}

# Cache uname output for potential use
UNAME_S=$(/usr/bin/env uname -s)

# Cache our origin directory
export _DIR_ORIGIN=$(get_absolute_path ${BASH_SOURCE})
