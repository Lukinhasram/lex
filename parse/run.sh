#!/bin/bash
# ============================================================
# Script para executar a análise léxica + sintática do SomaPares.c
# Gera o parser, compila e executa tudo em um único comando.
# ============================================================

set -e  # Parar em caso de erro

JAR="antlr-3.5.3-complete.jar"
CP=".:$JAR"

echo "╔══════════════════════════════════════════════════╗"
echo "║     BUILD & RUN — Analisador Léxico+Sintático    ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Passo 0: Limpar arquivos compilados anteriores
rm -f *.class

# Passo 1: Gerar lexer e parser a partir das gramáticas
echo "[1/3] Gerando lexer e parser com ANTLR 3..."
java -jar "$JAR" CParser.g
echo "Arquivos gerados: CLexer.java, CParserParser.java, CParserLexer.java"
echo ""

# Passo 2: Compilar tudo
echo "[2/3] Compilando arquivos Java..."
javac -cp "$CP" CParserParser.java CParserLexer.java TestParser.java
echo "Compilação concluída sem erros"
echo ""

# Passo 3: Executar a análise completa
echo "[3/3] Executando análise léxica + sintática..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

java -cp "$CP" TestParser
