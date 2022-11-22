#!/usr/bin/env bash
#
# Copyright 2022 Develop Group Participants. All right reserver.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
JSWORKER_ROOT=${SCRIPT_DIR}

uname -a
if [[ "$OSTYPE" =~ "darwin" ]]; then
    # on mac os
    OS="macos"
elif [[ "$OSTYPE" =~ ^linux ]];then
    # on linux
    OS="linux"
else
    echo "unsupported os"
    exit 1
fi

echo "1. try to install wget !"
command -v wget >/dev/null 2>&1 || {
  echo "install wget ...!"
  exit -1
}

echo "2. try to install rust !"
command -v cargo >/dev/null 2>&1 || {
  echo "install rust ... !"
  curl https://sh.rustup.rs -sSf | sh
}

echo "3. try to install rust wasm32-wasi toolchains ..."
command -v cbindgen >/dev/null 2>&1 || {
    echo "install rust wasm32-wasi toolchains ... !"
    rustup default stable
    rustup target add wasm32-wasi
    cargo install --force cbindgen
}

echo "4. try to install wasi-sdk ..."
if [ -d "/opt/wasi-sdk" ]; then
    echo "wasi-sdk exist, skip install"
else
    echo "install wasi-sdk ..."
    wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-14/wasi-sdk-14.0-${OS}.tar.gz -O wasi-sdk.tar.gz
    tar -xzf wasi-sdk.tar.gz
    mv wasi-sdk-14.0 /opt/wasi-sdk
    rm wasi-sdk.tar.gz
fi

echo "5. try to install wasm-opt ..."
if [ -d "/opt/binaryen" ]; then
    echo "wasm-opt exist, skip install"
else
    echo "install wasm-opt ..."
    wget https://github.com/WebAssembly/binaryen/releases/download/version_108/binaryen-version_108-x86_64-${OS}.tar.gz -O binaryen.tar.gz
    tar -xzf binaryen.tar.gz
    mv binaryen-version_108 /opt/binaryen
    rm binaryen.tar.gz
fi

echo "6. try to install wasmtime !"
command -v wasmtime >/dev/null 2>&1 || {
  echo "install wasmtime ... !"
  curl https://wasmtime.dev/install.sh -sSf | bash
}