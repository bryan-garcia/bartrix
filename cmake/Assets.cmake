# #############################################################################
# MIT License
#
# Copyright (c) 2022 Michał Jaroń <m.jaron@protonmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# #############################################################################
# CMake assets - content of file accessible from C++ constant variable.
# @author Michał Jaroń <m.jaron@protonmail.com>
#
# E.g:
#
#     set (ASSET_NAMESPACE "my::cpp::name_space")
#     set (ASSET_INCLUDE_PREFIX "my/cpp/assets")
#     asset_textAsset("my_dir/my_asset.txt")
#
# Above example will generate header and source files
# with a c-string literal accessible under given namespace:
#
#     namespace my{ namespace cpp { namespace name_space {
#         constexpr const char* const my_asset = "...<file_content>...";
#     } } }
#
# Usses global variables:
#     * ASSET_NAMESPACE      A c++ namespace or not set (or empty) string. E.g: `my::name_space`.
#     * ASSET_INCLUDE_PREFIX A relative directory where all generated include files will be stored
#                            and visible when #include <my/assets/prefix/path>
#                            Default value: "assets".
#
# Following variables will be set:
#     * ASSET_HEADERS      <list> Each invocation of this function adds header (.h) to this list (header with full file path).
#     * ASSET_SOURCES      <list> Each invocation of this function adds source (.cpp) to this list (source with full file path).
#     * ASSET_INCLUDE_DIRS <string> Sets directory where generated headers are stored.
#
#


cmake_minimum_required(VERSION 3.16)

set(ASSET_DEBUG OFF CACHE BOOL "Display more messages when preparing assets.")
set(ASSET_TEMPLATES_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE PATH "Where to look for templates.")

function (asset_debugMessage what)
    if (ASSET_DEBUG)
        message("D| ${what}")
    endif()
endfunction()


# Escapes string to c-string literal value.
# E.g:
#     asset_convertToCStringLiteral(ESCAPED_VAR "${STRING_TO_ESCAPE}")
function(asset_convertToCStringLiteral var value)
    set(escaped "${value}")
    string(REGEX REPLACE "\\\\" "\\\\\\\\" escaped "${escaped}")  # replacing \ to \\
    string(REGEX REPLACE "\"" "\\\\\"" escaped "${escaped}")      # replacing " to \"
    string(REGEX REPLACE "\n" "\\\\n\"\n\"" escaped "${escaped}") # replacing new lines to \n character.
    set("${var}" "\"${escaped}\"" PARENT_SCOPE)
endfunction()

# Parses c++ @param namespace and produces some useful variables to fill asset template.
#
# Params:
#     * namespace A c++ namespace or empty string, e.g: `my::namespace`
# Sets global variables:
#     * ASSET_NAMESPACE_BEGIN Contains namespaces and opening braces, e.g: `my { namespace {`.
#     * ASSET_NAMESPACE_END   Contains proper count of closing namespace braces, e.g: `}}`.
function (asset_resolveNamespace namespace)
    string(REGEX MATCHALL "[a-zA-Z0-9_]+" NAMESPACE_PARTS "${namespace}")
    asset_debugMessage( "NAMESPACE_PARTS: ${NAMESPACE_PARTS}")
    set (ASSET_NAMESPACE_BEGIN "")
    set (ASSET_NAMESPACE_END "")
    foreach(ENTRY ${NAMESPACE_PARTS})
        asset_debugMessage(${ENTRY})
        set (ASSET_NAMESPACE_BEGIN "${ASSET_NAMESPACE_BEGIN}namespace ${ENTRY} {\n")
        set (ASSET_NAMESPACE_END "} // !namespace ${ENTRY}\n${ASSET_NAMESPACE_END}")
    endforeach()
    set(ASSET_NAMESPACE_BEGIN "${ASSET_NAMESPACE_BEGIN}" PARENT_SCOPE)
    set(ASSET_NAMESPACE_END   "${ASSET_NAMESPACE_END}"   PARENT_SCOPE)
endfunction()

# Determines how to name asset variable in generated sources.
#
# Sets global variables:
#     * ASSET_VARIABLE <string> Contains name of variable in generated sources.
function (asset_resolveVariableName assetName)
    string(REGEX REPLACE "-" "_" ASSET_VARIABLE "${assetName}")  # replacing - to _
    set(ASSET_VARIABLE "${ASSET_VARIABLE}" PARENT_SCOPE)
endfunction()

