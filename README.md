# ChronoScript Compiler - Lexical Analyzer

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Language](https://img.shields.io/badge/language-Flex%2FC-green)
![Course](https://img.shields.io/badge/course-CSE%203212-orange)
![Platform](https://img.shields.io/badge/platform-Linux%20|%20macOS%20|%20Windows%20WSL-lightgrey)

A lexical analyzer (scanner/tokenizer) for **ChronoScript**, a custom programming language with time-themed syntax that maps to C-like constructs.

---

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [ChronoScript Language Reference](#chronoscript-language-reference)
- [Sample Programs](#sample-programs)
- [Output Verification](#output-verification)
- [Technical Details](#technical-details)
- [Troubleshooting](#troubleshooting)
- [Course Information](#course-information)
- [License](#license)

---

## 🎯 Overview

This project implements the **lexical analysis phase** of a compiler for ChronoScript, an educational programming language designed for the CSE 3212 Compiler Lab course. The lexer is built using **Flex** (Fast Lexical Analyzer Generator) and transforms source code into a stream of tokens for subsequent parsing.

### What is a Lexical Analyzer?

A lexical analyzer (lexer/scanner) is the first phase of a compiler that:
1. Reads source code character by character
2. Groups characters into meaningful tokens (keywords, identifiers, operators, etc.)
3. Filters out whitespace and comments
4. Reports lexical errors (invalid characters/symbols)
5. Passes tokens to the parser for syntax analysis

### Lab Project Context

- **Course**: CSE 3212 - Compiler Design Laboratory
- **Phase**: Lexical Analysis (Phase 1)
- **Tool**: Flex (Lexical Analyzer Generator)
- **Language**: ChronoScript (Custom C-like language)
- **Status**: ✅ Lexer Implementation Complete

---

## ✨ Features

### Core Functionality
- ✅ **Complete Token Recognition**: 75 unique token types
- ✅ **Line Tracking**: Accurate line number reporting for error messages
- ✅ **Comment Handling**: Both single-line (`//`) and multi-line (`/* */`)
- ✅ **Escape Sequences**: Full support for character escapes (`\n`, `\t`, `\\`, etc.)
- ✅ **Scientific Notation**: Float literals with exponent notation (e.g., `2.5e10`)
- ✅ **Debug Mode**: Optional verbose output for development
- ✅ **Error Reporting**: Clear error messages with line numbers
- ✅ **Standalone Operation**: Can run independently without parser

### Supported Language Features
- **Data Types**: `Matter` (int), `Energy` (float), `Atom` (char), `Stream` (string), `Truth` (bool), `Void`
- **Type Modifiers**: `flux` (volatile), `fixed` (const), `instance` (static)
- **Control Flow**: `Era` (if), `Alternate` (else), `Loop` (for), `Diverge` (break), `Persist` (continue)
- **Mathematical Functions**: `sine`, `cosine`, `tangent`, `logarithm`, `power`, `squareroot`, etc.
- **Operators**: Arithmetic, Logical, Bitwise, Comparison, Assignment
- **Advanced Features**: `structure` (struct), `unison` (union), `timeline` (array), `perspective` (switch)

---

## 🚀 Quick Start

### For Linux/macOS Users

```bash
# Install Flex and GCC
sudo apt install flex build-essential    # Ubuntu/Debian
# or
brew install flex                         # macOS

# Build the lexer
make

# Run on a sample file
make run FILE=sample1.chrono
```

### For Windows Users

**Option 1: WSL (Recommended)**
```powershell
# Launch WSL Ubuntu
wsl -d Ubuntu

# Install tools
sudo apt update
sudo apt install flex build-essential

# Navigate to project
cd "/mnt/e/Programming/Lab Projects/Compiler Lab Project/ChronoScript-Compiler"

# Build and run
make
make run FILE=sample1.chrono
```

**See [WINDOWS_INSTALL.md](WINDOWS_INSTALL.md) for complete Windows setup instructions.**

---

## 📦 Prerequisites

### Required Tools
- **Flex** (version 2.6.0 or higher) - Lexical analyzer generator
- **GCC** or **Clang** - C compiler
- **Make** (optional but recommended) - Build automation

### Operating System Support
- ✅ Linux (Ubuntu, Fedora, Arch, etc.)
- ✅ macOS (Intel and Apple Silicon)
- ✅ Windows (via WSL, Cygwin, or WinFlexBison)

### Installation Guides
- **Linux/macOS**: See [INSTALL.md](INSTALL.md)
- **Windows**: See [WINDOWS_INSTALL.md](WINDOWS_INSTALL.md)

---

## 📁 Project Structure

```
ChronoScript-Compiler/
│
├── chronoscript.l               # Flex lexer specification (main source)
├── Makefile                     # Build automation script
│
├── sample1.chrono               # Sample program: Basic features
├── sample2.chrono               # Sample program: Advanced features
├── sample_math.chrono           # Sample program: Mathematical functions
│
├── output_sample1.txt           # Expected output for sample1.chrono
├── output_sample2.txt           # Expected output for sample2.chrono
├── output_math.txt              # Expected output for sample_math.chrono
│
├── README.md                    # This file
├── COMMANDS.md                  # Detailed command reference
├── INSTALL.md                   # Installation guide (Linux/macOS)
├── WINDOWS_INSTALL.md           # Installation guide (Windows)
├── CODE_EXPLANATION.md          # Code documentation
│
└── chrono_script_compiler_project_proposal.md  # Project proposal
```

### Generated Files (after build)
```
lex.yy.c                        # Generated C source from Flex
chrono_lexer                    # Compiled executable (Linux/macOS)
chrono_lexer.exe                # Compiled executable (Windows)
chrono_lexer_debug              # Debug version executable
outputs/                        # Test output directory
```

---

## 💻 Usage

### Method 1: Using Makefile (Recommended)

#### Build the Lexer
```bash
make
```

#### Run on a Specific File
```bash
make run FILE=sample1.chrono
make run FILE=sample2.chrono
make run FILE=sample_math.chrono
```

#### Test All Sample Files
```bash
make test
```
This runs the lexer on all sample files and saves output to `outputs/` directory.

#### Build and Run in Debug Mode
```bash
make debug FILE=sample_math.chrono
```

#### Clean Generated Files
```bash
make clean          # Remove generated files
make distclean      # Remove generated files and outputs
```

#### Check Build Environment
```bash
make check
```

#### Show File Statistics
```bash
make stats
```

#### View All Available Commands
```bash
make help
```

---

### Method 2: Manual Build Process

#### Step 1: Generate C Source
```bash
flex chronoscript.l
```
This creates `lex.yy.c`.

#### Step 2: Compile
```bash
gcc lex.yy.c -o chrono_lexer -lfl
```

On some systems, you may need:
```bash
gcc lex.yy.c -o chrono_lexer -ll
```

#### Step 3: Run
```bash
./chrono_lexer sample1.chrono
```

#### Debug Mode (Manual)
```bash
sudo apt-get update
sudo apt-get install flex make gcc
```

#### macOS
```bash
brew install flex make gcc
```

### Verify Installation
```bash
flex --version    # Should show Flex version
gcc --version     # Should show GCC version
make --version    # Should show Make version
```

---

## 🚀 Installation

1. **Clone or download the repository**
   ```bash
   git clone <repository-url>
   cd ChronoScript-Compiler
   ```

2. **Verify files are present**
   ```bash
   ls -l
   # Should see: chronoscript.l, Makefile, README.md
   ```

3. **Build the lexer**
   ```bash
   make
   ```

4. **Verify build**
   ```bash
   ls -l chronoscript
   # Should see the executable file
   ```

---

## 💻 Usage

### Basic Usage

#### Analyze a ChronoScript File
```bash
./chronoscript input.cs
```

#### Read from Standard Input
```bash
./chronoscript
# Type code manually, press Ctrl+D (Linux/Mac) or Ctrl+Z (Windows) when done
```

#### Pipe Input
```bash
echo "Matter x = 42;" | ./chronoscript
```

### Debug Mode

#### Compile with Debug Output
```bash
make debug
```

#### Run in Debug Mode
```bash
./chronoscript_debug example.cs
```

**Debug output includes:**
- Token name
- Matched lexeme (actual text)
- Line number

**Example:**
```
Line 1: Token MATTER ('Matter')
Line 1: Token IDENTIFIER ('x')
Line 1: Token ASSIGN ('=')
Line 1: Token INTEGER_LITERAL ('42')
Line 1: Token SEMICOLON (';')
```

### Make Commands

| Command | Description |
|---------|-------------|
| `make` or `make all` | Build release version |
| `make debug` | Build with debug output |
| `make clean` | Remove generated files |
| `make rebuild` | Clean and rebuild |
| `make test` | Run test suite |

---

## 📖 ChronoScript Language Reference

### Data Types

| ChronoScript | C Equivalent | Description |
|--------------|--------------|-------------|
| `Void` | `void` | No return type |
| `Truth` | `bool` | Boolean (true/false) |
| `Matter` | `int` | Integer |
| `Atom` | `char` | Character |
| `Stream` | `char*` | String |
| `Energy` | `float` | Single-precision float |
| `HighEnergy` | `double` | Double-precision float |
| `pureMatter` | `short int` | Short integer |
| `largeMatter` | `long int` | Long integer |
| `fullEnergy` | `long double` | Extended precision float |
| `smallMatter` | `unsigned int` | Unsigned integer |

### Type Qualifiers

| ChronoScript | C Equivalent |
|--------------|--------------|
| `flux` | `auto` |
| `fixed` | `const` |

### Keywords

| ChronoScript | C Equivalent | Category |
|--------------|--------------|----------|
| `timeline` | `main` | Program entry |
| `structure` | `struct` | Data structure |
| `unison` | `union` | Union type |
| `instance` | `typedef` | Type definition |
| `Event` | `function` | Function declaration |
| `Persist` | `continue` | Loop control |
| `Escape` | `break` | Loop control |
| `Resolve` | `return` | Function return |
| `Observe` | `scanf` | Input |
| `Broadcast` | `printf` | Output |
| `Era` | `if` | Conditional |
| `Alternate` | `else` | Conditional alternative |
| `Loop` | `for` | For loop |
| `Diverge` | `while` | While loop |
| `reforge` | `switch` | Switch statement |
| `standard` | `case` | Case label |
| `perspective` | `default` | Default case |

### Operators

#### Arithmetic
`+` `-` `*` `/` `%`

#### Relational
`==` `!=` `>` `<` `>=` `<=`

#### Logical
`&&` `||` `!`

#### Bitwise
`&` `|` `^` `<<` `>>`

#### Assignment
`=`

### Math Functions

| ChronoScript | C Equivalent |
|--------------|--------------|
| `sine` | `sin` |
| `cosine` | `cos` |
| `tangent` | `tan` |
| `invSine` | `asin` |
| `invCosine` | `acos` |
| `invTangent` | `atan` |
| `logarithm` | `log` |
| `power` | `pow` |
| `absolute` | `abs` |
| `floor` | `floor` |
| `ceiling` | `ceil` |
| `squareroot` | `sqrt` |

### Preprocessor Directives

| ChronoScript | C Equivalent |
|--------------|--------------|
| `#Incorporate` | `#include` |
| `#Constant` | `#define` |

### Example Program

**ChronoScript:**
```chronoscript
#Incorporate <stdio.h>

Event timeline() {
    Matter count = 0;
    
    Loop (count = 0; count < 10; count + 1) {
        Era (count % 2 == 0) {
            Broadcast("Even: ");
        }
        Alternate {
            Broadcast("Odd: ");
        }
        Broadcast(count);
    }
    
    Resolve 0;
}
```

**Equivalent C:**
```c
#include <stdio.h>

int main() {
    int count = 0;
    
    for (count = 0; count < 10; count + 1) {
        if (count % 2 == 0) {
            printf("Even: ");
        }
        else {
            printf("Odd: ");
        }
        printf(count);
    }
    
    return 0;
}
```

---

## 📁 Project Structure

```
ChronoScript-Compiler/
│
├── chronoscript.l           # Flex lexer specification
├── Makefile                 # Build automation
├── README.md               # This file
├── CODE_EXPLANATION.md     # Detailed code documentation
│
├── examples/               # Sample ChronoScript programs
│   ├── hello.cs
│   ├── loops.cs
│   └── math.cs
│
├── tests/                  # Test files
│   ├── test_keywords.cs
│   ├── test_operators.cs
│   └── test_literals.cs
│
└── build/                  # Generated files (created by make)
    ├── lex.yy.c
    └── chronoscript
```

---

## 🔨 Compilation Modes

### Normal Mode (Release)
```bash
make
./chronoscript input.cs
```
**Output:** Only token numbers
```
Token: 3
Token: 75
Token: 36
Token: 71
Token: 55
```

### Debug Mode
```bash
make debug
./chronoscript_debug input.cs
```
**Output:** Detailed token information
```
Line 1: Token MATTER ('Matter')
Line 1: Token IDENTIFIER ('x')
Line 1: Token ASSIGN ('=')
Line 1: Token INTEGER_LITERAL ('42')
Line 1: Token SEMICOLON (';')
```

### Manual Compilation
```bash
# Generate C code from Flex file
flex chronoscript.l

# Compile without Flex library (using noyywrap)
gcc lex.yy.c -o chronoscript

# Or with Flex library
gcc lex.yy.c -o chronoscript -ll
```

---

## 📝 Examples

### Example 1: Variable Declaration
**Input:**
```chronoscript
Matter x = 42;
```

**Output (Debug Mode):**
```
Line 1: Token MATTER ('Matter')
Line 1: Token IDENTIFIER ('x')
Line 1: Token ASSIGN ('=')
Line 1: Token INTEGER_LITERAL ('42')
Line 1: Token SEMICOLON (';')
```

### Example 2: Float with Scientific Notation
**Input:**
```chronoscript
Energy speed = 2.998e8;
```

**Output:**
```
Line 1: Token ENERGY ('Energy')
Line 1: Token IDENTIFIER ('speed')
Line 1: Token ASSIGN ('=')
Line 1: Token FLOAT_LITERAL ('2.998e8')
Line 1: Token SEMICOLON (';')
```

### Example 3: Conditional Statement
**Input:**
```chronoscript
Era (x > 0) {
    Broadcast("Positive");
}
```

**Output:**
```
Line 1: Token ERA ('Era')
Line 1: Token LPAREN ('(')
Line 1: Token IDENTIFIER ('x')
Line 1: Token GREATER ('>')
Line 1: Token INTEGER_LITERAL ('0')
Line 1: Token RPAREN (')')
Line 1: Token LBRACE ('{')
Line 2: Token BROADCAST ('Broadcast')
Line 2: Token LPAREN ('(')
Line 2: Token STRING_LITERAL ('"Positive"')
Line 2: Token RPAREN (')')
Line 2: Token SEMICOLON (';')
Line 3: Token RBRACE ('}')
```

### Example 4: Math Expression
**Input:**
```chronoscript
Energy result = sine(3.14) + squareroot(16);
```

**Output:**
```
Line 1: Token ENERGY ('Energy')
Line 1: Token IDENTIFIER ('result')
Line 1: Token ASSIGN ('=')
Line 1: Token SINE ('sine')
Line 1: Token LPAREN ('(')
Line 1: Token FLOAT_LITERAL ('3.14')
Line 1: Token RPAREN (')')
Line 1: Token PLUS ('+')
Line 1: Token SQUAREROOT ('squareroot')
Line 1: Token LPAREN ('(')
Line 1: Token INTEGER_LITERAL ('16')
Line 1: Token RPAREN (')')
Line 1: Token SEMICOLON (';')
```

### Example 5: Error Handling
**Input:**
```chronoscript
Matter x @ 42;
```

**Output:**
```
Line 1: Token MATTER ('Matter')
Line 1: Token IDENTIFIER ('x')
Lexical Error: Unknown symbol '@' at line 1
Line 1: Token INTEGER_LITERAL ('42')
Line 1: Token SEMICOLON (';')
```

---

## 🔍 Technical Details

### Token Return Values
All tokens return integer codes (1-75):
- 1-11: Data types
- 12-70: Keywords, operators, symbols
- 71-75: Literals and identifiers

### Semantic Values
The `yylval` union stores token values:
```c
union {
    int intval;        // Integer literals
    double doubleval;  // Float literals
    char charval;      // Character literals
    char* strval;      // Strings and identifiers
} yylval;
```

### Pattern Matching Priority
1. **Longest match**: Flex always prefers longer matches
2. **First rule**: If equal length, first rule wins
3. **Keywords before identifiers**: Why `"Matter"` matches keyword, not identifier

### Memory Management
- **Allocated**: String literals and identifiers (via `malloc`/`strdup`)
- **Stack**: Numeric and character literals (stored in union)
- **Note**: In production, parser must free allocated strings

---

## 🧪 Testing

### Run All Tests
```bash
make test
```

### Individual Test Files
```bash
./chronoscript tests/test_keywords.cs
./chronoscript tests/test_operators.cs
./chronoscript tests/test_literals.cs
```

### Create Your Own Test
1. Create a `.cs` file with ChronoScript code
2. Run: `./chronoscript yourfile.cs`
3. Verify token output

---

## 🐛 Troubleshooting

### Flex not found
```
Solution: Install Flex (see Prerequisites section)
```

### "undefined reference to yywrap"
```
Solution: Use %option noyywrap in .l file (already included)
Or: Compile with -ll flag
```

### Permission denied (Linux/Mac)
```bash
chmod +x chronoscript
```

### Compiler not found
```
Solution: Install GCC or use alternative C compiler
```

---

## 📚 Additional Resources

- **Flex Manual**: https://westes.github.io/flex/manual/
- **Compiler Design**: "Compilers: Principles, Techniques, and Tools" (Dragon Book)
- **Lexical Analysis**: Chapter 3 of most compiler textbooks
- **CODE_EXPLANATION.md**: Detailed line-by-line code documentation in this repository

---

## 🤝 Contributing

This is an educational project for CSE 3212. Contributions, suggestions, and feedback are welcome!

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -m 'Add improvement'`)
4. Push to branch (`git push origin feature/improvement`)
5. Open a Pull Request

---

## 📄 License

This project is created for educational purposes as part of CSE 3212 - Compiler Lab.

---

## 👥 Authors

**CSE 3212 Compiler Lab Project**

---

## 🙏 Acknowledgments

- Course Instructor: CSE 3212
- Tool: Flex (Fast Lexical Analyzer Generator)
- Reference: The Dragon Book (Compilers: Principles, Techniques, and Tools)

---

## 📞 Contact & Support

For questions, issues, or suggestions:
- Open an issue on the repository
- Contact course instructor
- Refer to CODE_EXPLANATION.md for detailed documentation

---

**Happy Compiling! 🚀**
