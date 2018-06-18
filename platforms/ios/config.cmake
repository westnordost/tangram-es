add_definitions(-DTANGRAM_IOS)

set(TANGRAM_FRAMEWORK_VERSION "0.9.4-dev")

### Emulate toolchain --
set(IOS TRUE)
set(CMAKE_OSX_SYSROOT "iphoneos")
set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator")
set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "9.3")
# set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH[variant=debug] "YES")
# set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH[variant=release] "NO")
### -- end

# Tell SQLiteCpp to not build its own copy of SQLite, we will use the system library instead.
set(SQLITECPP_INTERNAL_SQLITE OFF CACHE BOOL "")

set(TANGRAM_FRAMEWORK_HEADERS
    platforms/ios/Framework/TangramMap.h
    platforms/ios/TangramMap/TGGeoPolyline.h
    platforms/ios/TangramMap/TGGeoPolygon.h
    platforms/ios/TangramMap/TGGeoPoint.h
    platforms/ios/TangramMap/TGMarker.h
    platforms/ios/TangramMap/TGSceneUpdate.h
    platforms/ios/TangramMap/TGMapData.h
    platforms/ios/TangramMap/TGTypes.h
    platforms/ios/TangramMap/TGHttpHandler.h
    platforms/ios/TangramMap/TGLabelPickResult.h
    platforms/ios/TangramMap/TGMarkerPickResult.h
    platforms/ios/TangramMap/TGMapViewController.h
)

add_library(TangramMap SHARED
    ${TANGRAM_FRAMEWORK_HEADERS}
    platforms/common/platform_gl.cpp
    platforms/common/appleAllowedFonts.h
    platforms/common/appleAllowedFonts.mm
    platforms/ios/TangramMap/iosPlatform.h
    platforms/ios/TangramMap/iosPlatform.mm
    platforms/ios/TangramMap/TGHelpers.h
    platforms/ios/TangramMap/TGHelpers.mm
    platforms/ios/TangramMap/TGGeoPolyline.mm
    platforms/ios/TangramMap/TGGeoPolygon.mm
    platforms/ios/TangramMap/TGHttpHandler.mm
    platforms/ios/TangramMap/TGMapData+Internal.h
    platforms/ios/TangramMap/TGMapData.mm
    platforms/ios/TangramMap/TGSceneUpdate.mm
    platforms/ios/TangramMap/TGLabelPickResult+Internal.h
    platforms/ios/TangramMap/TGLabelPickResult.mm
    platforms/ios/TangramMap/TGMarkerPickResult+Internal.h
    platforms/ios/TangramMap/TGMarkerPickResult.mm
    platforms/ios/TangramMap/TGMarker+Internal.h
    platforms/ios/TangramMap/TGMarker.mm
    platforms/ios/TangramMap/TGTypes.mm
    platforms/ios/TangramMap/TGMapViewController+Internal.h
    platforms/ios/TangramMap/TGMapViewController.mm
)

target_link_libraries(TangramMap PRIVATE
    tangram-core
    sqlite3
    # Frameworks: use quotes so "-framework X" is treated as a single linker flag.
    "-framework CoreFoundation"
    "-framework CoreGraphics"
    "-framework CoreText"
    "-framework GLKit"
    "-framework OpenGLES"
    "-framework UIKit"
)

target_include_directories(TangramMap PRIVATE
    platforms/common
)

set_target_properties(TangramMap PROPERTIES
    FRAMEWORK TRUE
    PUBLIC_HEADER "${TANGRAM_FRAMEWORK_HEADERS}"
    MACOSX_FRAMEWORK_INFO_PLIST "${PROJECT_SOURCE_DIR}/platforms/ios/framework/Info.plist"
    XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION "${TANGRAM_FRAMEWORK_VERSION}"
    XCODE_ATTRIBUTE_DEFINES_MODULE "YES"
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES"
    XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++14"
    XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++"
)

# Set RPATH to be within the application /Frameworks directory
# set_xcode_property(TangramMap LD_DYLIB_INSTALL_NAME "@rpath/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}")