# Create a text asset header and source files.
# E.g:
#
#     set (ASSET_NAMESPACE "my::cpp::name_space")
#     set (ASSET_INCLUDE_PREFIX "my/cpp/assets")
#     asset_textAsset("my_dir/my_asset.txt")
#         it will create header and source files with variable named "my_asset".
#
# Usses global variables:
#     * ASSET_NAMESPACE A c++ namespace or not set (or empty) string. E.g: `my::name_space`.
#     * ASSET_INCLUDE_PREFIX A relative directory where all generated include files will be stored
#                            and visible when #include <my/assets/prefix/path>
#                            Default value: "assets".
#
# Sets variables:
#     * ASSET_HEADERS      <list> Each invocation of this function adds header (.h) to this list (header with full file path).
#     * ASSET_SOURCES      <list> Each invocation of this function adds source (.cpp) to this list (source with full file path).
#     * ASSET_INCLUDE_DIRS <string> Sets directory where generated headers are stored.
#
function(asset_textAsset path)
    asset_debugMessage("======= ======= ======= =======")
    asset_debugMessage("Preparing asset resource:")
    get_filename_component(ASSET_PATH "${path}" ABSOLUTE)
    asset_debugMessage("ASSET_PATH:           ${ASSET_PATH}")
    get_filename_component(ASSET_FILENAME "${path}" NAME)
    string(REGEX REPLACE "\\." "_" ASSET_NAME "${ASSET_FILENAME}") # Asset name is filename with _ instead of .
    asset_debugMessage("ASSET_NAME:           ${ASSET_NAME}")
    get_filename_component(ASSET_EXT  "${ASSET_PATH}" LAST_EXT) # Asset filename extension with a leading dot.
    string(REGEX REPLACE "\\." "" ASSET_EXT "${ASSET_EXT}")     # Asset filename shortest extension without a leading dot.
    asset_debugMessage("ASSET_EXT:            ${ASSET_EXT}")

    if ("${ASSET_INCLUDE_PREFIX}" STREQUAL "")
        set(ASSET_INCLUDE_PREFIX "assets")
    endif()
    asset_debugMessage("ASSET_INCLUDE_PREFIX: ${ASSET_INCLUDE_PREFIX}")

    asset_convertToCStringLiteral(ASSET_ESCAPED_FILENAME "${ASSET_FILENAME}")
    asset_convertToCStringLiteral(ASSET_ESCAPED_EXT "${ASSET_EXT}")
    asset_convertToCStringLiteral(ASSET_ESCAPED_NAME "${ASSET_NAME}")

    file (READ "${ASSET_PATH}" ASSET_RAW_STR)
    asset_convertToCStringLiteral(ASSET_ESCAPED_STR "${ASSET_RAW_STR}")
    string(LENGTH "${ASSET_RAW_STR}" ASSET_RAW_STR_LEN)
    set(ASSET_GENERATE_DIR "${CMAKE_CURRENT_BINARY_DIR}/Asset")
    set(ASSET_GENERATE_INC_BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}/Asset/inc")
    set(ASSET_GENERATE_INC_DIR "${ASSET_GENERATE_INC_BASE_DIR}/${ASSET_INCLUDE_PREFIX}")
    string(LENGTH "${ASSET_RAW_STR}" ASSET_SIZE)

    asset_resolveNamespace("${ASSET_NAMESPACE}") # -> ASSET_NAMESPACE_BEGIN, ASSET_NAMESPACE_END
    asset_resolveVariableName("${ASSET_NAME}")   # -> ASSET_VARIABLE

    # Asset template files configuration.
    set(ASSET_TEMPLATE_HEADER "${ASSET_TEMPLATES_DIR}/TextAssetTemplate.h.in")
    set(ASSET_TEMPLATE_SOURCE "${ASSET_TEMPLATES_DIR}/TextAssetTemplate.cpp.in")
    # Starting from CMAKE 3.18 it is possible to configure file.
#    set(ASSET_TEMPLATE_HEADER "${ASSET_GENERATE_DIR}/TextAssetTemplate.h.in")
#    set(ASSET_TEMPLATE_SOURCE "${ASSET_GENERATE_DIR}/TextAssetTemplate.cpp.in")
#    if (NOT EXISTS "${ASSET_TEMPLATE_HEADER}")
#        file(WRITE OUTPUT "${ASSET_TEMPLATE_HEADER}" CONTENT "${ASSET_TEMPLATE_HEADER_CONTENT}")
#    endif()
#    if (NOT EXISTS "${ASSET_TEMPLATE_SOURCE}")
#        file(WRITE OUTPUT "${ASSET_TEMPLATE_SOURCE}" CONTENT "${ASSET_TEMPLATE_SOURCE_CONTENT}")
#    endif()
    asset_debugMessage("ASSET_TEMPLATE_HEADER: ${ASSET_TEMPLATE_HEADER}")
    asset_debugMessage("ASSET_TEMPLATE_SOURCE: ${ASSET_TEMPLATE_SOURCE}")

    # Assert template generation destination configuration.
    set(ASSET_HEADER "${ASSET_GENERATE_INC_DIR}/${ASSET_NAME}.h")
    set(ASSET_SOURCE "${ASSET_GENERATE_DIR}/${ASSET_NAME}.cpp")
    asset_debugMessage("ASSET_HEADER: ${ASSET_HEADER}")
    asset_debugMessage("ASSET_SOURCE: ${ASSET_SOURCE}")

    message("Asset: ${ASSET_PATH}, destination: ${ASSET_GENERATE_DIR}")

    configure_file("${ASSET_TEMPLATE_HEADER}" "${ASSET_HEADER}")
    configure_file("${ASSET_TEMPLATE_SOURCE}" "${ASSET_SOURCE}")

    list(APPEND ASSET_HEADERS "${ASSET_HEADER}")
    list(APPEND ASSET_SOURCES "${ASSET_SOURCE}")
    set(ASSET_HEADERS "${ASSET_HEADERS}" PARENT_SCOPE)
    set(ASSET_SOURCES "${ASSET_SOURCES}" PARENT_SCOPE)
    set(ASSET_INCLUDE_DIRS "${ASSET_GENERATE_INC_BASE_DIR}" PARENT_SCOPE)
endfunction()

