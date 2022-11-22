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
QUICKJS_ROOT=${SCRIPT_DIR}/..

wasm_builder=wasi
FORCE_FLAGS=""
BUILD_TYPE=Release
function usage() {
  cat << EOF
  Usage: $0 [options]
  Options:
      -b|--builder      wasm builder options: [wasi, emcc]
      -d|--debug        in debug mode
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
        -b|--builder)
          shift
          wasm_builder=$1
          ;;
        -d|--debug)
          BUILD_TYPE=Debug
          ;;
        -f|--force)
          FORCE_FLAGS=-f
          ;;
        *)
         wasm_builder=$1
      esac
      shift
  done
}

echo $0 $@
options_parse $@

if [ x"wasi" = x"${wasm_builder}" ];then
  echo "${SCRIPT_DIR}/tools/wasi-builder.sh"
  ${SCRIPT_DIR}/tools/wasi-builder.sh
elif [ x"emcc" = x"${wasm_builder}" ];then
  ${SCRIPT_DIR}/tools/emcc-builder.sh --build-type ${BUILD_TYPE} ${FORCE_FLAGS}
else
  echo "can not find [${wasm_builder}] wasm builder!"
  exit -1
fi
