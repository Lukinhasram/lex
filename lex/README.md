# Analisador Léxico — Subconjunto de C com ANTLR 3

---

## Sobre o Projeto

O lexer reconhece os tokens do programa `SomaPares.c`, que calcula a soma dos números pares de 0 a 10. A partir da gramática `CLexer.g`, o ANTLR 3 gera automaticamente o lexer em Java. A classe `TestLexer.java` alimenta o programa C ao lexer e imprime cada token reconhecido com sua linha, coluna, tipo e valor.

---

## Estrutura do Projeto

```
.
├── CLexer.g          # Gramática do lexer (ANTLR 3)
├── SomaPares.c       # Programa C analisado
├── TestLexer.java    # Driver: executa o lexer e exibe os tokens
├── CLexer.java       # Gerado pelo ANTLR (não editar)
├── CLexer.tokens     # Tabela de tokens gerada pelo ANTLR (não editar)
└── tokens.txt        # Saída da análise léxica (gerado em tempo de execução)
```

---

## Pré-requisitos

- **Java JDK** 8 ou superior
- **ANTLR 3** — jar disponível em [antlr3.org](https://www.antlr3.org)

Salve o jar como `antlr-3.5.3-complete.jar` na raiz do projeto (ou ajuste o caminho nos comandos abaixo).

---

## Como Executar

### 1. Gerar o lexer a partir da gramática

```bash
java -jar antlr-3.5.3-complete.jar CLexer.g
```

Isso gera `CLexer.java` e `CLexer.tokens`.

### 2. Compilar

```bash
javac -cp .:antlr-3.5.3-complete.jar CLexer.java TestLexer.java
```

> No Windows, substitua `:` por `;` no classpath.

### 3. Executar

```bash
java -cp .:antlr-3.5.3-complete.jar TestLexer
```

A saída é exibida no terminal e salva em `tokens.txt`.

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

Saída (trecho):

```
=== ANÁLISE LÉXICA ANTLR3 ===

Linha Coluna Tipo            Valor
--------------------------------------------------
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
...
--------------------------------------------------
Total de tokens: 62
```

---

## Referências

- DOUGLAS, Johny. *Compiladores para Humanos*. Disponível em: [johnidouglas.gitbook.io](https://johnidouglas.gitbook.io/compiladores-para-humanos)
- ANTLR. *ANTLR 3 Documentation*. Disponível em: [antlr3.org](https://www.antlr3.org)
- PARR, Terence. *The Definitive ANTLR Reference*. Pragmatic Bookshelf, 2007.