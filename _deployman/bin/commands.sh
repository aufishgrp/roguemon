#!/usr/bin/env bash

# Script that prints out a Major.Minor.Patch version
# based on the VERSION file and the commit history

DEPLOYMAN_COMMIT_TAG=${DEPLOYMAN_COMMIT_TAG:-`cat _deployman/etc/commit-tag`}

function set_major_version() {
    if [ -f "VERSION" ]; then
        MAJOR_VERSION=`cat VERSION`;
    else
        MAJOR_VERSION="0";
    fi
}

function set_minor_version(){
    TEST_MINOR_EXISTS="`git rev-list ${MAJOR_VERSION}.0.0 2>/dev/null`"
    if [ "${TEST_MINOR_EXISTS}" ]; then
        MINOR_VERSION="`git rev-list --merges --count ${MAJOR_VERSION}.0.0..`";
    else
        MINOR_VERSION=0;
    fi
}

function set_patch_version(){
    TEST_MINOR_EXISTS="`git rev-list ${MAJOR_VERSION}.${MINOR_VERSION}.0 2>/dev/null`"
    if [ "${TEST_MINOR_EXISTS}" ]; then
        PATCH_VERSION=`git log --pretty=oneline --abbrev-commit -i --invert-grep --grep="${DEPLOYMAN_COMMIT_TAG}" ${MAJOR_VERSION}.${MINOR_VERSION}.0.. | wc -l | xargs`;
    else
        PATCH_VERSION=0;
    fi
}

function app-version(){
    GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`;
    ## Travis checkouts code in a detached mode.
    ## Can't rely on git to get the branch in that case.
    if [ "${TRAVIS}" == "true" ]; then
        GIT_BRANCH=${TRAVIS_BRANCH};
    fi

    VERSION_FORMAT="MMP"

    if [ "${1}" == "" ]; then
        VERSION_FORMAT="MMP"
    elif [ "${1}" == "3" ]; then
        VERSION_FORMAT="MMP"
    elif [ "${1}" == "2" ]; then
        VERSION_FORMAT="MM"
    else
        echo "Usage: app-version [2|3]"
        exit 1
    fi

    if [ "${GIT_BRANCH}" == "master" ]; then
        set_major_version;
        set_minor_version;

        if [ "${VERSION_FORMAT}" == "MM" ]; then
            echo "${MAJOR_VERSION}.${MINOR_VERSION}";
        else
            set_patch_version;
            echo "${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}";
        fi
    else
        echo "${GIT_BRANCH}";
    fi
}

function get_platform(){
    uname=`uname`
    if [ "${uname}" == "Linux" ]; then
        get_platform_linux
    elif [ "${uname}" == "Darwin" ]; then
        echo "brew"
    fi
}

function get_platform_linux(){
    if [ -f /etc/debian_version ]; then
        echo "apt"
    elif [ -f /etc/alpine-release ]; then
        echo "apk"
    else
        echo "Unsupported platform"
        exit 1
    fi
}

function platform(){
    get_platform
}

COMMAND=undefined
if [ "${1}" == "app-version" ]; then
    COMMAND=${1}
elif [ "${1}" == "platform" ]; then
    COMMAND=${1}
fi

if [ "${COMMAND}" == "" ]; then
    echo "${COMMAND} is not a valid command."
    exit 1
fi

shift
${COMMAND} $@
