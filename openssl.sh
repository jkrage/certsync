#!/usr/bin/env bash
###
### openssl.sh -- Convenience functions and setup for openssl
###
### Target capabilities:
###   Convert PEM to DER formats
###       openssl x509 -inform PEM -in STAGING_FILE.pem -OUTFORM PEM -OUT STAGING_FILE.cer
###   Extract certificate serial, issuer, subject, email
###       openssl x509 -inform DER -serial -issuer -subject -email -noout -in STAGING_FILE.cer

function _openssl_check_runtime () {
    # Error checking, ensure our helper functions have been loaded
    if [ -z "$(type -t error)" ]; then
        echo "EEK. You are not running from a known environment. Aborting."
        exit 1
    fi

    # We need our openssl path
    if [ -z "${CMD_OPENSSL}" ]; then
        error "CMD_OPENSSL is not defined. Who are you?"
        exit 1
    fi
}

# If runtime is checked, we presume we are in a specific run-time environment
#_openssl_check_runtime

function run_openssl () {
    echo $(${CMD_OPENSSL} version)
}

function openssl_pem_to_der () {
    # Suffixes are generally pem, cer (for DER)
    local _SUFFIX=".cer"
    local _EXIT="error"
    local _EXIT_VALUE=1
    # Process function arguments
    for arg in "$@"; do
        case ${arg} in
            '--suffix='* )
                _SUFFIX=".${arg#--*=}"
                shift
                continue
                ;;
            '--warnonly' )
                _EXIT="warn"
                _EXIT_VALUE=0
                shift
                continue
                ;;
        esac
    done

    # Determine the input and output filenames, including suffixes
    FILE_INPUT=$1
    if [ ! -r "${FILE_INPUT}" ]; then
        ${_EXIT} "openssl_pem_to_der: File not readable: ${FILE_INPUT}"
        return ${_EXIT_VALUE}
    fi
    if [ -z "$2" ]; then
        # Use the original filename, with our preferred _SUFFIX
        FILE_OUTPUT=${1%\.*}${_SUFFIX}
    else
        FILE_OUTPUT=${2%\.*}${_SUFFIX}
    fi

    # Convert the input certificate to the requested output file and format
    debug "openssl_pem_to_der: Convert a certificate from PEM to DER formats (${_SUFFIX})."
    (${CMD_OPENSSL} x509 -inform PEM -outform DER -in "${FILE_INPUT}" -out "${FILE_OUTPUT}") || ${_EXIT} "Conversion failed, see above message."
}

function openssl_get_certinfo () {
    CERT_TYPE="DER"
    CERT_SERIAL=""
    CERT_ISSUER=""
    # Process function arguments
    for arg in "$@"; do
        case ${arg} in
            '--type='* )
                CERT_TYPE=${arg#--*=}
                shift
                ;;
        esac
    done
    CERT_FILE=$1
    shift
    if [ -z "${CERT_FILE}" -o ! -r "${CERT_FILE}" ]; then
        error "Invalid file provided to openssl_get_certinfo."
    fi
    debug "Extract certificate information (serial, issuer, subject, email)."
    while read line ;do
        case ${line} in
            'issuer='* )
                CERT_ISSUER=${line#issuer=}
                continue
                ;;
            'notAfter='* )
                CERT_NOTAFTER=${line#notAfter=}
                continue
                ;;
            'notBefore='* )
                CERT_NOTBEFORE=${line#notBefore=}
                continue
                ;;
            'serial='* )
                CERT_SERIAL=${line#serial=}
                continue
                ;;
            'subject='* )
                CERT_SUBJECT=${line#subject=}
                continue
                ;;
            *' Fingerprint'* )
                CERT_FINGERPRINT_TYPE=${line%% Fingerprint=*}
                CERT_FINGERPRINT_TEXT=${line#* Fingerprint=}
                continue
                ;;
            *'@'* )
                CERT_EMAIL=${line}
                continue
                ;;
            * )
                warn "Unknown output in openssl_get_certinfo: ${line}"
                continue
                ;;
        esac
    done < <(${CMD_OPENSSL} x509 \
             -inform ${CERT_TYPE} -noout \
             -serial -issuer -subject -dates -email -fingerprint \
             -in "${CERT_FILE}")

    echo CERT_FILE=${CERT_FILE}
    echo CERT_TYPE=${CERT_TYPE}
    echo CERT_SERIAL=${CERT_SERIAL}
    echo CERT_ISSUER=${CERT_ISSUER}
    echo CERT_SUBJECT=${CERT_SUBJECT}
    echo CERT_EMAIL=${CERT_EMAIL}
    echo CERT_NOTBEFORE=${CERT_NOTBEFORE}
    echo CERT_NOTAFTER=${CERT_NOTAFTER}
    echo CERT_FINGERPRINT_TYPE=${CERT_FINGERPRINT_TYPE}
    echo CERT_FINGERPRINT_TEXT=${CERT_FINGERPRINT_TEXT}
}

#->TMP
source "$(dirname $0)/helpers.sh" || { echo "ERROR: helpers.sh not found!" ;exit 1 ; }
CMD_OPENSSL="/usr/bin/openssl"
#<-TMP
run_openssl
openssl_get_certinfo "test_certificate.cer"
#TODO: Get results of get_certinfo stashed
openssl_pem_to_der --suffix=der "test_certificate.pem"
openssl_pem_to_der --warnonly --suffix=der "does-not-exist"
