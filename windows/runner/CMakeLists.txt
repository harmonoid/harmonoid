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
target_link_libraries(
  ${BINARY_NAME} PRIVATE
  flutter
  flutter_wrapper_app
)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
add_dependencies(${BINARY_NAME} flutter_assemble)

add_custom_command(
  TARGET ${BINARY_NAME} PRE_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/../bin/" "$<TARGET_FILE_DIR:${BINARY_NAME}>"
)

set(MPV_SHARED_LIB "${CMAKE_BINARY_DIR}/mpv-2.dll")

if(NOT EXISTS "${MPV_SHARED_LIB}")
  file(
    DOWNLOAD
    "https://api.github.com/repos/alexmercerind/harmonoid-custom-codec/releases/assets/56309670"
    "${MPV_SHARED_LIB}"
    HTTPHEADER "Authorization: token $ENV{ACCESS_TOKEN}"
    HTTPHEADER "Accept: application/octet-stream"
    SHOW_PROGRESS
  )
endif()

add_custom_command(
  TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy "${MPV_SHARED_LIB}" "$<TARGET_FILE_DIR:${BINARY_NAME}>/mpv-2.dll"
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
  DEPENDS "${LIBMPV_ARCHIVE}"
)
