#!/usr/bin/env bash
###
### openssl.sh -- Convenience functions and setup for openssl
###
### Target capabilities:
###   Convert PEM to DER formats
###       openssl x509 -inform PEM -in STAGING_FILE.pem -OUTFORM PEM -OUT STAGING_FILE.cer
###   Extract certificate serial, issuer, subject, email
###       openssl x509 -inform DER -serial -issuer -subject -email -noout -in STAGING_FILE.cer
###   Generate a canonical file name for the certificate

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

# If runtime is checked, we presume running in a specific environment
#_openssl_check_runtime

function run_openssl () {
    echo $(${CMD_OPENSSL} version)
}

function openssl_pem_to_der () {
    # Process function arguments
    for arg in "$@"; do
        case ${arg} in
            '--type='* )
                _CERT_TYPE=${arg#--*=}
                shift
                ;;
        esac
    done
    debug "Convert a certificate from PEM to DER formats."
}

function openssl_get_certinfo () {
    CERT_TYPE="DER"
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
                ISSUER=${line#issuer=}
                continue
                ;;
            'notAfter='* )
                NOTAFTER=${line#notAfter=}
                continue
                ;;
            'notBefore='* )
                NOTBEFORE=${line#notBefore=}
                continue
                ;;
            'serial='* )
                SERIAL=${line#serial=}
                continue
                ;;
            'subject='* )
                SUBJECT=${line#subject=}
                continue
                ;;
            *' Fingerprint'* )
                FINGERPRINT_TYPE=${line%% Fingerprint=*}
                FINGERPRINT_TEXT=${line#* Fingerprint=}
                continue
                ;;
            *'@'* )
                EMAIL=${line}
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
    echo SERIAL=${SERIAL}
    echo ISSUER=${ISSUER}
    echo SUBJECT=${SUBJECT}
    echo EMAIL=${EMAIL}
    echo NOTBEFORE=${NOTBEFORE}
    echo NOTAFTER=${NOTAFTER}
    echo FINGERPRINT_TYPE=${FINGERPRINT_TYPE}
    echo FINGERPRINT_TEXT=${FINGERPRINT_TEXT}
}

#->TMP
source "$(dirname $0)/helpers.sh" || { echo "ERROR: helpers.sh not found!" ;exit 1 ; }
CMD_OPENSSL="/usr/bin/openssl"
#<-TMP
run_openssl
openssl_pem_to_der
openssl_get_certinfo "test_certificate.cer"
#TODO: Get results of get_certinfo stashed
