# ChronoScript Compiler Project Proposal

## Course Information
- **University:** Khulna University of Engineering & Technology (KUET)
- **Department:** Computer Science and Engineering
- **Course No:** CSE 3212
- **Course Title:** Compiler Design Laboratory
- **Submission Date:** 19 January, 2026

## Submitted To
- **Md. Badiuzzaman Shuvo**  
  Lecturer, Department of Computer Science and Engineering, KUET
- **Subah Nawar**  
  Lecturer, Department of Computer Science and Engineering, KUET

## Submitted By
- **Name:** Ariyan Aftab Spandan  
- **Roll:** 2107045  
- **Section:** A  
- **Lab Group:** A2  
- **Year:** 3rd  
- **Term:** 2nd  
- **Session:** 2023–24

---

## Title
**ChronoScript Compiler**

---

## 1. Introduction

### 1.1 Overview

ChronoScript is a custom-designed programming language that models computation using metaphors inspired by physics and temporal mechanics. Unlike traditional languages that treat execution as static instruction flow, ChronoScript conceptualizes program execution as the movement of *Matter* and *Energy* across a *Timeline*.

This compiler project demonstrates how a high-level, domain-themed language can be translated into executable form using classical compiler construction tools—**Flex** for lexical analysis and **Bison** for syntax analysis.

The language extends standard C constructs while preserving compatibility with common programming paradigms. In ChronoScript:
- Integers are represented as **Matter** (solid state)
- Floating-point values are represented as **Energy** (fluid state)
- Functions are described as **Events** in the timeline
- Conditional branching is described as **Divergence**

The compiler enforces strict syntactic and semantic rules to maintain causal consistency throughout program execution.

---

## 2. Project Objectives

The primary objectives of the ChronoScript Compiler project are:

1. To design and implement a lexical analyzer using Flex that can recognize a large set of custom tokens.
2. To develop a syntax analyzer using Bison capable of parsing ChronoScript grammar rules.
3. To map ChronoScript keywords and constructs to equivalent C language semantics.
4. To demonstrate practical knowledge of compiler phases such as tokenization, parsing, and semantic handling.
5. To provide a creative yet technically correct compiler implementation suitable for academic evaluation.

---

## 3. ChronoScript Keyword Mapping

ChronoScript introduces **66 unique tokens**, each mapped to an equivalent C construct.

### 3.1 Data Types

| ChronoScript | C Equivalent | Description |
|-------------|--------------|-------------|
| Void | void | Empty return type |
| Truth | bool | Boolean truth value |
| Matter | int | Whole number |
| Atom | char | Single character |
| Stream | char* | String data |
| Energy | float | Decimal value |
| HighEnergy | double | High-precision decimal |
| pureMatter | short int | Short integer |
| largeMatter | long int | Long integer |
| fullEnergy | long double | Highest precision decimal |
| smallMatter | unsigned int | Unsigned integer |

---

### 3.2 Control Flow Keywords

| ChronoScript | C Equivalent |
|-------------|--------------|
| Era | if |
| Alternate | else |
| Loop | for |
| Diverge | while |
| Resolve | return |
| Persist | continue |
| Escape | break |

---

### 3.3 Functions and I/O

| ChronoScript | C Equivalent |
|-------------|--------------|
| Event | function |
| Observe | scanf |
| Broadcast | printf |
| timeline | main |

---

### 3.4 Mathematical Functions

| ChronoScript | C Function |
|-------------|------------|
| sine | sin() |
| cosine | cos() |
| tangent | tan() |
| invSine | asin() |
| invCosine | acos() |
| invTangent | atan() |
| logarithm | log() |
| power | pow() |
| squareroot | sqrt() |
| absolute | abs() |
| floor | floor() |
| ceiling | ceil() |

---

### 3.5 Bitwise and Logical Operators

| Operator | Meaning |
|---------|---------|
| && | Logical AND |
| || | Logical OR |
| ! | Logical NOT |
| & | Bitwise AND |
| | | Bitwise OR |
| ^ | Bitwise XOR |
| << | Left shift |
| >> | Right shift |

---

## 4. Unique Features

### 4.1 SingularityCheck (Prime Number Detection)

The **SingularityCheck** function determines whether a number is prime. In ChronoScript terminology, a prime number is treated as a *Singularity*—a value that cannot be divided into smaller components without breaking its timeline.

The algorithm verifies that:
- The number is greater than 1
- No divisors exist in the range [2, √n]

If these conditions hold, the function returns **Truth**, signifying temporal purity.

---

### 4.2 MassAccumulation (Factorial Calculation)

**MassAccumulation** represents the factorial operation. Instead of a traditional iterative or recursive explanation, ChronoScript describes factorial computation as the accumulation of numerical mass over time.

As the timeline progresses, each recursive step adds gravitational weight to the result until a final unified mass is achieved.

This metaphor helps demonstrate recursion and iterative control flow in a conceptual and intuitive manner.

---

## 5. Tools and Technologies

- **Flex:** Lexical analysis and token generation
- **Bison:** Syntax analysis and parsing
- **C Language:** Target language for code generation
- **GCC:** Compilation and testing

---

## 6. Expected Outcomes

By completing this project, the following outcomes are expected:

- A fully functional lexical analyzer for ChronoScript
- A grammar-based parser capable of validating program structure
- Successful translation of ChronoScript programs into valid C-like execution logic
- Enhanced understanding of compiler design principles

---

## 7. Conclusion

The ChronoScript Compiler project combines creativity with classical compiler theory. By introducing a physics-inspired programming language and implementing it using Flex and Bison, this project demonstrates both technical proficiency and conceptual innovation.

The compiler serves as a practical academic exercise and a demonstration of how domain-specific languages can be designed and implemented using standard compiler construction tools.

---

## 8. References

1. Aho, A. V., Lam, M. S., Sethi, R., & Ullman, J. D. *Compilers: Principles, Techniques, and Tools*. Pearson Education.
2. Flex Manual – https://westes.github.io/flex/manual/
3. Bison Manual – https://www.gnu.org/software/bison/manual/
4. C Programming Language – https://en.cppreference.com/