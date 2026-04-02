/*
 * ChronoScript Compiler - Target Code Generator Implementation
 * Phase 6: Target Code Generation
 */

#include "target_codegen.h"

/* ============================================================
   TARGET CODE MANAGEMENT
   ============================================================ */

TargetCode* create_target_code() {
    TargetCode* code = (TargetCode*)malloc(sizeof(TargetCode));
    if (!code) {
        fprintf(stderr, "Error: Memory allocation failed for target code\n");
        exit(1);
    }
    code->head = NULL;
    code->tail = NULL;
    code->instruction_count = 0;
    return code;
}

void destroy_target_code(TargetCode* code) {
    if (!code) return;
    
    TargetInstruction* current = code->head;
    while (current) {
        TargetInstruction* next = current->next;
        if (current->operand1) free(current->operand1);
        if (current->operand2) free(current->operand2);
        if (current->operand3) free(current->operand3);
        free(current);
        current = next;
    }
    free(code);
}

TargetInstruction* create_target_instruction(TargetOpcode opcode,
    const char* op1, const char* op2, const char* op3) {
    TargetInstruction* instr = (TargetInstruction*)malloc(sizeof(TargetInstruction));
    if (!instr) {
        fprintf(stderr, "Error: Memory allocation failed for target instruction\n");
        exit(1);
    }
    
    instr->opcode = opcode;
    instr->operand1 = op1 ? strdup(op1) : NULL;
    instr->operand2 = op2 ? strdup(op2) : NULL;
    instr->operand3 = op3 ? strdup(op3) : NULL;
    instr->next = NULL;
    
    return instr;
}

void append_target_instruction(TargetCode* code, TargetInstruction* instr) {
    if (!code || !instr) return;
    
    if (!code->head) {
        code->head = instr;
        code->tail = instr;
    } else {
        code->tail->next = instr;
        code->tail = instr;
    }
    code->instruction_count++;
}

/* ============================================================
   REGISTER ALLOCATION
   ============================================================ */

RegisterAllocator* create_register_allocator() {
    RegisterAllocator* alloc = (RegisterAllocator*)malloc(sizeof(RegisterAllocator));
    if (!alloc) {
        fprintf(stderr, "Error: Memory allocation failed for register allocator\n");
        exit(1);
    }
    
    /* Initialize registers (R0, R1, ..., R7) */
    alloc->num_registers = MAX_REGISTERS;
    for (int i = 0; i < MAX_REGISTERS; i++) {
        alloc->registers[i] = (char*)malloc(8);
        sprintf(alloc->registers[i], "R%d", i);
        alloc->used[i] = 0;
    }
    
    return alloc;
}

void destroy_register_allocator(RegisterAllocator* alloc) {
    if (!alloc) return;
    
    for (int i = 0; i < alloc->num_registers; i++) {
        free(alloc->registers[i]);
    }
    free(alloc);
}

char* allocate_register(RegisterAllocator* alloc) {
    if (!alloc) return NULL;
    
    for (int i = 0; i < alloc->num_registers; i++) {
        if (!alloc->used[i]) {
            alloc->used[i] = 1;
            return alloc->registers[i];
        }
    }
    
    /* If no register available, return first register (simple strategy) */
    return alloc->registers[0];
}

void free_register(RegisterAllocator* alloc, const char* reg) {
    if (!alloc || !reg) return;
    
    for (int i = 0; i < alloc->num_registers; i++) {
        if (strcmp(alloc->registers[i], reg) == 0) {
            alloc->used[i] = 0;
            return;
        }
    }
}

void free_all_registers(RegisterAllocator* alloc) {
    if (!alloc) return;
    
    for (int i = 0; i < alloc->num_registers; i++) {
        alloc->used[i] = 0;
    }
}

/* ============================================================
   UTILITY FUNCTIONS
   ============================================================ */

