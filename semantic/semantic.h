/*
 * ChronoScript Compiler - Semantic Analyzer Header
 * Phase 3: Semantic Analysis
 * 
 * This module handles:
 * - Type checking
 * - Scope management
 * - Undeclared variable detection
 * - Duplicate declaration detection
 * - Function parameter validation
 * - Type compatibility checking
 */

#ifndef SEMANTIC_H
#define SEMANTIC_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Data type enumeration for ChronoScript */
typedef enum {
    TYPE_VOID,
    TYPE_TRUTH,      // bool
    TYPE_MATTER,     // int
    TYPE_ATOM,       // char
    TYPE_STREAM,     // string
    TYPE_ENERGY,     // float
    TYPE_HIGH_ENERGY,    // double
    TYPE_PURE_MATTER,    // short
    TYPE_LARGE_MATTER,   // long
    TYPE_FULL_ENERGY,    // long double
    TYPE_SMALL_MATTER,   // unsigned
    TYPE_STRUCTURE,      // struct
    TYPE_ARRAY,
    TYPE_FUNCTION,
    TYPE_ERROR,
    TYPE_UNKNOWN
} DataType;

/* Symbol table entry structure */
typedef struct SymbolEntry {
    char* name;
    DataType type;
    int scope_level;
    int line_number;
    int is_function;
    int is_array;
    int array_size;
    int param_count;
    DataType* param_types;      // For functions
    struct SymbolEntry* next;
} SymbolEntry;

/* Symbol table structure */
typedef struct SymbolTable {
    SymbolEntry* head;
    int current_scope;
    int error_count;
    int warning_count;
} SymbolTable;

/* Global symbol table */
extern SymbolTable* global_symbol_table;

/* Function prototypes */

/* Symbol table management */
SymbolTable* create_symbol_table();
void destroy_symbol_table(SymbolTable* table);
void enter_scope(SymbolTable* table);
void exit_scope(SymbolTable* table);

/* Symbol operations */
SymbolEntry* insert_symbol(SymbolTable* table, const char* name, DataType type, 
                          int line_number, int is_function, int is_array);
SymbolEntry* lookup_symbol(SymbolTable* table, const char* name);
SymbolEntry* lookup_symbol_current_scope(SymbolTable* table, const char* name);

/* Type checking */
DataType get_type_from_string(const char* type_str);
const char* get_type_name(DataType type);
int are_types_compatible(DataType type1, DataType type2);
int can_cast_type(DataType from, DataType to);

/* Semantic analysis functions */
void check_variable_declaration(SymbolTable* table, const char* name, 
                                DataType type, int line, int is_array);
void check_variable_usage(SymbolTable* table, const char* name, int line);
void check_function_declaration(SymbolTable* table, const char* name, 
                               DataType return_type, int param_count, 
                               DataType* param_types, int line);
void check_function_call(SymbolTable* table, const char* name, int arg_count, 
                        DataType* arg_types, int line);
void check_assignment(SymbolTable* table, const char* var_name, 
                     DataType expr_type, int line);
void check_binary_operation(DataType left_type, DataType right_type, 
                           const char* operator, int line);
void check_unary_operation(DataType operand_type, const char* operator, int line);
void check_array_access(SymbolTable* table, const char* array_name, 
                       DataType index_type, int line);
void check_return_statement(SymbolTable* table, DataType return_type, 
                           const char* func_name, int line);

/* Error reporting */
void semantic_error(const char* message, int line);
void semantic_warning(const char* message, int line);
void print_semantic_summary(SymbolTable* table);
void print_symbol_table(SymbolTable* table);

/* Utility functions */
int is_numeric_type(DataType type);
int is_integer_type(DataType type);
int is_float_type(DataType type);
DataType get_result_type(DataType type1, DataType type2, const char* operator);

#endif /* SEMANTIC_H */
