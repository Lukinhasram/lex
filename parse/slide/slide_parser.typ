#import "lib.typ": *

#show: slides.with(
  title: "Compiladores — Análise Sintática",
  subtitle: "Análise Léxica + Sintática com ANTLR 3 — Subconjunto de C",
  date: "14.06.2026",
  authors: ("Jéssica Pereira, Kauã Bispo, Kenandja Krishna, Liriel Gomes, Lucas Ramos",),

  ratio: 16/9,
  layout: "medium",
  title-color: blue.darken(60%),
  toc: true,
  first-slide: true,
  count: "number",
)

// ============================================================
// SEÇÃO 1 — Introdução
// ============================================================
= Introdução

== Sobre este Trabalho

*Disciplina:* Compiladores \
*Professor:* Alexandre Paes \
*Instituição:* Universidade Federal de Alagoas — Campus Arapiraca

#v(0.5em)

*Equipe:*

+ Jéssica Pereira 
+ Kauã Bispo
+ Kenandja Krishna 
+ Liriel Gomes 
+ Lucas Ramos

#v(0.5em)

*Gerador utilizado:* ANTLR 3 \
*Linguagem alvo:* Java \
*Gramática:* `CParser.g` — Lexer + Parser para um subconjunto de C (Soma dos Pares)


== O que é Análise Sintática?

#v(5em)

#quote(attribution: [Johny Douglas — _Compiladores para Humanos_])[
  "A análise sintática, também conhecida como _parser_, é a *segunda fase* de um compilador.
  Ela recebe a sequência de tokens produzida pelo analisador léxico e verifica se essa
  sequência está de acordo com as *regras gramaticais* da linguagem, construindo uma
  *árvore sintática* que representa a estrutura hierárquica do programa."
]

#pagebreak()

O parser consome os tokens do lexer e reconhece a estrutura do programa:

```
PROGRAM
├─ INCLUDE_DIR
│   └─ 'stdio'
└─ FUNC_DEF
    ├─ INT 'int'
    ├─ ID  'main'
    └─ BLOCK
        ├─ VAR_DECL ...
        ├─ FOR_STMT ...
        └─ RETURN_STMT ...
```

O resultado é uma *AST (Abstract Syntax Tree)* — árvore sintática abstrata.


== Fluxo da Compilação

#align(center + horizon)[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
    gutter: 6pt,
    align: center + horizon,

    block(fill: blue.darken(60%), radius: 4pt, inset: 8pt,
      text(fill: white, weight: "bold", size: 0.85em)[Código\ Fonte]),
    text(size: 1.4em)[→],
    block(fill: green.darken(30%), radius: 4pt, inset: 8pt,
      text(fill: white, weight: "bold", size: 0.85em)[Análise\ Léxica]),
    text(size: 1.4em)[→],
    block(fill: red.darken(20%), radius: 4pt, inset: 8pt,
      text(fill: white, weight: "bold", size: 0.85em)[Análise\ *Sintática*]),
    text(size: 1.4em)[→],
    block(fill: luma(80), radius: 4pt, inset: 8pt,
      text(fill: white, weight: "bold", size: 0.85em)[Geração\ de Código]),
  )
  #v(0.6em)
  
  A *análise sintática* é a *segunda etapa*: consome os tokens do lexer e constrói a *AST* que representa a estrutura do programa.
]


// ============================================================
// SEÇÃO 2 — ANTLR
// ============================================================
= O Gerador ANTLR

== O que é o ANTLR?

*ANTLR* — _Another Tool for Language Recognition_ \
Criado por *Terence Parr* (Universidade de São Francisco)

#v(0.5em)

- Ferramenta de geração de *Lexers* e *Parsers* a partir de uma gramática `.g`
- Amplamente utilizado na construção de linguagens de programação, frameworks e ferramentas de análise
- Suporta múltiplas linguagens alvo: Java, Python, C, C\#, C++, PHP

#v(0.5em)

Neste trabalho, geramos o código em *Java*.


== Como o ANTLR Funciona

