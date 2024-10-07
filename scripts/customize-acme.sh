#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 University of Applied Sciences Osnabrück
# SPDX-FileContributor: Andreas Schliebitz
# SPDX-FileContributor: Henri Graf
# SPDX-FileContributor: Jonas Tüpker
# SPDX-FileContributor: Lukas Hesse
# SPDX-FileContributor: Maik Fruhner
# SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
# SPDX-FileContributor: Tobias Wamhof
#
# SPDX-License-Identifier: AGPL-3.0-or-later

echo "$(date +"%Y-%m-%d %H:%M:%S.%6N") - ${0}"

cd "${AG_SOURCE_DIR}/platform" || exit 1

sed -i "s/ACME_EMAIL=.*/ACME_EMAIL=${AG_ACME_EMAIL}/g" .env

if [[ "${AG_SSL_MODE}" == "lets-encrypt-dns" ]]; then
  sed -i "s/ACME_DNS_CHALLENGE_PROVIDER=.*/ACME_DNS_CHALLENGE_PROVIDER=${AG_ACME_DNS_CHALLENGE_PROVIDER}/g" .env
  sed -i "s/DUCKDNS_TOKEN=.*/DUCKDNS_TOKEN=${AG_LETSENCRYPT_TOKEN}/g" .env
elif [[ "${AG_SSL_MODE}" == "lets-encrypt-http" ]]; then
  echo "ACME for SSL mode '${AG_SSL_MODE}' already customized by setting ACME_EMAIL=${AG_ACME_EMAIL}."
elif [[ "${AG_SSL_MODE}" == "http-acme-eab" ]]; then
  sed -i "s|ACME_CASERVER=.*|ACME_CASERVER=${AG_ACME_CASERVER}|g" .env
  sed -i "s/ACME_EAB_KID=.*/ACME_EAB_KID=${AG_ACME_EAB_KID}/g" .env
  sed -i "s/ACME_EAB_HMACENCODED=.*/ACME_EAB_HMACENCODED=${AG_ACME_EAB_HMACENCODED}/g" .env
fi

# Rename dummy certs to match AG_PROJECT_BASE_URL
# Will be replaced by certs from acme.json

acme_certs_path="${AG_SOURCE_DIR}/platform/config/traefik/certs/acme"

cd "${acme_certs_path}/wildcard" || exit 2
mv ./*.crt "${AG_PROJECT_BASE_URL}.crt"
mv ./*.key "${AG_PROJECT_BASE_URL}.key"

cd "${acme_certs_path}/domains" || exit 3
find . -type f -name "registry.*.crt" -exec mv '{}' "registry.${AG_PROJECT_BASE_URL}.crt" \;
find . -type f -name "registry.*.key" -exec mv '{}' "registry.${AG_PROJECT_BASE_URL}.key" \;