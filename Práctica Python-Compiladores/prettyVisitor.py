from colorama import Fore
if __name__ is not None and "." in __name__:
    from .llullParser import llullParser
    from .llullVisitor import llullVisitor
else:
    from llullParser import llullParser
    from llullVisitor import llullVisitor


indent = '    '
indentaciones = 1
expr = False
inFor = False


class prettyVisitor(llullVisitor):

    # Root visitará todas las declaraciones del programa para almacenarlas
    def visitRoot(self, ctx: llullParser.RootContext):
        l = list(ctx.getChildren())
        array = []
        for i in range(0, len(l)-1):
            self.visit(l[i])

    # Visita las declaraciones de acciones y crea su respectivo objeto
    def visitDeclaraciones(self, ctx: llullParser.DeclaracionesContext):
        l = list(ctx.getChildren())
        print()
        print (Fore.LIGHTRED_EX + l[0].getText() + ' ' + Fore.LIGHTMAGENTA_EX + l[1].getText() + Fore.RESET, end='')
        print (l[2].getText(), end='')
        i = 3
        while l[i].getText() != ')':
            if l[i].getText() != ',':
                print(l[i].getText(), end='')
            else:
                print(',', end=' ')
            i += 1
        print(') {', end='')
        self.visit(ctx.bloque())
        print()
        print('}')

    # Visita las llamadas a acciones y llama al método llamarAcciones para ejecutar las registradas
    def visitLlamadas(self, ctx: llullParser.LlamadasContext):
        l = list(ctx.getChildren())
        print()
        global indentaciones
        for i in range(0, indentaciones):
            print(indent, end='')

        print(Fore.CYAN + l[0].getText() + Fore.RESET, end='')
        print('(', end='')
        i = 2
        while l[i].getText() != ')':
            if l[i].getText() != ',':
                print(l[i].getText(), end='')
            else:
                print(',', end=' ')
            i += 1
        print(')', end='')

    # Lee un valor
    def visitRead(self, ctx: llullParser.ReadContext):
        return self.visitChildren(ctx)

    # Asigna un valor a una variable
    def visitAsignacion(self, ctx: llullParser.AsignacionContext):
        global indentaciones
        global inFor
        if not inFor:
            print()
        for i in range(0, indentaciones):
            print(indent, end='')

        variable = ctx.IDENTIFICADOR().getText()
        print(Fore.CYAN + variable + Fore.RESET + ' ' + Fore.RED + '=' + Fore.RESET, end=' ')
        self.visit(ctx.expr())

    # Visit a parse tree produced by llullParser#crearArray.
    def visitCrearArray(self, ctx: llullParser.CrearArrayContext):
        l = list(ctx.getChildren())
        print()
        global indentaciones
        for i in range(0, indentaciones):
            print(indent, end='')
        nombre = ctx.IDENTIFICADOR().getText()
        print(Fore.CYAN + l[0].getText() + Fore.RESET + '(', end='')
        while l[i].getText() != ')':
            if l[i].getText() != ',':
                print(l[i].getText(), end='')
            else:
                print(',', end=' ')
            i += 1
        print(')', end='')

    # Visit a parse tree produced by llullParser#getArray.
    def visitGetArray(self, ctx: llullParser.GetArrayContext):
        l = list(ctx.getChildren())
        global expr
        if (not expr):
            print()

        global indentaciones
        for i in range(0, indentaciones):
            print(indent, end='')
        nombre = ctx.IDENTIFICADOR().getText()
        print(Fore.CYAN + l[0].getText() + Fore.RESET + '(', end='')
        i = 2
        while l[i].getText() != ')':
            if l[i].getText() != ',':
                print(l[i].getText(), end='')
            else:
                print(',', end=' ')
            i += 1
        print(')', end='')

    # Visit a parse tree produced by llullParser#setArray.
    def visitSetArray(self, ctx: llullParser.SetArrayContext):
        l = list(ctx.getChildren())
        print()
        global indentaciones
        for i in range(0, indentaciones):
            print(indent, end='')
        nombre = ctx.IDENTIFICADOR().getText()
        print(Fore.CYAN + l[0].getText() + Fore.RESET + '(', end='')
        i = 2
        while l[i].getText() != ')':
            if l[i].getText() != ',':
                print(l[i].getText(), end='')
            else:
                print(',', end=' ')
            i += 1
        print(')', end='')

    # Visit a parse tree produced by llullParser#conditionalIf.
    def visitConditionalIf(self, ctx: llullParser.ConditionalIfContext):
        l = list(ctx.getChildren())
        print()
        global indentaciones
        global expr
        for i in range(0, indentaciones):
            print(indent, end='')

        print(Fore.LIGHTRED_EX + l[0].getText() + ' ' + Fore.RESET + '(', end='')
        expr = True
        k = indentaciones
        indentaciones = 0
        self.visit(ctx.expr())
        expr = False
        print(') {', end='')
        indentaciones = k + 1
        self.visit(ctx.bloque(0))

        print()
        for i in range(0, indentaciones-1):
            print(indent, end='')
        print('}', end=' ')

        if len(l) > 5:
            print(Fore.LIGHTRED_EX + l[5].getText() + ' ' + Fore.RESET, end=' ')
            print('{')
            self.visit(ctx.bloque(1))
            print()
            for i in range(0, indentaciones-1):
                print(indent, end='')
            print('}', end='')
        indentaciones -= 1

    # Visit a parse tree produced by llullParser#conditionalWhile.
    def visitConditionalWhile(self, ctx: llullParser.ConditionalWhileContext):
        l = list(ctx.getChildren())
        print()
        global indentaciones
        for i in range(0, indentaciones):
            print(indent, end='')
        print(Fore.BLUE + l[0].getText() + Fore.RESET + '(', end='')
        self.visit(ctx.expr())
        print(') {', end='')
        indentaciones += 1
        self.visit(ctx.bloque())
        print()
        for i in range(0, indentaciones-1):
            print(indent, end='')
        print('}')
        indentaciones -= 1

    # Visit a parse tree produced by llullParser#conditionalFor.
    def visitConditionalFor(self, ctx: llullParser.ConditionalForContext):
        l = list(ctx.getChildren())
        print()
        global indentaciones
        global inFor
        for i in range(0, indentaciones):
            print(indent, end='')

        print(Fore.BLUE + l[0].getText() + '(', end='')
        m = indentaciones
        indentaciones = 0
        inFor = True
        self.visit(ctx.asignacion(0))
        print(',', end=' ')
        self.visit(ctx.expr())
        print(',', end=' ')
        self.visit(ctx.asignacion(1))
        print(') {', end='')
        inFor = False
        indentaciones = m+1
        self.visit(ctx.bloque())
        print()
        for i in range(0, indentaciones-1):
            print(indent, end='')
        print('}', end='')
        indentaciones -= 1

    # Método que visita las expresiones del lenguaje
    def visitExpr(self, ctx: llullParser.ExprContext):
        l = list(ctx.getChildren())
        if len(l) == 1:
            self.visit(l[0])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MAS":
            self.visit(l[0])
            print('+', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MENOS":
            self.visit(l[0])
            print('-', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MULT":
            self.visit(l[0])
            print('*', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "DIV":
            self.visit(l[0])
            print('/', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MOD":
            self.visit(l[0])
            print('%', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MENOR":
            self.visit(l[0])
            print('<', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MAYOR":
            self.visit(l[0])
            print(' >', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MAYORIGUAL":
            self.visit(l[0])
            print('>=', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MENORIGUAL":
            self.visit(l[0])
            print('<=', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "EQUAL":
            self.visit(l[0])
            print('==', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "NOTEQUAL":
            self.visit(l[0])
            print('<>', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "AND":
            self.visit(l[0])
            print('&&', end=' ')
            self.visit(l[2])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "OR":
            self.visit(l[0])
            print('||', end=' ')
            self.visit(l[2])

    # Método que trata las primitivas del lenguaje
    def visitPrimitivas(self, ctx: llullParser.PrimitivasContext):
        l = list(ctx.getChildren())
        if llullParser.symbolicNames[l[0].getSymbol().type] == "INT":
            print(Fore.CYAN + l[0].getText() + Fore.RESET, end='')
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "FLOAT":
            print(Fore.CYAN + l[0].getText() + Fore.RESET, end='')
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "TRUE":
            print('True', end='')
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "FALSE":
            print('False', end='')
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "IDENTIFICADOR":
            var = ctx.getText()
            print(var, end='')
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "STRING":
            print(Fore.CYAN + l[0].getText() + Fore.RESET, end='')
        else:
            self.visit(ctx.expr())

    # Método write
    def visitEscribir(self, ctx: llullParser.EscribirContext):
        l = list(ctx.getChildren())
        print()
        global indentaciones
        for i in range(0, indentaciones):
            print(indent, end='')

        print(Fore.CYAN + l[0].getText() + Fore.RESET, end='')
        print('(', end='')
        i = 2
        while l[i].getText() != ')':
            if l[i].getText() != ',':
                print(l[i].getText(), end='')
            else:
                print(',', end=' ')
            i += 1
        print(')', end='')
