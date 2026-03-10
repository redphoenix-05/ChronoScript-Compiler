@echo off
REM Build script for ChronoScript Parser on Windows
REM Requires: Flex, Bison, and GCC (MinGW or similar)

echo =========================================
echo ChronoScript Parser Build Script
echo =========================================
echo.

REM Check if flex is available
where flex >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: flex not found in PATH
    echo Please install Flex or add it to your PATH
    exit /b 1
)

REM Check if bison is available
where bison >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: bison not found in PATH
    echo Please install Bison or add it to your PATH
    exit /b 1
)

REM Check if gcc is available
where gcc >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: gcc not found in PATH
    echo Please install GCC (MinGW) or add it to your PATH
    exit /b 1
)

echo Step 1: Generating lexer from chronoscript.l...
flex chronoscript.l
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flex failed
    exit /b 1
)
echo [OK] Lexer generated: lex.yy.c
echo.

echo Step 2: Generating parser from chronoscript.y...
bison -d -v chronoscript.y
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Bison failed
    exit /b 1
)
echo [OK] Parser generated: chronoscript.tab.c, chronoscript.tab.h
echo.

echo Step 3: Compiling parser...
gcc lex.yy.c chronoscript.tab.c -o chronoscript_parser.exe
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Compilation failed
    exit /b 1
)
echo [OK] Parser compiled: chronoscript_parser.exe
echo.

echo =========================================
echo Build completed successfully!
echo =========================================
echo.
echo Run the parser with:
echo   chronoscript_parser.exe test_samples\test1_declarations.cs
echo.

exit /b 0
