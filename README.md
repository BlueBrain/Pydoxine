# Introduction

Pydoxine is an isomer of Pyridoxine, vitamin B6, that allows you to put some
vitamins in your Boost.Python wrappings.

Pydoxine doesn't come in pellets, but is a collection of Python and CMake
scripts that solves the problem of resusing the doxygen documentation of
C++ headers to use it as docstrings in the wrapping. The main idea is to use
the xml output from doxygen to transform it into text strings that can be plugged
in the wrapping definitions. This transformation is carried out by a tweaked
version of [breathe](https://github.com/michaeljones/breathe), an extension for
the documentation system Sphinx.

From a user point of view the key feature provided by this project is a CMake
function with all the logic required to generate the C++ files to be used
to provide docstrings inside your Boost.Python code.

# Dependencies

CMake >= 3
python-docutils
sphinx >= 1.3

The modified version of breathe is shipped as part of these sources.

# Instructions

The following guide provides the instructions to integrate and use Pydoxine
inside an existint project. This guide assumes the reader is familiar with
CMake and git.

## Code base integration

To use Pydoxine, first you have to integrate in the code base of you project.
The instruction to do it using git submodules follow:

 1. From the repository tree:

        $ git submodule add https://github.com/BlueBrain/Pydoxine docstrings

    Here we have choosen docstrings as the target directory, but feel free to
    change it to whatever suits your needs.

 2. And then commit the addition of the submodule. If you index was clean you
    can simply do:
 commit -am "Addition of Pydoxine git module"

## CMake modifications

Assuming you have imported Pydoxine under ${PROJECT_SOURCE_DIR}/docstrings,
the code that you need to add to your CMake scripts is this:

    list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/docstrings/CMake)
    include(PythonDocstrings)

    docstrings(WRAPPING_SOURCES WRAPPED_HEADERS)

where `WRAPPED_SOURCES' is a CMake variable with a list of Boost.Python C++
sources and `WRAPPED_HEADERS' is another one with the header source files for the
doxygen documentation. One limitation of the current implementation is that the
header and source file lists must use absolute paths.

The macro `docstrings' will parse the Boost.Python sources and produce a file
called init_docstrings.cpp in ${PROJECT_BINARY_DIR}/docstrings/cpp. This file
is included from ${PROJECT_BINARY_DIR}/docstrings/cpp/docstrings.cpp.

The CMake target that builds your Python module must include
docstrings/cpp/docstrings.cpp as a source file and it must be made depend
on ${PROJECT_NAME}-docstrings (a target created by the macro docstrings):

    add_dependencies(your_target ${PROJECT_NAME}-docstrings)

## Boost.Python sources modifications

In your Boost.Python sources you have to include the header file
${PROJECT_BINARY_DIR}/docstrings/cpp/docstrings.h.

This header defines the macros DOXY_CLASS, DOXY_ENUM and DOXY_FN. These macros
generate the code that obtains the C-style string to be used as docstring
for the wrapping. The argument taken is always the fully qualified name of the
object to be documented. For overloaded functions you can choose a particular
overload including the function signature. If no signature is provided, the
docstring will contain the documentation of all the overloads (and the output
text won't be rendered correctly inside the Python console).

For optimal results include this line at the beginning of the module:
  boost::python::docstring_options doc_options(true, true, false);

# Example

The directory called example contains a full project showing how all the pieces
fit together.

# Funding & Acknowledgment
 
The development of this software was supported by funding to the Blue Brain Project,
a research center of the École polytechnique fédérale de Lausanne (EPFL), from the
Swiss government’s ETH Board of the Swiss Federal Institutes of Technology.

This project has received funding from the European Union's Horizon 2020 Framework
Programme for Research and Innovation under the Specific Grant Agreement No. 720270
(Human Brain Project SGA1).

This project is based upon work supported by the King Abdullah University of Science and
Technology (KAUST) Office of Sponsored Research (OSR) under Award No. OSR-2017-CRG6-3438.

# License

Pydoxine is licensed under the LGPL, unless noted otherwise, e.g., for external dependencies.
See file LICENSE.txt for the full license.

Copyright (c) 2021 Blue Brain Project/EPFL and contributors.

This project is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License version 3 as published by the Free Software Foundation.

This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this
library; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
Boston, MA 02110-1301 USA
 
