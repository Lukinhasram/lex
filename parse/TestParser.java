import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

public class TestParser {

    // Mapa de token IDs para nomes legíveis
    private static final Map<Integer, String> tokenNames = new HashMap<>();

    static {
        tokenNames.put(CParserParser.ASSIGN, "ASSIGN");
        tokenNames.put(CParserParser.COMMA, "COMMA");
        tokenNames.put(CParserParser.COMMENT, "COMMENT");
        tokenNames.put(CParserParser.DOT, "DOT");
        tokenNames.put(CParserParser.EQ, "EQ");
        tokenNames.put(CParserParser.FOR, "FOR");
        tokenNames.put(CParserParser.GT, "GT");
        tokenNames.put(CParserParser.ID, "ID");
        tokenNames.put(CParserParser.IF, "IF");
        tokenNames.put(CParserParser.INC, "INC");
        tokenNames.put(CParserParser.INCLUDE, "INCLUDE");
        tokenNames.put(CParserParser.INT, "INT");
        tokenNames.put(CParserParser.LBRACE, "LBRACE");
        tokenNames.put(CParserParser.LE, "LE");
        tokenNames.put(CParserParser.LPAREN, "LPAREN");
        tokenNames.put(CParserParser.LT, "LT");
        tokenNames.put(CParserParser.MOD, "MOD");
        tokenNames.put(CParserParser.NUM, "NUM");
        tokenNames.put(CParserParser.PLUS, "PLUS");
        tokenNames.put(CParserParser.RBRACE, "RBRACE");
        tokenNames.put(CParserParser.RETURN, "RETURN");
        tokenNames.put(CParserParser.RPAREN, "RPAREN");
        tokenNames.put(CParserParser.SEMI, "SEMI");
        tokenNames.put(CParserParser.STRING, "STRING");
        tokenNames.put(CParserParser.WS, "WS");
    }

    // Mapa de token IDs de nós imaginários para nomes legíveis
    private static final Map<Integer, String> astNodeNames = new HashMap<>();

    static {
        astNodeNames.put(CParserParser.PROGRAM, "PROGRAM");
        astNodeNames.put(CParserParser.FUNC_DEF, "FUNC_DEF");
        astNodeNames.put(CParserParser.BLOCK, "BLOCK");
        astNodeNames.put(CParserParser.VAR_DECL, "VAR_DECL");
        astNodeNames.put(CParserParser.FOR_STMT, "FOR_STMT");
        astNodeNames.put(CParserParser.FOR_INIT, "FOR_INIT");
        astNodeNames.put(CParserParser.FOR_COND, "FOR_COND");
        astNodeNames.put(CParserParser.FOR_UPDATE, "FOR_UPDATE");
        astNodeNames.put(CParserParser.IF_STMT, "IF_STMT");
        astNodeNames.put(CParserParser.RETURN_STMT, "RETURN_STMT");
        astNodeNames.put(CParserParser.ASSIGN_STMT, "ASSIGN_STMT");
        astNodeNames.put(CParserParser.EXPR_STMT, "EXPR_STMT");
        astNodeNames.put(CParserParser.FUNC_CALL, "FUNC_CALL");
        astNodeNames.put(CParserParser.ARG_LIST, "ARG_LIST");
        astNodeNames.put(CParserParser.INCLUDE_DIR, "INCLUDE_DIR");
    }

