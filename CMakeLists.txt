cmake_minimum_required(VERSION 3.2)

project(obs-vintage-filter)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(ARCH_NAME "64bit")
	set(OBS_BUILDDIR_ARCH "build64")
	set(_lib_suffix 64)
else()
	set(ARCH_NAME "32bit")
	set(OBS_BUILDDIR_ARCH "build32")
	set(_lib_suffix 32)
endif()

##########################################
# find libobs                            #
##########################################
include(external/FindLibObs.cmake)
find_package(LibObs REQUIRED)

set(obs-vintage-filter_SOURCES
	src/vintage-filter.c
	)

include_directories(
	${LIBOBS_INCLUDE_DIR}
)

add_library(obs-vintage-filter MODULE
	${obs-vintage-filter_SOURCES}
	)

target_link_libraries(obs-vintage-filter
	${LIBOBS_LIB}
	)

# --- Windows-specific build settings and tasks ---
if(WIN32)
	# --- Release package helper ---
	# The "release" folder has a structure similar OBS' one on Windows
	set(RELEASE_DIR "${PROJECT_SOURCE_DIR}/release")

	add_custom_command(TARGET obs-vintage-filter POST_BUILD
		# If config is Release, package release files
		COMMAND if $<CONFIG:Release>==1 (
		"${CMAKE_COMMAND}" -E make_directory
		"${RELEASE_DIR}/data/obs-plugins/obs-vintage-filter"
		"${RELEASE_DIR}/obs-plugins/${ARCH_NAME}")

		# If config is RelWithDebInfo, package release files
		COMMAND if $<CONFIG:RelWithDebInfo>==1 (
		"${CMAKE_COMMAND}" -E make_directory
		"${RELEASE_DIR}/data/obs-plugins/obs-vintage-filter"
		"${RELEASE_DIR}/obs-plugins/${ARCH_NAME}")

		COMMAND if $<CONFIG:Release>==1 ("${CMAKE_COMMAND}" -E copy_directory
		"${PROJECT_SOURCE_DIR}/data"
		"${RELEASE_DIR}/data/obs-plugins/obs-vintage-filter")

		COMMAND if $<CONFIG:RelWithDebInfo>==1 ("${CMAKE_COMMAND}" -E copy_directory
		"${PROJECT_SOURCE_DIR}/data"
		"${RELEASE_DIR}/data/obs-plugins/obs-vintage-filter")

		COMMAND if $<CONFIG:RelWithDebInfo>==1 ("${CMAKE_COMMAND}" -E copy
		"$<TARGET_PDB_FILE:obs-vintage-filter>"
		"${RELEASE_DIR}/obs-plugins/${ARCH_NAME}")

		COMMAND (
		"${CMAKE_COMMAND}" -E copy
		"$<TARGET_FILE:obs-vintage-filter>"
		"${RELEASE_DIR}/obs-plugins/${ARCH_NAME}")

		# Copy to obs-studio environment for immediate testing
		COMMAND (
		"${CMAKE_COMMAND}" -E copy
		"$<TARGET_FILE:obs-vintage-filter>"
		"${LIBOBS_INCLUDE_DIR}/../${OBS_BUILDDIR_ARCH}/rundir/$<CONFIG>/obs-plugins/${ARCH_NAME}")

		COMMAND if $<CONFIG:Debug>==1 (
		"${CMAKE_COMMAND}" -E copy
		"$<TARGET_PDB_FILE:obs-vintage-filter>"
		"${LIBOBS_INCLUDE_DIR}/../${OBS_BUILDDIR_ARCH}/rundir/$<CONFIG>/obs-plugins/${ARCH_NAME}")

		COMMAND (
		"${CMAKE_COMMAND}" -E make_directory
		"${LIBOBS_INCLUDE_DIR}/../${OBS_BUILDDIR_ARCH}/rundir/$<CONFIG>/data/obs-plugins/obs-vintage-filter")

		COMMAND (
		"${CMAKE_COMMAND}" -E copy_directory
		"${PROJECT_SOURCE_DIR}/data"
		"${LIBOBS_INCLUDE_DIR}/../${OBS_BUILDDIR_ARCH}/rundir/$<CONFIG>/data/obs-plugins/obs-vintage-filter")
		)
endif()

if(UNIX AND NOT APPLE)
	set_target_properties(obs-vintage-filter PROPERTIES PREFIX "")

	file(GLOB effect_files data/*.effect)
	file(GLOB locale_files data/locale/*.ini)

	install(TARGETS obs-vintage-filter LIBRARY DESTINATION
		"${CMAKE_INSTALL_PREFIX}/lib/obs-plugins")
	install(FILES ${effect_files} DESTINATION
		"${CMAKE_INSTALL_PREFIX}/share/obs/obs-plugins/obs-vintage-filter/")
	install(FILES ${locale_files} DESTINATION
		"${CMAKE_INSTALL_PREFIX}/share/obs/obs-plugins/obs-vintage-filter/locale")
endif()
