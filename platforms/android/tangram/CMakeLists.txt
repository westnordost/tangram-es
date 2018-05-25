add_definitions(-DTANGRAM_ANDROID)

add_subdirectory(../../../core ./core)

add_library(tangram SHARED
  ../../common/platform_gl.cpp
  src/main/cpp/jniExports.cpp
  src/main/cpp/androidPlatform.cpp
  src/main/cpp/sqlite3ndk.cpp
)

target_include_directories(tangram PUBLIC
  ../../../core/deps/SQLiteCpp/sqlite3 # sqlite3ndk.cpp needs sqlite3.h
)

target_link_libraries(tangram
  PUBLIC
  tangram-core
  # android libraries
  GLESv2 log z atomic android
)
