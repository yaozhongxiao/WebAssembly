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

project(quickjs-wasm)

option(ENABLE_BIGNUM "enable the bigint feature" ON)
message(STATUS "CONFIG_BIGNUM = ${ENABLE_BIGNUM}")

add_definitions(-DLYNX_DEV=1 -D__WASI_SDK__=1 -DCONFIG_BIGNUM=${ENABLE_BIGNUM})

# Set quickjs root path
set(QUICKJS_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
set(QUICKJS_ROOT "${QUICKJS_ROOT}/quickjs")

set(QUICKJS_SOURCES
  ${QUICKJS_ROOT}/quickjs/source/cutils.cc
  ${QUICKJS_ROOT}/quickjs/source/libregexp.cc
  ${QUICKJS_ROOT}/quickjs/source/libunicode.cc
  ${QUICKJS_ROOT}/quickjs/source/quickjs.cc
  ${QUICKJS_ROOT}/quickjs/source/dlmalloc.cc
  ${QUICKJS_ROOT}/quickjs/source/quickjs_version.cc
  ${QUICKJS_ROOT}/quickjs/source/quickjs-libc.cc
  ${QUICKJS_TOOL_SOURCES}
)

set(QUICKJS_SOURCES
  ${QUICKJS_ROOT}/quickjs/source/libbf.cc
  ${QUICKJS_SOURCES}
)

include_directories(
  ${QUICKJS_ROOT}/include
)

# Set quickjs source compilation flags
set_source_files_properties(
  ${QUICKJS_SOURCES} PROPERTIES COMPILE_FLAGS
  "-Wall -Wextra -Wundef -Wunused -Wuninitialized \
   -Wno-sign-compare -Wno-unused-variable -Wno-unused-parameter \
   -Wno-missing-field-initializers -Wwrite-strings -Wchar-subscripts \
   -funsigned-char -MF -flto -Os -fPIC -Wno-c++11-narrowing -Wno-c99-designator \
   -Wno-implicit-function-declaration -Wno-unused-but-set-variable \
   -Wno-unused-but-set-variable -Wno-undef -Wno-unused-function"
)

add_library(quick STATIC ${QUICKJS_SOURCES})

add_executable(quick_main ${QUICKJS_SOURCES})
# set(CMAKE_EXECUTABLE_SUFFIX ".html") # 编译生成.html
