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
