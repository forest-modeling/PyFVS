# Build the PyFVS extension
#
# Hierarchical project as described here
#  https://bloerg.net/2012/11/10/cmake-and-distutils.html

cmake_minimum_required (VERSION 3.12 FATAL_ERROR)

# CMake extension, etc. relative to the base directory
# Extension modules copied over from scikit-build
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

project(pyfvs Fortran C CXX)

# read the PyFVS version number from a file
file(STRINGS "pyfvs/_version.py" PACKAGE_VERSION REGEX "[0-9]+\\.[0-9]+\\.[0-9]+")
message(STATUS "Package version: ${PACKAGE_VERSION}")

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

add_subdirectory(open-fvs)
