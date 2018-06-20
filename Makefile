all: android osx ios

.PHONY: clean
.PHONY: clean-android
.PHONY: clean-osx
.PHONY: clean-xcode
.PHONY: clean-ios
.PHONY: clean-rpi
.PHONY: clean-linux
.PHONY: clean-benchmark
.PHONY: clean-shaders
.PHONY: clean-tizen-arm
.PHONY: clean-tizen-x86
.PHONY: clean-ios-framework
.PHONY: clean-ios-framework-sim
.PHONY: android
.PHONY: osx
.PHONY: xcode
.PHONY: ios
.PHONY: rpi
.PHONY: linux
.PHONY: benchmark
.PHONY: ios-framework
.PHONY: ios-framework-universal
.PHONY: cmake-osx
.PHONY: cmake-xcode
.PHONY: cmake-ios
.PHONY: cmake-ios-framework
.PHONY: cmake-ios-framework-sim
.PHONY: cmake-rpi
.PHONY: cmake-linux
.PHONY: install-android
.PHONY: ios-docs

ANDROID_BUILD_DIR = platforms/android/tangram/build
OSX_BUILD_DIR = build/osx
OSX_XCODE_BUILD_DIR = build/xcode
IOS_BUILD_DIR = build/ios
IOS_DOCS_BUILD_DIR = build/ios-docs
RPI_BUILD_DIR = build/rpi
LINUX_BUILD_DIR = build/linux
TESTS_BUILD_DIR = build/tests
BENCH_BUILD_DIR = build/bench
TIZEN_ARM_BUILD_DIR = build/tizen-arm
TIZEN_X86_BUILD_DIR = build/tizen-x86

OSX_TARGET = tangram
IOS_TARGET = tangram
IOS_FRAMEWORK_TARGET = TangramMap
OSX_XCODE_PROJ = tangram.xcodeproj
IOS_XCODE_PROJ = tangram.xcodeproj
IOS_FRAMEWORK_XCODE_PROJ = tangram.xcodeproj

XCPRETTY = $(shell command -v xcpretty 2> /dev/null)

# Default build type is Release
BUILD_TYPE = Release
ifdef DEBUG
	BUILD_TYPE = Debug
endif

BENCH_CMAKE_PARAMS = \
	-DBENCHMARK=1 \
	-DAPPLICATION=0 \
	-DCMAKE_BUILD_TYPE=Release \
	${CMAKE_OPTIONS}

UNIT_TESTS_CMAKE_PARAMS = \
	-DUNIT_TESTS=1 \
	-DAPPLICATION=0 \
	-DCMAKE_BUILD_TYPE=Debug \
	${CMAKE_OPTIONS}

IOS_CMAKE_PARAMS = \
	-DPLATFORM_TARGET=ios \
	-G Xcode \
	${CMAKE_OPTIONS}

DARWIN_XCODE_CMAKE_PARAMS = \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DPLATFORM_TARGET=darwin \
	-DCMAKE_OSX_DEPLOYMENT_TARGET:STRING="10.9" \
	-G Xcode \
	${CMAKE_OPTIONS}

DARWIN_CMAKE_PARAMS = \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DPLATFORM_TARGET=darwin \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE \
	${CMAKE_OPTIONS}

RPI_CMAKE_PARAMS = \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DPLATFORM_TARGET=raspberrypi \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE \
	${CMAKE_OPTIONS}

LINUX_CMAKE_PARAMS = \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DPLATFORM_TARGET=linux \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE \
	${CMAKE_OPTIONS}

ifndef TIZEN_PROFILE
	TIZEN_PROFILE=mobile
endif

ifndef TIZEN_VERSION
	TIZEN_VERSION=3.0
endif

TIZEN_ARM_CMAKE_PARAMS = \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DTIZEN_SDK=$$TIZEN_SDK \
	-DTIZEN_SYSROOT=$$TIZEN_SDK/platforms/tizen-${TIZEN_VERSION}/${TIZEN_PROFILE}/rootstraps/${TIZEN_PROFILE}-${TIZEN_VERSION}-device.core \
	-DTIZEN_DEVICE=1 \
	-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_DIR}/tizen.toolchain.cmake \
	-DPLATFORM_TARGET=tizen \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE \
	${CMAKE_OPTIONS}

