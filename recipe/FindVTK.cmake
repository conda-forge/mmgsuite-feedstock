# Find only the VTK modules used by MMG.
#
# The conda-forge vtk-base package contains these libraries, but its upstream
# VTKConfig.cmake imports targets for modules split into the full vtk package.
# Loading that config therefore fails while validating absent libraries such
# as IOFFMPEG.  Avoid the monolithic exported target set and locate only MMG's
# file-I/O dependencies.

set(_vtk_required_modules
  vtksys
  CommonCore
  CommonDataModel
  CommonExecutionModel
  IOCore
  IOLegacy
  IOParallel
  IOParallelXML
  IOXML
)

set(_vtk_prefix_hints ${CMAKE_PREFIX_PATH})
if(DEFINED ENV{PREFIX})
  list(PREPEND _vtk_prefix_hints "$ENV{PREFIX}")
endif()
if(DEFINED ENV{LIBRARY_PREFIX})
  list(PREPEND _vtk_prefix_hints "$ENV{LIBRARY_PREFIX}")
endif()
list(REMOVE_DUPLICATES _vtk_prefix_hints)

set(_vtk_include_hints)
set(_vtk_library_hints)
foreach(_vtk_prefix IN LISTS _vtk_prefix_hints)
  file(GLOB _vtk_prefix_include_hints LIST_DIRECTORIES true
    "${_vtk_prefix}/include/vtk-*"
  )
  list(APPEND _vtk_include_hints ${_vtk_prefix_include_hints})
  list(APPEND _vtk_library_hints "${_vtk_prefix}/lib")
endforeach()

find_path(VTK_INCLUDE_DIR
  NAMES vtkVersion.h
  HINTS ${_vtk_include_hints}
  NO_CMAKE_FIND_ROOT_PATH
)

if(VTK_INCLUDE_DIR)
  file(STRINGS "${VTK_INCLUDE_DIR}/vtkVersionQuick.h" _vtk_version_lines
    REGEX "^#define VTK_(MAJOR|MINOR)_VERSION "
  )
  file(STRINGS "${VTK_INCLUDE_DIR}/vtkVersionMacros.h" _vtk_build_version_line
    REGEX "^#define VTK_(MAJOR|MINOR|BUILD)_VERSION "
  )
  list(APPEND _vtk_version_lines "${_vtk_build_version_line}")
  foreach(_vtk_part MAJOR MINOR BUILD)
    string(REGEX MATCH
      "#define VTK_${_vtk_part}_VERSION +([0-9]+)"
      _vtk_version_match
      "${_vtk_version_lines}"
    )
    set(VTK_${_vtk_part}_VERSION "${CMAKE_MATCH_1}")
  endforeach()
  set(VTK_VERSION
    "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}.${VTK_BUILD_VERSION}"
  )
  set(_vtk_library_suffix "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}")
endif()

set(VTK_LIBRARIES)
set(_vtk_missing_modules)
set(_vtk_required_variables VTK_INCLUDE_DIR)
foreach(_vtk_module IN LISTS _vtk_required_modules)
  if(_vtk_module STREQUAL "vtksys")
    set(_vtk_library_stem "vtksys")
  else()
    set(_vtk_library_stem "vtk${_vtk_module}")
  endif()
  find_library(VTK_${_vtk_module}_LIBRARY
    NAMES
      "${_vtk_library_stem}-${_vtk_library_suffix}"
      "${_vtk_library_stem}"
    HINTS ${_vtk_library_hints}
    NO_CMAKE_FIND_ROOT_PATH
  )
  list(APPEND _vtk_required_variables VTK_${_vtk_module}_LIBRARY)
  if(VTK_${_vtk_module}_LIBRARY)
    list(APPEND VTK_LIBRARIES "${VTK_${_vtk_module}_LIBRARY}")
  else()
    list(APPEND _vtk_missing_modules "${_vtk_module}")
  endif()
endforeach()

include(FindPackageHandleStandardArgs)
string(REPLACE ";" ", " _vtk_missing_modules_message "${_vtk_missing_modules}")
find_package_handle_standard_args(VTK
  REQUIRED_VARS ${_vtk_required_variables}
  VERSION_VAR VTK_VERSION
  FAIL_MESSAGE
    "Could not find the vtk-base modules required by MMG: ${_vtk_missing_modules_message}"
)

if(VTK_FOUND)
  set(VTK_INCLUDE_DIRS "${VTK_INCLUDE_DIR}")
  include_directories(SYSTEM "${VTK_INCLUDE_DIR}")
endif()

mark_as_advanced(VTK_INCLUDE_DIR)
foreach(_vtk_module IN LISTS _vtk_required_modules)
  mark_as_advanced(VTK_${_vtk_module}_LIBRARY)
endforeach()
