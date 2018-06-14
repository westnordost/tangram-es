include(${CMAKE_SOURCE_DIR}/cmake/iOS.toolchain.cmake)

set(FRAMEWORK_VERSION "0.9.4-dev")

set(IOS_TARGET_VERSION "9.3")

message(STATUS "Build for iOS archs " ${IOS_ARCH})

set(FRAMEWORK_NAME TangramMap)

add_definitions(-DTANGRAM_IOS)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}
    -fobjc-abi-version=2
    -fobjc-arc
    -std=c++14
    -stdlib=libc++
    -w
    -miphoneos-version-min=${IOS_TARGET_VERSION}
    -isysroot ${CMAKE_IOS_SDK_ROOT}")

set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}
    -fobjc-abi-version=2
    -fobjc-arc
    -w
    -miphoneos-version-min=${IOS_TARGET_VERSION}
    -isysroot ${CMAKE_IOS_SDK_ROOT}")

if(${IOS_PLATFORM} STREQUAL "SIMULATOR")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mios-simulator-version-min=6.0")
else()
    if(${CMAKE_BUILD_TYPE} STREQUAL "Release")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fembed-bitcode")
        add_compile_options("-fembed-bitcode")
    endif()
endif()

# Tell SQLiteCpp to not build its own copy of SQLite, we will use the system library instead.
set(SQLITECPP_INTERNAL_SQLITE OFF CACHE BOOL "")

set(FRAMEWORK_HEADERS
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
    ${FRAMEWORK_HEADERS}
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

add_bundle_resources(RESOURCES "${PROJECT_SOURCE_DIR}/platforms/ios/framework/Modules" "./Modules")

target_link_libraries(TangramMap PRIVATE
    tangram-core
    sqlite3
)

target_include_directories(TangramMap PRIVATE
    platforms/common
)

set(IOS_FRAMEWORK_RESOURCES ${PROJECT_SOURCE_DIR}/platforms/ios/framework/Info.plist)

set_target_properties(TangramMap PROPERTIES
    CLEAN_DIRECT_OUTPUT 1
    FRAMEWORK TRUE
    MACOSX_FRAMEWORK_IDENTIFIER com.mapzen.tangramMap
    MACOSX_FRAMEWORK_INFO_PLIST ${IOS_FRAMEWORK_RESOURCES}
    PUBLIC_HEADER "${FRAMEWORK_HEADERS}"
    RESOURCE "${IOS_FRAMEWORK_RESOURCES}"
)

set_xcode_property(TangramMap CODE_SIGN_IDENTITY "")
set_xcode_property(TangramMap CODE_SIGNING_REQUIRED "NO")
set_xcode_property(TangramMap CODE_SIGN_ENTITLEMENTS "")
set_xcode_property(TangramMap CODE_SIGNING_ALLOWED "NO")

if(${CMAKE_BUILD_TYPE} STREQUAL "Release")
    set_xcode_property(TangramMap GCC_GENERATE_DEBUGGING_SYMBOLS NO)
    set_xcode_property(TangramMap DEPLOYMENT_POSTPROCESSING YES)
    set_xcode_property(TangramMap COPY_PHASE_STRIP NO)
    set_xcode_property(TangramMap STRIP_INSTALLED_PRODUCT YES)
    set_xcode_property(TangramMap STRIP_STYLE non-global)
    set_xcode_property(TangramMap SEPARATE_STRIP YES)
    set_xcode_property(TangramMap DEAD_CODE_STRIPPING YES)
else()
    set_xcode_property(TangramMap GCC_GENERATE_DEBUGGING_SYMBOLS YES)
endif()

if(${IOS_PLATFORM} STREQUAL "SIMULATOR")
    # properties for simulator architectures
else()
    if(${CMAKE_BUILD_TYPE} STREQUAL "Release")
        set_xcode_property(TangramMap ENABLE_BITCODE "YES")
        set_xcode_property(TangramMap BITCODE_GENERATION_MODE bitcode)
    endif()
endif()

set_xcode_property(TangramMap SUPPORTED_PLATFORMS "iphonesimulator iphoneos")
set_xcode_property(TangramMap ONLY_ACTIVE_ARCH "NO")
set_xcode_property(TangramMap VALID_ARCHS "${IOS_ARCH}")
set_xcode_property(TangramMap ARCHS "${IOS_ARCH}")
set_xcode_property(TangramMap DEFINES_MODULE "YES")
set_xcode_property(TangramMap CURRENT_PROJECT_VERSION "${FRAMEWORK_VERSION}")
set_xcode_property(TangramMap IPHONEOS_DEPLOYMENT_TARGET "${IOS_TARGET_VERSION}")

# Set RPATH to be within the application /Frameworks directory
set_xcode_property(TangramMap LD_DYLIB_INSTALL_NAME "@rpath/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}")

target_add_framework(TangramMap CoreFoundation)
target_add_framework(TangramMap CoreGraphics)
target_add_framework(TangramMap CoreText)
target_add_framework(TangramMap GLKit)
target_add_framework(TangramMap OpenGLES)
target_add_framework(TangramMap UIKit)

# Generate demo app configuration plist file to inject API key
configure_file(
    platforms/ios/App/Config.plist.in
    platforms/ios/App/resources/Config.plist
)
