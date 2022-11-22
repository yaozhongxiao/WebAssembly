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
QUICKJS_ROOT="${SCRIPT_DIR}/../.."
WASI_SDK_URL=git@github.com:WebAssembly/wasi-sdk.git

CHDIR=$(pwd)
if [[ "$OSTYPE" =~ "darwin" ]]; then
  # on mac os
  OS="macos"
elif [[ "$OSTYPE" =~ ^linux ]]; then
  # on linux
  OS="linux"
else
  echo "unsupported os"
  exit 1
fi
echo "OS: ${OS}"

# install wasi-sdk
WASI_SDK_ROOT=${QUICKJS_ROOT}/wasm/wasi-sdk
if [ -d "${WASI_SDK_ROOT}" ]; then
  echo "found ${WASI_SDK_ROOT}, skip download"
else
  git clone -b wasi-sdk-14-${OS} ${WASI_SDK_URL} ${WASI_SDK_ROOT}
fi
if [ ! -d "${WASI_SDK_ROOT}" ]; then
  echo "failed to download wasi-sdk"
  exit 1
fi

# build target
build_wasi="${CHDIR}/build_wasi"
if [ -d ${build_wasi} ]; then
  rm -rf ${build_wasi}
fi
if [ ! -d ${build_wasi} ]; then
  mkdir -p ${build_wasi} && cd ${build_wasi}
  cmake \
    -DCMAKE_TOOLCHAIN_FILE=${QUICKJS_ROOT}/wasm/wasi-sdk.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_BIGNUM=1 \
    -G "Unix Makefiles" \
    ${QUICKJS_ROOT}/wasm
  make quick -j
  command -v wasm2wat >/dev/null 2>&1 && {
    if [ -f ${build_wasi}/quick.wasm ]; then
      wasm2wat ${build_wasi}/quick.wasm -o ${build_wasi}/quick.wat
    fi
  }
fi

INSTALL_DIR=${CHDIR}/release
if [ -d ${INSTALL_DIR} ];then
  rm -rf ${INSTALL_DIR}
fi
mkdir -p ${INSTALL_DIR}/lib
# install libs
cp ${build_wasi}/libquick.a ${INSTALL_DIR}/lib/libquick.a

# install headers
cp -rf ${QUICKJS_ROOT}/include ${INSTALL_DIR}/
rm -rf ${INSTALL_DIR}/include/quickjs
rm -rf ${INSTALL_DIR}/include/debugger_struct.h
rm -rf ${INSTALL_DIR}/include/malloc_debug_check.h

# clean build
rm -rf ${build_wasi}
rm -rf ${WASI_SDK_ROOT}
