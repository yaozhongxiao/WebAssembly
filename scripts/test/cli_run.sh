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
# set -ex

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
NPM_QJS_ROOT=${SCRIPT_DIR}/..
NPN_QJS_TEST_ROOT=${SCRIPT_DIR}

function usage() {
  cat << EOF
  Usage: $0 [options]
  Options:
      --cli  bin        cli binary options: [wasmtime, bwa]
      -h|--help         Print This Message
      --abort           Abort Testing While Case Failure
      --logging         Show Testing Logs
EOF
  exit 0;
}

cli_bin=wasmtime
abort_fail=false
show_logging=false
env_setup=false
function options_parse() {
  while test $# -gt 0; do
      case "$1" in
        -h|--help)
          usage
          ;;
        --abort)
          abort_fail=true
          ;;
        --logging)
          show_logging=true
          ;;
        --cli)
          shift
          cli_bin=$1
          ;;
        --setup)
          env_setup=true
          ;;
        *)
        cli_bin=$1
      esac
      shift
  done
}

echo $0 $@
options_parse $@

if [ x${env_setup} = x"true" ];then
  ${NPN_QJS_TEST_ROOT}/env_setup.sh
fi

cd ${NPN_QJS_TEST_ROOT}
EXEC_CLI=`which ${cli_bin}`
if [ ! -f "${EXEC_CLI}" ];then
  echo "${cli_bin} missed, please build ${cli_bin} before hands!"
  exit -1
fi

QJS_WASM=${NPM_QJS_ROOT}/build/quickjs-wasm.wasm
if [ ! -f "${QJS_WASM}" ];then
  echo "${QJS_WASM} missed, please build ${QJS_WASM} before hands!"
  exit -1
fi

if [ ${cli_bin} == "wasmtime" ]; then
  COMMAND_SCRIPT="${EXEC_CLI} --env key=value --env name=data --invoke wasm_main ${QJS_WASM}"
elif [ ${cli_bin} == "bwa" ]; then
  COMMAND_SCRIPT="${EXEC_CLI} run --env key=value --env name=data -m wasm_main ${QJS_WASM}"
else
  echo "not supported cli \"${cli_bin}\""
  exit 1
fi

test_logs=()
test_suit=basic-tests
test_cases=($(ls -f ${NPN_QJS_TEST_ROOT}/js/*.js))
# fail_cases=
total_cases=${#test_cases[@]}
suc_cases=0
for((i=0; i<${total_cases}; i++))
do
  echo ""
  echo "[$i]: start run ${test_cases[$i]}"
  echo "cat ${test_cases[$i]} | ${COMMAND_SCRIPT}"
  cat ${test_cases[$i]} | ${COMMAND_SCRIPT}
  if [ $? -eq 0 ];then
    ((suc_cases++))
    echo "[$i]: ${test_cases[$i]} passed!"
    test_logs+=("[$i]: ${test_cases[$i]} passed!")
  else
    echo "x[$i]: ${test_cases[$i]} failed!"
    test_logs+=("x[$i]: ${test_cases[$i]} failed!")
    if [ x"${abort_fail}" = x"true" ];then
      exit -1
    fi
  fi
done

echo ""
echo "${test_suit}[${suc_cases}/${total_cases}]: ${suc_cases} success out of ${total_cases} cases!"
echo "=================================================="
function show_logs() {
  for log in "${test_logs[@]}"
  do
    echo ${log}
  done
}

if [ x"${show_logging}" = x"true" ];then
  show_logs
fi
if [ ${suc_cases} -ne ${total_cases} ];then
  if [ x"${show_logs}" = x"true" ];then
    show_logs
  fi
  exit -1
fi
