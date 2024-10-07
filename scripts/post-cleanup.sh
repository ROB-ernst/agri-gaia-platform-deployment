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

# Remove dangling images
docker image prune --force

# Remove dangling build cache
docker builder prune --force

# Remove stopped containers
[[ "${AG_REMOVE_STOPPED_CONTAINERS}" == true ]] \
  && docker container prune --force

# Remove source files by deleting cloned git repo
# but do not remove acme certificate
if [[ "${AG_REMOVE_SOURCE_FILES}" == true ]]; then
    cd "${AG_SOURCE_DIR}" || exit 1
    mv ./platform/acme . 2> /dev/null
    rm -rf ./platform/*
    rm -rf ./platform/.* 2>/dev/null
    mv ./acme ./platform 2> /dev/null
fi