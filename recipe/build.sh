set -e

if [[ "${target_platform}" == "osx-arm64" ]]; then
  USE_ELAS=OFF
  # Disable Perl to skip Fortran header generation during cross-compilation.
  # The genheader tool would be compiled for arm64 but needs to run on x86_64.
  CROSS_ARGS="-DCMAKE_DISABLE_FIND_PACKAGE_Perl=TRUE"
else
  USE_ELAS=ON
  CROSS_ARGS=""
fi

cmake -G "Ninja" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DTEST_LIBMMG3D=OFF \
    -DTEST_LIBMMG2D=OFF \
    -DTEST_LIBMMGS=OFF \
    -DTEST_LIBMMG=OFF \
    -DUSE_VTK=${use_vtk} \
    -DUSE_ELAS=${USE_ELAS} \
    ${CROSS_ARGS} \
    -S . \
    -B build
cmake --build ./build --verbose --config Release
cmake --install ./build --verbose

