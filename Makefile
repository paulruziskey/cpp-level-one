# Defines a newline.
define n


endef

PROJECT_NAME := $(strip $(PROJECT_NAME))
PROJECT_PATH := $(strip $(PROJECT_PATH))
PROJECT_DIR := $(if $(PROJECT_PATH),$(PROJECT_PATH)/)$(PROJECT_NAME)
SRC_DIR := $(PROJECT_DIR)/src
INCLUDE_DIR := $(PROJECT_DIR)/include
DOCS_DIR := $(PROJECT_DIR)/docs
CMAKE_DIR := $(PROJECT_DIR)/cmake
TESTS_DIR := $(PROJECT_DIR)/tests

define MAIN_CPP_CONTENT
#include <cstdlib>

int main() {
    return EXIT_SUCCESS;
}
endef

MATCHES_SEM_VER_NUM := ^[0-9]+[.][0-9]+[.][0-9]+$
MATCHES_SEM_VER_NUM_WITHOUT_MINOR_VER_NUM := ^[0-9]+[.][0-9]+$
MATCHES_MINOR_VER_NUM := [.][0-9]+$
CMAKE_VERSION := $(strip $(CMAKE_VERSION))
ifneq ($(CMAKE_VERSION),)
	MANUAL_CMAKE_VERSION := true
	VALID := $(shell if [[ '$(CMAKE_VERSION)' =~ $(MATCHES_SEM_VER_NUM) ]] || [[ '$(CMAKE_VERSION)' =~ $(MATCHES_SEM_VER_NUM_WITHOUT_MINOR_VER_NUM) ]]; then echo 'valid'; fi)
else
	CMAKE_VERSION := $(strip $(foreach word,$(shell cmake --version),$(shell if [[ '$(word)' =~ $(MATCHES_SEM_VER_NUM) ]]; then echo '$(word)'; fi)))
	VALID := $(if $(CMAKE_VERSION),valid)
endif
CMAKE_VERSION := $(shell echo '$(CMAKE_VERSION)' | sed -E 's/$(MATCHES_MINOR_VER_NUM)//')
DESCRIPTION := $(strip $(DESCRIPTION))
define GLOBAL_CMAKE_CONTENT
cmake_minimum_required(VERSION $(CMAKE_VERSION) FATAL_ERROR)

project($(PROJECT_NAME)
    VERSION 0.1.0
    DESCRIPTION "$(DESCRIPTION)"
    LANGUAGES CXX
)
message(STATUS "Creating project `$${CMAKE_PROJECT_NAME}`")

set(CMAKE_CXX_FLAGS "$${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic -Werror")

set(INCLUDE_DIR "$${CMAKE_SOURCE_DIR}/include/$${CMAKE_PROJECT_NAME}")
set(CMAKE_INCLUDE_PATH $${INCLUDE_DIR} $${CMAKE_INCLUDE_PATH})
set(SRC_DIR "$${CMAKE_SOURCE_DIR}/src")
endef
ifdef CPM
	CPM_SET_MANUALLY := true
	GLOBAL_CMAKE_CONTENT := $(GLOBAL_CMAKE_CONTENT)$n$ninclude(cmake/CPM.cmake)$n$n
endif
GLOBAL_CMAKE_CONTENT := $(GLOBAL_CMAKE_CONTENT)$n$nadd_subdirectory(src)
ifdef TESTING
	TESTS_SET_MANUALLY := true
	GLOBAL_CMAKE_CONTENT := $(GLOBAL_CMAKE_CONTENT)$nadd_subdirectory(tests)
endif

ifndef TARGET_NAME
	TARGET_NAME := main
else
	MANUAL_TARGET_NAME := true
endif
ifndef STD
	STD := 23
else
	MANUAL_STD := true
endif
TARGET_NAME := $(strip $(TARGET_NAME))
STD := $(strip $(STD))
define SRC_CMAKE_CONTENT
set(MAIN_TARGET_NAME $(TARGET_NAME))

message(STATUS "Creating `$${MAIN_TARGET_NAME}`")
add_executable($${MAIN_TARGET_NAME} main.cpp)

message(STATUS "Configuring `$${MAIN_TARGET_NAME}`")
target_compile_features($${MAIN_TARGET_NAME} PUBLIC cxx_std_$(STD))
target_include_directories($${MAIN_TARGET_NAME} PRIVATE
    $$<BUILD_INTERFACE:$${INCLUDE_DIR}>
    $$<INSTALL_INTERFACE:include/$${CMAKE_PROJECT_NAME}>
)

