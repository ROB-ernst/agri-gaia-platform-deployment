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

cd "${AG_SOURCE_DIR}/platform/secrects/certs/issued" || exit 1

# Rename any *.crt and *.key files to start with AG_PROJECT_BASE_URL
mv ./*.crt "${AG_PROJECT_BASE_URL}.crt"
mv ./*.key "${AG_PROJECT_BASE_URL}.key"

# Check if issued certificate and key with AG_PROJECT_BASE_URL as prefix exist.
test -z "$(find . -maxdepth 1 -name "${AG_PROJECT_BASE_URL}.crt" -print -quit)" && exit 2
test -z "$(find . -maxdepth 1 -name "${AG_PROJECT_BASE_URL}.key" -print -quit)" && exit 3