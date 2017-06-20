# Extracted from https://github.com/InsightSoftwareConsortium/ITKExamples/blob/master/CMake/FindSphinx.cmake
# - This module looks for Sphinx
# Find the Sphinx documentation generator
#
# Optional inputs:
#  - environment variable SPHINX_ROOT to hint installed location
#  - CMake variable SPHINX_ROOT to hint installed location
#
# This modules defines
# SPHINX_EXECUTABLE
# SPHINX_FOUND

find_program(SPHINX_EXECUTABLE
  NAMES sphinx-build
  PATHS
  /usr/bin
  /usr/local/bin
  /opt/local/bin
  $ENV{SPHINX_ROOT}/bin
  ${SPHINX_ROOT}/bin
  DOC "Sphinx documentation generator"
)

if(NOT SPHINX_EXECUTABLE)
  set(_Python_VERSIONS
    3.4 3.3 3.2 3.1 3.0 2.7 2.6 2.5 2.4 2.3 2.2 2.1 2.0 1.6 1.5
  )

  foreach(_version ${_Python_VERSIONS})
    set(_sphinx_NAMES sphinx-build-${_version})

    find_program(SPHINX_EXECUTABLE
      NAMES ${_sphinx_NAMES}
      PATHS
        /usr/bin
        /usr/local/bin
        /opt/local/bin
        $ENV{SPHINX_ROOT}/bin
        ${SPHINX_ROOT}/bin
      DOC "Sphinx documentation generator"
    )
  endforeach()
endif()


if(Sphinx_FIND_VERSION AND SPHINX_EXECUTABLE)
  execute_process(COMMAND ${SPHINX_EXECUTABLE} --version
                  OUTPUT_VARIABLE _text
                  ERROR_VARIABLE _dummy)
  set(_match_string "Sphinx \\(sphinx-build\\) ([0-9\\.]+).*")

  if (NOT _text)
    # Older versions do not support --version and the error output when
    # used with no arguments is different
    execute_process(COMMAND ${SPHINX_EXECUTABLE} ERROR_VARIABLE _text)
    set(_match_string "Sphinx v([0-9\\.]+).*")
  endif()

  string(REGEX REPLACE "${_match_string}" "\\1" _sphinxVersion ${_text})

  if (Sphinx_FIND_VERSION_EXACT)
    if (NOT _sphinxVersion EQUAL Sphinx_FIND_VERSION)
      if(NOT Sphinx_FIND_QUIETLY)
        message(WARNING "No suitable Sphinx version, requested ${Sphinx_FIND_VERSION} exact, found ${_sphinxVersion}")
      endif()
      unset(SPHINX_EXECUTABLE)
      return()
    endif()
  else()
    if (_sphinxVersion VERSION_LESS Sphinx_FIND_VERSION)
      if(NOT Sphinx_FIND_QUIETLY)
        message(WARNING "No suitable Sphinx version, requested ${Sphinx_FIND_VERSION}, found ${_sphinxVersion}")
      endif()
      unset(SPHINX_EXECUTABLE)
      return()
    endif()
  endif()
endif()


include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(Sphinx DEFAULT_MSG SPHINX_EXECUTABLE)
