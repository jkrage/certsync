#!/usr/bin/env bash
###
### helpers.sh -- Convenience functions and setup
###
#
# Internal Variables
#
# DEBUG of 0 to disable debug messages, 1 to enable
DEBUG=1

# Find a useful tput
CMD_TPUT=$(which tput)
if [ -x "${CMD_TPUT}" ]; then
	TXT_RESET="$(${CMD_TPUT} sgr0)"
	TXT_BOLD="$(${CMD_TPUT} bold)"
	TXT_ERROR="${TXT_BOLD}$(${CMD_TPUT} setaf 1)"
	TXT_WARN="${TXT_BOLD}$(${CMD_TPUT} setaf 3)"
	TXT_NOTE="${TXT_BOLD}$(${CMD_TPUT} setaf 2)"
	TXT_DEBUG="${TXT_BOLD}$(${CMD_TPUT} setaf 4)"
else
	TXT_RESET=""
	TXT_BOLD=""
	TXT_ERROR=""
	TXT_WARN=""
	TXT_NOTE=""
fi

#
# Internal Functions
#
function output () {
	echo $*
}

function note () {
	output "${TXT_NOTE}NOTE:${TXT_RESET} " $*
}

function error () {
	output "${TXT_ERROR}ERROR:${TXT_RESET} " $*
	exit 1
}

function warn () {
	output "${TXT_WARN}WARNING:${TXT_RESET} " $*
}

function debug () {
	if [[ ${DEBUG} ]]; then
		output "${TXT_DEBUG}DEBUG:${TXT_RESET} " $*
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
