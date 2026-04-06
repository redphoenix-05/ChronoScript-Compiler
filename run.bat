@echo off
REM Run a ChronoScript source file.
REM Usage:  run.bat tests\calculator.cs
REM
REM Skips flex / bison entirely.
REM Rebuilds the compiler from pre-generated C files only if the exe is missing.

if "%~1"=="" (
    echo Usage: run.bat ^<source.cs^>
    exit /b 1
)

set EXE=chronoscript_compiler.exe

REM ---------- build if exe is missing ----------
if not exist "%EXE%" (
    echo Compiler not found. Building from pre-generated sources...
    where gcc >nul 2>nul
    if %ERRORLEVEL% NEQ 0 ( echo ERROR: gcc not found in PATH & exit /b 1 )

    gcc -c lex.yy.c               -o lex.yy.o           -I. -w
    if %ERRORLEVEL% NEQ 0 ( echo ERROR: lex.yy.c failed        & exit /b 1 )

    gcc -c chronoscript.tab.c     -o chronoscript.tab.o  -I. -w
    if %ERRORLEVEL% NEQ 0 ( echo ERROR: chronoscript.tab.c failed & exit /b 1 )

    gcc -c intermediate/icg.c     -o icg.o               -I. -w
    if %ERRORLEVEL% NEQ 0 ( echo ERROR: icg.c failed            & exit /b 1 )

    gcc -c optimization/optimizer.c -o optimizer.o       -I. -w
    if %ERRORLEVEL% NEQ 0 ( echo ERROR: optimizer.c failed      & exit /b 1 )

    gcc -c target/target_codegen.c  -o target_codegen.o  -I. -w
    if %ERRORLEVEL% NEQ 0 ( echo ERROR: target_codegen.c failed & exit /b 1 )

    gcc lex.yy.o chronoscript.tab.o icg.o optimizer.o target_codegen.o ^
        -o %EXE% -lm
    if %ERRORLEVEL% NEQ 0 ( echo ERROR: Link failed & exit /b 1 )

    echo Compiler built successfully.
    echo.
)

REM ---------- run ----------
%EXE% %*