#grid(
  columns: (1fr, 1fr),
  gutter: 16pt,

  [
    *Você escreve:*
    #v(0.3em)
    - Um arquivo `NomeDaGramatica.g`
    - Regras do *Lexer* (MAIÚSCULAS)
    - Regras do *Parser* (minúsculas)
    - Opção de linguagem alvo e saída AST

    #v(0.6em)
    *Executa:*
    ```bash
    antlr3 CParser.g
    ```
  ],

  [
    *O ANTLR gera automaticamente:*
    #v(0.3em)
    - `CParserLexer.java` — lexer gerado
    - `CParserParser.java` — parser gerado
    - `CParser.tokens` — tabela de tokens

    #v(0.3em)
    #text(size: 0.85em, style: "italic", fill: luma(80))[
      O `grammar CParser` com `output = AST` instrui
      o ANTLR a gerar o parser com suporte a árvores
      sintáticas usando as rewrite rules (`->`).
    ]
  ],
)

// ============================================================
// SEÇÃO 3 — A Gramática
// ============================================================
= A Gramática

== Gramática: `CParser.g`

#v(0.4em)

A gramática `CParser.g` define *lexer + parser* num único arquivo:

#grid(
  columns: (auto, 1fr),
  gutter: 6pt,
  [*Tipo:*],     [`grammar CParser` — gramática combinada (lexer + parser)],
  [*Saída:*],    [`output = AST` — ANTLR gera suporte a árvores sintáticas],
  [*Tokens imaginários:*], [Nós da AST sem correspondência no texto fonte],
  [*Rewrite rules:*], [Sintaxe `-> ^(NÓ filhos...)` que constrói a AST],
)

#v(0.5em)

*Tokens imaginários (nós da AST):*

#grid(
  columns: (1fr, 1fr),
  gutter: 4pt,
  [`PROGRAM`],     [`FOR_STMT`],
  [`FUNC_DEF`],    [`FOR_INIT`],
  [`BLOCK`],       [`FOR_COND`],
  [`VAR_DECL`],    [`FOR_UPDATE`],
  [`IF_STMT`],     [`ASSIGN_STMT`],
  [`RETURN_STMT`], [`EXPR_STMT`],
  [`FUNC_CALL`],   [`ARG_LIST`],
  [`INCLUDE_DIR`], [],
)


== Regras do Parser

#align(center)[
  ```antlr
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
    : varDecl | assignStmt | forStmt
    | ifStmt  | returnStmt | exprStmt
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
    : FOR LPAREN forInit SEMI
      forCond SEMI forUpdate RPAREN block
      -> ^(FOR_STMT forInit forCond
                    forUpdate block)
    ;

  ifStmt
    : IF LPAREN expr RPAREN block
      -> ^(IF_STMT expr block)
    ;

  returnStmt
    : RETURN expr SEMI
      -> ^(RETURN_STMT expr)
    ;

  expr
    : term ((PLUS|EQ|LE|LT|GT|MOD) term)*
    ;

  term
    : ID LPAREN argList? RPAREN
        -> ^(FUNC_CALL ID argList?)
    | ID | NUM | STRING
    ;
  ```
  ]


== Tabela de Tokens

#align(center)[
  #table(
    columns: (auto, auto, auto),
    stroke: blue.darken(60%).lighten(50%),
    fill: (_, row) => if row == 0 { blue.darken(60%) } else if calc.even(row) { luma(240) } else { white },
    inset: 6pt,

    table.header(
      text(fill: white, weight: "bold")[Token],
      text(fill: white, weight: "bold")[Tipo],
      text(fill: white, weight: "bold")[Descrição],
    ),

    [`INT`, `FOR`, `IF`, `RETURN`, `INCLUDE`], [Literal],   [Palavras-chave individuais],
    [`STRING`],  [Regular],  [`'"' (~'"')* '"'` — strings entre aspas (ex.: `"%d"`)],
    [`ID`],      [Regular],  [`('a'..'z'|'A'..'Z'|'_')('a'..'z'|'A'..'Z'|'0'..'9'|'_')*`],
    [`NUM`],     [Regular],  [`'0'..'9'+`],
    [`EQ`, `LE`, `INC`],    [Literal],  [Operadores multi-caractere: `==`, `<=`, `++`],
    [`PLUS`, `ASSIGN`, `MOD`, `DOT`], [Literal], [Operadores: `+`, `=`, `%`, `.`],
    [`LPAREN`, `RPAREN`, `LBRACE`, `RBRACE`, `SEMI`, `LT`, `GT`, `COMMA`], [Literal], [Delimitadores e pontuação],
    [`WS`],      [Regular],  [Espaços/quebras — descartados via `skip()`],
    [`COMMENT`], [Regular],  [Comentários de linha `//` — descartados via `skip()`],
    [`EOF`],     [Implícito],[Fim da entrada],
  )
]

