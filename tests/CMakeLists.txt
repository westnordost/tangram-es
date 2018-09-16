add_executable(allTests
  src/catch.cpp
  unit/curlTests.cpp
  unit/drawRuleTests.cpp
  unit/dukTests.cpp
  unit/fileTests.cpp
  unit/flyToTest.cpp
  unit/jobQueueTests.cpp
  unit/labelsTests.cpp
  unit/labelTests.cpp
  unit/layerTests.cpp
  unit/lineWrapTests.cpp
  unit/lngLatTests.cpp
  unit/mercProjTests.cpp
  unit/meshTests.cpp
  unit/sceneImportTests.cpp
  unit/sceneLoaderTests.cpp
  unit/sceneUpdateTests.cpp
  unit/stopsTests.cpp
  unit/styleMixerTests.cpp
  unit/styleSortingTests.cpp
  unit/styleUniformsTests.cpp
  unit/textureTests.cpp
  unit/tileIDTests.cpp
  unit/tileManagerTests.cpp
  unit/urlTests.cpp
  unit/yamlFilterTests.cpp
)

target_link_libraries(allTests
  tangram-core
  platform_mock
)

# Use all include directories from tangram-core because tests interact with internal classes.
target_include_directories(allTests PRIVATE
  $<TARGET_PROPERTY:tangram-core,INCLUDE_DIRECTORIES>
  catch
)

set_target_properties(allTests PROPERTIES
  EXCLUDE_FROM_ALL 1
)

# Copy resources into output directory
add_resources(allTests "${PROJECT_SOURCE_DIR}/scenes")
