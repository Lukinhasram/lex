#import "lib.typ": *

#show: slides.with(
  title: "Compiladores — Análise Léxica",
  subtitle: "Análise Léxica com ANTLR 3 — Subconjunto de C",
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
*Gramática:* `CLexer.g` — Lexer para um subconjunto de C (Soma dos Pares)


== O que é Análise Léxica?

#v(7em)

#quote(attribution: [Johny Douglas — _Compiladores para Humanos_])[
  "A análise léxica, também conhecida como _scanner_ ou leitura,
  é a *primeira fase* de um processo de compilação e sua função é
  fazer a leitura do programa fonte, caractere a caractere, agrupar
  os caracteres em *lexemas* e produzir uma sequência de símbolos
  léxicos conhecidos como *tokens*."
]

#pagebreak()

Na prática, dado o texto de entrada:

```c
#include <stdio.h>

int main() {
  int soma = 0;
  for (int i = 0; i <= 10; i++) {
    if (i % 2 == 0) {
      soma = soma + i;
    }
  }
  printf("%d", soma);
  return 0;
}
```

O analisador léxico reconhece cada pedaço significativo e o classifica como um *token*.


== Fluxo da Compilação

#align(center + horizon)[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
    gutter: 6pt,
    align: center + horizon,

    block(fill: blue.darken(60%), radius: 4pt, inset: 8pt,
      text(fill: white, weight: "bold", size: 0.85em)[Código\ Fonte]),
    text(size: 1.4em)[→],
    block(fill: red.darken(20%), radius: 4pt, inset: 8pt,
      text(fill: white, weight: "bold", size: 0.85em)[Análise\ *Léxica*]),
    text(size: 1.4em)[→],
    block(fill: green.darken(30%), radius: 4pt, inset: 8pt,
      text(fill: white, weight: "bold", size: 0.85em)[Análise\ Sintática]),
    text(size: 1.4em)[→],
    block(fill: luma(80), radius: 4pt, inset: 8pt,
      text(fill: white, weight: "bold", size: 0.85em)[Geração\ de Código]),
  )
  #v(0.6em)
  
  A *análise léxica* é a *primeira etapa*: transforma o texto bruto em uma sequência de tokens que o parser irá consumir.
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
    - Regras do *Lexer* (maiúsculas)
    - Regras do *Parser* (minúsculas)
    - Opção de linguagem alvo

    #v(0.6em)
    *Executa:*
    ```bash
    antlr3 CLexer.g
    ```
  ],

  [
    *O ANTLR gera automaticamente:*
    #v(0.3em)
    - `CLexer.java` — lexer gerado
    - `CLexer.tokens` — tabela de tokens
    - Compilar com `javac -cp antlr-3.x.jar CLexer.java`

    #v(0.3em)
    #text(size: 0.85em, style: "italic", fill: luma(80))[
      O `CLexer.java` é a implementação do lexer
      que realiza a tokenização da entrada em Java.
    ]
  ],
)

// ============================================================
// SEÇÃO 3 — Gramática
// ============================================================
= A Gramática

== Gramática: Subconjunto de C


#v(0.4em)

*Código fonte analisado:*

```c
#include <stdio.h>

int main() {
  int soma = 0;
  for (int i = 0; i <= 10; i++) {
    if (i % 2 == 0) {
      soma = soma + i;
    }
  }
  printf("%d", soma);
  return 0;
}
```



#grid(
  columns: (auto, 1fr),
  gutter: 6pt,
  [*T* (terminais):], [`INT`, `FOR`, `IF`, `RETURN`, `INCLUDE`, `STRING`, `ID`, `NUM`, `EQ`, `LE`, `INC`, `PLUS`, `ASSIGN`, `MOD`, `DOT`, `LPAREN`, `RPAREN`, `LBRACE`, `RBRACE`, `SEMI`, `LT`, `GT`, `COMMA`],
)


== Produções da Gramática

#grid(
  columns: (1fr, 1fr),
  gutter: 20pt,

  [
  *Este projeto usa apenas lexer*
      #v(0.3em)
  O arquivo atual não possui parser. Ele define somente o lexer `CLexer.g`, que reconhece palavras-chave, identificadores, números, operadores, strings, delimitadores e comentários.
  ],

  [
    *Regras do Lexer* 
    #v(0.3em)
    ```antlr
        INT     : 'int';
        FOR     : 'for';
        IF      : 'if';
        RETURN  : 'return';
        INCLUDE : '#include';
        STRING  : '"' (~'"')* '"';
        ID      : ('a'..'z'|'A'..'Z'|'_')
                  ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
        NUM     : '0'..'9'+;
        EQ      : '==';
        LE      : '<=';
        INC     : '++';
        PLUS    : '+';
        ASSIGN  : '=';
        MOD     : '%';
        DOT     : '.';
        LPAREN  : '(';
        RPAREN  : ')';
        LBRACE  : '{';
        RBRACE  : '}';
        SEMI    : ';';
        LT      : '<';
        GT      : '>';
        COMMA   : ',';
        WS      : (' '|'\t'|'\r'|'\n')+ { skip(); };
        COMMENT : '//' (~'\n')* { skip(); };
    ```
    #v(0.3em)
    #text(size: 0.82em, fill: luma(80))[
      `skip()`: espaços e comentários são descartados antes de gerar os tokens.
    ]
  ],
)


