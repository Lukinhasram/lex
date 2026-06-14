grammar CParser;

options {
  language = Java;
  output   = AST;
}

// Tokens imaginários para nós da AST
tokens {
  PROGRAM;
  FUNC_DEF;
  BLOCK;
  VAR_DECL;
  FOR_STMT;
  FOR_INIT;
  FOR_COND;
  FOR_UPDATE;
  IF_STMT;
  RETURN_STMT;
  ASSIGN_STMT;
  EXPR_STMT;
  FUNC_CALL;
  ARG_LIST;
  INCLUDE_DIR;
}

// ============================================================
// REGRAS DO PARSER (minúsculas) — com rewrite rules para AST
// ============================================================

program
    : includeDir functionDef EOF
      -> ^(PROGRAM includeDir functionDef)
    ;

includeDir
    : INCLUDE LT ID (DOT ID)? GT
      -> ^(INCLUDE_DIR INCLUDE ID+)
    ;

functionDef
    : type ID LPAREN RPAREN block
      -> ^(FUNC_DEF type ID block)
    ;

block
    : LBRACE statement* RBRACE
      -> ^(BLOCK statement*)
    ;

statement
    : varDecl
    | assignStmt
    | forStmt
    | ifStmt
    | returnStmt
    | exprStmt
    ;

varDecl
    : type ID (ASSIGN expr)? SEMI
      -> ^(VAR_DECL type ID expr?)
    ;

assignStmt
    : ID ASSIGN expr SEMI
      -> ^(ASSIGN_STMT ID expr)
    ;

forStmt
    : FOR LPAREN forInit SEMI forCond SEMI forUpdate RPAREN block
      -> ^(FOR_STMT forInit forCond forUpdate block)
    ;

forInit
    : type ID ASSIGN expr
      -> ^(FOR_INIT type ID expr)
    ;

forCond
    : expr
      -> ^(FOR_COND expr)
    ;

forUpdate
    : ID INC
      -> ^(FOR_UPDATE ID INC)
    ;

ifStmt
    : IF LPAREN expr RPAREN block
      -> ^(IF_STMT expr block)
    ;

returnStmt
    : RETURN expr SEMI
      -> ^(RETURN_STMT expr)
    ;

exprStmt
    : expr SEMI
      -> ^(EXPR_STMT expr)
    ;

expr
    : term ( (PLUS | EQ | LE | LT | GT | MOD) term )*
    ;

term
    : ID LPAREN argList? RPAREN -> ^(FUNC_CALL ID argList?)
    | ID
    | NUM
    | STRING
    ;

argList
    : expr (COMMA expr)* -> ^(ARG_LIST expr+)
    ;

type
    : INT
    ;

// ============================================================
// REGRAS DO LEXER (copiadas de CLexer.g)
// ============================================================

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
