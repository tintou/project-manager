project (project-manager)

cmake_minimum_required (VERSION 2.8)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/${CMAKE_PROJECT_NAME}")
set (GETTEXT_PACKAGE "com.github.tintou.project-manager")
set (EXEC_NAME "com.github.tintou.project-manager")
set (APP_NAME "Project Manager")
set (RELEASE_NAME "A simple project manager.")
set (DESKTOP_ICON "com.github.tintou.project-manager")
set (VERSION "0.1")
set (VERSION_INFO "Alpha")

configure_file (${CMAKE_SOURCE_DIR}/config.vala.cmake ${CMAKE_BINARY_DIR}/src/config.vala)
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
add_definitions (-w)

add_subdirectory (src)
add_subdirectory (data)
add_subdirectory (po)
add_subdirectory (schemas)
