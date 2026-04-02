/*
 * ChronoScript Compiler - Code Optimizer Implementation
 * Phase 5: Code Optimization
 */

#include "optimizer.h"
#include <ctype.h>

/* ============================================================
   HELPER FUNCTIONS
   ============================================================ */

int is_constant(const char* operand) {
    if (!operand) return 0;
    
    /* Check if operand is a number */
    int i = 0;
    if (operand[i] == '-' || operand[i] == '+') i++;
    
    while (operand[i]) {
        if (!isdigit(operand[i]) && operand[i] != '.') {
            return 0;
        }
        i++;
    }
    
    return (i > 0);
}

int get_constant_value(const char* operand) {
    if (!operand) return 0;
    return atoi(operand);
}

int can_fold_operation(TacOpcode opcode, const char* arg1, const char* arg2) {
    if (!arg1) return 0;
    
    if (is_unary_opcode(opcode)) {
        return is_constant(arg1);
    }
    
    if (is_binary_opcode(opcode)) {
        return (is_constant(arg1) && is_constant(arg2));
    }
    
    return 0;
}

int evaluate_constant_operation(TacOpcode opcode, int val1, int val2) {
    switch (opcode) {
        case TAC_ADD: return val1 + val2;
        case TAC_SUB: return val1 - val2;
        case TAC_MUL: return val1 * val2;
        case TAC_DIV: return (val2 != 0) ? val1 / val2 : 0;
        case TAC_MOD: return (val2 != 0) ? val1 % val2 : 0;
        case TAC_LT: return val1 < val2;
        case TAC_GT: return val1 > val2;
        case TAC_LE: return val1 <= val2;
        case TAC_GE: return val1 >= val2;
        case TAC_EQ: return val1 == val2;
        case TAC_NE: return val1 != val2;
        case TAC_AND: return val1 && val2;
        case TAC_OR: return val1 || val2;
        case TAC_BITAND: return val1 & val2;
        case TAC_BITOR: return val1 | val2;
        case TAC_BITXOR: return val1 ^ val2;
        case TAC_LSHIFT: return val1 << val2;
        case TAC_RSHIFT: return val1 >> val2;
        case TAC_UMINUS: return -val1;
        case TAC_UPLUS: return val1;
        case TAC_NOT: return !val1;
        default: return 0;
    }
}

int is_used_variable(const char* var, TacInstruction* start) {
    if (!var || !start) return 0;
    
    TacInstruction* instr = start;
    while (instr) {
        /* Check if variable is used in any argument */
        if (instr->arg1 && strcmp(instr->arg1, var) == 0) return 1;
        if (instr->arg2 && strcmp(instr->arg2, var) == 0) return 1;
        
        /* Check if variable is redefined (kills previous definition) */
        if (instr->result && strcmp(instr->result, var) == 0) return 0;
        
        instr = instr->next;
    }
    
    return 0;
}

int is_dead_code(TacInstruction* instr, TacCode* code) {
    if (!instr || !code) return 0;
    
    /* Don't eliminate control flow, function calls, or I/O */
    if (instr->opcode == TAC_LABEL || instr->opcode == TAC_GOTO ||
        instr->opcode == TAC_IF_GOTO || instr->opcode == TAC_IF_FALSE_GOTO ||
        instr->opcode == TAC_CALL || instr->opcode == TAC_RETURN ||
        instr->opcode == TAC_RETURN_VOID || instr->opcode == TAC_PRINT ||
        instr->opcode == TAC_READ || instr->opcode == TAC_FUNCTION_START ||
        instr->opcode == TAC_FUNCTION_END) {
        return 0;
    }
    
    /* Check if result is used later */
    if (instr->result) {
        return !is_used_variable(instr->result, instr->next);
    }
    
    return 0;
}

TacCode* copy_tac_code(TacCode* original) {
    if (!original) return NULL;
    
    TacCode* copy = create_tac_code();
    copy->temp_count = original->temp_count;
    copy->label_count = original->label_count;
    
    TacInstruction* instr = original->head;
    while (instr) {
        TacInstruction* new_instr = create_tac_instruction(
            instr->opcode, instr->result, instr->arg1, instr->arg2);
        append_tac_instruction(copy, new_instr);
        instr = instr->next;
    }
    
    return copy;
}

/* ============================================================
   OPTIMIZATION PASSES
   ============================================================ */

int constant_folding(TacCode* code) {
    if (!code) return 0;
    
    int optimizations = 0;
    TacInstruction* instr = code->head;
    
    while (instr) {
        if (can_fold_operation(instr->opcode, instr->arg1, instr->arg2)) {
            int val1 = get_constant_value(instr->arg1);
            int val2 = get_constant_value(instr->arg2);
            int result = evaluate_constant_operation(instr->opcode, val1, val2);
            
            /* Replace instruction with assignment */
            if (instr->result) {
                free(instr->arg1);
                if (instr->arg2) free(instr->arg2);
                
                char result_str[32];
                sprintf(result_str, "%d", result);
                instr->arg1 = strdup(result_str);
                instr->arg2 = NULL;
                instr->opcode = TAC_ASSIGN;
                
                optimizations++;
            }
        }
        instr = instr->next;
    }
    
    return optimizations;
}

