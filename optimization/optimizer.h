/*
 * ChronoScript Compiler - Code Optimizer Header
 * Phase 5: Code Optimization
 * 
 * This module performs optimizations on TAC:
 * - Constant folding
 * - Constant propagation
 * - Dead code elimination
 * - Algebraic simplifications
 * - Strength reduction
 */

#ifndef OPTIMIZER_H
#define OPTIMIZER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../intermediate/icg.h"

/* Optimization statistics */
typedef struct OptimizationStats {
    int constant_folding_count;
    int constant_propagation_count;
    int dead_code_eliminated;
    int strength_reductions;
    int algebraic_simplifications;
    int total_optimizations;
} OptimizationStats;

/* Function prototypes */

/* Main optimization function */
TacCode* optimize_code(TacCode* input_code, OptimizationStats* stats);

/* Individual optimization passes */
int constant_folding(TacCode* code);
int constant_propagation(TacCode* code);
int dead_code_elimination(TacCode* code);
int strength_reduction(TacCode* code);
int algebraic_simplification(TacCode* code);

/* Helper functions */
int is_constant(const char* operand);
int get_constant_value(const char* operand);
int can_fold_operation(TacOpcode opcode, const char* arg1, const char* arg2);
int evaluate_constant_operation(TacOpcode opcode, int val1, int val2);
int is_dead_code(TacInstruction* instr, TacCode* code);
int is_used_variable(const char* var, TacInstruction* start);

/* Copy TAC code */
TacCode* copy_tac_code(TacCode* original);

/* Optimization reporting */
void print_optimization_stats(OptimizationStats* stats, FILE* output);
void save_optimized_code(TacCode* code, const char* filename, OptimizationStats* stats);

#endif /* OPTIMIZER_H */
