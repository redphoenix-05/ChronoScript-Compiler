#!/bin/bash
# Build script for ChronoScript Parser on Unix/Linux/macOS

echo "========================================="
echo "ChronoScript Parser Build Script"
echo "========================================="
echo

# Check if flex is available
if ! command -v flex &> /dev/null; then
    echo "ERROR: flex not found in PATH"
    echo "Please install Flex"
    exit 1
fi

# Check if bison is available
if ! command -v bison &> /dev/null; then
    echo "ERROR: bison not found in PATH"
    echo "Please install Bison"
    exit 1
fi

# Check if gcc is available
if ! command -v gcc &> /dev/null; then
    echo "ERROR: gcc not found in PATH"
    echo "Please install GCC"
    exit 1
fi

echo "Step 1: Generating lexer from chronoscript.l..."
flex chronoscript.l
if [ $? -ne 0 ]; then
    echo "ERROR: Flex failed"
    exit 1
fi
echo "[OK] Lexer generated: lex.yy.c"
echo

echo "Step 2: Generating parser from chronoscript.y..."
bison -d -v chronoscript.y
if [ $? -ne 0 ]; then
    echo "ERROR: Bison failed"
    exit 1
fi
echo "[OK] Parser generated: chronoscript.tab.c, chronoscript.tab.h"
echo

echo "Step 3: Compiling parser..."
gcc lex.yy.c chronoscript.tab.c -o chronoscript_parser -lfl
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation failed"
    exit 1
fi
echo "[OK] Parser compiled: chronoscript_parser"
echo

echo "========================================="
echo "Build completed successfully!"
echo "========================================="
echo
echo "Run the parser with:"
echo "  ./chronoscript_parser test_samples/test1_declarations.cs"
echo

exit 0
