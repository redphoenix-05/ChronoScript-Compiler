/*
 * semantic.c - Semantic analysis for ChronoScript
 */
#include <stdio.h>
#include "../include/symtab.h"

int error_count = 0;

void semantic_error(const char *msg, int line) {
    fprintf(stderr, "Semantic error at line %d: %s\n", line, msg);
    error_count++;
}
