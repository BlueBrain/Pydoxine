# Copyright (c) 2016, EPFL/Blue Brain Project
#                     Juan Hernando <jhernando@fi.upm.es>
#
# This file is part of Pydoxine <https://github.com/BlueBrain/Pydoxine>
#
# This library is free software; you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License version 3.0 as published
# by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# This script provides the function docstrings() to generate strings to be
# used as docstrings in Boost.Python.
#
# The function takes three input variables:
#  - DOCSTRINGS_INCLUDE_PATH: include path to project headers
#  - BOOST_PYTHON_SOURCES: the list of wrapping sources. Relative paths are
#    assumed wrt be CMAKE_CURRENT_SOURCE_DIR.
#  - CPP_HEADERS: the list of  C++ headers of the wrapped API. Relative paths
#    are assumed wrt be 'CMAKE_CURRENT_SOURCE_DIR/..'.
#
# The following global variables can control the behaviour of docstrings
#  - DOCSTRINGS_PREDEFINED_MACROS: A string to be appended to the PREDEFINED
#    parameter of the doxygen configuration.
#
# The user relevant output of this function is two C++ files and a CMake target.
# The files are:
#  - ${PROJECT_BINARY_DIR}/docstrings/cpp/docstrings.h, to be included in the
#    wrapping sources, provides the macros DOXY_CLASS, DOXY_FN and DOXY_ENUM to
#    be used in the wrapping functions.
#  - ${PROJECT_BINARY_DIR}/docstrings/cpp/docstrings.cpp and needs to be
#    included as part of the source files of the wrapping library.
#
# The CMake target is called ${PROJECT_NAME}-docstrings and is should be added
# as a dependency as the wrapping library target.

if(NOT DOXYGEN_FOUND)
  find_package(Doxygen)
endif()
if(NOT SPHINX_FOUND)
  find_package(Sphinx 1.3)
endif()

if(DOXYGEN_FOUND AND SPHINX_FOUND)
  add_definitions(-D${PROJECT_NAME}_USE_SPHINX -D${PROJECT_NAME}_USE_DOXYGEN)
endif()

# This must stay declared at the file level. It can't be inside the function
# because the macro expansion of CMAKE_CURRENT_LIST_FILE will point to the
# wrong directory.
get_filename_component(_docstrings_path ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
set(_docstrings_path ${_docstrings_path}/..)

function(DOCSTRINGS BOOST_PYTHON_SOURCES CPP_HEADERS DOCSTRINGS_INCLUDE_PATH)
  set(_doxygen_config_input_files)

  set(_docstrings_wrapping_sources)
  foreach(_source ${${BOOST_PYTHON_SOURCES}})
    if(IS_ABSOLUTE ${_source})
      list(APPEND _docstrings_wrapping_sources ${_source})
    else()
      list(APPEND _docstrings_wrapping_sources
        ${CMAKE_CURRENT_SOURCE_DIR}/${_source})
    endif()
  endforeach()

  set(_docstrings_wrapped_headers)
  foreach(HEADER ${${CPP_HEADERS}})
    if(IS_ABSOLUTE ${HEADER})
      list(APPEND _docstrings_wrapped_headers ${HEADER})
    else()
      set(HEADER ${CMAKE_CURRENT_SOURCE_DIR}/../${HEADER})
      list(APPEND _docstrings_wrapped_headers ${HEADER})
    endif()
    set(_doxygen_config_input_files "${_doxygen_config_input_files} ${HEADER}")
  endforeach()

  configure_file(${_docstrings_path}/docstrings/wrapping.cfg.in
                 ${PROJECT_BINARY_DIR}/docstrings/wrapping.cfg)

  configure_file(${_docstrings_path}/docstrings/sphinx_conf.py.in
                 ${PROJECT_BINARY_DIR}/docstrings/conf.py)

  configure_file(${_docstrings_path}/docstrings/build.py.in
                 ${PROJECT_BINARY_DIR}/docstrings/build.py)

  configure_file(${_docstrings_path}/docstrings/cpp/docstrings.h.in
                 ${PROJECT_BINARY_DIR}/docstrings/cpp/docstrings.h)

  configure_file(${_docstrings_path}/docstrings/cpp/docstrings.cpp.in
                 ${PROJECT_BINARY_DIR}/docstrings/cpp/docstrings.cpp)

  if(NOT DOXYGEN_FOUND OR NOT SPHINX_FOUND)
    return()
  endif()

  add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/docstrings/xml/index.xml
    COMMAND ${DOXYGEN_EXECUTABLE} wrapping.cfg
    DEPENDS ${_docstrings_path}/docstrings/wrapping.cfg.in
            ${_docstrings_wrapped_headers}
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/docstrings)

  add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/docstrings/cpp/init_docstrings.cpp
    COMMAND ${PYTHON_EXECUTABLE} ${PROJECT_BINARY_DIR}/docstrings/build.py
      ${PROJECT_BINARY_DIR}/docstrings/xml ${_docstrings_wrapping_sources}
    COMMAND ${SPHINX_EXECUTABLE} -q -b docstrings
      ${PROJECT_BINARY_DIR}/docstrings ${PROJECT_BINARY_DIR}/docstrings/cpp
    DEPENDS ${PROJECT_BINARY_DIR}/docstrings/xml/index.xml
            ${_docstrings_path}/docstrings/sphinx_conf.py.in
            ${_docstrings_path}/docstrings/build.py.in
            ${_docstrings_wrapping_sources}
            ${_docstrings_wrapped_headers}
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/docstrings/cpp)

  add_custom_target(${PROJECT_NAME}-docstrings
    DEPENDS ${PROJECT_BINARY_DIR}/docstrings/cpp/init_docstrings.cpp)
endfunction(DOCSTRINGS)
