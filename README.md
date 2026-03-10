# ChronoScript Compiler

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Language](https://img.shields.io/badge/language-Flex%2FBison%2FC-green)
![Course](https://img.shields.io/badge/course-CSE%203212-orange)
![Platform](https://img.shields.io/badge/platform-Linux%20|%20macOS%20|%20Windows-lightgrey)
![Status](https://img.shields.io/badge/status-Parser%20Complete-success)

A complete **lexical and syntax analyzer** for **ChronoScript**, a custom programming language with time-themed syntax that maps to C-like constructs.

---

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Building the Parser](#building-the-parser)
- [Running Tests](#running-tests)
- [ChronoScript Language Reference](#chronoscript-language-reference)
- [Documentation](#documentation)
- [Technical Details](#technical-details)
- [Troubleshooting](#troubleshooting)
- [What's Next](#whats-next)

---

## 🎯 Overview

This project implements the **lexical analysis** and **syntax analysis** phases of a compiler for ChronoScript, an educational programming language designed for the CSE 3212 Compiler Lab course.

### Compiler Phases Implemented

✅ **Phase 1: Lexical Analysis** (Flex)
- Tokenizes ChronoScript source code
- Recognizes 80+ token types
- Handles comments and escape sequences
- Line number tracking

✅ **Phase 2: Syntax Analysis** (Bison)
- Parses token streams into Abstract Syntax Tree (AST)
- Symbol table with scope management
- Error recovery and reporting
- Full language feature support

### What is a Compiler?

A compiler transforms source code into executable programs through several phases:
1. **Lexical Analysis** - Breaks code into tokens
2. **Syntax Analysis** - Checks grammar and builds AST (← **You are here**)
3. **Semantic Analysis** - Type checking, scope resolution (Coming soon)
4. **Code Generation** - Produces target code (Future work)

### Lab Project Context

- **Course**: CSE 3212 - Compiler Design Laboratory
- **Current Phase**: Syntax Analysis (Parser)
- **Tools**: Flex (Lexer) + Bison (Parser)
- **Language**: ChronoScript (Custom C-like language with temporal features)
- **Status**: ✅ Lexer Complete | ✅ Parser Complete

---

## ✨ Features

### Lexical Analyzer (Phase 1)
- ✅ **80+ Token Types**: Complete recognition of all ChronoScript constructs
- ✅ **Line Tracking**: Accurate line number reporting for errors
- ✅ **Comment Handling**: Single-line (`//`) and multi-line (`/* */`)
- ✅ **Escape Sequences**: Full support (`\n`, `\t`, `\\`, `\'`, etc.)
- ✅ **Scientific Notation**: Floating-point with exponents (e.g., `2.5e10`)
- ✅ **Error Reporting**: Clear messages with line numbers

### Syntax Analyzer (Phase 2) - NEW!
- ✅ **Complete Grammar**: All ChronoScript language features
- ✅ **AST Construction**: Builds full Abstract Syntax Tree
- ✅ **Symbol Table**: Multi-scope management with duplicate detection
- ✅ **Operator Precedence**: 13 precedence levels (C-compatible)
- ✅ **Error Recovery**: Continues parsing after syntax errors
- ✅ **Type Tracking**: Records variable and function types
- ✅ **Recursion Support**: Full support for recursive functions

### Supported Language Features
- **Data Types**: 
  - `Matter` (int), `Energy` (float/double), `Atom` (char), `Stream` (string), `Truth` (bool)
  - Sized types: `smallMatter`, `largeMatter`, `HighEnergy`, `fullEnergy`, `pureMatter`
- **Control Flow**: 
  - `Era` (if), `Alternate` (else), `Loop` (for/while)
  - `Escape` (break), `Persist` (continue), `Resolve` (return)
- **Functions**:
  - `Event` (main-like functions)
  - Parameters and return values
  - Recursion
- **Structures**: `structure` (struct definitions)
- **Arrays**: Declaration, initialization, and access
- **Operators**: 
  - Arithmetic: `+`, `-`, `*`, `/`, `%`, `^` (power)
  - Logical: `&&`, `||`, `!`
  - Bitwise: `&`, `|`, `^`, `<<`, `>>`
  - Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
  - Assignment: `=`, `+=`, `-=`, `*=`, `/=`, `%=`
- **Built-in Math**: `sine`, `cosine`, `tangent`, `squareroot`, `absolute`, `floor`, `ceiling`, `logarithm`, `power`
- **I/O**: `Broadcast` (print), `Observe` (debug print)

---

## 🚀 Quick Start

### Prerequisites
- **Flex** (Fast Lexical Analyzer)
- **Bison** (GNU Parser Generator)
- **GCC** (GNU Compiler Collection)

**Installation:**
```bash
# Ubuntu/Debian
sudo apt-get install flex bison gcc

# macOS
brew install flex bison gcc

# Windows: Use MinGW, Cygwin, or WSL
```

### Build and Run (3 Easy Steps)

#### Option 1: Using Makefile (Recommended)
```bash
# Build
make

# Run a test
./chronoscript_parser test_samples/test1_declarations.cs

# Run all tests
make test
```

#### Option 2: Using Build Scripts

**Windows:**
```cmd
build.bat
chronoscript_parser.exe test_samples\test1_declarations.cs
```

**Linux/macOS:**
```bash
chmod +x build.sh
./build.sh
./chronoscript_parser test_samples/test1_declarations.cs
```

#### Option 3: Manual Build
```bash
flex chronoscript.l
bison -d chronoscript.y
gcc lex.yy.c chronoscript.tab.c -o chronoscript_parser -lfl
./chronoscript_parser test_samples/test1_declarations.cs
```
---

## 📁 Project Structure

```
ChronoScript-Compiler/
│
├── chronoscript.l               # Flex lexer specification
├── chronoscript.y               # Bison parser specification (NEW!)
├── Makefile                     # Build automation
├── build.sh                     # Linux/macOS build script
├── build.bat                    # Windows build script
│
├── test_samples/                # Parser test programs
│   ├── test1_declarations.cs    # Variable declarations
│   ├── test2_expressions.cs     # Arithmetic & logical expressions
│   ├── test3_control_flow.cs    # If/else, loops, break/continue
│   ├── test4_functions.cs       # Function definitions & recursion
│   ├── test5_comprehensive.cs   # Complete program features
│   └── test6_errors.cs          # Syntax error detection
│
├── samples/                     # Lexer test programs (original)
│   ├── sample1_helloworld.txt
│   ├── sample2_arithmetic.txt
│   ├── sample3_control.txt
│   ├── sample4_functions.txt
│   └── sample5_complete.txt
│
├── outputs/                     # Lexer output files
│   ├── output1_helloworld.txt
│   ├── output2_arithmetic.txt
│   ├── output3_control.txt
│   ├── output4_functions.txt
│   └── output5_complete.txt
│
├── PARSER_DOCUMENTATION.md      # Complete parser documentation
├── QUICKSTART.md                # Quick start guide
├── README.md                    # This file
└── chrono_script_compiler_project_proposal.md
```

### Key Files Explained

| File | Purpose |
|------|---------|
| `chronoscript.l` | Flex lexer - tokenizes ChronoScript code |
| `chronoscript.y` | Bison parser - grammar rules and AST construction |
| `Makefile` | Automated build system |
| `test_samples/*.cs` | Comprehensive test programs for parser |
| `PARSER_DOCUMENTATION.md` | In-depth parser design and grammar documentation |
| `QUICKSTART.md` | 5-minute getting started guide |

---

## 🔨 Building the Parser

### Using Makefile (Recommended)

```bash
# Build everything
make

# Check for grammar conflicts
make check-grammar

# Clean generated files
make clean

# Rebuild from scratch
make rebuild

# Show help
make help
```

### Manual Build Process

```bash
# Step 1: Generate lexer
flex chronoscript.l
# Produces: lex.yy.c

# Step 2: Generate parser
bison -d -v chronoscript.y
# Produces: chronoscript.tab.c, chronoscript.tab.h, chronoscript.output

# Step 3: Compile
gcc lex.yy.c chronoscript.tab.c -o chronoscript_parser -lfl

# Step 4: Run
./chronoscript_parser test_samples/test1_declarations.cs
```

---

## 🧪 Running Tests

### Run All Tests
```bash
make test
```

### Run Individual Tests
```bash
make test1  # Variable declarations
make test2  # Expressions
make test3  # Control flow
make test4  # Functions
make test5  # Comprehensive
make test6  # Error detection
```

### Manual Testing
```bash
# Parse a specific file
./chronoscript_parser test_samples/test1_declarations.cs

# Parse from stdin
./chronoscript_parser
# Type or paste code, then Ctrl+D (Linux/Mac) or Ctrl+Z (Windows)

# Parse your own file
./chronoscript_parser my_program.cs
```

### Expected Output

```
ChronoScript Parser - Syntax Analysis Phase
============================================

Parsing file: test1_declarations.cs

Syntax analysis successful

===========================================
Parsing completed successfully!
===========================================

=== Abstract Syntax Tree ===
PROGRAM
  DECL_LIST
    FUNC_DECL <Event> (main)
      PARAM_LIST
      COMPOUND_STMT
        DECL_LIST
          VAR_DECL <Matter> (x)
          VAR_DECL <Energy> (pi)
            FLOAT = 3.141590
        STMT_LIST
          ...

=== Symbol Table ===
Name                 Type            Scope    Function   Line
---------------------------------------------------------------
main                 Event           0        Yes        1
x                    Matter          1        No         3
pi                   Energy          1        No         4
...
```
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

### Hello World

```chronoscript
Event main() {
    Broadcast("Hello, ChronoScript!");
    Resolve 0;
}
```

### Variable Declarations

```chronoscript
// Data types
Matter age = 25;              // int
Energy temperature = 98.6;    // float/double
Atom grade = 'A';             // char
Stream name = "ChronoScript"; // string
Truth isValid = 1;            // bool

// Multiple declarations
Matter x, y, z;
Energy a = 1.0, b = 2.0, c = 3.0;

// Arrays
Matter numbers[10];
Energy values[100];
```

### Control Flow

```chronoscript
// If-Else (Era-Alternate)
Era (x > 0) {
    Broadcast("Positive");
} Alternate Era (x < 0) {
    Broadcast("Negative");
} Alternate {
    Broadcast("Zero");
}

// For loop
Loop (Matter i = 0; i < 10; i = i + 1) {
    Broadcast("Counting");
}

// While-style loop
Loop (condition) {
    // body
}

// Break and continue
Loop (Matter i = 0; i < 20; i = i + 1) {
    Era (i == 10) {
        Escape;      // break
    }
    Era (i % 2 == 0) {
        Persist;     // continue
    }
    Broadcast("Odd number");
}
```

### Functions

```chronoscript
// Function with return value
Matter factorial(Matter n) {
    Era (n <= 1) {
        Resolve 1;
    }
    Resolve n * factorial(n - 1);
}

// Function with multiple parameters
Energy average(Energy a, Energy b) {
    Resolve (a + b) / 2.0;
}

// Void function
Void printHeader() {
    Broadcast("===================");
    Broadcast("ChronoScript Program");
    Broadcast("===================");
    Resolve;
}

// Main function
Event main() {
    Matter fact5 = factorial(5);
    Energy avg = average(10.0, 20.0);
    printHeader();
    Resolve 0;
}
```

### Structures

```chronoscript
structure Point {
    Energy x;
    Energy y;
};

structure Rectangle {
    Energy width;
    Energy height;
};

Event main() {
    // Structure usage would be in semantic analysis phase
    Resolve 0;
}
```

### Expressions

```chronoscript
// Arithmetic
Matter result = 5 + 3 * 2;        // 11
Matter power = 2 ^ 8;              // 256
Energy division = 10.0 / 3.0;      // 3.333...

// Logical
Truth cond = (x > 0) && (y < 100);
Truth check = !flag || isValid;

// Bitwise
Matter masked = value & 0xFF;
Matter shifted = data << 4;
Matter xored = a ^ b;

// Compound assignment
x = x + 5;
y = y * 2;
z = z / 3;
```

### Built-in Math Functions

```chronoscript
Energy angle = 45.0;
Energy sinVal = sine(angle);
Energy cosVal = cosine(angle);
Energy tanVal = tangent(angle);

Energy number = 16.0;
Energy sqVal = squareroot(number);
Matter absVal = absolute(-42);

Energy floored = floor(3.9);      // 3.0
Energy ceiled = ceiling(3.1);     // 4.0
Energy logged = logarithm(10.0);
Energy powered = power(2.0, 8.0); // 256.0
```

### Complete Example

```chronoscript
// Factorial calculator with validation
Matter factorial(Matter n) {
    Era (n < 0) {
        Resolve -1;  // Error value
    }
    Era (n <= 1) {
        Resolve 1;
    }
    Resolve n * factorial(n - 1);
}

Truth isPrime(Matter n) {
    Era (n <= 1) {
        Resolve 0;
    }
    Loop (Matter i = 2; i * i <= n; i = i + 1) {
        Era (n % i == 0) {
            Resolve 0;
        }
    }
    Resolve 1;
}

Event main() {
    Broadcast("ChronoScript Math Demo");
    
    // Calculate factorials
    Loop (Matter i = 1; i <= 5; i = i + 1) {
        Matter fact = factorial(i);
        Broadcast("Factorial calculated");
    }
    
    // Find primes
    Matter primeCount = 0;
    Loop (Matter n = 2; n < 50; n = n + 1) {
        Era (isPrime(n)) {
            primeCount = primeCount + 1;
        }
    }
    
    Broadcast("Program completed");
    Resolve 0;
}
```

---

## 📚 Documentation

### Comprehensive Guides

| Document | Description |
|----------|-------------|
| [PARSER_DOCUMENTATION.md](PARSER_DOCUMENTATION.md) | Complete parser design, grammar rules, AST structure |
| [QUICKSTART.md](QUICKSTART.md) | 5-minute quick start guide |
| README.md (this file) | Project overview and usage |

### Parser Documentation Includes:
- ✅ Complete grammar in BNF notation
- ✅ AST node type reference
- ✅ Symbol table design
- ✅ Operator precedence table
- ✅ Error handling strategies
- ✅ Design decisions and rationale
- ✅ Future enhancement roadmap

---

## 🔧 Technical Details

### Lexical Analyzer (chronoscript.l)

**Technology:** Flex 2.6+  
**Output:** Token stream with line numbers  
**Tokens:** 80+ unique types  
**Features:**
- Regular expression-based pattern matching
- Line number tracking (`yylineno`)
- Comment filtering (single-line and multi-line)
- Escape sequence processing
- Scientific notation support

### Syntax Analyzer (chronoscript.y)

**Technology:** Bison 3.x (LALR parser generator)  
**Output:** Abstract Syntax Tree (AST)  
**Grammar:** Context-free grammar with 35+ production rules  
**Features:**
- Bottom-up LALR parsing
- Shift-reduce conflict resolution
- 13 operator precedence levels
- Error recovery with `error` token
- Location tracking (`@n` notation)
- Semantic value types (`%union`)

### Symbol Table

**Implementation:** Linked-list with scope tracking  
**Operations:**
- Insert: O(n) - checks for duplicates
- Lookup: O(n) - searches all scopes
- Scope enter/exit: O(n) - cleanup on exit

**Data Stored:**
- Variable/function name
- Data type
- Scope level
- Line number
- Function/array flags

### AST Structure

**Node Types:** 25+ enumerated types  
**Children:** Up to 4 per node  
**Siblings:** Linked-list for sequences  

**Example AST Node:**
```c
typedef struct ASTNode {
    NodeType type;
    int line;
    char* value;
    int intval;
    double floatval;
    struct ASTNode* child[4];
    struct ASTNode* sibling;
    char* data_type;
    char* op;
} ASTNode;
```

---

## 🐛 Troubleshooting

### Build Issues

**Problem:** `flex: command not found`  
**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install flex

# macOS
brew install flex

# Windows: Install via MinGW or Cygwin
```

**Problem:** `bison: command not found`  
**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install bison

# macOS
brew install bison

# Windows: Install via MinGW or Cygwin
```

**Problem:** `undefined reference to 'yywrap'`  
**Solution:** Add `-lfl` flag when compiling:
```bash
gcc lex.yy.c chronoscript.tab.c -o chronoscript_parser -lfl
```

**Problem:** Shift/reduce or reduce/reduce conflicts  
**Solution:** Check `chronoscript.output` for details:
```bash
bison -v chronoscript.y
cat chronoscript.output | grep conflict
```

### Runtime Issues

**Problem:** Syntax errors not being caught  
**Solution:** Check that error recovery rules are working:
```bash
./chronoscript_parser test_samples/test6_errors.cs
```

**Problem:** Symbol table not showing variables  
**Solution:** Ensure `insert_symbol()` is called in grammar actions for declarations.

**Problem:** AST not printing correctly  
**Solution:** Check that `print_ast()` is traversing both children and siblings.

### Common Errors

**Lexical Errors:**
```
Lexical Error: Unknown symbol '@' at line 5
```
Solution: Check that all characters are valid ChronoScript syntax.

**Syntax Errors:**
```
Syntax error at line 10: Invalid expression statement
```
Solution: Check for missing semicolons, unmatched braces, or incorrect grammar.

**Semantic Errors:**
```
Semantic error at line 8: Redeclaration of 'x'
```
Solution: Variable already declared in current scope - use different name or check scope.

---

## 🚀 What's Next?

### Phase 3: Semantic Analysis (Planned)
- [ ] Complete type checking system
- [ ] Type inference for expressions
- [ ] Function signature validation
- [ ] Scope and lifetime analysis
- [ ] Constant folding
- [ ] Dead code detection

### Phase 4: Intermediate Code Generation (Planned)
- [ ] Three-address code (TAC) generation
- [ ] Control flow graphs (CFG)
- [ ] Basic optimization passes
- [ ] Symbol table integration with code gen

### Phase 5: Code Optimization (Planned)
- [ ] Constant propagation
- [ ] Common subexpression elimination
- [ ] Loop optimization
- [ ] Peephole optimization

### Phase 6: Code Generation (Planned)
- [ ] Target: x86-64 assembly or LLVM IR
- [ ] Register allocation
- [ ] Instruction selection
- [ ] Final executable generation

---

## 🎓 Course Information

- **Course:** CSE 3212 - Compiler Design Laboratory
- **Institution:** [Your University]
- **Semester:** [Current Semester]
- **Phase:** Syntax Analysis (Parser) - Complete ✅

### Learning Objectives Achieved
✅ Understanding of lexical analysis principles  
✅ Proficiency with Flex lexical analyzer generator  
✅ Understanding of context-free grammars  
✅ Proficiency with Bison parser generator  
✅ AST construction and traversal  
✅ Symbol table design and implementation  
✅ Error handling and recovery strategies  

---

## 📝 License

This project is for educational purposes as part of the CSE 3212 Compiler Design Laboratory course.

---

## 👤 Author

[Your Name]  
[Your University]  
CSE 3212 - Compiler Design Lab

---

## 🙏 Acknowledgments

- Course instructor and TAs
- "Compilers: Principles, Techniques, and Tools" (Dragon Book)
- Flex and Bison documentation
- GNU Compiler Collection (GCC) team

---

## 📞 Contact

For questions or issues:
- Email: [your.email@university.edu]
- Course Forum: [Link to course discussion board]

---

**Last Updated:** February 2026  
**Version:** 2.0.0 (Parser Complete)

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
