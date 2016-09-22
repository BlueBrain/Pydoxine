# Copyright (c) 2016, EPFL/Blue Brain Project
#                     Juan Hernando <jhernando@fi.upm.es>
#
# This file is part of Pydoxine <https://github.com/BlueBrain/Pydoxine>
#
# This library is free software; you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License version 3.0 as published
# by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Code based in a similar script from the OpenRAVE project.

from sphinx.builders import Builder
import sphinx.addnodes
from six import StringIO
import xml2rst
import re
import os
import sys

string_type = str if  sys.version_info.major == 3 else unicode

xml2rst.setDefaultOptions()
mainXsltF = open(os.path.dirname(__file__) + '/xml2rst.xsl','r')

def mangleCPPIdentifier(id) :
    out = StringIO.StringIO()
    for t in ['class', 'function', 'enum'] :
        if t in id[:len(t)] :
            id = id[len(t):]
    underscore = False
    for c in id :
        if c != '_' :
            if underscore :
                if c == '1' :
                    out.write(':')
                else :
                    out.write(c.upper())
            else :
                out.write(c)
            underscore = False
        else :
            if underscore :
                out.write('_')
            underscore = not underscore
    return out.read()

def append_text(output, nodes):
    if type(nodes) == sphinx.addnodes.desc:
        assert(type(nodes[1]) == sphinx.addnodes.desc_content)
        nodes = nodes[1]

    whitespace = re.compile('^[\s]*$')
    breathe_directive = re.compile('[\s]*\.\. class:: [a-z]+[\s]*$')

    for node in nodes:
        # Documentation of enum values is really special because they sphinx
        # rendering intersperses this desc and index nodes that xml2rst can't
        # handle.
        # The following code tries to deal with that.
        if type(node) == sphinx.addnodes.index:
            # This can be ignored, we don't need it at all
            continue
        if type(node) == sphinx.addnodes.desc:
            # This is the enum value name
            desc_name = node[0][1]
            assert(type(desc_name) == sphinx.addnodes.desc_name)
            output.write("* " + desc_name[0])
            # And this is the description
            if len(node[1]) != 0:
                output.write(": ")
            desc_content = node[1]
            assert(type(desc_content) == sphinx.addnodes.desc_content)
            append_text(output, desc_content)
            continue

        domtree=node.asdom()
        inF = StringIO()
        domtree.writexml(inF, indent="", addindent="", newl="")
        inF.seek(0)

        outF = StringIO()
        xml2rst.convert(inF=inF, outF=outF, mainXsltF=mainXsltF)
        outF.seek(0)
        empty_line = False

        comment = StringIO()
        empty_comment = True
        for line in outF.read().split('\n') :
            if breathe_directive.match(line):
                continue

            if empty_line and not empty_comment :
                comment.write('\\n')
            empty_line = False
            empty_comment = False
            # Quoting some characters
            line = re.sub('\\\\','\\\\\\\\', line)
            line = re.sub('\t','\\\\t', line)
            line = re.sub('"','\\\\"', line)
            line = re.sub('([a-zA-Z])::([a-zA-Z])','\\1.\\2', line)

            comment.write(line)
            comment.write('\\n')
        comment.seek(0)
        output.write(comment.read())
        inF.close()
        outF.close()



class CDocstringBuilder(Builder) :
    """
    Builds C style strings with the docstrings to use in Boosth Python
    """
    name = 'docstrings'
    format = 'docstrings'

    def __init__(self, app) :
        super(CDocstringBuilder, self).__init__(app)

    def get_relative_uri(self, docname, typ=None):
        # This is irrelevant
        return docname

    def get_outdated_docs(self) :
        return 'all'

    def init(self) :
        pass

    def prepare_writing(self, docnames) :
        pass

    def write_doc(self, docname, doctree) :

        comments = StringIO()
        # Sorting the names alphabetically to minimize changes over reviews.
        nodes = []
        for node in doctree:
            if not 'fqname' in node :
                # Skipping node without name
                continue
            nodes.append((node['fqname'], node))
        nodes.sort()

        for name, node_stack in nodes:
            comments.write('m["%s"] = "' % name)
            append_text(comments, node_stack[0])
            comments.write('";\n')

        out = open(self.app.config.cpp_docstrings_out_file, 'w')
        out.write("""\
// File automatically generated by %s

void initDocStrings(std::map<std::string, std::string> &m)
{
""" % __file__)
        comments.seek(0)
        out.write(comments.read())
        out.write("}\n")

    def finish(self) :
        print('finish')

def setup(app) :
    app.add_builder(CDocstringBuilder)
    app.add_config_value('cpp_docstrings_out_file', False, False)
