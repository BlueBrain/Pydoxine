list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../CMake)

include(PythonDocstrings)

set(WRAPPED_HEADERS ${CMAKE_SOURCE_DIR}/example.h)
set(WRAPPING_SOURCES ${CMAKE_SOURCE_DIR}/python/example.cpp)

docstrings(WRAPPING_SOURCES WRAPPED_HEADERS)

include_directories(${PROJECT_BINARY_DIR}/docstrings/cpp
                    ${PYTHON_INCLUDE_DIR})

add_library(example SHARED example.cpp
  ${PROJECT_BINARY_DIR}/docstrings/cpp/docstrings.cpp)
add_dependencies(example PyxygenExample-docstrings)

target_link_libraries(example ${PYTHON_LIBRARIES}
                      ${Boost_PYTHON${USE_BOOST_PYTHON_VERSION}_LIBRARY})

set_target_properties(example PROPERTIES
  PREFIX "" OUTPUT_NAME "_example"
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/example)
configure_file(__init__.py
               ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/example/__init__.py)