TIZEN_X86_CMAKE_PARAMS = \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DTIZEN_SDK=$$TIZEN_SDK \
	-DTIZEN_SYSROOT=$$TIZEN_SDK/platforms/tizen-${TIZEN_VERSION}/${TIZEN_PROFILE}/rootstraps/${TIZEN_PROFILE}-${TIZEN_VERSION}-emulator.core \
	-DTIZEN_DEVICE=0 \
	-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_DIR}/tizen.toolchain.cmake \
	-DPLATFORM_TARGET=tizen \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE \
	${CMAKE_OPTIONS}

clean: clean-android clean-osx clean-ios clean-rpi clean-tests clean-xcode clean-linux clean-shaders \
	clean-tizen-arm clean-tizen-x86

clean-android:
	rm -rf platforms/android/build
	rm -rf platforms/android/tangram/build
	rm -rf platforms/android/tangram/.externalNativeBuild
	rm -rf platforms/android/demo/build

clean-osx:
	rm -rf ${OSX_BUILD_DIR}

clean-ios:
	rm -rf ${IOS_BUILD_DIR}

clean-rpi:
	rm -rf ${RPI_BUILD_DIR}

clean-linux:
	rm -rf ${LINUX_BUILD_DIR}

clean-xcode:
	rm -rf ${OSX_XCODE_BUILD_DIR}

clean-tests:
	rm -rf ${TESTS_BUILD_DIR}

clean-benchmark:
	rm -rf ${BENCH_BUILD_DIR}

