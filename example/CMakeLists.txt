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

cmake_minimum_required(VERSION 3.1 FATAL_ERROR)

project(PydoxineExample VERSION 1.0.0)
set(PydoxineExample_VERSION_ABI 1)

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