    public static void main(String[] args) throws Exception {
        // Código C a ser analisado (SomaPares.c)
        String code = "#include <stdio.h>\n\n" +
            "int main() {\n" +
            "    int soma = 0;\n" +
            "    for (int i = 0; i <= 10; i++) {\n" +
            "        if (i % 2 == 0) {\n" +
            "            soma = soma + i;\n" +
            "        }\n" +
            "    }\n" +
            "    printf(\"%d\", soma);\n" +
            "    return 0;\n" +
            "}\n";

        // Abrir arquivo para escrita
        PrintWriter writer = new PrintWriter(new FileWriter("parse_result.txt"));

        // ============================================================
        // PARTE 1 — ANÁLISE LÉXICA
        // ============================================================
        String header = "╔══════════════════════════════════════════════════╗\n" +
                         "║         ANÁLISE LÉXICA + SINTÁTICA ANTLR3       ║\n" +
                         "╚══════════════════════════════════════════════════╝";
        output(header, writer);

        output("\n━━━ FASE 1: ANÁLISE LÉXICA ━━━\n", writer);

        // Criar um CharStream a partir do código
        ANTLRStringStream input1 = new ANTLRStringStream(code);
        CParserLexer lexer1 = new CParserLexer(input1);

        String tableHeader = String.format("%-5s %-8s %-15s %-15s", "Linha", "Coluna", "Tipo", "Valor");
        output(tableHeader, writer);
        output("-".repeat(50), writer);

        int count = 0;
        Token token;
        while ((token = lexer1.nextToken()).getType() != Token.EOF) {
            String tokenName = tokenNames.getOrDefault(token.getType(), "UNKNOWN");
            String line = String.format("%-5d %-8d %-15s %-15s",
                token.getLine(),
                token.getCharPositionInLine() + 1,
                tokenName,
                "'" + token.getText() + "'");
            output(line, writer);
            count++;
        }

        output("-".repeat(50), writer);
        output(String.format("\nTotal de tokens: %d", count), writer);

        // ============================================================
        // PARTE 2 — ANÁLISE SINTÁTICA
        // ============================================================
        output("\n━━━ FASE 2: ANÁLISE SINTÁTICA ━━━\n", writer);

        // Recriar o lexer para o parser (o stream foi consumido)
        ANTLRStringStream input2 = new ANTLRStringStream(code);
        CParserLexer lexer2 = new CParserLexer(input2);
        CommonTokenStream tokens = new CommonTokenStream(lexer2);

        // Criar o parser
        CParserParser parser = new CParserParser(tokens);

        try {
            // Executar a análise sintática a partir da regra inicial 'program'
            CParserParser.program_return result = parser.program();

            // Verificar se houve erros
            int numErrors = parser.getNumberOfSyntaxErrors();

            if (numErrors == 0) {
                output("✓ Programa ACEITO pela gramática!", writer);
                output("  Nenhum erro sintático encontrado.\n", writer);
            } else {
                output(String.format("✗ Programa REJEITADO: %d erro(s) sintático(s) encontrado(s).\n", numErrors), writer);
            }

            // Exibir a árvore sintática (AST)
            if (result.getTree() != null) {
                Tree tree = (Tree) result.getTree();

                // AST em formato linear (toStringTree)
                output("━━━ ÁRVORE SINTÁTICA (AST — formato linear) ━━━\n", writer);
                output(tree.toStringTree(), writer);

                // AST formatada com indentação hierárquica
                output("\n━━━ ÁRVORE SINTÁTICA (AST — formato hierárquico) ━━━\n", writer);
                printTree(tree, 0, "", true, writer);
            }

        } catch (RecognitionException e) {
            output("✗ Erro de reconhecimento: " + e.getMessage(), writer);
        }

        // ============================================================
        // RESUMO FINAL
        // ============================================================
        output("\n━━━ RESUMO ━━━\n", writer);
        output("Programa analisado:  SomaPares.c", writer);
        output("Total de tokens:     " + count, writer);
        output("Gramática utilizada: CParser.g", writer);
        output("Ferramenta:          ANTLR 3.5.3", writer);

        writer.close();
        System.out.println("\nResultados salvos em 'parse_result.txt'");
    }

    /**
     * Imprime texto no console e no arquivo simultaneamente.
     */
    private static void output(String text, PrintWriter writer) {
        System.out.println(text);
        writer.println(text);
    }

    /**
     * Imprime a árvore sintática com indentação hierárquica estilo tree.
     * Usa caracteres │, ├─ e └─ para representar a estrutura.
     */
    private static void printTree(Tree tree, int depth, String prefix, boolean isLast, PrintWriter writer) {
        StringBuilder sb = new StringBuilder();

        if (depth > 0) {
            sb.append(prefix);
            sb.append(isLast ? "└─ " : "├─ ");
        }

        // Determinar o nome do nó
        String nodeText = tree.getText();
        int nodeType = tree.getType();

        // Verificar se é um nó imaginário da AST
        String astName = astNodeNames.get(nodeType);
        if (astName != null) {
            sb.append(astName);
        } else if (nodeText == null || nodeText.equals("nil")) {
            sb.append("(raiz)");
        } else {
            // Token real — mostrar tipo e valor
            String typeName = tokenNames.getOrDefault(nodeType, "?");
            sb.append(typeName).append(" '").append(nodeText).append("'");
        }

        output(sb.toString(), writer);

        // Preparar o prefixo para os filhos
        String childPrefix = prefix + (depth > 0 ? (isLast ? "   " : "│  ") : "");

        // Imprimir filhos recursivamente
        int childCount = tree.getChildCount();
        for (int i = 0; i < childCount; i++) {
            printTree(tree.getChild(i), depth + 1, childPrefix, i == childCount - 1, writer);
        }
    }
}
