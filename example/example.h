#ifndef EXAMPLE
#define EXAMPLE

#include <string>

namespace example
{

/**
    \brief A class with a short description that is longer than normal to
    test how the final layout looks like.

    A long description: Sed ut perspiciatis unde omnis iste natus error sit
    voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque
    ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae
    dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit
    aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui
    ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem
    ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non
    numquam eius modi tempora incidunt ut labore et dolore magnam aliquam
    quaerat voluptatem.
*/
class BaseExample
{
public:
    /**
       A list of things
    */
    enum Things
    {
    #ifdef DOXYGEN_TO_BREATHE
        FOO = 0, //!< A foo thing
        BAR = 1 //!< A bar thing
    #else
        THING_FOO = 0, //!< A foo thing
        THING_BAR = 1 //!< A bar thing
    #endif
    };
};

namespace module
{

/**
\brief This is the brief

@ingroup Main

And this the long
- hola
- lista
*/
class Example : public BaseExample
{
public:
    /**
       A nestexd class.

       This is an opaque type.
    */
    class Nested;

    /** \brief The pulic method */
    void publicMethod() {}

    /**
        An overload of the public method with arguments.

        This one has 2 arguments

        @param a One parameter
        @param b Other parameter

        @see publicMethod
    */
    void publicMethod(int a, std::string b) {}

    /** \brief A method without much to say but a brief comment two lines
     long (in the final output).

     Rather uninteresting.

     @param x
     @return int
    */
    int f(int x) const { return 0; }

protected:
    /** The protected method */
    void protectedMethod() {}
};

}

}
#endif
