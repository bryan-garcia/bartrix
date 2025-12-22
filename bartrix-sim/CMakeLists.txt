cmake_minimum_required(VERSION 3.10)
project(bartrix-sim)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# setting up static assets
include(../cmake/Assets.cmake)
set(ASSET_NAMESPACE "bart::assets")
set(ASSET_INCLUDE_PREFIX "bart/assets")

asset_textAsset("../bart_gtfs_data/stops.txt")

add_library(BartGtfsAssets STATIC ${ASSET_HEADERS} ${ASSET_SOURCES})
target_include_directories(BartGtfsAssets PUBLIC ${ASSET_INCLUDE_DIRS})

set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")

file(GLOB_RECURSE PROJECT_SOURCES "${SRC_DIR}/*.cpp" "${SRC_DIR}/*.c")
file(GLOB_RECURSE PROJECT_HEADERS "${INCLUDE_DIR}/*.h" "${INCLUDE_DIR}/*.hpp")

add_executable(bartrix-sim ${PROJECT_SOURCES} ${PROJECT_HEADERS})
target_include_directories(bartrix-sim PRIVATE ${INCLUDE_DIR})
target_link_libraries(bartrix-sim PRIVATE BartGtfsAssets)
