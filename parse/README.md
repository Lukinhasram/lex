# Analisador Léxico e Sintático — Subconjunto de C com ANTLR 3

---

## Sobre o Projeto

Este projeto implementa um **analisador léxico** e um **analisador sintático** para o programa `SomaPares.c`, que calcula a soma dos números pares de 0 a 10.

- **Análise Léxica**: A gramática `CLexer.g` define as regras do lexer. A classe `TestLexer.java` alimenta o programa C ao lexer e imprime cada token reconhecido com sua linha, coluna, tipo e valor.
- **Análise Sintática**: A gramática combinada `CParser.g` define regras do lexer e do parser. A classe `TestParser.java` executa ambas as fases e exibe a **Árvore Sintática Abstrata (AST)** gerada.

---

## Estrutura do Projeto

```
.
├── CLexer.g              # Gramática do lexer (ANTLR 3)
├── CParser.g             # Gramática combinada lexer+parser (ANTLR 3)
├── SomaPares.c           # Programa C analisado
├── TestLexer.java        # Driver: executa o lexer e exibe os tokens
├── TestParser.java       # Driver: executa lexer + parser e exibe a AST
├── CLexer.java           # Gerado pelo ANTLR a partir de CLexer.g (não editar)
├── CLexer.tokens         # Tabela de tokens do CLexer (não editar)
├── CParserParser.java    # Parser gerado pelo ANTLR a partir de CParser.g (não editar)
├── CParserLexer.java     # Lexer gerado pelo ANTLR a partir de CParser.g (não editar)
├── CParser.tokens        # Tabela de tokens do CParser (não editar)
├── tokens.txt            # Saída da análise léxica (gerado em tempo de execução)
└── parse_result.txt      # Saída da análise léxica + sintática (gerado em tempo de execução)
```

---

## Pré-requisitos

