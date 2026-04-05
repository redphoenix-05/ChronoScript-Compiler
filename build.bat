@echo off
REM Build script for ChronoScript Compiler on Windows
REM Requires: Flex, Bison, and GCC (MinGW or similar)

echo =========================================
echo  ChronoScript Compiler Build Script
echo =========================================
echo.

REM ---- tool checks ----
where flex  >nul 2>nul
if %ERRORLEVEL% NEQ 0 ( echo ERROR: flex not found in PATH  & exit /b 1 )
where bison >nul 2>nul
if %ERRORLEVEL% NEQ 0 ( echo ERROR: bison not found in PATH & exit /b 1 )
where gcc   >nul 2>nul
if %ERRORLEVEL% NEQ 0 ( echo ERROR: gcc not found in PATH   & exit /b 1 )

REM ---- Step 1: Lexer ----
echo Step 1: Generating lexer (flex) ...
pushd lexer
flex chronoscript.l
if %ERRORLEVEL% NEQ 0 ( popd & echo ERROR: Flex failed & exit /b 1 )
popd
echo [OK] lexer/lex.yy.c
echo.

REM ---- Step 2: Parser ----
echo Step 2: Generating parser (bison) ...
bison -d -v -o chronoscript.tab.c parser/chronoscript.y
if %ERRORLEVEL% NEQ 0 ( echo ERROR: Bison failed & exit /b 1 )
echo [OK] chronoscript.tab.c / chronoscript.tab.h
echo.

REM ---- Step 3: Compile each translation unit ----
echo Step 3: Compiling ...

gcc -c lexer/lex.yy.c       -o lex.yy.o            -I. -w
if %ERRORLEVEL% NEQ 0 ( echo ERROR: lex.yy.c failed      & exit /b 1 )

gcc -c chronoscript.tab.c   -o chronoscript.tab.o   -I. -w
if %ERRORLEVEL% NEQ 0 ( echo ERROR: chronoscript.tab.c failed & exit /b 1 )

gcc -c intermediate/icg.c   -o icg.o               -I. -w
if %ERRORLEVEL% NEQ 0 ( echo ERROR: icg.c failed          & exit /b 1 )

gcc -c optimization/optimizer.c  -o optimizer.o    -I. -w
if %ERRORLEVEL% NEQ 0 ( echo ERROR: optimizer.c failed    & exit /b 1 )

gcc -c target/target_codegen.c   -o target_codegen.o -I. -w
if %ERRORLEVEL% NEQ 0 ( echo ERROR: target_codegen.c failed & exit /b 1 )

echo [OK] All object files compiled
echo.

REM ---- Step 4: Link ----
echo Step 4: Linking ...
gcc lex.yy.o chronoscript.tab.o icg.o optimizer.o target_codegen.o ^
    -o chronoscript_compiler.exe -lm
if %ERRORLEVEL% NEQ 0 ( echo ERROR: Link failed & exit /b 1 )
echo [OK] chronoscript_compiler.exe
echo.

echo =========================================
echo  Build completed successfully!
echo =========================================
echo.
echo Usage:
echo   chronoscript_compiler.exe tests\test1_declarations.cs
echo   chronoscript_compiler.exe tests\simple.cs --ast
echo   chronoscript_compiler.exe tests\demo.cs   --no-pipeline
echo.

exit /b 0