clean-shaders:
	rm -rf core/generated/*.h

clean-tizen-arm:
	rm -rf ${TIZEN_ARM_BUILD_DIR}

clean-tizen-x86:
	rm -rf ${TIZEN_X86_BUILD_DIR}

android: android-demo
	@echo "run: 'adb install -r android/demo/build/outputs/apk/demo-debug.apk'"

android-sdk:
	@cd platforms/android/ && \
	./gradlew tangram:assembleRelease

android-demo:
	@cd platforms/android/ && \
	./gradlew demo:assembleDebug

osx: cmake-osx
	cmake --build ${OSX_BUILD_DIR}

cmake-osx:
	@mkdir -p ${OSX_BUILD_DIR}
	@cd ${OSX_BUILD_DIR} && \
	cmake ../.. ${DARWIN_CMAKE_PARAMS}

OSX_BUILD = \
	xcodebuild -target ${OSX_TARGET} -project ${OSX_XCODE_BUILD_DIR}/${OSX_XCODE_PROJ} -configuration ${BUILD_TYPE}

xcode: cmake-xcode
ifeq (, $(shell which xcpretty))
	${OSX_BUILD}
else
	${OSX_BUILD} | ${XCPRETTY}
endif

cmake-xcode:
	@mkdir -p ${OSX_XCODE_BUILD_DIR}
	@cd ${OSX_XCODE_BUILD_DIR} && \
	cmake ../.. ${DARWIN_XCODE_CMAKE_PARAMS}

IOS_BUILD = xcodebuild -workspace platforms/ios/Tangram.xcworkspace -scheme TangramDemo -configuration ${BUILD_TYPE}

ios: cmake-ios
ifeq (, $(shell which xcpretty))
	${IOS_BUILD}
else
	${IOS_BUILD} | ${XCPRETTY}
endif

ios-docs:
ifeq (, $(shell which jazzy))
	$(error "Please install jazzy by running 'gem install jazzy'")
endif
	@mkdir -p ${IOS_DOCS_BUILD_DIR}
	@cd platforms/ios && \
	jazzy --config jazzy.yml

cmake-ios:
	@mkdir -p ${IOS_BUILD_DIR}
	@cd ${IOS_BUILD_DIR} && \
	cmake ../.. ${IOS_CMAKE_PARAMS}
	cp platforms/ios/WorkspaceSettings.xcsettings platforms/ios/Tangram.xcworkspace/xcuserdata/${USER}.xcuserdatad/WorkspaceSettings.xcsettings

IOS_FRAMEWORK_BUILD = xcodebuild -workspace platforms/ios/Tangram.xcworkspace -scheme TangramMap -configuration ${BUILD_TYPE}

ios-framework: cmake-ios
ifeq (, $(shell which xcpretty))
	${IOS_FRAMEWORK_BUILD}
else
	set -euo pipefail; ${IOS_FRAMEWORK_BUILD} | ${XCPRETTY}
endif

IOS_FRAMEWORK_SIM_BUILD = xcodebuild -workspace platforms/ios/Tangram.xcworkspace -scheme TangramMap -configuration ${BUILD_TYPE} -sdk iphonesimulator

ios-framework-sim: cmake-ios
ifeq (, $(shell which xcpretty))
	${IOS_FRAMEWORK_SIM_BUILD}
else
	set -euo pipefail; ${IOS_FRAMEWORK_SIM_BUILD} | ${XCPRETTY}
endif

ios-framework-universal: ios-framework ios-framework-sim
	@mkdir -p ${IOS_BUILD_DIR}/${BUILD_TYPE}-universal
	@cp -r ${IOS_BUILD_DIR}/${BUILD_TYPE}-iphoneos/TangramMap.framework ${IOS_BUILD_DIR}/${BUILD_TYPE}-universal
	lipo ${IOS_BUILD_DIR}/${BUILD_TYPE}-iphoneos/TangramMap.framework/TangramMap \
		${IOS_BUILD_DIR}/${BUILD_TYPE}-iphonesimulator/TangramMap.framework/TangramMap \
		-create -output ${IOS_BUILD_DIR}/${BUILD_TYPE}-universal/TangramMap.framework/TangramMap

rpi: cmake-rpi
	cmake --build ${RPI_BUILD_DIR}

cmake-rpi:
	@mkdir -p ${RPI_BUILD_DIR}
	@cd ${RPI_BUILD_DIR} && \
	cmake ../.. ${RPI_CMAKE_PARAMS}

linux: cmake-linux
	cmake --build ${LINUX_BUILD_DIR}

cmake-linux:
	@mkdir -p ${LINUX_BUILD_DIR}
	@cd ${LINUX_BUILD_DIR} && \
	cmake ../.. ${LINUX_CMAKE_PARAMS}

tizen-arm: cmake-tizen-arm
	cmake --build ${TIZEN_ARM_BUILD_DIR}

cmake-tizen-arm:
	@mkdir -p ${TIZEN_ARM_BUILD_DIR}
	@cd ${TIZEN_ARM_BUILD_DIR} && \
	cmake ../.. ${TIZEN_ARM_CMAKE_PARAMS}

tizen-x86: cmake-tizen-x86
	cmake --build ${TIZEN_X86_BUILD_DIR}

cmake-tizen-x86:
	mkdir -p ${TIZEN_X86_BUILD_DIR}
	cd ${TIZEN_X86_BUILD_DIR} && \
	cmake ../.. ${TIZEN_X86_CMAKE_PARAMS}

tests: unit-tests

unit-tests:
	@mkdir -p ${TESTS_BUILD_DIR}
	@cd ${TESTS_BUILD_DIR} && \
	cmake ../.. ${UNIT_TESTS_CMAKE_PARAMS} && \
	cmake --build .

benchmark:
	@mkdir -p ${BENCH_BUILD_DIR}
	@cd ${BENCH_BUILD_DIR} && \
	cmake ../.. ${BENCH_CMAKE_PARAMS} && \
	cmake --build .

format:
	@for file in `git diff --diff-filter=ACMRTUXB --name-only -- '*.cpp' '*.h'`; do \
		if [[ -e $$file ]]; then clang-format -i $$file; fi \
	done
	@echo "format done on `git diff --diff-filter=ACMRTUXB --name-only -- '*.cpp' '*.h'`"

### Android Helpers
android-install:
	@adb install -r platforms/android/demo/build/outputs/apk/demo-debug.apk
