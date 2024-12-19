cmake -G "Ninja" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D BUILD_SHARED_LIBS=ON  ^
      -D "CMAKE_INSTALL_PREFIX=%PREFIX%" ^
      -D USE_VTK=OFF ^
      -D MMG5_PACKAGE:BOOL=OFF ^
      -S .  ^
      -B builddir
if errorlevel 1 exit 1

cmake --build builddir
if errorlevel 1 exit 1

cmake --install builddir
if errorlevel 1 exit 1