int constant_propagation(TacCode* code) {
    if (!code) return 0;
    
    int optimizations = 0;
    TacInstruction* instr = code->head;
    
    /* Simple constant propagation within basic blocks */
    while (instr) {
        /* If we have x = constant */
        if (instr->opcode == TAC_ASSIGN && is_constant(instr->arg1)) {
            const char* var = instr->result;
            const char* constant = instr->arg1;
            
            /* Look ahead and replace uses of var with constant */
            TacInstruction* next = instr->next;
            while (next && next->opcode != TAC_LABEL) {
                /* Stop if variable is redefined */
                if (next->result && strcmp(next->result, var) == 0) break;
                
                /* Replace arg1 */
                if (next->arg1 && strcmp(next->arg1, var) == 0) {
                    free(next->arg1);
                    next->arg1 = strdup(constant);
                    optimizations++;
                }
                
                /* Replace arg2 */
                if (next->arg2 && strcmp(next->arg2, var) == 0) {
                    free(next->arg2);
                    next->arg2 = strdup(constant);
                    optimizations++;
                }
                
                next = next->next;
            }
        }
        instr = instr->next;
    }
    
    return optimizations;
}

int dead_code_elimination(TacCode* code) {
    if (!code) return 0;
    
    int eliminated = 0;
    TacInstruction* prev = NULL;
    TacInstruction* instr = code->head;
    
    while (instr) {
        if (is_dead_code(instr, code)) {
            TacInstruction* to_delete = instr;
            
            if (prev) {
                prev->next = instr->next;
            } else {
                code->head = instr->next;
            }
            
            if (instr == code->tail) {
                code->tail = prev;
            }
            
            instr = instr->next;
            
            if (to_delete->result) free(to_delete->result);
            if (to_delete->arg1) free(to_delete->arg1);
            if (to_delete->arg2) free(to_delete->arg2);
            free(to_delete);
            
            eliminated++;
        } else {
            prev = instr;
            instr = instr->next;
        }
    }
    
    return eliminated;
}

int strength_reduction(TacCode* code) {
    if (!code) return 0;
    
    int reductions = 0;
    TacInstruction* instr = code->head;
    
    while (instr) {
        /* Multiplication by power of 2 -> left shift */
        if (instr->opcode == TAC_MUL) {
            if (is_constant(instr->arg2)) {
                int val = get_constant_value(instr->arg2);
                
                /* Check if power of 2 */
                if (val > 0 && (val & (val - 1)) == 0) {
                    int shift = 0;
                    while (val > 1) {
                        val >>= 1;
                        shift++;
                    }
                    
                    instr->opcode = TAC_LSHIFT;
                    free(instr->arg2);
                    char shift_str[16];
                    sprintf(shift_str, "%d", shift);
                    instr->arg2 = strdup(shift_str);
                    reductions++;
                }
            }
        }
        
        /* Division by power of 2 -> right shift */
        if (instr->opcode == TAC_DIV) {
            if (is_constant(instr->arg2)) {
                int val = get_constant_value(instr->arg2);
                
                /* Check if power of 2 */
                if (val > 0 && (val & (val - 1)) == 0) {
                    int shift = 0;
                    while (val > 1) {
                        val >>= 1;
                        shift++;
                    }
                    
                    instr->opcode = TAC_RSHIFT;
                    free(instr->arg2);
                    char shift_str[16];
                    sprintf(shift_str, "%d", shift);
                    instr->arg2 = strdup(shift_str);
                    reductions++;
                }
            }
        }
        
        instr = instr->next;
    }
    
    return reductions;
}

