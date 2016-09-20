# Description

This project solves the problem of resusing the doxygen documentation of
C++ headers for Boost Python wrappings. The main idea is to use the xml
output from doxygen to transform it into text strings to used in the wrapping
definitions. This transformation is carried out by a tweaked version of
breathe, an extensions for the documentation system Sphinx.

# Dependencies

python-docutils
sphinx >= 1.3

The modified version of breathe is shipped as part of these sources.

# Instructions

## Project integration

Merge this project with your source tree:

  git remote add -f docstrings ssh://bbpgit.epfl.ch/user/hernando/python-docstrings.git
  git read-tree --prefix=/ -u docstrings/master
  git commit -am "Merging docstrings project"

## CMake modifications

Assuming you have imported Pyxygen under ${PROJECT_SOURCE_DIR}/docstrings,
add the following to your CMakeLists.txt:

  list(APPEND CMAKE_MODULE_PATH ${PROJET_SOURCE_DIR}/docstrings)
  include(PythonDocstrings)
  docstrings(WRAPPING_SOURCES WRAPPED_HEADERS)

where `WRAPPED_SOURCES' is a CMake variable with a list of Boost.Python sources
and `WRAPPED_HEADERS' is another one with the .h files that contain the doxygen
documentation.
The macro `docstrings' will parse the Boost.Python sources and produce a file
called init_docstrings.cpp in ${PROJECT_BUILD_DIR}/docstrings/cpp. This file
is included from ${PROJECT_BUILD_DIR}/docstrings/cpp/docstrings.cpp.

The CMake target that builds your Python module must include
docstrings/cpp/docstrings.cpp as part of its sources and it must be made
dependable on ${PROJECT_NAME}-docstrings (a target created by the macro
docstrings):

  add_dependencies(your_target ${PROJECT_NAME}-docstrings)

## Bosst.Python sources modifications

In your Boost.Python sources you have to include the header file
${PROJECT_BINARY_DIR}/docstrigngs/docstrings.h.
This header defines the macros DOXY_CLASS, DOXY_ENUM and DOXY_FN. These macros
generate the code that obtains the C-style string to be used as docstring
for the wrapping. The argument taken is always the fully qualified name of the
object to be documented. For overloaded functions you can choose a particular
overload including the function signature. If no signature is provided, the
docstring will contain the documentation of all the overloads (and the output
text won't be rendered correctly inside the Python console).

For optimal results include this line at the beginning of the module:
  boost::python::docstring_options doc_options(true, true, false);

Example
-------
The git branch `example' contains a complete example.
