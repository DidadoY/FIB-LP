grammar llull;
 
root : declaraciones* EOF
    ;
 
bloque : acciones*
    ;
 
acciones : llamadas
    | read
    | asignacion
    | crearArray
    | setArray
    | conditionalIf
    | conditionalWhile
    | conditionalFor
    | escribir
    | expr
    ;

declaraciones : VOID IDENTIFICADOR PA (IDENTIFICADOR (COMA IDENTIFICADOR)*)? PC CA bloque CC
    ;

llamadas : IDENTIFICADOR PA (expr (COMA expr)*)? PC
    ;

read : READ PA IDENTIFICADOR PC
    ;

asignacion : IDENTIFICADOR IGUAL expr
    ;

crearArray : ARRAY PA IDENTIFICADOR COMA expr PC
    ;

getArray : GET PA IDENTIFICADOR COMA expr PC
    ;

setArray : SET PA IDENTIFICADOR COMA expr COMA expr PC
    ;

conditionalIf : IF expr CA bloque CC (ELSE CA bloque CC)?
    ;
 
conditionalWhile : WHILE expr CA bloque CC
    ;

conditionalFor : FOR PA asignacion PUNTOYCOMA expr PUNTOYCOMA asignacion PC CA bloque CC
    ;

escribir : WRITE PA (expr (COMA expr)*)? PC
    ;
 
expr : MENOS expr 
    | NOT expr
    | expr (MULT | DIV | MOD) expr
    | expr (MAS | MENOS) expr
    | expr (MENORIGUAL | MAYORIGUAL | MENOR | MAYOR) expr
    | expr (EQUAL | NOTEQUAL) expr
    | expr AND expr
    | expr OR expr
    | getArray
    | primitivas
    ;
 
primitivas : PA expr PC
    | (INT | FLOAT)
    | (TRUE | FALSE)
    | IDENTIFICADOR
    | STRING
    ;
 
OR : '||';
AND : '&&';
EQUAL : '==';
NOTEQUAL : '<>';
MAYOR : '>';
MENOR : '<';
MAYORIGUAL : '>=';
MENORIGUAL : '<=';
MAS : '+';
MENOS : '-';
MULT : '*';
DIV : '/';
MOD : '%';
NOT : '!';
 
IGUAL : '=';
PA : '(';
PC : ')';
CA : '{';
CC : '}';
COMA : ',';
PUNTOYCOMA : ';';

VOID : 'void';
TRUE : 'true';
FALSE : 'false';
IF : 'if';
ELSE : 'else';
WRITE : 'write';
READ : 'read';
WHILE : 'while';
FOR : 'for' ;
ARRAY : 'array' ;
GET : 'get' ;
SET : 'set' ;

IDENTIFICADOR : [a-zA-Z_] [a-zA-Z_0-9]*;
INT : [0-9]+;
FLOAT: [0-9]+ '.' [0-9]* | '.' [0-9]+;
STRING : '"' (~["\r\n] | '""')* '"';
COMENTARIO: '#' ~[\r\n]* -> skip;
WS: [ \t\r\n] -> skip;

