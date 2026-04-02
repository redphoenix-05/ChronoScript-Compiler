# ChronoScript Compiler

![Version](https://img.shields.io/badge/version-3.0.0-blue)
![Language](https://img.shields.io/badge/language-Flex%2FBison%2FC-green)
![Course](https://img.shields.io/badge/course-CSE%203212-orange)
![Platform](https://img.shields.io/badge/platform-Linux%20|%20macOS%20|%20Windows-lightgrey)
![Status](https://img.shields.io/badge/status-All%20Phases%20Complete-success)

A **complete compiler implementation** for **ChronoScript**, a custom programming language with time-themed syntax. This project implements all six phases of a traditional compiler pipeline, from lexical analysis to target code generation.

---

## 📋Table of Contents
- [Overview](#overview)
- [ChronoScript Language](#chronoscript-language)
- [Compiler Phases](#compiler-phases)
- [Installation](#installation)
- [Building the Compiler](#building-the-compiler)
- [Running the Compiler](#running-the-compiler)
- [Project Structure](#project-structure)
- [Example Programs](#example-programs)
- [Output Files](#output-files)
- [Technical Details](#technical-details)
- [Future Improvements](#future-improvements)
- [Course Information](#course-information)

---

## 🎯 Overview

ChronoScript is an educational programming language that uses **temporal and physics-themed metaphors** for traditional programming concepts. This compiler transforms ChronoScript source code into executable target code through six distinct compilation phases.

### Why ChronoScript?

- **Educational Purpose**: Demonstrates complete compiler construction
- **Creative Syntax**: Time and physics metaphors make programming concepts more intuitive
- **Academic Quality**: Suitable for CSE 3212 Compiler Design Laboratory

### Compilation Pipeline

```
ChronoScript Source Code (.cs)
          ↓
[Phase 1] Lexical Analysis (Flex)
          ↓
[Phase 2] Syntax Analysis (Bison)
          ↓
[Phase 3] Semantic Analysis
          ↓
[Phase 4] Intermediate Code Generation (3-Address Code)
          ↓
[Phase 5] Code Optimization
          ↓
[Phase 6] Target Code Generation (Pseudo-Assembly)
          ↓
Target Code Output
```

---

## 🌟 ChronoScript Language

### Language Philosophy

ChronoScript conceptualizes program execution as the movement of **Matter** (data) and **Energy** (computation) across a **Timeline** (program flow).

### Keyword Mappings

| ChronoScript | C Equivalent | Description |
|--------------|--------------|-------------|
| **Data Types** |||
| `Matter` | `int` | Integer values |
| `Energy` | `float` | Floating-point values |
| `Atom` | `char` | Single characters |
| `Stream` | `char*` | Strings |
| `Truth` | `bool` | Boolean values |
| `HighEnergy` | `double` | Double precision |
| `pureMatter` | `short` | Short integer |
| `largeMatter` | `long` | Long integer |
| `Void` | `void` | Empty type |
| **Control Flow** |||
| `Era` | `if` | Conditional statement |
| `Alternate` | `else` | Else clause |
| `Loop` | `for/while` | Iteration |
| `Persist` | `continue` | Continue loop |
| `Escape` | `break` | Break loop |
| `Resolve` | `return` | Return statement |
| **Functions** |||
| `Event` | `function` | Function declaration |
| `Broadcast` | `print` | Output statement |
| `Observe` | `debug_print` | Debug output |
| **Structures** |||
| `structure` | `struct` | Structure definition |
| `timeline` | `array` | Array type |

### Mathematical Functions

- `sine()`, `cosine()`, `tangent()`
- `invSine()`, `invCosine()`, `invTangent()`
- `logarithm()`, `power()`, `squareroot()`
- `absolute()`, `floor()`, `ceiling()`

### Example Code

```chronoscript
// Factorial function in ChronoScript
Matter factorial(Matter n) {
    Era (n <= 1) {
        Resolve 1;
    }
    Resolve n * factorial(n - 1);
}

Event main() {
    Matter result = factorial(5);
    Broadcast("Result calculated!");
    Resolve 0;
}
```

---

## 🔧 Compiler Phases

### Phase 1: Lexical Analysis
**Tool**: Flex (Fast Lexical Analyzer)

**Features:**
- Recognizes 80+ token types
- Handles comments (single-line `//` and multi-line `/* */`)
- Supports escape sequences in strings and characters
- Line number tracking for error reporting
- Scientific notation for floating-point numbers

**Output**: Token stream

### Phase 2: Syntax Analysis
**Tool**: Bison (Parser Generator)

**Features:**
- Complete grammar for all ChronoScript constructs
- Abstract Syntax Tree (AST) construction
- 13 levels of operator precedence
- Error recovery mechanisms
- Support for recursive functions
- Array and structure declarations

**Output**: Abstract Syntax Tree (AST)

### Phase 3: Semantic Analysis
**Implementation**: Custom C module (`semantic/semantic.c`)

**Features:**
- Symbol table with multi-scope management
- Type checking and type compatibility
- Undeclared variable detection
- Duplicate declaration checking
- Function parameter validation
- Array bounds checking (compile-time)
- Type compatibility for operations

**Output**: Validated AST + Symbol Table

### Phase 4: Intermediate Code Generation
**Implementation**: Custom C module (`intermediate/icg.c`)

**Features:**
- Three-address code (TAC) generation
- Temporary variable management
- Label generation for control flow
- Support for:
  - Arithmetic expressions
  - Logical operations
  - Control flow (if, while, for)
  - Function calls
  - Array operations

**Output**: `outputs/intermediate_code.txt`

### Phase 5: Code Optimization
**Implementation**: Custom C module (`optimization/optimizer.c`)

**Optimization Techniques:**
1. **Constant Folding**: Evaluate constant expressions at compile-time
2. **Constant Propagation**: Replace variables with their constant values
3. **Dead Code Elimination**: Remove unused code
4. **Algebraic Simplification**: Simplify expressions (e.g., `x * 1 = x`)
5. **Strength Reduction**: Replace expensive operations (e.g., `x * 2` → `x << 1`)

**Output**: `outputs/optimized_code.txt`

### Phase 6: Target Code Generation
**Implementation**: Custom C module (`target/target_codegen.c`)

**Features:**
- Pseudo-assembly code generation
- Register allocation (8 general-purpose registers)
- Instruction selection
- Label resolution
- Stack frame management

**Output**: `outputs/target_code.txt`

---

## 💻 Installation

### Prerequisites

#### Ubuntu/Debian Linux
```bash
sudo apt-get update
sudo apt-get install flex bison gcc make
```

#### macOS
```bash
brew install flex bison gcc make
```

#### Windows
Two options:

**Option 1: Windows Subsystem for Linux (WSL)**
```bash
wsl --install
# Then follow Ubuntu instructions above
```

**Option 2: MinGW or Cygwin**
1. Install MinGW: https://www.mingw-w64.org/
2. Install Flex and Bison through MinGW Package Manager

### Verify Installation
```bash
flex --version
bison --version
gcc --version
make --version
```

---

## 🏗️ Building the Compiler

### Quick Build
```bash
# Clone or navigate to the project directory
cd ChronoScript-Compiler

# Build the compiler
make

# The executable 'chrono_compiler' will be created
```

### Build Steps Explained
```bash
# 1. Generate lexer from chronoscript.l
flex lexer/chronoscript.l

# 2. Generate parser from chronoscript.y
bison -d -v parser/chronoscript.y

# 3. Compile all modules
gcc -c semantic/semantic.c -o semantic.o
gcc -c intermediate/icg.c -o icg.o
gcc -c optimization/optimizer.c -o optimizer.o
gcc -c target/target_codegen.c -o target_codegen.o

# 4. Link everything
gcc lex.yy.c chronoscript.tab.c semantic.o icg.o optimizer.o target_codegen.o \
    -o chrono_compiler -lfl -lm
```

### Clean Build
```bash
make clean      # Remove build artifacts
make cleanall   # Remove build artifacts and output files
make            # Rebuild
```

---

## 🚀 Running the Compiler

### Basic Usage
```bash
./chrono_compiler <input_file.cs>
```

### Examples
```bash
# Compile the demo program
./chrono_compiler tests/demo.cs

# Compile a simple program
./chrono_compiler tests/simple.cs

# Compile with all phases output
./chrono_compiler tests/test1_declarations.cs
```

### Run All Tests
```bash
make test
```

### Run Specific Test
```bash
make run FILE=tests/demo.cs
```

### Compilation Output

The compiler will generate the following files in the `outputs/` directory:

1. **intermediate_code.txt** - Three-address code representation
2. **optimized_code.txt** - Optimized intermediate code
3. **target_code.txt** - Final pseudo-assembly code
4. **symbol_table.txt** - Symbol table with all variables and functions

### Console Output

```
ChronoScript Compiler - Complete Pipeline
==========================================

[Phase 1] Lexical Analysis
Tokenizing source code...
✓ Lexical analysis complete

[Phase 2] Syntax Analysis
Parsing token stream...
✓ Syntax analysis complete

[Phase 3] Semantic Analysis
Checking types and scopes...
✓ Semantic analysis complete
  Errors: 0
  Warnings: 0

[Phase 4] Intermediate Code Generation
Generating 3-address code...
✓ Intermediate code generated
  File: outputs/intermediate_code.txt

[Phase 5] Code Optimization
Applying optimizations...
✓ Optimization complete
  Constant Folding: 5
  Dead Code Eliminated: 3
  Total Optimizations: 12
  File: outputs/optimized_code.txt

[Phase 6] Target Code Generation
Generating pseudo-assembly...
✓ Target code generated
  Instructions: 45
  File: outputs/target_code.txt

==========================================
Compilation successful!
==========================================
```

---

## 📁 Project Structure

```
ChronoScript-Compiler/
│
├── lexer/                          # Phase 1: Lexical Analysis
│   └── chronoscript.l              # Flex lexer specification
│
├── parser/                         # Phase 2: Syntax Analysis
│   └── chronoscript.y              # Bison parser specification
│
├── semantic/                       # Phase 3: Semantic Analysis
│   ├── semantic.h                  # Semantic analyzer header
│   └── semantic.c                  # Semantic analyzer implementation
│
├── intermediate/                   # Phase 4: Intermediate Code Generation
│   ├── icg.h                       # ICG header
│   └── icg.c                       # ICG implementation
│
├── optimization/                   # Phase 5: Code Optimization
│   ├── optimizer.h                 # Optimizer header
│   └── optimizer.c                 # Optimizer implementation
│
├── target/                         # Phase 6: Target Code Generation
│   ├── target_codegen.h            # Target code generator header
│   └── target_codegen.c            # Target code generator implementation
│
├── tests/                          # Test programs
│   ├── demo.cs                     # Comprehensive demo
│   ├── simple.cs                   # Simple test
│   ├── test1_declarations.cs       # Variable declarations
│   ├── test2_expressions.cs        # Expression evaluation
│   ├── test3_control_flow.cs       # Control structures
│   ├── test4_functions.cs          # Function definitions
│   ├── test5_comprehensive.cs      # Complete features
│   └── test6_errors.cs             # Error handling
│
├── outputs/                        # Generated output files
│   ├── intermediate_code.txt       # TAC output
│   ├── optimized_code.txt          # Optimized TAC
│   ├── target_code.txt             # Pseudo-assembly
│   └── symbol_table.txt            # Symbol table
│
├── docs/                           # Documentation
│   └── code_explanation.md         # Detailed code explanation
│
├── Makefile                        # Build automation
├── README.md                       # This file
├── .gitignore                      # Git ignore rules
└── chrono_script_compiler_project_proposal.md
```

---

## 📝 Example Programs

### Example 1: Simple Arithmetic
```chronoscript
Event main() {
    Matter a = 10;
    Matter b = 20;
    Matter sum = a + b;
    
    Broadcast("Sum calculated!");
    Resolve 0;
}
```

### Example 2: Factorial
```chronoscript
Matter factorial(Matter n) {
    Era (n <= 1) {
        Resolve 1;
    }
    Resolve n * factorial(n - 1);
}

Event main() {
    Matter result = factorial(5);
    Resolve 0;
}
```

### Example 3: Array Processing
```chronoscript
Event main() {
    Matter numbers[10];
    
    Loop (Matter i = 0; i < 10; i = i + 1) {
        numbers[i] = i * i;
    }
    
    Resolve 0;
}
```

---

## 📤 Output Files

### Intermediate Code Example
```
function main:
    t0 = 10
    a = t0
    t1 = 20
    b = t1
    t2 = a + b
    sum = t2
    print "Sum calculated!"
    return 0
end_function main
```

### Optimized Code Example
```
function main:
    a = 10
    b = 20
    sum = 30          # Constant folding applied
    print "Sum calculated!"
    return 0
end_function main
```

### Target Code Example
```assembly
; ChronoScript Compiler - Target Code
main:
    PUSH    FP
    MOVE    FP, SP
    MOVE    R0, 10
    STORE   a, R0
    MOVE    R1, 20
    STORE   b, R1
    MOVE    R2, 30
    STORE   sum, R2
    PRINT   "Sum calculated!"
    MOVE    R0, 0
    RET
```

---

## 🔬 Technical Details

### Lexer Features
- **80+ Tokens**: Complete coverage of language features
- **Regular Expressions**: Pattern matching for identifiers, numbers, strings
- **Escape Sequences**: Full support (`\n`, `\t`, `\\`, etc.)
- **Comments**: Single and multi-line
- **Error Recovery**: Continues after lexical errors

### Parser Features
- **LR(1) Parsing**: Bison-generated LALR parser
- **13 Precedence Levels**: C-compatible operator precedence
- **Error Productions**: Graceful error recovery
- **AST Construction**: Full tree representation
- **Dangling Else Resolution**: Proper if-else association

### Semantic Analyzer Features
- **Symbol Table**: Hash-table based with O(1) lookup
- **Scope Management**: Nested scope support
- **Type System**: Strong typing with implicit conversions
- **Error Messages**: Line number and contextual information

### Code Generator Features
- **3-Address Code**: Industry-standard IR format
- **SSA Form**: Partial static single assignment
- **Control Flow**: Structured control flow preservation

### Optimizer Features
- **Data Flow Analysis**: Reaching definitions, live variables
- **Peephole Optimization**: Local pattern matching
- **Multiple Passes**: Iterative optimization until fixed point

### Target Generator Features
- **Register Allocation**: Graph coloring algorithm
- **Instruction Selection**: Optimal instruction matching
- **Stack Management**: Proper frame handling

---

## 🚧 Future Improvements

### Potential Enhancements
1. **More Optimizations**:
   - Common subexpression elimination
   - Loop optimization (loop invariant code motion)
   - Function inlining

2. **Advanced Features**:
   - Pointers and dynamic memory
   - Object-oriented constructs
   - Generic programming support

3. **Better Code Generation**:
   - Multiple backend targets (x86, ARM, MIPS)
   - Real assembly code generation
   - Link with standard library

4. **IDE Integration**:
   - Syntax highlighting
   - Error highlighting
   - Autocomplete

5. **Debugger**:
   - Step-through execution
   - Breakpoints
   - Variable inspection

---

## 🎓 Course Information

- **Course**: CSE 3212 - Compiler Design Laboratory
- **Institution**: Khulna University of Engineering & Technology (KUET)
- **Department**: Computer Science and Engineering
- **Student**: Ariyan Aftab Spandan
- **Roll**: 2107045
- **Session**: 2023-24

### Learning Outcomes
- Understanding of compiler phases
- Practical experience with Flex and Bison
- Implementation of optimization algorithms
- Code generation techniques
- Software engineering best practices

---

## 📄 License

This project is created for educational purposes as part of CSE 3212 Compiler Design Laboratory course.

---

## 🤝 Contributing

This is an academic project. For suggestions or improvements, please contact the author.

---

## 📧 Contact

**Ariyan Aftab Spandan**
- Roll: 2107045
- Department of CSE, KUET

---

## 🙏 Acknowledgments

- Course Instructors: Md. Badiuzzaman Shuvo, Subah Nawar
- Reference: Aho, Sethi, Ullman - "Compilers: Principles, Techniques, and Tools" (Dragon Book)
- Tools: GNU Project (Flex, Bison, GCC)

---

**Happy Compiling! 🚀**
