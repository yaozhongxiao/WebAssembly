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
CUR_DIR=$(pwd)

EMSDK_DOWNLOAD_DIR=${SCRIPT_DIR}/emsdk

BUILD_TYPE=Release
FORCE_FLAGS=""
function usage() {
  cat << EOF
  Usage: $0 [options]
  Options:
      --build-type      build-type[ Debug, Release ]
      -f|--force        force flags
      -h|--help         Print This Message
EOF
  exit 0;
}

function options_parse() {
  while test $# -gt 0; do
      case "$1" in
        -h|--help)
          usage
          ;;
        --build-type)
          shift
          BUILD_TYPE=$1
          ;;
        -f|--force)
          FORCE_FLAGS=-f
          ;;
        *)
         usage
      esac
      shift
  done
}

echo $0 $@
options_parse $@

# install emscripten if necessary
${SCRIPT_DIR}/emsdk-installer.sh ${EMSDK_DOWNLOAD_DIR} ${FORCE_FLAGS}
command -v emcc >/dev/null 2>&1 || {
  source ${EMSDK_DOWNLOAD_DIR}/emsdk_env.sh
}
echo $(which emcc)

# build target
build_emcc="${CUR_DIR}/build_emcc"
if [ -d ${build_emcc} ]; then
  rm -rf ${build_emcc}
fi
if [ ! -d ${build_emcc} ]; then
  mkdir -p ${build_emcc} && cd ${build_emcc}
  emcmake cmake \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DENABLE_BIGNUM=0 \
    -G "Unix Makefiles" \
    ${QUICKJS_ROOT}/wasm
  emmake make -j
  command -v wasm2wat >/dev/null 2>&1 && {
    if [ -f ${build_emcc}/quick.wasm ]; then
      wasm2wat ${build_emcc}/quick.wasm -o ${build_emcc}/quickjs.wat
    fi
    if [ -f ${build_emcc}/quick_main.wasm ]; then
      wasm2wat ${build_emcc}/quick_main.wasm -o ${build_emcc}/quick_main.wat
    fi
  }
fi

INSTALL_DIR=${CUR_DIR}/release
if [ -d ${INSTALL_DIR} ];then
  rm -rf ${INSTALL_DIR}
fi
mkdir -p ${INSTALL_DIR}/lib
# install libs
cp ${build_emcc}/libquick.a ${INSTALL_DIR}/lib/libquick.a

# install headers
cp -rf ${QUICKJS_ROOT}/include ${INSTALL_DIR}/
rm -rf ${INSTALL_DIR}/include/quickjs
rm -rf ${INSTALL_DIR}/include/debugger_struct.h
rm -rf ${INSTALL_DIR}/include/malloc_debug_check.h

# clean build
if [ x"${FORCE_FLAGS}" = x"-f" ];then
  [ -d "${build_emcc}" ] && {
    rm -rf ${build_emcc}
  }

  [ -d "${EMSDK_DOWNLOAD_DIR}" ] && {
    rm -rf ${EMSDK_DOWNLOAD_DIR}
  }
fi
