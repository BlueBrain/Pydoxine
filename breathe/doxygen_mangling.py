import re
from six import StringIO

def unmangleId(id) :
    """
    Unmangles a doxygen ID and returns a tuple with the scope type, the
    C++ identifier of the scope (empty for files, which means global scope)
    and the identified type. When the identified type is a unique ID the
    returned id is an empty string (the name will have to be retrieved from
    the 'name' property of the data object with this ID).
    """
    out = StringIO()
    underscore = False
    c = 0
    while c < len(id) :
        if id[c] != '_' :
            if underscore :
                if id[c] == '1' :
                    out.write(':')
                elif id[c] == '8' :
                    out = StringIO()
                    out.write('file')
                    # Skipping extension
                    c += 1
                    if id[c] != 'h' :
                        c += 2
                else :
                    out.write(id[c].upper())
            else :
                out.write(id[c])
            underscore = False
        else :
            if underscore :
                out.write('_')
            underscore = not underscore
        c += 1
    out.seek(0)
    out = out.read()

    for t in ['class', 'struct', 'namespace', 'file'] :
        if t in out[:len(t)] :
            id = out[len(t):]
            if re.search("([^:]|^):[^:]", id) :
                scope = id.rsplit(':', 1)[0]
                return (t, scope, '')
            else :
                try :
                    scope, id = id.rsplit('::', 1)
                    return (t, scope, id)
                except ValueError:
                    return (t, '', id)

    #This is a file, removing the file name

    return out

def mangleId(id) :
    """
    Mangles a C++ identifier as a doxygen doxygen ID without any prefix
    """
    out = StringIO()
    for c in id :
        if c == '_' :
            out.write('__')
        elif c == ':' :
            out.write('_1')
        elif c.isupper() :
            out.write('_')
            out.write(c.lower())
        else :
            out.write(c)
    out.seek(0)
    return out.read()
