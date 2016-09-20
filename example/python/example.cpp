#include <boost/python.hpp>

#include "../example.h"

using namespace boost::python;
using namespace example;

BaseExample::Things BaseExample::theThing;

#include "docstrings.h"

void (module::Example::*Example_publicMethod1)() =
    &module::Example::publicMethod;
void (module::Example::*Example_publicMethod2)(int, std::string) =
    &module::Example::publicMethod;

class dummy_namespace {};

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
                      DOXY_VAR(example::BaseExample::theThing));
}

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
        .def("f", &module::Example::f,
             DOXY_FN(example::module::Example::f))
        ;
}

}
