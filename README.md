# ChronoScript Compiler

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Language](https://img.shields.io/badge/language-Flex%2FBison%2FC-green)
![Platform](https://img.shields.io/badge/platform-Linux%20|%20macOS%20|%20Windows-lightgrey)
![Status](https://img.shields.io/badge/status-All%20Phases%20Complete-success)

ChronoScript is a small experimental programming language built around a time-based theme. This repository contains a full compiler pipeline that takes ChronoScript code and processes it step by step until it produces a low-level output.

---

## Overview

The project follows the classic structure of a compiler. Each stage is implemented separately so it is easier to understand how source code is transformed internally.

### Pipeline

```
Input (.cs)
   ↓
Lexical Analysis
   ↓
Syntax Analysis
   ↓
Semantic Checking
   ↓
Intermediate Code
   ↓
Optimization
   ↓
Target Code
```

---

## Language Idea

ChronoScript uses a different naming style compared to traditional languages:

- Variables are treated like **matter**
- Execution behaves like a **timeline**
- Computation is described as **energy flow**

---

## Keywords Mapping

| ChronoScript | Equivalent | Meaning |
|--------------|-----------|--------|
| Matter | int | integer |
| Energy | float | floating point |
| Atom | char | character |
| Stream | string | text |
| Truth | bool | boolean |
| Era | if | condition |
| Alternate | else | alternative branch |
| Loop | loop | iteration |
| Escape | break | exit loop |
| Persist | continue | skip iteration |
| Resolve | return | return value |
| Event | function | function |
| Broadcast | print | output |

---

## Example

```chronoscript
Matter factorial(Matter n) {
    Era (n <= 1) {
        Resolve 1;
    }
    Resolve n * factorial(n - 1);
}

Event main() {
    Matter result = factorial(5);
    Broadcast("Done");
    Resolve 0;
}
```

---

## Compiler Stages

### 1. Lexical Analysis
Breaks input into tokens using Flex.

### 2. Syntax Analysis
Checks grammar rules using Bison.

### 3. Semantic Analysis
Verifies variables, scopes, and basic types.

### 4. Intermediate Code
Generates simple instruction-like code.

### 5. Optimization
Applies small improvements like constant folding.

### 6. Target Code
Produces a pseudo assembly output.

---

## Installation

### Linux
```bash
sudo apt-get install flex bison gcc make
```

### macOS
```bash
brew install flex bison gcc make
```

### Windows
Use WSL or MinGW.

---

## Build

```bash
make
```

---

## Run

```bash
./chrono_compiler input.cs
```

---

## Output

The compiler generates:

- intermediate_code.txt  
- optimized_code.txt  
- target_code.txt  
- symbol_table.txt  

---

## Project Structure

```
lexer/
parser/
semantic/
intermediate/
optimization/
target/
tests/
outputs/
```

---

## Notes

Some parts took a few attempts to get right, especially grammar rules and intermediate code handling. Small mistakes in earlier stages often affected later outputs, so debugging required careful checking.

---

## Future Work

- Improve optimization
- Better register handling
- More language features

---

## Contact

Ariyan Aftab Spandan  
Email: ariyan2107045@gmail.com