message(STATUS "Adding headers to `$${MAIN_TARGET_NAME}`")
file(GLOB header_files $${INCLUDE_DIR}/*.hpp)
target_sources($${MAIN_TARGET_NAME} PUBLIC
    FILE_SET header_set TYPE HEADERS
    BASE_DIRS $${INCLUDE_DIR}
    FILES $${header_files}
)

message(STATUS "Adding sources to `$${MAIN_TARGET_NAME}`")
file(GLOB source_files $${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
list(FILTER source_files EXCLUDE REGEX main.cpp)
target_sources($${MAIN_TARGET_NAME} PRIVATE $${source_files})

set(MAIN_TARGET_NAME $${MAIN_TARGET_NAME} PARENT_SCOPE)
endef
define TESTS_CMAKE_CONTENT
message(STATUS "Getting all test files")
file(GLOB test_sources $${CMAKE_CURRENT_SOURCE_DIR}/test_*.cpp)
if(NOT test_sources)
    message("Add all tests to the `tests` directory with the prefix `test_`")
    return()
endif()
message(STATUS "Creating `test`")
add_executable(test $${test_sources})

message(STATUS "Configuring `test`")
get_target_property(MAIN_TARGET_COMPILE_FEATURES $${MAIN_TARGET_NAME} COMPILE_FEATURES)
target_compile_features(test PRIVATE $${MAIN_TARGET_COMPILE_FEATURES})
target_include_directories(test PRIVATE $${INCLUDE_DIR})

message(STATUS "Adding headers to `test`")
file(GLOB header_files $${INCLUDE_DIR}/*.hpp)
target_sources($${MAIN_TARGET_NAME} PUBLIC
    FILE_SET header_set TYPE HEADERS
    BASE_DIRS $${INCLUDE_DIR}
    FILES $${header_files}
)

message(STATUS "Adding sources to `test`")
file(GLOB source_files $${SRC_DIR}/*.cpp)
list(FILTER source_files EXCLUDE REGEX main.cpp)
target_sources(test PRIVATE $${source_files})

enable_testing()
endef

.PHONY: all
all: validate project src include docs $(if $(CPM),cmake) $(if $(TESTING),tests)

.PHONY: validate
validate:
	$(if $(PROJECT_NAME),,$(error No project name specified.$nUse PROJECT_NAME to specify project name.))
	$(if $(VALID),,$(if $(MANUAL_CMAKE_VERSION),\
		$(error Invalid CMake version number given.$nVersion should be written using semantic versioning.),\
		$(error Unable to automatically determine CMake version.$nSpecify manually using the CMAKE_VERSION argument.)\
	))

.PHONY: project
project: validate
	$(info creating project directory)
	$(shell mkdir -p $(PROJECT_DIR))
	$(info creating global CMakeLists.txt)
	$(file > $(PROJECT_DIR)/CMakeLists.txt,$(GLOBAL_CMAKE_CONTENT))
	$(info creating README.md)
	$(file > $(PROJECT_DIR)/README.md)

.PHONY: src
src: project
	$(info creating source directory)
	$(shell mkdir $(SRC_DIR))
	$(info creating main.cpp)
	$(file > $(SRC_DIR)/main.cpp,$(MAIN_CPP_CONTENT))
	$(info creating local CMakeLists.txt)
	$(file > $(SRC_DIR)/CMakeLists.txt,$(SRC_CMAKE_CONTENT))

.PHONY: include
include: project
	mkdir $(INCLUDE_DIR)
	mkdir $(INCLUDE_DIR)/$(PROJECT_NAME)

.PHONY: docs
docs: project
	mkdir $(DOCS_DIR)

.PHONY: cmake
cmake: project src
	mkdir $(CMAKE_DIR)
	wget -O $(CMAKE_DIR)/CPM.cmake https://github.com/cpm-cmake/CPM.cmake/releases/latest/download/get_cpm.cmake

.PHONY: tests
tests: project src
	$(info creating testing directory)
	$(shell mkdir $(TESTS_DIR))
	$(info creating local CMakeLists.txt)
	$(file > $(TESTS_DIR)/CMakeLists.txt,$(TESTS_CMAKE_CONTENT))

.PHONY: clean
clean:
	$(if $(PROJECT_NAME),,$(error No project name specified.$nUse PROJECT_NAME to specify project name.))
	$(if $(CPM_SET_MANUALLY),$(warning CPM set, but it won't be used.))
	$(if $(TESTING_SET_MANUALLY),$(warning TESTING set, but it won't be used.))
	$(if $(MANUAL_CMAKE_VERSION),$(warning CMAKE_VERSION provided, but it won't be used.))
	$(if $(DESCRIPTION),$(warning DESCRIPTION provided, but it won't be used.),)
	$(if $(MANUAL_TARGET_NAME),$(warning TARGET_NAME provided, but it won't be used.))
	$(if $(MANUAL_STD),$(warning STD provided, but it won't be used.))
	rm -rf $(PROJECT_DIR)

.PHONY: help
help:
	$(info \
		$nPROJECT_NAME (required): project name\
		$nPROJECT_PATH: path to project (defaults to empty)\
		$nCPM: if set, CPM support will be added to the project (defaults to unset)\
		$nTESTING: if set, `tests` directory will be added to the project (defaults to unset)\
		$nCMAKE_VERSION: manually specify CMake version$(if $(MANUAL_CMAKE_VERSION),, (defaults to `$(CMAKE_VERSION)`))\
		$nDESCRIPTION: CMake description for the project (defaults to empty)\
		$nTARGET_NAME: CMake target name (defaults to `main`)\
		$nSTD: CMake C++ version (defaults to `23`)$n\
	)