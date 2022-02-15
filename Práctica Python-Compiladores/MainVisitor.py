if __name__ is not None and "." in __name__:
    from .llullParser import llullParser
    from .llullVisitor import llullVisitor
else:
    from llullParser import llullParser
    from llullVisitor import llullVisitor


class Errores(Exception):
    def __init__(self, mensaje):
        self.mensaje = 'ERROR:::' + mensaje


class Accion:
    # Clase que almacena las acciones del lenguaje Llull
    def __init__(self, nombre, parametros, bloque):
        self.nombre = nombre
        self.parametros = parametros
        self.bloque = bloque


class MainVisitor(llullVisitor):
    # Método que inicializa el proceso por el que empezaremos con su memoria
    def __init__(self, proceso='main', parametros=[]):
        self.proceso = proceso
        self.parametros = parametros

        self.acciones = {}
        self.memoria = []

    # Método que llama a las acciones de .llull
    def llamarAcciones(self, nombre, valores):
        if nombre not in self.acciones:
            raise Errores("No existe el procedimiento " + nombre + " defínelo y vuelve a intentarlo")
        elif len(self.acciones[nombre].parametros) > len(valores):
            raise Errores("El número de parámetros introducidos es menor al requerido")
        elif len(self.acciones[nombre].parametros) < len(valores):
            raise Errores("El número de parámetros introducidos es mayor al requerido")
        vars = {}
        for i in range(0, len(valores)):
            vars[self.acciones[nombre].parametros[i]] = valores[i]
        self.memoria.append(vars)
        self.visit(self.acciones[nombre].bloque)
        self.memoria.pop(-1)  # guardamos las variables locales en el índice -1 y las vamos eliminando

    # Root visitará todas las declaraciones del programa para almacenarlas
    def visitRoot(self, ctx: llullParser.RootContext):
        l = list(ctx.getChildren())
        for proceso in l:
            self.visit(proceso)
        self.llamarAcciones(self.proceso, self.parametros)

    # Visita las declaraciones de acciones y crea su respectivo objeto
    def visitDeclaraciones(self, ctx: llullParser.DeclaracionesContext):
        l = list(ctx.getChildren())
        nombreAccion = l[1].getText()
        i = 3
        parametros = []
        while l[i].getText() != ')':
            if l[i].getText() != ',':
                parametro = l[i].getText()
                if parametro in parametros:
                    raise Errores('Parámetro duplicado')
                else:
                    parametros.append(l[i].getText())
            i += 1
        if nombreAccion in self.acciones:
            raise Errores('Acción ' + nombreAccion + ' ya definida')
        else:
            self.acciones[nombreAccion] = Accion(nombreAccion, parametros, ctx.bloque())

    # Visita las llamadas a acciones y llama al método llamarAcciones para ejecutar las registradas
    def visitLlamadas(self, ctx: llullParser.LlamadasContext):
        l = list(ctx.getChildren())
        nombreAccion = l[0].getText()
        i = 2
        valores = []
        while l[i].getText() != ')':
            if l[i].getText() != ',':
                valores.append(self.visit(l[i]))
            i += 1
        if nombreAccion in self.acciones:
            self.llamarAcciones(nombreAccion, valores)
        else:
            raise Errores('Acción ' + nombreAccion + ' no definida')

    # Lee un valor
    def visitRead(self, ctx: llullParser.ReadContext):
        l = list(ctx.getChildren())
        self.memoria[-1][l[2].getText()] = int(input())

    # Asigna un valor a una variable
    def visitAsignacion(self, ctx: llullParser.AsignacionContext):
        variable = ctx.IDENTIFICADOR().getText()
        valor = self.visit(ctx.expr())
        self.memoria[-1][variable] = valor

    # Visit a parse tree produced by llullParser#crearArray.
    def visitCrearArray(self, ctx: llullParser.CrearArrayContext):
        nombre = ctx.IDENTIFICADOR().getText()
        posiciones = int(self.visit(ctx.expr()))
        array = []
        i = 0
        for i in range(0, posiciones):
            array.insert(i, 0)
        self.memoria[-1][nombre] = array

    # Visit a parse tree produced by llullParser#getArray.
    def visitGetArray(self, ctx: llullParser.GetArrayContext):
        nombre = ctx.IDENTIFICADOR().getText()
        posicion = int(self.visit(ctx.expr()))
        valores = self.memoria[-1][nombre]
        if posicion > 0 and posicion < len(valores):
            return int(valores[posicion])
        else:
            raise Errores('La posición está fuera de los límites del array')

    # Visit a parse tree produced by llullParser#setArray.
    def visitSetArray(self, ctx: llullParser.SetArrayContext):
        nombre = ctx.IDENTIFICADOR().getText()
        posicion = int(self.visit(ctx.expr(0)))
        valor = int(self.visit(ctx.expr(1)))
        self.memoria[-1][nombre][posicion] = valor

    # Visit a parse tree produced by llullParser#conditionalIf.
    def visitConditionalIf(self, ctx: llullParser.ConditionalIfContext):
        l = list(ctx.getChildren())
        valor = self.visit(ctx.expr())
        if bool(valor):
            self.visit(ctx.bloque(0))
        elif len(l) > 5:
            self.visit(ctx.bloque(1))

    # Visit a parse tree produced by llullParser#conditionalWhile.
    def visitConditionalWhile(self, ctx: llullParser.ConditionalWhileContext):
        valor = self.visit(ctx.expr())
        while bool(valor):
            self.visit(ctx.bloque())
            valor = self.visit(ctx.expr())

    # Visit a parse tree produced by llullParser#conditionalFor.
    def visitConditionalFor(self, ctx: llullParser.ConditionalForContext):
        self.visit(ctx.asignacion(0))
        valor = self.visit(ctx.expr())
        while bool(valor):
            self.visit(ctx.bloque())
            self.visit(ctx.asignacion(1))
            valor = self.visit(ctx.expr())

    # Método que visita las expresiones del lenguaje
    def visitExpr(self, ctx: llullParser.ExprContext):
        l = list(ctx.getChildren())
        if len(l) == 1:
            return self.visit(l[0])
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MAS":
            return int(self.visit(l[0])) + int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MENOS":
            return int(self.visit(l[0])) - int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MULT":
            return int(self.visit(l[0])) * int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "DIV":
            if int(self.visit(l[2])) == 0:
                raise Errores('División entre 0')
            return int(self.visit(l[0])) / int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MOD":
            return int(self.visit(l[0])) % int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MENOR":
            return int(self.visit(l[0])) < int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MAYOR":
            return int(self.visit(l[0])) > int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MAYORIGUAL":
            return int(self.visit(l[0])) >= int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "MENORIGUAL":
            return int(self.visit(l[0])) <= int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "EQUAL":
            return int(self.visit(l[0])) == int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "NOTEQUAL":
            return int(self.visit(l[0])) != int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "AND":
            return int(self.visit(l[0])) and int(self.visit(l[2]))
        elif llullParser.symbolicNames[l[1].getSymbol().type] == "OR":
            return int(self.visit(l[0])) or int(self.visit(l[2]))

    # Método que trata las primitivas del lenguaje
    def visitPrimitivas(self, ctx: llullParser.PrimitivasContext):
        l = list(ctx.getChildren())
        if llullParser.symbolicNames[l[0].getSymbol().type] == "INT":
            return int(l[0].getText())
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "FLOAT":
            return int(l[0].getText())
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "TRUE":
            return True
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "FALSE":
            return False
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "IDENTIFICADOR":
            var = ctx.getText()
            valor = self.memoria[-1][var]
            if valor is None:
                return 0
            else:
                return valor
        elif llullParser.symbolicNames[l[0].getSymbol().type] == "STRING":
            string = ctx.getText()
            new = string[1:len(string)-1]
            return new
        else:
            return self.visit(ctx.expr())

    # Método write
    def visitEscribir(self, ctx: llullParser.EscribirContext):
        l = list(ctx.getChildren())
        i = 2
        while l[i].getText() != ')':
            if l[i].getText() != ',':
                print(self.visit(l[i]), end=' ')
            i += 1
        print()
