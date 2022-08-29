# Build the PyFVS extension
#
# FIXME: (not this anymore) Hierarchical project as described here
#  https://bloerg.net/2012/11/10/cmake-and-distutils.html
#
# Example Projects
# https://github.com/Nicholaswogan/skbuild-f2py-examples/blob/main/hello-fortran-cmaker/CMakeLists.txt

cmake_minimum_required (VERSION 3.12 FATAL_ERROR)

# CMake extension, etc. relative to the base directory
# Extension modules copied over from scikit-build
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

project(pyfvs Fortran C CXX)
enable_language(Fortran)

# Required CMake Packages
# Base Python requirements
find_package(Python3 REQUIRED COMPONENTS NumPy Interpreter Development.Module)

# Bail if the there are missing Python components
if (NOT ${Python3_FOUND})
    message(STATUS "Python Interpreter: ${Python3_EXECUTABLE}")
    message(STATUS "Python Libraries: ${Python3_LIBRARIES}")
    message(STATUS "Python Include dirs: ${Python3_INCLUDE_DIRS}")
    message(STATUS "Numpy Include dirs: ${Python3_NumPy_INCLUDE_DIRS}")
    message(FATAL_ERROR "Required Python components not found.")
endif ()

# Scikit-build requirements
find_package(PythonExtensions REQUIRED)
find_package(Cython REQUIRED)
find_package(F2PY REQUIRED)

message(STATUS "F2PY included from: ${F2PY_INCLUDE_DIR}")

include_directories(BEFORE ${_Python3_NumPy_INCLUDE_DIR})
include_directories(BEFORE ${PYTHON_INCLUDE_DIRS})

message(STATUS "Python: ${PYTHON_PREFIX}")
message(STATUS "Python Includes: ${PYTHON_INCLUDE_DIRS}")
message(STATUS "Numpy Includes: ${_Python3_NumPy_INCLUDE_DIR}")
message(STATUS "Python Libs: ${PYTHON_LIBRARIES}")

## FIXME: version now comes from the Git
# # Read in the PyFVS version number
# file(STRINGS "pyfvs/_version.py" PACKAGE_VERSION REGEX "[0-9]+\\.[0-9]+\\.[0-9]+")
# message(STATUS "Package version: ${PACKAGE_VERSION}")

# set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/src")

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

# Add the custom Open-FVS CMakelists.txt subdirectory
set(fvs_root "${CMAKE_SOURCE_DIR}/fvs")
add_subdirectory(build_fvs)
