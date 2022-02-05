cmake_minimum_required(VERSION 3.15)
project(runner LANGUAGES CXX)

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)
apply_standard_settings(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
add_dependencies(${BINARY_NAME} flutter_assemble)

add_custom_command(
  TARGET ${BINARY_NAME} PRE_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/../bin/msvcp140.dll" "$<TARGET_FILE_DIR:${BINARY_NAME}>/msvcp140.dll"
  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/../bin/vcruntime140.dll" "$<TARGET_FILE_DIR:${BINARY_NAME}>/vcruntime140.dll"
  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/../bin/vcruntime140_1.dll" "$<TARGET_FILE_DIR:${BINARY_NAME}>/vcruntime140_1.dll"
)

set(LIBMPV_URL "https://udomain.dl.sourceforge.net/project/mpv-player-windows/libmpv/mpv-dev-x86_64-20220116-git-1ba0547.7z")
set(LIBMPV_ARCHIVE "${CMAKE_BINARY_DIR}/mpv-dev-x86_64-20220116-git-1ba0547.7z")
if (NOT EXISTS "${LIBMPV_ARCHIVE}")
  file(DOWNLOAD "${LIBMPV_URL}" "${LIBMPV_ARCHIVE}")
endif()

add_custom_command(
  TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E tar xzf \"${LIBMPV_ARCHIVE}\"
  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/mpv-2.dll" "$<TARGET_FILE_DIR:${BINARY_NAME}>/mpv-1.dll"
  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/../bin/smtc-win32.dll" "$<TARGET_FILE_DIR:${BINARY_NAME}>/smtc-win32.dll"
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
  DEPENDS "${LIBMPV_ARCHIVE}"
)
