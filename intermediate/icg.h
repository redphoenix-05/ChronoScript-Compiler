/*
 * ChronoScript Compiler - Intermediate Code Generator Header
 * Phase 4: Intermediate Code Generation (3-Address Code)
 * 
 * This module generates three-address code (TAC) from the AST
 * - Handles arithmetic expressions
 * - Handles assignments
 * - Handles control flow (if, while, for)
 * - Generates temporary variables
 * - Generates labels for jumps
 */

#ifndef ICG_H
#define ICG_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Shared AST types (defined in project root ast.h) */
#include "../ast.h"

/* TAC instruction types */
typedef enum {
    TAC_ADD,          // t = a + b
    TAC_SUB,          // t = a - b
    TAC_MUL,          // t = a * b
    TAC_DIV,          // t = a / b
    TAC_MOD,          // t = a % b
    TAC_ASSIGN,       // t = a
    TAC_COPY,         // t = a (simple copy)
    TAC_UMINUS,       // t = -a
    TAC_UPLUS,        // t = +a
    TAC_NOT,          // t = !a
    
    TAC_LT,           // t = a < b
    TAC_GT,           // t = a > b
    TAC_LE,           // t = a <= b
    TAC_GE,           // t = a >= b
    TAC_EQ,           // t = a == b
    TAC_NE,           // t = a != b
    
    TAC_AND,          // t = a && b
    TAC_OR,           // t = a || b
    
    TAC_BITAND,       // t = a & b
    TAC_BITOR,        // t = a | b
    TAC_BITXOR,       // t = a ^ b
    TAC_LSHIFT,       // t = a << b
    TAC_RSHIFT,       // t = a >> b
    
    TAC_LABEL,        // label:
    TAC_GOTO,         // goto label
    TAC_IF_GOTO,      // if a goto label
    TAC_IF_FALSE_GOTO,// if !a goto label
    
    TAC_PARAM,        // param a
    TAC_CALL,         // t = call func, n
    TAC_RETURN,       // return a
    TAC_RETURN_VOID,  // return
    
    TAC_ARRAY_READ,   // t = a[i]
    TAC_ARRAY_WRITE,  // a[i] = t
    
    TAC_FUNCTION_START,  // function name:
    TAC_FUNCTION_END,    // end function
    
    TAC_PRINT,        // print a
    TAC_READ          // read a
} TacOpcode;

/* TAC instruction structure */
typedef struct TacInstruction {
    TacOpcode opcode;
    char* result;           // Result operand
    char* arg1;             // First operand
    char* arg2;             // Second operand
    struct TacInstruction* next;
} TacInstruction;

/* TAC code list */
typedef struct TacCode {
    TacInstruction* head;
    TacInstruction* tail;
    int temp_count;         // Counter for temporary variables
    int label_count;        // Counter for labels
} TacCode;

/* Function prototypes */

/* TAC code management */
TacCode* create_tac_code();
void destroy_tac_code(TacCode* code);
TacInstruction* create_tac_instruction(TacOpcode opcode, const char* result,
                                       const char* arg1, const char* arg2);
void append_tac_instruction(TacCode* code, TacInstruction* instr);
void append_tac_code(TacCode* dest, TacCode* src);

/* Temporary and label generation */
char* new_temp(TacCode* code);
char* new_label(TacCode* code);

/* TAC output */
void print_tac_instruction(TacInstruction* instr, FILE* output);
void print_tac_code(TacCode* code, FILE* output);
void save_tac_to_file(TacCode* code, const char* filename);

/* Utility functions */
const char* get_opcode_string(TacOpcode opcode);
int is_binary_opcode(TacOpcode opcode);
int is_unary_opcode(TacOpcode opcode);
int is_comparison_opcode(TacOpcode opcode);
TacOpcode get_tac_opcode_from_operator(const char* operator_str);

/* Main TAC generation function */
TacCode* generate_intermediate_code(ASTNode* ast_root);

#endif /* ICG_H */
