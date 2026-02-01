# ChronoScript Compiler - Lexical Analyzer

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Language](https://img.shields.io/badge/language-Flex%2FC-green)
![Course](https://img.shields.io/badge/course-CSE%203212-orange)

A lexical analyzer (scanner/tokenizer) for **ChronoScript**, a custom programming language with time-themed syntax that maps to C-like constructs.

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [ChronoScript Language Reference](#chronoscript-language-reference)
- [Project Structure](#project-structure)
- [Compilation Modes](#compilation-modes)
- [Examples](#examples)
- [Technical Details](#technical-details)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

This project implements the lexical analysis phase of a compiler for ChronoScript, an educational programming language designed for the CSE 3212 Compiler Lab course. The lexer is built using **Flex** (Fast Lexical Analyzer Generator) and transforms source code into a stream of tokens for subsequent parsing.

### What is a Lexical Analyzer?

A lexical analyzer (lexer/scanner) is the first phase of a compiler that:
1. Reads source code character by character
2. Groups characters into meaningful tokens (keywords, identifiers, operators, etc.)
3. Filters out whitespace and comments
4. Reports lexical errors (invalid characters/symbols)
5. Passes tokens to the parser for syntax analysis

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

### Token Categories
| Category | Count | Examples |
|----------|-------|----------|
| Data Types | 11 | `Matter`, `Energy`, `Truth`, `Atom` |
| Keywords | 13 | `Era`, `Loop`, `Event`, `Resolve` |
| Operators | 20 | `+`, `-`, `*`, `/`, `==`, `&&`, `<<` |
| Math Functions | 12 | `sine`, `logarithm`, `squareroot` |
| Literals | 4 | Integers, floats, chars, strings |
| Symbols | 6 | `{`, `}`, `(`, `)`, `;`, `,` |
| Directives | 2 | `#Incorporate`, `#Constant` |

---

## 🔧 Prerequisites

### Required Software
- **Flex** (version 2.5.4 or higher)
- **GCC** or compatible C compiler
- **Make** (for using Makefile)

### Installation Commands

#### Windows
```powershell
# Using Chocolatey
choco install winflexbison3
choco install make

# Or using MSYS2
pacman -S flex make gcc
```

#### Linux (Ubuntu/Debian)
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
