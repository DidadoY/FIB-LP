from antlr4 import *
from llullLexer import llullLexer
import sys
from llullParser import llullParser
from prettyVisitor import prettyVisitor

input_stream = FileStream(sys.argv[1], 'utf-8')
lexer = llullLexer(input_stream)
token_stream = CommonTokenStream(lexer)
parser = llullParser(token_stream)
tree = parser.root()

visitor = prettyVisitor()
visitor.visit(tree)