== Tabela de Tokens Gerada

Após executar o ANTLR, o arquivo `CLexer.tokens` contém:

#v(0.4em)

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

#v(0.3em)
#text(size: 0.85em, fill: luma(80))[
  O ANTLR classifica tokens em: *literais*, *regulares* e *implícitos* (EOF).
]

// ============================================================
// SEÇÃO 4 — Análise Léxica na Prática
// ============================================================
= Análise Léxica na Prática

== O Arquivo de Gramática (.g)

#grid(
  columns: (1fr, 1fr),
  gutter: 16pt,

  [
    O arquivo `CLexer.g` é o *ponto de partida*:

    #v(0.3em)
    - Extensão `.g` = gramática *ANTLR 3*
    - Nome do arquivo = nome declarado em `lexer grammar`
    - Opção `language = Java` define a linguagem alvo
    - Apenas regras do *lexer* (MAIÚSCULAS)
    - `WS` e `COMMENT` usam `skip()` (ANTLR 3)

    #v(0.5em)
    Para gerar os arquivos Java:

```bash
    antlr3 CLexer.g
    javac -cp antlr-3.x.jar CLexer.java TestLexer.java
    java  -cp .:antlr-3.x.jar TestLexer
```
  ],

  text(size: 9pt)[
  ```antlr
      lexer grammar CLexer;

      options { language = Java; }

      // Palavras-chave (antes de ID)
      INT     : 'int';
      FOR     : 'for';
      IF      : 'if';
      RETURN  : 'return';
      INCLUDE : '#include';

      // Strings (para o printf)
      STRING : '"' (~'"')* '"';

      // Identificadores e números
      ID  : ('a'..'z'|'A'..'Z'|'_')
            ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
      NUM : '0'..'9'+;

      // Operadores (multi-char antes de single-char)
      EQ  : '=='; LE : '<='; INC : '++';
      PLUS : '+'; ASSIGN : '=';
      MOD  : '%'; DOT    : '.';

      // Delimitadores
      LPAREN : '('; RPAREN : ')';
      LBRACE : '{'; RBRACE : '}';
      SEMI   : ';'; LT : '<'; GT : '>';
      COMMA  : ',';

      // Ignorados
      WS      : (' '|'\t'|'\r'|'\n')+ { skip(); };
      COMMENT : '//' (~'\n')*          { skip(); };
  ```
  ],
)


== Fluxo de Tokenização no Código C

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

  [1], [*Input Stream*],  [`ANTLRStringStream(code)` — encapsula a string caractere a caractere],
  [2], [*Lexer (AFD)*],   [`CLexer(input)` — percorre a entrada e agrupa em lexemas],
  [3], [*Token Stream*],  [`CommonTokenStream(lexer)` — coleta os tokens em uma fila],
  [4], [*Iteração*],      [`lexer.nextToken()` — retorna o próximo token até `EOF`],
  [5], [*Saída*],         [Imprime linha, coluna, tipo e valor de cada token reconhecido],
)


== Saída da Análise Léxica

Entrada: `SomaPares.c` — programa C que soma os pares de *0 a 10*

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
    - A *análise léxica* é a 1ª fase da compilação
    - Transforma texto em uma sequência de *tokens*
    - O Lexer é implementado como um *Autômato Finito Determinístico (AFD)*
    - O token `WS` com `skip()` é descartado antes de chegar ao Parser

    #v(0.5em)
    *Ferramentas utilizadas:*
    - ANTLR 3
    - Runtime Java do ANTLR3
    - `javac` / `java` (JDK)
  ],

  [    
    *Tipos de tokens no programa analisado:*
    - *Palavras-chave* — `INT`, `FOR`, `IF`, `RETURN`, `INCLUDE`
    - *Identificadores* (`ID`) — `main`, `soma`, `printf`, `i`
    - *Literais numéricos* (`NUM`) — `0`, `2`, `10`
    - *Strings* (`STRING`) — `"%d"`
    - *Operadores* — `EQ` (`==`), `LE` (`<=`), `INC` (`++`), `PLUS`, `ASSIGN`, `MOD`
    - *Delimitadores* — `LPAREN`, `RPAREN`, `LBRACE`, `RBRACE`, `SEMI`, `LT`, `GT`, `COMMA`
    - *WS* e *COMMENT* são descartados via `skip()`

  ],
)


== Referências

#v(0.5em)

- *DOUGLAS, Johny.* _Compiladores para Humanos_. GitBook. Disponível em: #link("https://johnidouglas.gitbook.io/compiladores-para-humanos")[johnidouglas.gitbook.io]

- *ANTLR.* _Runtime C Documentation_. Disponível em: #link("https://www.antlr.org")[antlr.org]

- *Repositório do projeto:* disponível na descrição do vídeo (GitHub)

#v(1.5em)
