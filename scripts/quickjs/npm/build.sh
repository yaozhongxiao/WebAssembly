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
set -ex

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
QUICKJS_NPM_ROOT=${SCRIPT_DIR}
QUICKJS_ROOT=${QUICKJS_NPM_ROOT}/../..

BUILD_DIR=${QUICKJS_NPM_ROOT}/build
EMSDK_DOWNLOAD_DIR=${BUILD_DIR}/emsdk

OUTPUT_TYPE=js
FORCE_FLAGS=""
BUILD_TYPE=Release
function usage() {
  cat << EOF
  Usage: $0 [options]
  Options:
      -d|--debug        in debug mode
      -f|--force        force flags
      --js              output js
      --html            output html
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
        -d|--debug)
          BUILD_TYPE=Debug
          ;;
        -f|--force)
          FORCE_FLAGS=-f
          ;;
        --js)
          OUTPUT_TYPE=js
          ;;
        --html)
          OUTPUT_TYPE=html
          ;;
        *)
         usage
         ;;
      esac
      shift
  done
}

echo $0 $@
options_parse $@

if [ -d "${BUILD_DIR}" ] && [ x"${FORCE_FLAGS}" != x"-f" ];then 
  echo "${BUILD_DIR} already exists, skip building!"
  exit 0;
fi
mkdir -p ${BUILD_DIR}

# install emscripten if necessary
${QUICKJS_ROOT}/wasm/tools/emsdk-installer.sh ${EMSDK_DOWNLOAD_DIR}
command -v emcc >/dev/null 2>&1 || {
  source ${EMSDK_DOWNLOAD_DIR}/emsdk_env.sh
}
export PATH=${EMSDK}/upstream/bin:${PATH}
echo $(which emcc)
echo $(which emcmake)
echo $(which emmake)
echo $(which wasm-opt)

cd ${BUILD_DIR}

# emcmake configure
emcmake cmake VERBOSE=1 \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DENABLE_BIGNUM=0 \
  -DOUTPUT_TYPE=${OUTPUT_TYPE} \
  -G "Unix Makefiles" \
  ${QUICKJS_NPM_ROOT}

# emcmake build
emmake make -j quickjs-wasm

command -v wasm2wat >/dev/null 2>&1 && {
  if [ -f ${BUILD_DIR}/quickjs-wasm.wasm ]; then
    wasm2wat ${BUILD_DIR}/quickjs-wasm.wasm -o ${BUILD_DIR}/quickjs-wasm.wat
  fi
}

echo "install the wasm + js glue"
# -s SINGLE_FILE=1 do not generate wasm
if [ -f ${BUILD_DIR}/quickjs-wasm.wasm ];then
  cp -rf ${BUILD_DIR}/quickjs-wasm.wasm ${QUICKJS_NPM_ROOT}/lib
  if [ x"${BUILD_TYPE}" = x"Release" ];then
    command -v wasm-opt >/dev/null 2>&1 && {
      echo "wasm-opt -Os ${BUILD_DIR}/quickjs-wasm.wasm -o ${BUILD_DIR}/quickjs-wasm.wasm"
      wasm-opt -Os ${BUILD_DIR}/quickjs-wasm.wasm -o ${BUILD_DIR}/quickjs-wasm.wasm
    }
  fi
fi
cp -rf ${BUILD_DIR}/quickjs-wasm.js ${QUICKJS_NPM_ROOT}/lib
