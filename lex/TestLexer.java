import org.antlr.runtime.*;
import java.io.IOException;
import java.io.FileWriter;
import java.util.HashMap;
import java.util.Map;

public class TestLexer {
    
    // Mapa de token IDs para nomes
    private static final Map<Integer, String> tokenNames = new HashMap<>();
    
    static {
        tokenNames.put(CLexer.ASSIGN, "ASSIGN");
        tokenNames.put(CLexer.COMMA, "COMMA");
        tokenNames.put(CLexer.COMMENT, "COMMENT");
        tokenNames.put(CLexer.DOT, "DOT");
        tokenNames.put(CLexer.EQ, "EQ");
        tokenNames.put(CLexer.FOR, "FOR");
        tokenNames.put(CLexer.GT, "GT");
        tokenNames.put(CLexer.ID, "ID");
        tokenNames.put(CLexer.IF, "IF");
        tokenNames.put(CLexer.INC, "INC");
        tokenNames.put(CLexer.INCLUDE, "INCLUDE");
        tokenNames.put(CLexer.INT, "INT");
        tokenNames.put(CLexer.LBRACE, "LBRACE");
        tokenNames.put(CLexer.LE, "LE");
        tokenNames.put(CLexer.LPAREN, "LPAREN");
        tokenNames.put(CLexer.LT, "LT");
        tokenNames.put(CLexer.MOD, "MOD");
        tokenNames.put(CLexer.NUM, "NUM");
        tokenNames.put(CLexer.PLUS, "PLUS");
        tokenNames.put(CLexer.RBRACE, "RBRACE");
        tokenNames.put(CLexer.RETURN, "RETURN");
        tokenNames.put(CLexer.RPAREN, "RPAREN");
        tokenNames.put(CLexer.SEMI, "SEMI");
        tokenNames.put(CLexer.STRING, "STRING");
        tokenNames.put(CLexer.WS, "WS");
    }
    
    public static void main(String[] args) throws Exception {
        // Código C a ser analisado
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

        // Criar um CharStream a partir do código
        ANTLRStringStream input = new ANTLRStringStream(code);

        // Criar o lexer
        CLexer lexer = new CLexer(input);

        // Obter todos os tokens
        Token token;
        
        System.out.println("=== ANÁLISE LÉXICA ANTLR3 ===\n");
        System.out.printf("%-5s %-8s %-15s %-15s%n", "Linha", "Coluna", "Tipo", "Valor");
        System.out.println("-".repeat(50));
        
        // Abrir arquivo para escrita
        FileWriter writer = new FileWriter("tokens.txt");
        writer.write("=== ANÁLISE LÉXICA ANTLR3 ===\n\n");
        writer.write(String.format("%-5s %-8s %-15s %-15s%n", "Linha", "Coluna", "Tipo", "Valor"));
        writer.write("-".repeat(50) + "\n");
        
        int count = 0;
        while ((token = lexer.nextToken()).getType() != Token.EOF) {
            String tokenName = tokenNames.getOrDefault(token.getType(), "UNKNOWN");
            String line = String.format("%-5d %-8d %-15s %-15s%n", 
                token.getLine(), 
                token.getCharPositionInLine() + 1,
                tokenName,
                "'" + token.getText() + "'");
            
            System.out.print(line);
            writer.write(line);
            count++;
        }
        
        System.out.println("-".repeat(50));
        writer.write("-".repeat(50) + "\n");
        
        System.out.printf("\nTotal de tokens: %d\n", count);
        writer.write(String.format("\nTotal de tokens: %d\n", count));
        
        writer.close();
        System.out.println("\nTokens salvos em 'tokens.txt'");
    }
}
