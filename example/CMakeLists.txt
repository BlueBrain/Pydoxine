cmake_minimum_required(VERSION 3.1 FATAL_ERROR)

project(PyxygenExample VERSION 1.0.0)
set(PyxygenExample_VERSION_ABI 1)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/CMake
                              ${CMAKE_SOURCE_DIR}/CMake/common)
include(GitExternal)
include(Common)

common_find_package(Boost 1.54.0 REQUIRED
                    COMPONENTS python${USE_BOOST_PYTHON_VERSION})
common_find_package(PythonInterp REQUIRED)
common_find_package(PythonLibs REQUIRED)
common_find_package_post()

add_subdirectory(python)