const char* get_target_opcode_name(TargetOpcode opcode) {
    switch (opcode) {
        case TARGET_LOAD: return "LOAD";
        case TARGET_STORE: return "STORE";
        case TARGET_MOVE: return "MOVE";
        case TARGET_ADD: return "ADD";
        case TARGET_SUB: return "SUB";
        case TARGET_MUL: return "MUL";
        case TARGET_DIV: return "DIV";
        case TARGET_MOD: return "MOD";
        case TARGET_AND: return "AND";
        case TARGET_OR: return "OR";
        case TARGET_XOR: return "XOR";
        case TARGET_SHL: return "SHL";
        case TARGET_SHR: return "SHR";
        case TARGET_NEG: return "NEG";
        case TARGET_NOT: return "NOT";
        case TARGET_CMP: return "CMP";
        case TARGET_JMP: return "JMP";
        case TARGET_JE: return "JE";
        case TARGET_JNE: return "JNE";
        case TARGET_JL: return "JL";
        case TARGET_JG: return "JG";
        case TARGET_JLE: return "JLE";
        case TARGET_JGE: return "JGE";
        case TARGET_CALL: return "CALL";
        case TARGET_RET: return "RET";
        case TARGET_PUSH: return "PUSH";
        case TARGET_POP: return "POP";
        case TARGET_LABEL: return "";
        case TARGET_PRINT: return "PRINT";
        case TARGET_READ: return "READ";
        case TARGET_COMMENT: return ";";
        default: return "UNKNOWN";
    }
}

int needs_register(const char* operand) {
    if (!operand) return 0;
    /* Check if operand is a temporary variable */
    return (operand[0] == 't' && strlen(operand) > 1);
}

/* ============================================================
   TARGET CODE GENERATION
   ============================================================ */

