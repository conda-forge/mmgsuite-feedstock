cmake -G "Ninja" -D CMAKE_BUILD_TYPE=Release -D "CMAKE_INSTALL_PREFIX=%PREFIX%" -S . -B builddir
cmake --build builddir
cmake --install builddir