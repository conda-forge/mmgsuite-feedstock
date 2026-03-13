set -e

if [[ "${target_platform}" == "osx-arm64" ]]; then
  USE_ELAS=OFF
else
  USE_ELAS=ON
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
    -S . \
    -B build
cmake --build ./build --verbose --config Release
cmake --install ./build --verbose

