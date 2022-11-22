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
set(PROJECT_ROOT "${CMAKE_SOURCE_DIR}/../..")
set(QUICKJS_ROOT "${PROJECT_ROOT}/quickjs")
set(WASI_DIR "${QUICKJS_ROOT}/wasm/wasi-sdk")
set(WASI_C "${WASI_DIR}/bin/clang")
set(WASI_CXX "${WASI_DIR}/bin/clang++")
set(WASI_SYSROOT "${WASI_DIR}/share/wasi-sysroot")
set(WASI_INC "${WASI_DIR}/share/wasi-sysroot/include")
set(CMAKE_SYSROOT "${WASI_SYSROOT}")
set(CMAKE_OSX_SYSROOT "${WASI_SYSROOT}")
set(CMAKE_INSTALL_PREFIX "${WASI_SYSROOT}" CACHE PATH
        "Install path prefix, prepended onto install directories." FORCE)
set(CMAKE_C_COMPILER "${WASI_C}" CACHE FILEPATH "wasi-sdk c compiler" FORCE)
set(CMAKE_CXX_COMPILER "${WASI_CXX}" CACHE FILEPATH "wasi-sdk c++ compiler" FORCE)
set(CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES "${WASI_INC}" CACHE FILEPATH "wasi-sdk c include" FORCE)
set(CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES "${WASI_INC}" CACHE FILEPATH "wasi-sdk c++ include" FORCE)

set(COMPILE_FLAGS 
    "-Wall \
    -D_WASI_EMULATED_MMAN \
    -D_WASI_EMULATED_SIGNAL \
    -Wno-invalid-offsetof \
    -Qunused-arguments \
    -fno-sized-deallocation \
    -fno-aligned-new \
    -mthread-model single \
    -fPIC \
    -fno-rtti \
    -fno-exceptions \
    -fno-math-errno \
    -pipe \
    -fno-omit-frame-pointer \
    -funwind-tables \
    -mexec-model=reactor"
        )

# The options for the shared library
set(LINK_FLAGS 
    "-Wl,-z,noexecstack \
    -lwasi-emulated-mman \
    -lwasi-emulated-signal \
    -Wl,-z,text \
    -Wl,-z,relro \
    -Wl,-z,nocopyreloc \
    -Wl,-z,stack-size=1048576 \
    -Wl,--stack-first"
        )

set(CMAKE_SYSTEM_NAME Linux)

set(CMAKE_SHARED_LIBRARY_SONAME_C_FLAG "-Wl,-soname,")

# the actual options for c
set(CMAKE_C_FLAGS "-fsigned-char ${COMPILE_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG "-g")
set(CMAKE_C_FLAGS_RELEASE "-DNDEBUG")

# the actual options for cxx
set(CMAKE_CXX_FLAGS "-std=gnu++17 ${COMPILE_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")

# The linker options
set(CMAKE_SHARED_LINKER_FLAGS "${LINK_FLAGS}" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS "${LINK_FLAGS}" CACHE STRING "")
set(CMAKE_MODULE_LINKER_FLAGS "${LINK_FLAGS}" CACHE STRING "")

set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_C_COMPILER_ID_RUN TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_C_COMPILER_WORKS TRUE)
set(CMAKE_C_COMPILER_ID Clang)
set(CMAKE_C_COMPILER_FRONTEND_VARIANT GNU)
set(CMAKE_C_STANDARD_COMPUTED_DEFAULT 17)

set(CMAKE_CXX_COMPILER_ID_RUN TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_WORKS TRUE)
set(CMAKE_CXX_COMPILER_ID Clang)
set(CMAKE_CXX_COMPILER_FRONTEND_VARIANT GNU)
set(CMAKE_CXX_STANDARD_COMPUTED_DEFAULT 17)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)