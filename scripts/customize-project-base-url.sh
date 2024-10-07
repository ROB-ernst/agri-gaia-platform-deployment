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

sed -i "s/PROJECT_BASE_URL=.*/PROJECT_BASE_URL=${AG_PROJECT_BASE_URL}/g" .env
sed -i "s|KEYCLOAK_FRONTEND_URL=.*|KEYCLOAK_FRONTEND_URL=https://keycloak.${AG_PROJECT_BASE_URL}|g" .env

cd "${AG_SOURCE_DIR}/platform/services/frontend" || exit 2

grep -rl "agri-gaia.localhost" src/ | xargs sed -i "s/agri-gaia.localhost/${AG_PROJECT_BASE_URL}/g"
sed -i "s/agri-gaia.localhost/${AG_PROJECT_BASE_URL}/g" public/keycloak.json
