#!/usr/bin/env bash
#
# PROBLEM STATEMENT:
# Keeping X509v3 certificates (e.g., for S/MIME) synchronized in
# multiple local keystores, as used across multiple applications.
# Each application has its own mechanism for discovering and storing
# certificates, and may not be consistently supported by a central
# directory.
# IMPLEMENTATION:
# Provide the ability to manually identify a list of certificate queries
# or certificate files and load those into the appropriate keystores.
# Pseudo-code:
# Identify output OSX_KEYCHAIN
# Identify output MOZILLA_PROFILE location
# Identify output
# For each REQUEST in each PROVIDED_FILE and RUNTIME_QUERY
#   - Validate REQUEST format
#   - Add REQUEST to QUERY_LIST
# For each QUERY in the QUERY_LIST:
#   - Run QUERY and retrieve a CERT
#   - Add the CERT to the CERT_LIST
# For each CERT in the CERT_LIST:
#   - Extract the CERT to a STAGING_FILE
#   - Extract a NICKNAME from the cert
#     openssl x509 -inform DER -subject -email -noout -in STAGING_FILE.cer
#   - Add the CERT to the MOZILLA_PROFILE with NICKNAME
#     /opt/local/bin/nss-certutil -A -d ${PWD} -t ",," -n "NICKNAME" -i STAGING_FILE.cer
#   - Add the CERT to the OSX_KEYCHAIN
#     security add-certificates -k KEYCHAIN STAGING_FILE.cer
#     certtool i STAGING_FILE k=KEYCHAIN_FILE
#   - Store CERT in FILE_NICKNAME using DEFAULT_FORMAT
# Report status

# Load setup helper variables and functions
source "$(dirname $0)/helpers.sh" || { echo "ERROR: helpers.sh not found!" ;exit 1 ; }
_CONFIG_FILE="${HOME}/.config/certsync.config"

function load_config () {
    include --nowarn "$1" "certsync configuration file" && _CONFIG_LOADED=true
    CMD_OPENSSL=${CMD_OPENSSL:-$(which openssl)}
    CMD_CERTTOOL=${CMD_CERTTOOL:-$(which certtool)}
    CMD_CERTUTIL=${CMD_CERTUTIL:-$(which certutil)}
}

function show_config () {
    local _header="Configuration"
    if [ -z "${_CONFIG_LOADED}" ]; then
        _header="${_header} (defaults):"
    else
        _header="${_header} (including config file ${_CONFIG_FILE}):"
    fi
    note "${_header}"
    debug "certsync script directory is ${_DIR_ORIGIN}."
    note "  CMD_OPENSSL  :: ${CMD_OPENSSL}"
    note "  CMD_CERTTOOL :: ${CMD_CERTTOOL}"
    note "  CMD_CERTUTIL :: ${CMD_CERTUTIL}"
}

function verify_config () {
    local _WARNINGS=0
    local _ERRORS=0
    if [ ! -x "${CMD_OPENSSL}" ]; then
        warn "The openssl command was not found, please set CMD_OPENSSL."
        _ERRORS=$((++_ERRORS))
    fi
    if [ ! -x "${CMD_CERTTOOL}" ]; then
        warn "The Apple/OSX certtool command was not found, please set CMD_CERTTOOL."
        _WARNINGS=$((++_WARNINGS))
    fi
    if [ ! -x "${CMD_CERTUTIL}" ]; then
        warn "The Mozilla/NSS certutil command was not found, please set CMD_CERTUTIL."
        _WARNINGS=$((++_WARNINGS))
    fi
    if [[ ${_WARNINGS} -gt 0 ]]; then
        warn "Please review the prior warnings before continuing."
    fi
    if [[ ${_ERRORS} -gt 0 ]]; then
        error "Critical commands were not found, aborting."
    fi
    debug "_ERRORS=${_ERRORS}"
}

load_config "${_CONFIG_FILE}"
show_config
verify_config
