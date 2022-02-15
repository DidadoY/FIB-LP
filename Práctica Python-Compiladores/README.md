# El llenguatge de programació Llull
Llull és un llenguatge de programació molt similar a C

## Instalació
```bash
pip3 install -r requirements.txt
antlr4 -Dlanguage=Python3 -no-listener -visitor llull.g4
```

## L'intèrpret
Per executar l'intèrpret bàsic hem de fer la qual executarà el main per defecte:
```bash
python3 llull.py test-helloworld.llull
```

Si volem executar una funció concreta hem de fer:
```bash
python3 llull.py test-helloworld.llull funcio
```

Si la funció que volem executar necessita paràmetres:
```bash
python3 llull.py test-helloworld.llull funcio param1 param2 ...
```

L'intèrpret té el seu visitor que he implementat anomenat:
·MainVisitor.py

Els documents:
·llullVisitor.py
·llullParser.py
·llullLexer.py
·llull.interp
·llullLexer.interp

Són documents autogenerats per la gramàtica:
·llull.g4

## Pretty-Printer
Per executar el pretty-printer i obtenir un codi més bonic hem de fer:
```bash
python3 beat.py test-beat.llull
```

El pretty-printer té el seu visitor que he implementat anomenat:
·prettyVisitor.py

## Testing
He afegit diversos tests per testejar l'intèrpret i el pretty-printer aquests son:

·test-hanoi.llull
```c
void main() {
    read(n)
    hanoi(n, 1, 2, 3)
}

void hanoi(n, ori, dst, aux) {
    if (n > 0) {
        hanoi(n - 1, ori, aux, dst)
        write(ori, "->", dst)
        hanoi(n - 1, aux, dst, ori)
    }
}
```

·test-euclides.llull
```c
void main() {
    # llegeix dos enters i  n'escriu el seu maxim comu divisor
    write("Escriu dos nombres")
    read(a)
    read(b)
    write("El seu MCD es")
    euclides(a, b)
}

void euclides(a, b) {
    while (a <> b) {
        if (a > b) {
            a = a - b
        } else {
            b = b - a
        }
    }
    write(a)
}
```

·test-helloworld.llull
```c
# Hello World en Llull

void main() {
    write("El Primer dia: Déu creà la llum")
}
```

·test-eratostenes.llull
```c
void main() {
    read(n)
    array(p, n + 1) # crea un array [0 .. n] inicialitzant totes les posicions a zero
    write(p)
    eratostenes(p, n)
    write(p)
    for (i = 2; i <= n; i = i + 1) {
        if (get(p, i) == 1) {
            write(i)
        }
    }
}

void eratostenes(p, n) {
    set(p, 0, 0)
    set(p, 1, 0)
    for (i = 2; i <= n; i = i + 1) {
        set(p, i, 1)
    }
    for (i = 2; i * i <= n; i = i + 1) {
        if (get(p, i) == 1) {
            for (j = i + i; j <= n; j = j + i) {
                set(p, j, 0)
            }
        }
    }
}
```

## Tractament d'errors
El programa tracta tots els errors esmentats a l'enunciat

## Autor
Marc Nebot Moyano
