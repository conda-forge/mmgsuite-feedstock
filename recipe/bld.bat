copy /Y "%RECIPE_DIR%\FindVTK.cmake" "cmake\modules\FindVTK.cmake"
if errorlevel 1 exit 1

cmake -G "Ninja" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_CXX_STANDARD=17 ^
      -D CMAKE_CXX_STANDARD_REQUIRED=ON ^
      -D BUILD_SHARED_LIBS=ON  ^
      -D "CMAKE_INSTALL_PREFIX=%PREFIX%" ^
      -D USE_VTK=%use_vtk% ^
      -D MMG5_PACKAGE:BOOL=OFF ^
      -D "CMAKE_CXX_FLAGS=/DNOMINMAX" ^
      -S .  ^
      -D MMG_INSTALL_PRIVATE_HEADERS:BOOL=ON ^
      -B builddir
if errorlevel 1 exit 1

cmake --build builddir
if errorlevel 1 exit 1

cmake --install builddir
if errorlevel 1 exit 1