// ============================================================
// SEÇÃO 4 — Análise na Prática
// ============================================================
= Análise na Prática

== O Arquivo de Gramática (.g)

#grid(
  columns: (1fr, 1fr),
  gutter: 16pt,

  [
    O arquivo `CParser.g` combina lexer e parser:

    #v(0.3em)
    - `grammar CParser` — gramática combinada
    - `output = AST` — ativa geração de árvore
    - Tokens imaginários declarados em `tokens { }`
    - Regras do *parser* em minúsculas com rewrite rules `->  ^(...)`
    - Regras do *lexer* em MAIÚSCULAS (idênticas ao `CLexer.g`)

    Para gerar e executar:

    #text(size:8pt)[
    ```bash
    antlr3 CParser.g
    javac -cp antlr-3.x.jar \
      CParserLexer.java \
      CParserParser.java \
      TestParser.java
    java -cp .:antlr-3.x.jar TestParser
    ```
    ]
  ],

  text(size: 9pt)[
  ```antlr
  grammar CParser;

  options {
    language = Java; output   = AST;
  }

  tokens {
    PROGRAM; FUNC_DEF; BLOCK; VAR_DECL; FOR_STMT; FOR_INIT; FOR_COND; FOR_UPDATE; IF_STMT; RETURN_STMT; ASSIGN_STMT; EXPR_STMT; FUNC_CALL; ARG_LIST; INCLUDE_DIR;
  }

  program
    : includeDir functionDef EOF
      -> ^(PROGRAM includeDir functionDef)
    ;

  // ... demais regras do parser ...

  // Regras do lexer (mesmas do CLexer.g)
  ```
  ],
)


== Fluxo de Análise no Código Java

#table(
  columns: (auto, auto, 1fr),
  stroke: none,
  inset: (x: 8pt, y: 6pt),
  fill: (_, row) => if calc.even(row) { luma(240) } else { white },

  table.header(
    text(weight: "bold")[Passo],
    text(weight: "bold")[Componente],
    text(weight: "bold")[O que faz],
  ),

  [1], [*Input Stream*],    [`ANTLRStringStream(code)` — encapsula a string caractere a caractere],
  [2], [*Lexer (AFD)*],     [`CParserLexer(input)` — tokeniza a entrada],
  [3], [*Token Stream*],    [`CommonTokenStream(lexer)` — coleta tokens em fila para o parser],
  [4], [*Parser*],          [`CParserParser(tokens)` — consome os tokens e valida a gramática],
  [5], [*Regra inicial*],   [`parser.program()` — dispara a análise a partir de `program`],
  [6], [*AST*],             [`result.getTree()` — retorna a árvore sintática construída],
  [7], [*Saída*],           [Imprime tokens (fase léxica) + AST hierárquica (fase sintática)],
)


== Saída — Fase Léxica

Fase 1 do `TestParser.java`: mesma tokenização do projeto anterior.

#v(0.3em)

#grid(
  columns: (1fr, 1fr),
  gutter: 16pt,

  [
    ```
Linha Coluna Tipo            Valor
------------------------------------------
1     1      INCLUDE         '#include'
1     9      LT              '<'
1     10     ID              'stdio'
1     15     DOT             '.'
1     16     ID              'h'
1     17     GT              '>'
3     1      INT             'int'
3     5      ID              'main'
3     9      LPAREN          '('
3     10     RPAREN          ')'
3     12     LBRACE          '{'
4     5      INT             'int'
4     9      ID              'soma'
    ```
  ],

  [
    ```
Linha Coluna Tipo            Valor
------------------------------------------
4     14     ASSIGN          '='
4     16     NUM             '0'
4     17     SEMI            ';'
5     5      FOR             'for'
5     9      LPAREN          '('
5     10     INT             'int'
5     14     ID              'i'
5     16     ASSIGN          '='
5     18     NUM             '0'
5     19     SEMI            ';'
...
------------------------------------------
Total de tokens: 62
    ```
  ],
)