int algebraic_simplification(TacCode* code) {
    if (!code) return 0;
    
    int simplifications = 0;
    TacInstruction* instr = code->head;
    
    while (instr) {
        /* x + 0 = x or 0 + x = x */
        if (instr->opcode == TAC_ADD) {
            if (is_constant(instr->arg1) && get_constant_value(instr->arg1) == 0) {
                free(instr->arg1);
                instr->arg1 = instr->arg2;
                instr->arg2 = NULL;
                instr->opcode = TAC_ASSIGN;
                simplifications++;
            } else if (is_constant(instr->arg2) && get_constant_value(instr->arg2) == 0) {
                free(instr->arg2);
                instr->arg2 = NULL;
                instr->opcode = TAC_ASSIGN;
                simplifications++;
            }
        }
        
        /* x * 1 = x or 1 * x = x */
        if (instr->opcode == TAC_MUL) {
            if (is_constant(instr->arg1) && get_constant_value(instr->arg1) == 1) {
                free(instr->arg1);
                instr->arg1 = instr->arg2;
                instr->arg2 = NULL;
                instr->opcode = TAC_ASSIGN;
                simplifications++;
            } else if (is_constant(instr->arg2) && get_constant_value(instr->arg2) == 1) {
                free(instr->arg2);
                instr->arg2 = NULL;
                instr->opcode = TAC_ASSIGN;
                simplifications++;
            }
            /* x * 0 = 0 or 0 * x = 0 */
            else if ((is_constant(instr->arg1) && get_constant_value(instr->arg1) == 0) ||
                     (is_constant(instr->arg2) && get_constant_value(instr->arg2) == 0)) {
                if (instr->arg1) free(instr->arg1);
                if (instr->arg2) free(instr->arg2);
                instr->arg1 = strdup("0");
                instr->arg2 = NULL;
                instr->opcode = TAC_ASSIGN;
                simplifications++;
            }
        }
        
        /* x - 0 = x */
        if (instr->opcode == TAC_SUB) {
            if (is_constant(instr->arg2) && get_constant_value(instr->arg2) == 0) {
                free(instr->arg2);
                instr->arg2 = NULL;
                instr->opcode = TAC_ASSIGN;
                simplifications++;
            }
        }
        
        instr = instr->next;
    }
    
    return simplifications;
}

/* ============================================================
   MAIN OPTIMIZATION FUNCTION
   ============================================================ */

TacCode* optimize_code(TacCode* input_code, OptimizationStats* stats) {
    if (!input_code || !stats) return NULL;
    
    printf("\n========================================\n");
    printf("       CODE OPTIMIZATION\n");
    printf("========================================\n");
    
    /* Initialize statistics */
    stats->constant_folding_count = 0;
    stats->constant_propagation_count = 0;
    stats->dead_code_eliminated = 0;
    stats->strength_reductions = 0;
    stats->algebraic_simplifications = 0;
    stats->total_optimizations = 0;
    
    /* Copy input code */
    TacCode* optimized = copy_tac_code(input_code);
    
    /* Perform optimization passes */
    printf("Performing constant folding...\n");
    stats->constant_folding_count = constant_folding(optimized);
    
    printf("Performing constant propagation...\n");
    stats->constant_propagation_count = constant_propagation(optimized);
    
    /* Apply constant folding again after propagation */
    stats->constant_folding_count += constant_folding(optimized);
    
    printf("Performing algebraic simplification...\n");
    stats->algebraic_simplifications = algebraic_simplification(optimized);
    
    printf("Performing strength reduction...\n");
    stats->strength_reductions = strength_reduction(optimized);
    
    printf("Eliminating dead code...\n");
    stats->dead_code_eliminated = dead_code_elimination(optimized);
    
    /* Calculate total */
    stats->total_optimizations = stats->constant_folding_count +
                                 stats->constant_propagation_count +
                                 stats->dead_code_eliminated +
                                 stats->strength_reductions +
                                 stats->algebraic_simplifications;
    
    printf("\nOptimization complete!\n");
    printf("Total optimizations: %d\n", stats->total_optimizations);
    printf("========================================\n\n");
    
    return optimized;
}

/* ============================================================
   OPTIMIZATION REPORTING
   ============================================================ */

void print_optimization_stats(OptimizationStats* stats, FILE* output) {
    if (!stats || !output) return;
    
    fprintf(output, "\n========================================\n");
    fprintf(output, "     OPTIMIZATION STATISTICS\n");
    fprintf(output, "========================================\n");
    fprintf(output, "Constant Folding:         %d\n", stats->constant_folding_count);
    fprintf(output, "Constant Propagation:     %d\n", stats->constant_propagation_count);
    fprintf(output, "Dead Code Eliminated:     %d\n", stats->dead_code_eliminated);
    fprintf(output, "Strength Reductions:      %d\n", stats->strength_reductions);
    fprintf(output, "Algebraic Simplifications:%d\n", stats->algebraic_simplifications);
    fprintf(output, "----------------------------------------\n");
    fprintf(output, "Total Optimizations:      %d\n", stats->total_optimizations);
    fprintf(output, "========================================\n");
}

void save_optimized_code(TacCode* code, const char* filename, OptimizationStats* stats) {
    if (!code || !filename) return;
    
    FILE* file = fopen(filename, "w");
    if (!file) {
        fprintf(stderr, "Error: Cannot open file '%s' for writing\n", filename);
        return;
    }
    
    fprintf(file, "========================================\n");
    fprintf(file, "    OPTIMIZED INTERMEDIATE CODE\n");
    fprintf(file, "========================================\n\n");
    
    TacInstruction* instr = code->head;
    while (instr) {
        print_tac_instruction(instr, file);
        instr = instr->next;
    }
    
    if (stats) {
        print_optimization_stats(stats, file);
    }
    
    fclose(file);
    printf("Optimized code saved to: %s\n", filename);
}
