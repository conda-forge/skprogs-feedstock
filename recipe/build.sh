#!/usr/bin/env bash
set -ex

cmake_options=(
   ${CMAKE_ARGS}
   "-DCMAKE_BUILD_TYPE=Release"
   "-DLAPACK_LIBRARY='lapack;blas'"
   "-DBUILD_SHARED_LIBS=ON"
   "-GNinja"
   ${cmake_mpi_options[@]}
   ..
)

mkdir -p _build
pushd _build

FFLAGS=$FFLAGS:"-fno-backtrace" cmake "${cmake_options[@]}"
ninja all install

#
# Relatively quick test to check build sanity
#

ctest_regexps=(
  'LDA-PW91/Non-Relativistic$'
)

for ctest_regexp in ${ctest_regexps[@]}; do
  ctest --output-on-failure -R "${ctest_regexp}"
done
popd