== Saída — Fase Sintática

Fase 2: o parser valida a estrutura e constrói a *AST*.

#v(0.3em)

#grid(
  columns: (1fr, 1fr),
  gutter: 16pt,

  [
    *Resultado da validação:*
    ```
✓ Programa ACEITO pela gramática!
  Nenhum erro sintático encontrado.
    ```

    #v(0.5em)
    *AST — formato linear:*
    #text(size:9.6pt)[
    ```
    (PROGRAM
      (INCLUDE_DIR #include stdio h)
      (FUNC_DEF int main
        (BLOCK
          (VAR_DECL int soma 0)
          (FOR_STMT ...)
          (EXPR_STMT ...)
          (RETURN_STMT 0))))
    ```
    ]
  ],

  [
    *AST — formato hierárquico:*
    ```
PROGRAM
├─ INCLUDE_DIR
│   ├─ INCLUDE '#include'
│   ├─ ID 'stdio'
│   └─ ID 'h'
└─ FUNC_DEF
    ├─ INT 'int'
    ├─ ID 'main'
    └─ BLOCK
        ├─ VAR_DECL
        │   ├─ INT 'int'
        │   ├─ ID 'soma'
        │   └─ NUM '0'
        ├─ FOR_STMT
        │   ├─ FOR_INIT ...
        │   ├─ FOR_COND ...
        │   ├─ FOR_UPDATE ...
        │   └─ BLOCK
        │       └─ IF_STMT ...
        ├─ EXPR_STMT
        │   └─ FUNC_CALL
        │       ├─ ID 'printf'
        │       └─ ARG_LIST ...
        └─ RETURN_STMT
            └─ NUM '0'
    ```
  ],
)


// ============================================================
// SEÇÃO 5 — Conclusão
// ============================================================
= Conclusão

== Resumo

#grid(
  columns: (1fr, 1fr),
  gutter: 20pt,

  [
    *O que aprendemos:*
    #v(0.3em)
    - A *análise sintática* é a 2ª fase da compilação
    - O parser consome tokens e verifica conformidade com a gramática
    - Rewrite rules (`-> ^(...)`) constroem a *AST* automaticamente
    - Tokens imaginários (`PROGRAM`, `FUNC_DEF`, etc.) formam os nós internos da árvore
    - Um programa *aceito* produz uma AST; um *rejeitado* gera erros sintáticos

    #v(0.5em)
    *Ferramentas utilizadas:*
    - ANTLR 3
    - Runtime Java do ANTLR 3
    - `javac` / `java` (JDK)
  ],

  [
    *Regras do parser implementadas:*
    - `program` — estrutura completa do arquivo C
    - `includeDir` — diretiva `#include`
    - `functionDef` — definição de função
    - `block` — bloco de instruções `{ ... }`
    - `varDecl` — declaração de variável
    - `assignStmt` — atribuição
    - `forStmt` — laço `for` com `forInit`, `forCond`, `forUpdate`
    - `ifStmt` — condicional `if`
    - `returnStmt` — instrução `return`
    - `exprStmt` — expressões como `printf(...)`
    - `expr` / `term` / `argList` — expressões e argumentos
  ],
)


== Referências

#v(0.5em)

- *DOUGLAS, Johny.* _Compiladores para Humanos_. GitBook. Disponível em: #link("https://johnidouglas.gitbook.io/compiladores-para-humanos")[johnidouglas.gitbook.io]

- *ANTLR.* _ANTLR 3 Documentation_. Disponível em: #link("https://www.antlr3.org")[antlr3.org]

- *PARR, Terence.* _The Definitive ANTLR Reference_. Pragmatic Bookshelf, 2007.

- *Repositório do projeto:* disponível na descrição do vídeo (GitHub)

#v(1.5em)