void translate_tac_instruction(TacInstruction* tac_instr, TargetCode* target,
                                RegisterAllocator* alloc) {
    if (!tac_instr || !target || !alloc) return;
    
    TargetInstruction* instr = NULL;
    
    switch (tac_instr->opcode) {
        case TAC_ADD:
            instr = create_target_instruction(TARGET_ADD, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_SUB:
            instr = create_target_instruction(TARGET_SUB, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_MUL:
            instr = create_target_instruction(TARGET_MUL, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_DIV:
            instr = create_target_instruction(TARGET_DIV, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_MOD:
            instr = create_target_instruction(TARGET_MOD, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_ASSIGN:
        case TAC_COPY:
            instr = create_target_instruction(TARGET_MOVE, tac_instr->result,
                                            tac_instr->arg1, NULL);
            break;
            
        case TAC_UMINUS:
            instr = create_target_instruction(TARGET_NEG, tac_instr->result,
                                            tac_instr->arg1, NULL);
            break;
            
        case TAC_NOT:
            instr = create_target_instruction(TARGET_NOT, tac_instr->result,
                                            tac_instr->arg1, NULL);
            break;
            
        case TAC_BITAND:
            instr = create_target_instruction(TARGET_AND, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_BITOR:
            instr = create_target_instruction(TARGET_OR, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_BITXOR:
            instr = create_target_instruction(TARGET_XOR, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_LSHIFT:
            instr = create_target_instruction(TARGET_SHL, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_RSHIFT:
            instr = create_target_instruction(TARGET_SHR, tac_instr->result,
                                            tac_instr->arg1, tac_instr->arg2);
            break;
            
        case TAC_LT:
        case TAC_GT:
        case TAC_LE:
        case TAC_GE:
        case TAC_EQ:
        case TAC_NE:
            /* Comparison: CMP followed by conditional move */
            instr = create_target_instruction(TARGET_CMP, tac_instr->arg1,
                                            tac_instr->arg2, NULL);
            append_target_instruction(target, instr);
            
            /* Set result based on comparison */
            instr = create_target_instruction(TARGET_MOVE, tac_instr->result,
                                            "0", NULL);
            append_target_instruction(target, instr);
            
            char* skip_label = (char*)malloc(32);
            sprintf(skip_label, "skip_%d", target->instruction_count);
            
            TargetOpcode jump_op = TARGET_JMP;
            if (tac_instr->opcode == TAC_EQ) jump_op = TARGET_JNE;
            else if (tac_instr->opcode == TAC_NE) jump_op = TARGET_JE;
            else if (tac_instr->opcode == TAC_LT) jump_op = TARGET_JGE;
            else if (tac_instr->opcode == TAC_GT) jump_op = TARGET_JLE;
            else if (tac_instr->opcode == TAC_LE) jump_op = TARGET_JG;
            else if (tac_instr->opcode == TAC_GE) jump_op = TARGET_JL;
            
            instr = create_target_instruction(jump_op, skip_label, NULL, NULL);
            append_target_instruction(target, instr);
            
            instr = create_target_instruction(TARGET_MOVE, tac_instr->result,
                                            "1", NULL);
            append_target_instruction(target, instr);
            
            instr = create_target_instruction(TARGET_LABEL, skip_label, NULL, NULL);
            free(skip_label);
            break;
            
        case TAC_LABEL:
            instr = create_target_instruction(TARGET_LABEL, tac_instr->result,
                                            NULL, NULL);
            break;
            
        case TAC_GOTO:
            instr = create_target_instruction(TARGET_JMP, tac_instr->result,
                                            NULL, NULL);
            break;
            
        case TAC_IF_GOTO:
            /* Compare arg1 with 0, jump if not zero */
            instr = create_target_instruction(TARGET_CMP, tac_instr->arg1,
                                            "0", NULL);
            append_target_instruction(target, instr);
            instr = create_target_instruction(TARGET_JNE, tac_instr->result,
                                            NULL, NULL);
            break;
            
        case TAC_IF_FALSE_GOTO:
            /* Compare arg1 with 0, jump if zero */
            instr = create_target_instruction(TARGET_CMP, tac_instr->arg1,
                                            "0", NULL);
            append_target_instruction(target, instr);
            instr = create_target_instruction(TARGET_JE, tac_instr->result,
                                            NULL, NULL);
            break;
            
        case TAC_CALL:
            /* Push parameters (simplified) */
            if (tac_instr->arg2) {
                instr = create_target_instruction(TARGET_PUSH, tac_instr->arg2,
                                                NULL, NULL);
                append_target_instruction(target, instr);
            }
            
            /* Call function */
            instr = create_target_instruction(TARGET_CALL, tac_instr->arg1,
                                            NULL, NULL);
            append_target_instruction(target, instr);
            
            /* Store result if needed */
            if (tac_instr->result) {
                instr = create_target_instruction(TARGET_POP, tac_instr->result,
                                                NULL, NULL);
            }
            break;
            
        case TAC_RETURN:
            if (tac_instr->arg1) {
                instr = create_target_instruction(TARGET_MOVE, "R0",
                                                tac_instr->arg1, NULL);
                append_target_instruction(target, instr);
            }
            instr = create_target_instruction(TARGET_RET, NULL, NULL, NULL);
            break;
            
        case TAC_RETURN_VOID:
            instr = create_target_instruction(TARGET_RET, NULL, NULL, NULL);
            break;
            
        case TAC_PRINT:
            instr = create_target_instruction(TARGET_PRINT, tac_instr->arg1,
                                            NULL, NULL);
            break;
            
        case TAC_READ:
            instr = create_target_instruction(TARGET_READ, tac_instr->arg1,
                                            NULL, NULL);
            break;
            
        case TAC_FUNCTION_START:
            /* Add comment and label */
            instr = create_target_instruction(TARGET_COMMENT,
                "==================== Function Start ====================",
                NULL, NULL);
            append_target_instruction(target, instr);
            instr = create_target_instruction(TARGET_LABEL, tac_instr->result,
                                            NULL, NULL);
            append_target_instruction(target, instr);
            instr = create_target_instruction(TARGET_PUSH, "FP", NULL, NULL);
            append_target_instruction(target, instr);
            instr = create_target_instruction(TARGET_MOVE, "FP", "SP", NULL);
            break;
            
        case TAC_FUNCTION_END:
            instr = create_target_instruction(TARGET_MOVE, "SP", "FP", NULL);
            append_target_instruction(target, instr);
            instr = create_target_instruction(TARGET_POP, "FP", NULL, NULL);
            append_target_instruction(target, instr);
            instr = create_target_instruction(TARGET_RET, NULL, NULL, NULL);
            append_target_instruction(target, instr);
            instr = create_target_instruction(TARGET_COMMENT,
                "==================== Function End ======================",
                NULL, NULL);
            break;
            
        default:
            instr = create_target_instruction(TARGET_COMMENT,
                "Unknown TAC instruction", NULL, NULL);
            break;
    }
    
    if (instr) {
        append_target_instruction(target, instr);
    }
}

TargetCode* generate_target_code(TacCode* tac_code) {
    if (!tac_code) return NULL;
    
    printf("\n========================================\n");
    printf("     TARGET CODE GENERATION\n");
    printf("========================================\n");
    printf("Generating pseudo-assembly code...\n");
    
    TargetCode* target = create_target_code();
    RegisterAllocator* alloc = create_register_allocator();
    
    /* Add header comment */
    TargetInstruction* header = create_target_instruction(TARGET_COMMENT,
        "ChronoScript Compiler - Target Code", NULL, NULL);
    append_target_instruction(target, header);
    
    header = create_target_instruction(TARGET_COMMENT,
        "Generated Pseudo-Assembly Code", NULL, NULL);
    append_target_instruction(target, header);
    
    /* Translate each TAC instruction */
    TacInstruction* tac_instr = tac_code->head;
    while (tac_instr) {
        translate_tac_instruction(tac_instr, target, alloc);
        tac_instr = tac_instr->next;
    }
    
    destroy_register_allocator(alloc);
    
    printf("Target code generation complete!\n");
    printf("Total instructions: %d\n", target->instruction_count);
    printf("========================================\n\n");
    
    return target;
}

/* ============================================================
   TARGET CODE OUTPUT
   ============================================================ */

void print_target_instruction(TargetInstruction* instr, FILE* output) {
    if (!instr || !output) return;
    
    if (instr->opcode == TARGET_LABEL) {
        fprintf(output, "%s:\n", instr->operand1);
    } else if (instr->opcode == TARGET_COMMENT) {
        fprintf(output, "; %s\n", instr->operand1);
    } else {
        fprintf(output, "\t%-8s", get_target_opcode_name(instr->opcode));
        
        if (instr->operand1) {
            fprintf(output, " %s", instr->operand1);
        }
        if (instr->operand2) {
            fprintf(output, ", %s", instr->operand2);
        }
        if (instr->operand3) {
            fprintf(output, ", %s", instr->operand3);
        }
        fprintf(output, "\n");
    }
}

void print_target_code(TargetCode* code, FILE* output) {
    if (!code || !output) return;
    
    fprintf(output, "========================================\n");
    fprintf(output, "       TARGET CODE (Pseudo-Assembly)\n");
    fprintf(output, "========================================\n\n");
    
    TargetInstruction* instr = code->head;
    while (instr) {
        print_target_instruction(instr, output);
        instr = instr->next;
    }
    
    fprintf(output, "\n========================================\n");
    fprintf(output, "Total instructions: %d\n", code->instruction_count);
    fprintf(output, "========================================\n");
}

void save_target_code(TargetCode* code, const char* filename) {
    if (!code || !filename) return;
    
    FILE* file = fopen(filename, "w");
    if (!file) {
        fprintf(stderr, "Error: Cannot open file '%s' for writing\n", filename);
        return;
    }
    
    print_target_code(code, file);
    fclose(file);
    
    printf("Target code saved to: %s\n", filename);
}
