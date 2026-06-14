lexer grammar CLexer;

options {
  language = Java;
}

// Palavras-chave (devem vir antes de ID)
INT     : 'int';
FOR     : 'for';
IF      : 'if';
RETURN  : 'return';
INCLUDE : '#include';

// Strings (para o printf)
STRING : '"' (~'"')* '"';

// Identificadores
ID : ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;

// Números
NUM : '0'..'9'+;

// Operadores multi-caractere (devem vir antes dos single-char)
EQ     : '==';
LE     : '<=';
INC    : '++';

// Operadores
PLUS   : '+';
ASSIGN : '=';
MOD    : '%';
DOT    : '.';

// Delimitadores
LPAREN : '(';
RPAREN : ')';
LBRACE : '{';
RBRACE : '}';
SEMI   : ';';
LT     : '<';
GT     : '>';
COMMA  : ',';

// Espaços em branco (ignorados)
WS : (' '|'\t'|'\r'|'\n')+ { skip(); };

// Comentários (ignorados)
COMMENT : '//' (~'\n')* { skip(); };