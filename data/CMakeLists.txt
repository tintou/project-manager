configure_file(project-manager.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/project-manager.desktop)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/project-manager.desktop DESTINATION share/applications)
install (FILES project-manager.appdata.xml DESTINATION share/appdata)
