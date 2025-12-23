
cmake_minimum_required(VERSION 3.10)
project(bartrix-sim)

# Export compile commands for tooling
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# --- Static Assets Setup ---
include(../cmake/Assets.cmake)
set(ASSET_NAMESPACE "bart::assets")
set(ASSET_INCLUDE_PREFIX "bart/assets")
asset_textAsset("../bart_gtfs_data/stops.txt")

add_library(BartGtfsAssets STATIC ${ASSET_HEADERS} ${ASSET_SOURCES})
target_include_directories(BartGtfsAssets PUBLIC ${ASSET_INCLUDE_DIRS})

# --- Source and Header Files ---
set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
file(GLOB_RECURSE PROJECT_SOURCES
	"${SRC_DIR}/*.cpp"
	"${SRC_DIR}/*.c"
	"${SRC_DIR}/*.cc"
)
file(GLOB_RECURSE PROJECT_HEADERS
	"${INCLUDE_DIR}/*.h"
	"${INCLUDE_DIR}/*.hpp"
)

# --- Executable Setup ---
add_executable(bartrix-sim ${PROJECT_SOURCES} ${PROJECT_HEADERS})
target_include_directories(bartrix-sim PRIVATE ${INCLUDE_DIR})
target_link_libraries(bartrix-sim PRIVATE BartGtfsAssets)

# --- External Libraries ---
find_package(CURL REQUIRED)
target_link_libraries(bartrix-sim PRIVATE CURL::libcurl)

# --- Protobuf Setup ---
find_package(Protobuf REQUIRED)
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ../gtfs-realtime.proto)
target_sources(bartrix-sim PRIVATE ${PROTO_SRCS} ${PROTO_HDRS})
# Make sure the generated protobuf headers in the build directory are discoverable
target_include_directories(bartrix-sim PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_include_directories(bartrix-sim PRIVATE ${Protobuf_INCLUDE_DIRS})
target_link_libraries(bartrix-sim PRIVATE ${Protobuf_LIBRARIES})
