# Build Open-FVS using CMake
# Original configuration by: NCrookston July 24 2012
# Refactoring by: Tod Haren
#
# Open-FVS project level CMake file
# FVS variants are built in individual subdirectories
#   CMakeLists.txt files are generated for each variant
#   CMakeLists.txt.in is the variant template
#
# Targets:
#   Variant Targets: <var> (e.g. ie)
#     FVS<var> - FVS executable binary
#     libfvs<var> - FVS shared library (*.dll,*.so)
#     libfvs<var>_static - FVS static library (*.a)
#     <var> - Build all variant binaries
# Global:
#    all - Build all configured variants
#    zip - Archive the results of "all" in a zip file
#
# A subset of available FVS variants can be built
#   by populating the FVS_VARIANT environment variable
#   
# Parallel build are executed simultaneously for all configured variants
# 
# CMake features and options should work as documented
#    https://cmake.org/cmake/help/latest/
# Common build systems should work MinGW Makefiles, Unix Makefiles, Ninja, etc.
# C, C++, Fortran compilers should be in the environment PATH
#   Compilers can be specified using environment variables CC, CXX, FC, etc.
#
# Example Usage:
#   Basic debug build, all variants:
#   $ mkdir build
#   $ cd build
#   $ cmake -G "MinGW Makefiles" ..
#   $ cmake --build .
#
#   Ninja release build, specific variants:
#   $ mkdir build
#   $ cd build
#	$ cmake -S .. -B release -G "Ninja" -DFVS_VARIANTS=pn,wc,so -DCMAKE_BUILD_TYPE=Release
#   $ cmake --build release -j14
#   $ cmake --build release --target zip
#
# Run incremental builds by calling cmake --build <dir>
#   Most build systems will restrict builds to modified files 

cmake_minimum_required (VERSION 3.13)

project(Open-FVS
	LANGUAGES Fortran C CXX
	)

# Default variable values which can be set on the command line
set(FVS_VARIANTS "all" CACHE STRING "FVS variants to configure, eg. pnc,wcc,oc,op")
string(TOLOWER ${FVS_VARIANTS} FVS_VARIANTS)

# Get the list of variants to configure
if (FVS_VARIANTS STREQUAL "all")
	# Enumerate all available variants
    file(GLOB source_lists "${PROJECT_SOURCE_DIR}/bin/FVS*_sourceList.txt")
	set(FVS_VARIANTS "")
	foreach (lst ${source_lists})
		STRING(REGEX MATCH "FVS(..)_sourceList\.txt$" foo ${lst})
		list(APPEND FVS_VARIANTS ${CMAKE_MATCH_1})
	endforeach ()

else ()

	# Verify the user supplied variants to configure
	string(REPLACE "," ";" FVS_VARIANTS "${FVS_VARIANTS}")
	string(REPLACE " " ";" FVS_VARIANTS "${FVS_VARIANTS}")
	
	foreach (var ${FVS_VARIANTS})
		set(pth "${PROJECT_SOURCE_DIR}/bin/FVS${var}_sourceList.txt")
		if (NOT EXISTS ${pth})
			list(REMOVE_ITEM FVS_VARIANTS ${var})
			message(STATUS "*** Variant ${var} source list does not exist: ${pth}") 
		endif ()
	endforeach ()
	
endif ()

message(STATUS "Variants to configure: ${FVS_VARIANTS}")

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Configure FVS Variants: ${FVS_VARIANTS}")

# Save all outputs to a common location
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Open-FVS/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Open-FVS/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Open-FVS/bin)

set(all_targets "")

# Configure each variant and add it as a subdirectory
foreach (variant ${FVS_VARIANTS})

	set(target_name "FVS${variant}")
	set(sl "${target_name}_sourceList.txt") # Using the variant source lists
	get_filename_component(slfn "bin/${sl}" ABSOLUTE)

	# Read the source file list
	file(STRINGS "${slfn}"  source_files  NEWLINE_CONSUME)
	
	string(REPLACE "../" "${CMAKE_CURRENT_LIST_DIR}/" source_files ${source_files})

	# Setup the variant target subdirectory
	set(target_folder "${PROJECT_BINARY_DIR}/${target_name}")
	file(MAKE_DIRECTORY ${target_folder})
	file(WRITE ${target_folder}/sourcelist.txt ${source_files})
	
	# Perform variable substitution on the variant CMakeLists.txt
	set(header_message "**** DO NOT EDIT - This is an auto-generated file")
	configure_file(
		CMakeLists.txt.in
		${target_folder}/CMakeLists.txt
		@ONLY # replace strings with the form @VAR@, but not ${VAR}
		)
	
	message(STATUS "Configure subdirectory: ${target_folder}")
	add_subdirectory(${target_folder})
	
	# Custom target for all components of the variant
	set(variant_targets ${target_name} lib${target_name} lib${target_name}_static)
	add_custom_target(${variant} ALL DEPENDS ${variant_targets})
	
	# Add the variant components to the global target list
	list(APPEND all_targets ${variant_targets})

endforeach(variant)

# Add a target for zipping the outputs
# NOTE: ARCHIVE_NAME should be defined externally by the build platform
#       It should consist of the revision number, system_name, etc.
if (NOT DEFINED ENV{ARCHIVE_NAME})
	set(ENV{ARCHIVE_NAME} "open-fvs")
endif ()

add_custom_target(zip
		DEPENDS ${all_targets}
		COMMAND ${CMAKE_COMMAND} -E tar "cfv" "$ENV{ARCHIVE_NAME}.zip" --format=zip
			"${PROJECT_BINARY_DIR}/Open-FVS"
		)
