#!/usr/bin/env bash

PLATFORM="unknown"

function brew-tools(){
    brew install go dep
    go-tools
}

function apk-tools(){
    apk add --no-cache curl
    apt-tools
}

function apt-tools(){
    curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
    go-tools
}

function go-tools() {
    go get -u golang.org/x/tools/cmd/goimports
    go get -u golang.org/x/lint/golint
    go get -u google.golang.org/grpc
    go get -u github.com/golang/protobuf/protoc-gen-go
    go get -u github.com/mattn/goveralls
    echo "Go tools installed"
}

function set_platform(){
    uname=`uname`
    if [ "${uname}" == "Linux" ]; then
        set_platform_linux
    elif [ "${uname}" == "Darwin" ]; then
        PLATFORM="brew"
    fi
}

function set_platform_linux(){
    if [ -f /etc/debian_version ]; then
        PLATFORM="apt"
    elif [ -f /etc/alpine-release ]; then
        PLATFORM="apk"
    else
        echo "Unsupported platform"
        exit 1
    fi
}

set_platform

PLATFORM_TOOLS="${PLATFORM}-tools"
$PLATFORM_TOOLS
