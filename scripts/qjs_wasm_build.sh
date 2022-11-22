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
PROJECT_ROOT=${SCRIPT_DIR}

REPO_URL=""
REPO_BRANCH=develop
REPO_COMMITID=""
REPO_OUTPUT_DIR=${PROJECT_ROOT}/download

function usage() {
    cat << EOF
    Usage: $0 [options]
    Options:
    --url             Project Git URL
    -b|--branch       Project Git Branch
    -c|--commit       Project CommitID
    -o|--output       Project Output Directory
    --clean)          Clean Build Result
    -h|--help         This Message.
EOF
}

function CleanAll() {
    echo "clean all"
}

function options_parse() {
    while test $# -gt 0; do
        case "$1" in
            --url)
                if [[ ! -z "${2}" ]] && [[ $2 != -* ]];then
                shift
                REPO_URL=$1
                fi
                ;;
            -b|--branch)
                if [[ ! -z "${2}" ]] && [[ $2 != -* ]];then
                shift
                REPO_BRANCH=$1
                fi
                ;;
            -o|--output)
                if [[ ! -z "${2}" ]] && [[ $2 != -* ]];then
                shift
                REPO_OUTPUT=$1
                fi
                ;;
            -c|--commit)
                if [ ! -z "${2}" ] && [[ $2 != -* ]];then
                shift
                REPO_COMMITID=$1
                fi
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                REPO_URL=$1
                ;;
        esac
        shift
    done
}

# parse options
echo $0 $@
options_parse $@

# backup release
if [ -d release ];then
    mv release release_bk_$(date +%Y-%m-%d_%H-%M-%S)
fi

${SCRIPT_DIR}/repo_download.sh --branch ${REPO_BRANCH} --commit ${REPO_COMMITID} --url ${REPO_URL} --output ${REPO_OUTPUT_DIR} 

PROJECT_NAME=${REPO_URL##*/}
PROJECT_NAME=${PROJECT_NAME%%.*}
REPO_OUTPUT=${REPO_OUTPUT_DIR}/${PROJECT_NAME}

QJS_WASM_BUILDER_DIR=${SCRIPT_DIR}/quickjs
${QJS_WASM_BUILDER_DIR}/build_wasm.sh

if [ -d ${REPO_OUTPUT_DIR} ];then
   rm -rf ${REPO_OUTPUT_DIR}
fi
