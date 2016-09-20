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

target_link_libraries(example
  ${Boost_PYTHON_LIBRARY} ${PYTHON_LIBRARIES})

set_target_properties(example PROPERTIES PREFIX "" OUTPUT_NAME "_example")

