#!/usr/bin/env bash

function isRepoCreated(){
    [ -d .git ] && git status >/dev/null
}

function downloadSourceFromRepo(){
    if [[ ${1} == "" ]]; then
        >&2 echo "Error: Branch didn't set. Arg required."
        return 1
    fi

    local BRANCH_OR_TAG_NAME="${1}"

    [ ! -d ~/.ssh ] && mkdir -p ~/.ssh

    if ! isRepoCreated ; then
        git clone -b ${BRANCH_OR_TAG_NAME} ${GIT_REPO_URL_LINK} . && \
        git config user.name nginx && \
        git config user.email nginx@tonicforhealth.com
        GIT_RESULT="$?"
    else
        git gc --prune=now && git reset && git fetch --all && git checkout --force ${BRANCH_OR_TAG_NAME} && git pull -f
        GIT_RESULT="$?"
    fi
    return ${GIT_RESULT}
}

function downloadVendor(){
    composer install -n
}

function prepareResourceAndData(){
    if ! bin/console doctrine:schema:validate ;then
        bin/console doctrine:schema:update --force
    fi
}

case "$1" in
    download)
        downloadSourceFromRepo "${2-master}" && \
        downloadVendor
        ;;
    init)
        prepareResourceAndData
        ;;
	*)
		cat <<EOF
Commands:
    download [BRANCH_OR_TAG_NAME=master]
    init
EOF
	    ;;
esac

