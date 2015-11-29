find_package (PkgConfig)

pkg_check_modules (DEPS REQUIRED gthread-2.0 gee-0.8 gtk+-3.0>=3.12 granite libgda-5.0)

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.26" MINIMUM)

include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    Application.vala
    MainWindow.vala
    Settings.vala
    Panels/Blueprints.vala
    Panels/Bugs.vala
    Panels/Code.vala
    Panels/Overview.vala
    ${CMAKE_CURRENT_BINARY_DIR}/config.vala
PACKAGES
    libgda-5.0
    gtk+-3.0
    gee-0.8
    granite
    ${UNITY_PACKAGES}
OPTIONS
  --vapidir=${CMAKE_SOURCE_DIR}/vapi
  --target-glib=2.32
  --thread
  ${UNITY_OPTIONS}
)

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})

add_executable (${EXEC_NAME} ${VALA_C})
target_link_libraries (${EXEC_NAME} ${DEPS_LIBRARIES}) 

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
