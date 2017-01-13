configure_file(com.github.tintou.project-manager.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/com.github.tintou.project-manager.desktop)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/com.github.tintou.project-manager.desktop DESTINATION share/applications)
install (FILES com.github.tintou.project-manager.appdata.xml DESTINATION share/metainfo)
install (DIRECTORY icons/ DESTINATION share/icons/hicolor PATTERN "icons/*")
