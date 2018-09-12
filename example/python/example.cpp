/* Copyright (c) 2016-2017, EPFL/Blue Brain Project
 *                          Juan Hernando <juan.hernando@epfl.ch>
 *
 * This file is part of Pydoxine <https://github.com/BlueBrain/Pydoxine>
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3.0 as published
 * by the Free Software Foundation.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <boost/python.hpp>

#include "../example.h"

using namespace boost::python;
using namespace example;

BaseExample::Things BaseExample::theThing;

#include "docstrings.h"

void (example::module::Example::*Example_publicMethod1)() =
    &example::module::Example::publicMethod;
void (example::module::Example::*Example_publicMethod2)(int, std::string) =
    &example::module::Example::publicMethod;

class dummy_namespace
{
};

// clang-format off
BOOST_PYTHON_MODULE(_example)
{

docstring_options doc_options(true, true, false);

class_<BaseExample> baseExampleWrapper(
    "BaseExample", DOXY_CLASS(example::BaseExample), no_init);
{
    scope baseExampleScope = baseExampleWrapper;

    enum_<BaseExample::Things> things(
        "Things", DOXY_ENUM(example::BaseExample::Things));
    things.value("FOO", BaseExample::THING_FOO);
    things.value("BAR", BaseExample::THING_BAR);

    baseExampleWrapper
        .def_readonly("finished", &BaseExample::theThing,
                      DOXY_VAR( example::BaseExample::theThing));
}

enum_<example::module::Enum>("Enum", DOXY_ENUM(example::module::Enum))
    .value("ONE", example::module::ENUM_ONE);

scope module = class_<dummy_namespace>("module", no_init);

class_<example::module::Example> exampleWrapper(
    "Example", DOXY_CLASS(example::module::Example), init<>());
{
    scope exampleScope = exampleWrapper;

    exampleWrapper
        .def("publicMethod", Example_publicMethod1,
             DOXY_FN(example::module::Example::publicMethod()))
        .def("publicMethod", Example_publicMethod2,
             DOXY_FN(example::module::Example::publicMethod(int, std::string)))
        .def("f", &example::module::Example::f,
             DOXY_FN(example::module::Example::f));
}
// clang-format on

}
