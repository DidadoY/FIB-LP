from antlr4 import *
from llullLexer import llullLexer
import sys
from llullParser import llullParser
from MainVisitor import Errores, MainVisitor

input_stream = FileStream(sys.argv[1], 'utf-8')

lexer = llullLexer(input_stream)
token_stream = CommonTokenStream(lexer)
parser = llullParser(token_stream)
tree = parser.root()

if len(sys.argv) == 3:
    visitor = MainVisitor(sys.argv[2])
elif len(sys.argv) > 3:
    array = []
    i = 0
    for parametros in sys.argv[3:]:
        array.insert(i, int(parametros))
        i += 1
    visitor = MainVisitor(sys.argv[2], array)

else:
    visitor = MainVisitor()

try:
    visitor.visit(tree)

except Errores as msgerror:
    print(msgerror.mensaje)
