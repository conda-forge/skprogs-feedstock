#!/usr/bin/env bash
set -ex

if [ "${mpi}" != "nompi" ]; then
  MPI=ON
  NPROCS=2
else
  MPI=OFF
  NPROCS=1
fi

cmake_options=(
   ${CMAKE_ARGS}
   "-DCMAKE_BUILD_TYPE=Release"
   "-DLAPACK_LIBRARY='lapack;blas'"
   "-DWITH_MPI=${MPI}"
   "-DBUILD_SHARED_LIBS=ON"
   "-DTEST_MPI_PROCS=${NPROCS}"
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

if [ "${mpi}" != "nompi" ]; then
  ctest_regexps=(
    'LDA-PW91/Non-Relativistic/Dynamic-conv$'
    'LDA-PW91/Non-Relativistic/Dynamic-noconv$'
  )
else
  ctest_regexps=(
    'LDA-PW91/Non-Relativistic/Power$'
  )
fi

for ctest_regexp in ${ctest_regexps[@]}; do
  ctest --output-on-failure -R "${ctest_regexp}"
done
popd
