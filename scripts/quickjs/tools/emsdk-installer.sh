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

FORCE_FLAGS=""

EMSDK_ROOT=$(pwd)/emsdk
EMSDK_VERSION=2.0.34
function usage() {
  cat << EOF
  Usage: $0 [options]
  Options:
      --root            emsdk Root Directory
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
        --root)
          shift
          EMSDK_ROOT=$1
          ;;
        -f|--force)
          FORCE_FLAGS=-f
          ;;
        *)
         EMSDK_ROOT=$1
      esac
      shift
  done
}

echo $0 $@
options_parse $@

if [ -d "${EMSDK_ROOT}" ];then
  if [ x"${FORCE_FLAGS}" = x"-f" ];then
    rm -rf ${EMSDK_ROOT}
  else
    echo "${EMSDK_ROOT} already exists, skip install"
    exit 0
  fi
fi
# install wasi-sdk
command -v emcc >/dev/null 2>&1 && {
  echo "emcc already exists, skip install"
  exit 0
}

echo "install emscripten"
git clone https://github.com/emscripten-core/emsdk.git ${EMSDK_ROOT}
cd  ${EMSDK_ROOT}
./emsdk install ${EMSDK_VERSION}
./emsdk activate ${EMSDK_VERSION}
#  source ${EMSDK_ROOT}/emsdk_env.sh
