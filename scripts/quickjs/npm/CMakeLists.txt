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
cmake_minimum_required(VERSION 3.4.1)

project(quickjs-wasm-npm)

# Set quickjs root path
set(QJS_NPM_ROOT "${CMAKE_CURRENT_LIST_DIR}")
set(QUICKJS_ROOT "${QJS_NPM_ROOT}/../..")

# include the quickjs static library(wasm target)
include(${QUICKJS_ROOT}/wasm/CMakeLists.txt)

option(OUTPUT_TYPE "enable the bigint feature" "js")
set(REGEX_HTML "html|HTML")
if(OUTPUT_TYPE MATCHES ${REGEX_HTML})
  set(CMAKE_EXECUTABLE_SUFFIX ".html") # 编译生成.html
else()
  set(CMAKE_EXECUTABLE_SUFFIX ".js") # 编译生成.html
endif()

message(STATUS "build-type  : ${CMAKE_BUILD_TYPE}")
message(STATUS "output-type : ${CMAKE_EXECUTABLE_SUFFIX}")

set(CMAKE_COMMON_FLAGS "-std=c++11 \
  -fvisibility=hidden \
  -fvisibility-inlines-hidden")

set(LINKER_FLAGS "-s WASM=1 \
  -s EXPORTED_FUNCTIONS=@${QJS_NPM_ROOT}/exported_functions.json \
  -s EXPORTED_RUNTIME_METHODS=@${QJS_NPM_ROOT}/exported_runtime_methods.json \
  --pre-js ${QJS_NPM_ROOT}/src/js/pre-script.js \
  --post-js ${QJS_NPM_ROOT}/src/js/post-script.js \
  -s ALLOW_MEMORY_GROWTH=1 \
  -s LLD_REPORT_UNDEFINED \
  -s SINGLE_FILE=0 \
  -s STRICT=1 \
  --bind")

if(CMAKE_EXECUTABLE_SUFFIX MATCHES ".js")
  set(LINKER_FLAGS "${LINKER_FLAGS} \
  -s MODULARIZE=1 \
  -s EXPORT_NAME=QjsModule")
  # -s EXPORT_ES6=1"
endif()

if (CMAKE_BUILD_TYPE MATCHES "Debug")
  set(CMAKE_COMMON_FLAGS "${CMAKE_COMMON_FLAGS} -O0 -g")
  add_definitions(-DENABLE_DEBUG=1)
else() # Release
  set(CMAKE_COMMON_FLAGS "${CMAKE_COMMON_FLAGS} -flto -O3")
  add_definitions(-DENABLE_DEBUG=0)
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_COMMON_FLAGS}")

include_directories(
  ${QUICKJS_ROOT}/include
)

set(QUICKJS_NPM_SOURCES
  ${QJS_NPM_ROOT}/src/wasm-binding.cc
)

add_executable(quickjs-wasm ${QUICKJS_NPM_SOURCES})
target_link_libraries(quickjs-wasm PUBLIC quick ${LINKER_FLAGS})
