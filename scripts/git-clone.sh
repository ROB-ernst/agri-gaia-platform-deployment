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

cd "${AG_SOURCE_DIR}" || exit 1

# If platform directory exists
if [[ -d platform ]]; then
    # Always backup certs
    mv platform/secrects/certs .

    # Remove platform git directory
    rm -rf platform
fi

if [[ "${AG_GIT_PUBLIC_REPOSITORIES}" == false ]]; then
    git_clone_url="git@platform.${AG_GIT_BASE_URL}:${AG_GIT_ORGANIZATION}/${AG_GIT_REPOSITORY_PLATFORM}.git"
else
    git_clone_url="https://${AG_GIT_BASE_URL}/${AG_GIT_ORGANIZATION}/${AG_GIT_REPOSITORY_PLATFORM}.git"
fi

git_clone_exit_code=0
git clone "${git_clone_url}" platform
git_clone_exit_code=$?

# Check if 'git clone' succeeded
[[ "${git_clone_exit_code}" -ne 0 ]] && { echo "Git clone returned nonzero exit code."; exit 3; }

cd platform || exit 4

git fetch --all
git checkout "${AG_GIT_BRANCH_PLATFORM}" || exit 5
git submodule init

if [[ "${AG_GIT_PUBLIC_REPOSITORIES}" == false ]]; then
    # Change submodule urls to match the "Host" aliases in ~/.ssh/config
    git_org_url="${AG_GIT_BASE_URL}:${AG_GIT_ORGANIZATION}"
    backend_submodule_base="git@backend.${git_org_url}"
    frontend_submodule_base="git@frontend.${git_org_url}"
else
    # Update submodule urls to use https instead of git@ssh
    git_org_url="${AG_GIT_BASE_URL}/${AG_GIT_ORGANIZATION}"
    backend_submodule_base="https://${git_org_url}"
    frontend_submodule_base="${backend_submodule_base}"
fi

git config submodule.services/backend.url "${backend_submodule_base}/${AG_GIT_REPOSITORY_BACKEND}.git"
git config submodule.services/frontend.url "${frontend_submodule_base}/${AG_GIT_REPOSITORY_FRONTEND}.git"

git submodule update

# If certs backup exists, always restore it
if [[ -d ../certs ]]; then
    rm -rf secrects/certs && \
        mv ../certs secrects
fi

# Merge contents of deployment secrets into platform/secrets
rsync -avhP --checksum ../secrets/ ./secrects/

cd services/frontend || exit 6
git submodule update --init
git checkout "${AG_GIT_BRANCH_FRONTEND}" || exit 7

cd ../backend || exit 8
git submodule update --init
git checkout "${AG_GIT_BRANCH_BACKEND}" || exit 9
