/*
 * ChronoScript Compiler - Target Code Generator Header
 * Phase 6: Target Code Generation
 * 
 * This module generates target code (pseudo-assembly or C-like code)
 * from the optimized intermediate representation.
 */

#ifndef TARGET_CODEGEN_H
#define TARGET_CODEGEN_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "icg.h"

/* Target code instruction types */
typedef enum {
    TARGET_LOAD,      // LOAD reg, addr
    TARGET_STORE,     // STORE addr, reg
    TARGET_MOVE,      // MOVE dest, src
    TARGET_ADD,       // ADD dest, src1, src2
    TARGET_SUB,       // SUB dest, src1, src2
    TARGET_MUL,       // MUL dest, src1, src2
    TARGET_DIV,       // DIV dest, src1, src2
    TARGET_MOD,       // MOD dest, src1, src2
    TARGET_AND,       // AND dest, src1, src2
    TARGET_OR,        // OR dest, src1, src2
    TARGET_XOR,       // XOR dest, src1, src2
    TARGET_SHL,       // SHL dest, src1, src2
    TARGET_SHR,       // SHR dest, src1, src2
    TARGET_NEG,       // NEG dest, src
    TARGET_NOT,       // NOT dest, src
    TARGET_CMP,       // CMP src1, src2
    TARGET_JMP,       // JMP label
    TARGET_JE,        // JE label (jump if equal)
    TARGET_JNE,       // JNE label (jump if not equal)
    TARGET_JL,        // JL label (jump if less)
    TARGET_JG,        // JG label (jump if greater)
    TARGET_JLE,       // JLE label (jump if less or equal)
    TARGET_JGE,       // JGE label (jump if greater or equal)
    TARGET_CALL,      // CALL function
    TARGET_RET,       // RET
    TARGET_PUSH,      // PUSH src
    TARGET_POP,       // POP dest
    TARGET_LABEL,     // label:
    TARGET_PRINT,     // PRINT src
    TARGET_READ,      // READ dest
    TARGET_COMMENT    // ; comment
} TargetOpcode;

/* Target instruction structure */
typedef struct TargetInstruction {
    TargetOpcode opcode;
    char* operand1;
    char* operand2;
    char* operand3;
    struct TargetInstruction* next;
} TargetInstruction;

/* Target code structure */
typedef struct TargetCode {
    TargetInstruction* head;
    TargetInstruction* tail;
    int instruction_count;
} TargetCode;

/* Register allocation */
#define MAX_REGISTERS 8
typedef struct RegisterAllocator {
    char* registers[MAX_REGISTERS];  // Available registers
    int used[MAX_REGISTERS];         // Usage flags
    int num_registers;
} RegisterAllocator;

/* Function prototypes */

/* Target code management */
TargetCode* create_target_code();
void destroy_target_code(TargetCode* code);
TargetInstruction* create_target_instruction(TargetOpcode opcode, 
    const char* op1, const char* op2, const char* op3);
void append_target_instruction(TargetCode* code, TargetInstruction* instr);

/* Register allocation */
RegisterAllocator* create_register_allocator();
void destroy_register_allocator(RegisterAllocator* alloc);
char* allocate_register(RegisterAllocator* alloc);
void free_register(RegisterAllocator* alloc, const char* reg);
void free_all_registers(RegisterAllocator* alloc);

/* Target code generation */
TargetCode* generate_target_code(TacCode* tac_code);
void translate_tac_instruction(TacInstruction* tac_instr, TargetCode* target, 
                                RegisterAllocator* alloc);

/* Target code output */
void print_target_instruction(TargetInstruction* instr, FILE* output);
void print_target_code(TargetCode* code, FILE* output);
void save_target_code(TargetCode* code, const char* filename);

/* Utility functions */
const char* get_target_opcode_name(TargetOpcode opcode);
int needs_register(const char* operand);

#endif /* TARGET_CODEGEN_H */
