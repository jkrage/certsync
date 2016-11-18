#!/usr/bin/env bash
###
### utilities.sh -- Convenience functions and setup
###
### Included by other scripts, such as through:
### source "$(dirname $0)/utilities.sh" || { echo "ERROR: utilities.sh not found!" ;exit 1 ; }

#
# Internal Variables
#
# DEBUG of 0 to disable debug messages, 1 to enable
DEBUG=${DEBUG:-0}

# Find a useful tput
CMD_TPUT=$(which tput)
if [ -x "${CMD_TPUT}" ]; then
	_TXT_RESET="$(${CMD_TPUT} sgr0)"
	_TXT_BOLD="$(${CMD_TPUT} bold)"
	_TXT_ERROR="${_TXT_BOLD}$(${_CMD_TPUT} setaf 1)" # Bold/Red
	_TXT_WARN="${_TXT_BOLD}$(${_CMD_TPUT} setaf 3)" # Bold/Yellow
	_TXT_NOTE="${_TXT_BOLD}$(${_CMD_TPUT} setaf 2)" # Bold/Green
	_TXT_DEBUG="${_TXT_BOLD}$(${_CMD_TPUT} setaf 4)" # Bold/Cyan
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
	local LABEL="NOTE:"
	local arg
	for arg in "$@"; do
		case ${arg} in
			'--label='* )
				LABEL=${arg#--*=}
				shift
				;;
		esac
	done
	output "${_TXT_NOTE}${LABEL}${_TXT_RESET} ""$@"
}

# error [--noexit] [-exitvalue=N] [--] string ...
# By default, exits script with error code 1
# --noexit skips the exit call
# --exitvalue=N uses integer N as exit value
# -- as an argument skips further arguments, needed if a non-argument string starts with --
function error () {
	# Preserve the prior command's return value
	local _return_value=$?
	local _return_command="exit"
	local LABEL="ERROR:"
	local arg
	for arg in "$@"; do
		case ${arg} in
			'--' )
				shift
				break
				;;
			'--noexit' )
				_return_command="return"
				shift
				continue
				;;
			'--exitvalue='* )
				_return_value=${arg#--*=}
				shift
				continue
				;;
			'--label='* )
				LABEL=${arg#--*=}
				shift
				continue
				;;
		esac
	done
	output "${_TXT_ERROR}${LABEL}${_TXT_RESET} ""$@"
	${_return_command} ${_return_value}
}

function warn () {
	local LABEL="WARN:"
	local arg
	for arg in "$@"; do
		case ${arg} in
			'--label='* )
				LABEL=${arg#--*=}
				shift
				continue
				;;
		esac
	done
	output "${_TXT_WARN}${LABEL}${_TXT_RESET} ""$*"
}

function debug () {
	local LABEL="DEBUG:"
	local arg
	for arg in "$@"; do
		case ${arg} in
			'--label='* )
				LABEL=${arg#--*=}
				shift
				continue
				;;
		esac
	done
	if [[ ${DEBUG} > 0 ]]; then
		output "${_TXT_DEBUG}${LABEL}${_TXT_RESET} ""$@"
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

# include [--nowarn] string ...
# --nowarn does not emit a user-visible warning on failure
# -- as an argument skips further arguments, needed if a non-argument string starts with --
function include () {
	local NOWARN=""
	local arg
	for arg in "$@"; do
		case ${arg} in
			'--' )
				shift
				break
				;;
			'--nowarn' )
				NOWARN=true
				shift
				continue
				;;
		esac
	done
	### source the provided script into the current environment
	### after error-checking, and provide debug tracking.
	if [ -f "$1" ]; then
		debug "Sourcing ${2:-content} from $1"
		source "$1"
	else
		if [ -z "${NOWARN}" ]; then
			warn "Include file $1 was skipped (not a file)"
		fi
		return -1
	fi
}

# Cache uname output for potential use
UNAME_S=$(/usr/bin/env uname -s)

# Cache our origin directory
export _DIR_ORIGIN=$(get_absolute_path ${BASH_SOURCE})