- **Java JDK** 8 ou superior
- **ANTLR 3** — jar disponível em [antlr3.org](https://www.antlr3.org)

Salve o jar como `antlr-3.5.3-complete.jar` na raiz do projeto (ou ajuste o caminho nos comandos abaixo).

---

## Como Executar

### Análise Léxica (apenas tokens)

#### 1. Gerar o lexer a partir da gramática

```bash
java -jar antlr-3.5.3-complete.jar CLexer.g
```

Isso gera `CLexer.java` e `CLexer.tokens`.

#### 2. Compilar

```bash
javac -cp .:antlr-3.5.3-complete.jar CLexer.java TestLexer.java
```

> No Windows, substitua `:` por `;` no classpath.

#### 3. Executar

```bash
java -cp .:antlr-3.5.3-complete.jar TestLexer
```

A saída é exibida no terminal e salva em `tokens.txt`.

---

### Análise Léxica + Sintática (tokens + AST)

#### 1. Gerar o parser a partir da gramática combinada

```bash
java -jar antlr-3.5.3-complete.jar CParser.g
```

Isso gera `CParserParser.java`, `CParserLexer.java` e `CParser.tokens`.

#### 2. Compilar

```bash
javac -cp .:antlr-3.5.3-complete.jar CParserParser.java CParserLexer.java TestParser.java
```

#### 3. Executar

```bash
java -cp .:antlr-3.5.3-complete.jar TestParser
```

A saída é exibida no terminal e salva em `parse_result.txt`.

---

## Tokens Reconhecidos

| Categoria       | Tokens                                                      |
|-----------------|-------------------------------------------------------------|
| Palavras-chave  | `INT`, `FOR`, `IF`, `RETURN`, `INCLUDE`                     |
| Identificadores | `ID`                                                        |
| Literais        | `NUM`, `STRING`                                             |
| Operadores      | `EQ` (`==`), `LE` (`<=`), `INC` (`++`), `PLUS`, `ASSIGN`, `MOD`, `DOT` |
| Delimitadores   | `LPAREN`, `RPAREN`, `LBRACE`, `RBRACE`, `SEMI`, `LT`, `GT`, `COMMA` |
| Ignorados       | `WS` (espaços/quebras de linha), `COMMENT` (comentários `//`) |

Operadores multi-caractere (`==`, `<=`, `++`) são declarados antes dos de um caractere para garantir prioridade na correspondência. Palavras-chave são declaradas antes de `ID` pelo mesmo motivo.

---

## Regras do Parser (Gramática Sintática)

A gramática `CParser.g` define as seguintes produções para validar a estrutura do programa:

| Regra          | Produção                                                                 |
|----------------|--------------------------------------------------------------------------|
| `program`      | `includeDir functionDef EOF`                                             |
| `includeDir`   | `INCLUDE LT ID (DOT ID)? GT`                                            |
| `functionDef`  | `type ID LPAREN RPAREN block`                                            |
| `block`        | `LBRACE statement* RBRACE`                                               |
| `statement`    | `varDecl \| assignStmt \| forStmt \| ifStmt \| returnStmt \| exprStmt`   |
| `varDecl`      | `type ID (ASSIGN expr)? SEMI`                                            |
| `assignStmt`   | `ID ASSIGN expr SEMI`                                                    |
| `forStmt`      | `FOR LPAREN forInit SEMI forCond SEMI forUpdate RPAREN block`            |
| `forInit`      | `type ID ASSIGN expr`                                                    |
| `forCond`      | `expr`                                                                   |
| `forUpdate`    | `ID INC`                                                                 |
| `ifStmt`       | `IF LPAREN expr RPAREN block`                                            |
| `returnStmt`   | `RETURN expr SEMI`                                                       |
| `exprStmt`     | `expr SEMI`                                                              |
| `expr`         | `term ((PLUS \| EQ \| LE \| LT \| GT \| MOD) term)*`                    |
| `term`         | `ID LPAREN argList? RPAREN \| ID \| NUM \| STRING`                       |
| `argList`      | `expr (COMMA expr)*`                                                     |
| `type`         | `INT`                                                                    |

---

## Nós da AST (Árvore Sintática Abstrata)

O parser utiliza **tokens imaginários** para criar nós significativos na AST:

| Nó Imaginário   | Significado                              |
|-----------------|------------------------------------------|
| `PROGRAM`       | Nó raiz do programa                      |
| `FUNC_DEF`      | Definição de função                      |
| `BLOCK`         | Bloco de código `{ ... }`                |
| `VAR_DECL`      | Declaração de variável                   |
| `ASSIGN_STMT`   | Atribuição (`soma = expr`)               |
| `FOR_STMT`      | Laço `for`                               |
| `FOR_INIT`      | Inicialização do `for`                   |
| `FOR_COND`      | Condição do `for`                        |
| `FOR_UPDATE`    | Atualização do `for`                     |
| `IF_STMT`       | Condicional `if`                         |
| `RETURN_STMT`   | Instrução `return`                       |
| `EXPR_STMT`     | Expressão como instrução (ex: `printf()`) |
| `FUNC_CALL`     | Chamada de função                        |
| `ARG_LIST`      | Lista de argumentos de função            |
| `INCLUDE_DIR`   | Diretiva `#include`                      |

---

## Exemplo de Saída

Entrada (`SomaPares.c`):

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

### Saída da Análise Léxica (trecho):

```
━━━ FASE 1: ANÁLISE LÉXICA ━━━

Linha Coluna   Tipo            Valor
--------------------------------------------------
1     1        INCLUDE         '#include'
1     10       LT              '<'
1     11       ID              'stdio'
1     16       DOT             '.'
1     17       ID              'h'
1     18       GT              '>'
3     1        INT             'int'
3     5        ID              'main'
3     9        LPAREN          '('
3     10       RPAREN          ')'
3     12       LBRACE          '{'
...
--------------------------------------------------
Total de tokens: 59
```

### Saída da Análise Sintática:

```
━━━ FASE 2: ANÁLISE SINTÁTICA ━━━

✓ Programa ACEITO pela gramática!
  Nenhum erro sintático encontrado.
```

### Árvore Sintática Abstrata (AST):

```
PROGRAM
├─ INCLUDE_DIR
│  ├─ INCLUDE '#include'
│  ├─ ID 'stdio'
│  └─ ID 'h'
└─ FUNC_DEF
   ├─ INT 'int'
   ├─ ID 'main'
   └─ BLOCK
      ├─ VAR_DECL
      │  ├─ INT 'int'
      │  ├─ ID 'soma'
      │  └─ NUM '0'
      ├─ FOR_STMT
      │  ├─ FOR_INIT
      │  │  ├─ INT 'int'
      │  │  ├─ ID 'i'
      │  │  └─ NUM '0'
      │  ├─ FOR_COND
      │  │  ├─ ID 'i'
      │  │  ├─ LE '<='
      │  │  └─ NUM '10'
      │  ├─ FOR_UPDATE
      │  │  ├─ ID 'i'
      │  │  └─ INC '++'
      │  └─ BLOCK
      │     └─ IF_STMT
      │        ├─ ID 'i'
      │        ├─ MOD '%'
      │        ├─ NUM '2'
      │        ├─ EQ '=='
      │        ├─ NUM '0'
      │        └─ BLOCK
      │           └─ ASSIGN_STMT
      │              ├─ ID 'soma'
      │              ├─ ID 'soma'
      │              ├─ PLUS '+'
      │              └─ ID 'i'
      ├─ EXPR_STMT
      │  └─ FUNC_CALL
      │     ├─ ID 'printf'
      │     └─ ARG_LIST
      │        ├─ STRING '"%d"'
      │        └─ ID 'soma'
      └─ RETURN_STMT
         └─ NUM '0'
```

---

## Referências

- DOUGLAS, Johny. *Compiladores para Humanos*. Disponível em: [johnidouglas.gitbook.io](https://johnidouglas.gitbook.io/compiladores-para-humanos)
- ANTLR. *ANTLR 3 Documentation*. Disponível em: [antlr3.org](https://www.antlr3.org)
- PARR, Terence. *The Definitive ANTLR Reference*. Pragmatic Bookshelf, 2007.