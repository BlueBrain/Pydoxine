# docstrings()
#   blah
#
# Input variables
#   DOCSTRINGS_EXCLUDE_SYMBOLS

common_find_package(Sphinx 1.3)
common_find_package(Doxygen)

if(DOXYGEN_FOUND AND SPHINX_FOUND)
  add_definitions(-D${PROJECT_NAME}_USE_SPHINX -D${PROJECT_NAME}_USE_DOXYGEN)
endif()

# This must stay declared at the file level. It can't be inside the function
# because the macro expansion of CMAKE_CURRENT_LIST_FILE will point to the
# wrong directory.
get_filename_component(_docstrings_path ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
set(_docstrings_path ${_docstrings_path}/..)

function(DOCSTRINGS BOOST_PYTHON_SOURCES CPP_HEADERS)
  set(_docstrings_wrapped_headers ${${CPP_HEADERS}})
  set(_doxygen_config_input_files)
  set(_docstrings_wrapping_sources ${${BOOST_PYTHON_SOURCES}})
  foreach(HEADER ${_docstrings_wrapped_headers})
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
    DEPENDS ${PROJECT_BINARY_DIR}/docstrings/wrapping.cfg
            ${_docstrings_wrapped_headers}
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/docstrings)

  add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/docstrings/cpp/init_docstrings.cpp
    COMMAND
      ${PYTHON_EXECUTABLE} ${PROJECT_BINARY_DIR}/docstrings/build.py
        ${PROJECT_BINARY_DIR}/docstrings/xml ${_docstrings_wrapping_sources}
    COMMAND
      ${SPHINX_EXECUTABLE} -q -b docstrings ${PROJECT_BINARY_DIR}/docstrings
      ${PROJECT_BINARY_DIR}/docstrings/cpp
    DEPENDS ${PROJECT_BINARY_DIR}/docstrings/xml/index.xml
            ${PROJECT_BINARY_DIR}/docstrings/conf.py
            ${PROJECT_BINARY_DIR}/docstrings/build.py
            ${_docstrings_wrapping_sources}
            ${_docstrings_wrapped_headers}
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/docstrings/cpp)

  add_custom_target(
    ${PROJECT_NAME}-docstrings DEPENDS ${PROJECT_BINARY_DIR}/docstrings/cpp/init_docstrings.cpp)
endfunction(DOCSTRINGS)
