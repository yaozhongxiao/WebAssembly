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
    -t|--target       Project Build Target
    -c|--commit       Project CommitID
    -o|--output       Project Output Directory
    -d|--debug        Build With Debug Mode (default)
    -r|--release      Build With Release Mode
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
            -t|--target)
                if [ ! -z "${2}" ] && [[ $2 != -* ]];then
                shift
                REPO_TARGET=$1
                fi
                ;;
            -c|--commit)
                if [ ! -z "${2}" ] && [[ $2 != -* ]];then
                shift
                REPO_COMMITID=$1
                fi
                ;;
            --clean)
                CleanAll
                ;;
            -d|--debug)
                BuildType=Debug
                ;;
            -r|--release)
                BuildType=Release
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

if [ -z "${REPO_URL}" ];then
    echo "please check the git repo url before hands!"
    exit -1
fi

# parse project name
PROJECT_NAME=${REPO_URL##*/}
PROJECT_NAME=${PROJECT_NAME%%.*}
REPO_OUTPUT=${REPO_OUTPUT_DIR}/${PROJECT_NAME}
# download project
if [ -d ${REPO_OUTPUT} ];then
    echo "rm -rf ${REPO_OUTPUT}"
    rm -rf ${REPO_OUTPUT}
fi

#clone project
echo "git clone ${REPO_URL} -b ${REPO_BRANCH} ${REPO_OUTPUT}"
git clone ${REPO_URL} -b ${REPO_BRANCH} ${REPO_OUTPUT}

# checkout target commit
if [ ! -z ${REPO_COMMITID} ];then
    cd ${REPO_OUTPUT}
    echo "git checkout ${REPO_COMMITID}"
    git checkout ${REPO_COMMITID}
fi