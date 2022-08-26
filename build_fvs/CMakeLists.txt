# Custom Open-FVS build process
# CMakeLists.txt.in is a template for FVS variant builds
#   - Adds API files to the build
#   -
#
# A new subdirectory will be created for each requested FVS variant
#   where a configured template will be written before the
#   variant subdirectory is added to the CMake build

cmake_minimum_required (VERSION 3.12 FATAL_ERROR)

project(open-fvs
	LANGUAGES Fortran C CXX
	)

# Default variable values which can be set on the command line
set(FVS_VARIANTS "all" CACHE STRING "FVS variants to configure, eg. pn,wc,oc,op")
string(TOLOWER ${FVS_VARIANTS} FVS_VARIANTS)

# Get the list of variants to configure
if (FVS_VARIANTS STREQUAL "all")
	# Enumerate all available variants
    file(GLOB source_lists "${fvs_root}/bin/FVS*_sourceList.txt")
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
		set(pth "${fvs_root}/bin/FVS${var}_sourceList.txt")
		if (NOT EXISTS ${pth})
			list(REMOVE_ITEM FVS_VARIANTS ${var})
			message(WARNING "*** SKIPPING variant ${var}, source list does not exist: ${pth}")
		endif ()
	endforeach ()

endif ()

message(STATUS "Variants to configure: ${FVS_VARIANTS}")

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Configure FVS Variants: ${FVS_VARIANTS}")

# # Save all outputs to a common location
# set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Open-FVS/lib)
# set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Open-FVS/lib)
# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Open-FVS/bin)

set(all_targets "")

# Configure each variant and add it as a subdirectory
foreach (variant ${FVS_VARIANTS})

	set(target_name "FVS${variant}")
	set(sl "${target_name}_sourceList.txt") # Using the variant source lists
	get_filename_component(slfn "${fvs_root}/bin/${sl}" ABSOLUTE)

	# Read the source file list
	file(STRINGS "${slfn}"  source_files  NEWLINE_CONSUME)

	string(REPLACE "../" "${fvs_root}/" source_files ${source_files})

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
	add_subdirectory(${target_folder} "${PROJECT_BINARY_DIR}/${target_name}/bin")

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
