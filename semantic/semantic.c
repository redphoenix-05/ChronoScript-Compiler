/*
 * ChronoScript Compiler - Semantic Analyzer Implementation
 * Phase 3: Semantic Analysis
 */

#include "semantic.h"

/* Global symbol table instance */
SymbolTable* global_symbol_table = NULL;

/* ============================================================
   SYMBOL TABLE MANAGEMENT
   ============================================================ */

SymbolTable* create_symbol_table() {
    SymbolTable* table = (SymbolTable*)malloc(sizeof(SymbolTable));
    if (!table) {
        fprintf(stderr, "Error: Memory allocation failed for symbol table\n");
        exit(1);
    }
    table->head = NULL;
    table->current_scope = 0;
    table->error_count = 0;
    table->warning_count = 0;
    return table;
}

void destroy_symbol_table(SymbolTable* table) {
    if (!table) return;
    
    SymbolEntry* current = table->head;
    while (current) {
        SymbolEntry* next = current->next;
        free(current->name);
        if (current->param_types) {
            free(current->param_types);
        }
        free(current);
        current = next;
    }
    free(table);
}

void enter_scope(SymbolTable* table) {
    if (table) {
        table->current_scope++;
    }
}

void exit_scope(SymbolTable* table) {
    if (!table) return;
    
    /* Remove all symbols from the current scope */
    SymbolEntry* current = table->head;
    SymbolEntry* prev = NULL;
    
    while (current) {
        if (current->scope_level == table->current_scope) {
            if (prev) {
                prev->next = current->next;
            } else {
                table->head = current->next;
            }
            
            SymbolEntry* to_delete = current;
            current = current->next;
            
            free(to_delete->name);
            if (to_delete->param_types) {
                free(to_delete->param_types);
            }
            free(to_delete);
        } else {
            prev = current;
            current = current->next;
        }
    }
    
    table->current_scope--;
}

/* ============================================================
   SYMBOL OPERATIONS
   ============================================================ */

SymbolEntry* insert_symbol(SymbolTable* table, const char* name, DataType type,
                          int line_number, int is_function, int is_array) {
    if (!table || !name) return NULL;
    
    /* Check for duplicate in current scope */
    SymbolEntry* existing = lookup_symbol_current_scope(table, name);
    if (existing) {
        char error_msg[256];
        sprintf(error_msg, "Redeclaration of '%s' (previously declared at line %d)",
                name, existing->line_number);
        semantic_error(error_msg, line_number);
        return NULL;
    }
    
    /* Create new symbol entry */
    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    if (!entry) {
        fprintf(stderr, "Error: Memory allocation failed for symbol entry\n");
        exit(1);
    }
    
    entry->name = strdup(name);
    entry->type = type;
    entry->scope_level = table->current_scope;
    entry->line_number = line_number;
    entry->is_function = is_function;
    entry->is_array = is_array;
    entry->array_size = 0;
    entry->param_count = 0;
    entry->param_types = NULL;
    entry->next = table->head;
    
    table->head = entry;
    
    return entry;
}

SymbolEntry* lookup_symbol(SymbolTable* table, const char* name) {
    if (!table || !name) return NULL;
    
    SymbolEntry* current = table->head;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

SymbolEntry* lookup_symbol_current_scope(SymbolTable* table, const char* name) {
    if (!table || !name) return NULL;
    
    SymbolEntry* current = table->head;
    while (current) {
        if (current->scope_level == table->current_scope &&
            strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

/* ============================================================
   TYPE CHECKING UTILITIES
   ============================================================ */

DataType get_type_from_string(const char* type_str) {
    if (!type_str) return TYPE_UNKNOWN;
    
    if (strcmp(type_str, "Void") == 0) return TYPE_VOID;
    if (strcmp(type_str, "Truth") == 0) return TYPE_TRUTH;
    if (strcmp(type_str, "Matter") == 0) return TYPE_MATTER;
    if (strcmp(type_str, "Atom") == 0) return TYPE_ATOM;
    if (strcmp(type_str, "Stream") == 0) return TYPE_STREAM;
    if (strcmp(type_str, "Energy") == 0) return TYPE_ENERGY;
    if (strcmp(type_str, "HighEnergy") == 0) return TYPE_HIGH_ENERGY;
    if (strcmp(type_str, "pureMatter") == 0) return TYPE_PURE_MATTER;
    if (strcmp(type_str, "largeMatter") == 0) return TYPE_LARGE_MATTER;
    if (strcmp(type_str, "fullEnergy") == 0) return TYPE_FULL_ENERGY;
    if (strcmp(type_str, "smallMatter") == 0) return TYPE_SMALL_MATTER;
    if (strcmp(type_str, "structure") == 0) return TYPE_STRUCTURE;
    if (strcmp(type_str, "Event") == 0) return TYPE_FUNCTION;
    
    return TYPE_UNKNOWN;
}

const char* get_type_name(DataType type) {
    switch (type) {
        case TYPE_VOID: return "Void";
        case TYPE_TRUTH: return "Truth";
        case TYPE_MATTER: return "Matter";
        case TYPE_ATOM: return "Atom";
        case TYPE_STREAM: return "Stream";
        case TYPE_ENERGY: return "Energy";
        case TYPE_HIGH_ENERGY: return "HighEnergy";
        case TYPE_PURE_MATTER: return "pureMatter";
        case TYPE_LARGE_MATTER: return "largeMatter";
        case TYPE_FULL_ENERGY: return "fullEnergy";
        case TYPE_SMALL_MATTER: return "smallMatter";
        case TYPE_STRUCTURE: return "structure";
        case TYPE_ARRAY: return "array";
        case TYPE_FUNCTION: return "function";
        case TYPE_ERROR: return "error";
        default: return "unknown";
    }
}

int is_numeric_type(DataType type) {
    return (type == TYPE_MATTER || type == TYPE_ENERGY || 
            type == TYPE_HIGH_ENERGY || type == TYPE_PURE_MATTER ||
            type == TYPE_LARGE_MATTER || type == TYPE_FULL_ENERGY ||
            type == TYPE_SMALL_MATTER);
}

int is_integer_type(DataType type) {
    return (type == TYPE_MATTER || type == TYPE_PURE_MATTER ||
            type == TYPE_LARGE_MATTER || type == TYPE_SMALL_MATTER);
}

int is_float_type(DataType type) {
    return (type == TYPE_ENERGY || type == TYPE_HIGH_ENERGY ||
            type == TYPE_FULL_ENERGY);
}

int are_types_compatible(DataType type1, DataType type2) {
    if (type1 == type2) return 1;
    
    /* Numeric types are compatible with each other */
    if (is_numeric_type(type1) && is_numeric_type(type2)) return 1;
    
    /* Truth can be used with integers */
    if ((type1 == TYPE_TRUTH && is_integer_type(type2)) ||
        (type2 == TYPE_TRUTH && is_integer_type(type1))) return 1;
    
    return 0;
}

int can_cast_type(DataType from, DataType to) {
    /* Same type - always allowed */
    if (from == to) return 1;
    
    /* Any numeric type can be cast to any other numeric type */
    if (is_numeric_type(from) && is_numeric_type(to)) return 1;
    
    /* Integer types can be cast to Truth */
    if (is_integer_type(from) && to == TYPE_TRUTH) return 1;
    if (from == TYPE_TRUTH && is_integer_type(to)) return 1;
    
    /* Atom can be cast to integer types */
    if (from == TYPE_ATOM && is_integer_type(to)) return 1;
    if (is_integer_type(from) && to == TYPE_ATOM) return 1;
    
    return 0;
}

DataType get_result_type(DataType type1, DataType type2, const char* operator) {
    /* If either is error, result is error */
    if (type1 == TYPE_ERROR || type2 == TYPE_ERROR) return TYPE_ERROR;
    
    /* Comparison operators always return Truth */
    if (strcmp(operator, "==") == 0 || strcmp(operator, "!=") == 0 ||
        strcmp(operator, "<") == 0 || strcmp(operator, ">") == 0 ||
        strcmp(operator, "<=") == 0 || strcmp(operator, ">=") == 0) {
        return TYPE_TRUTH;
    }
    
    /* Logical operators return Truth */
    if (strcmp(operator, "&&") == 0 || strcmp(operator, "||") == 0) {
        return TYPE_TRUTH;
    }
    
    /* If both are same type, return that type */
    if (type1 == type2) return type1;
    
    /* Float types take precedence */
    if (is_float_type(type1) || is_float_type(type2)) {
        if (type1 == TYPE_FULL_ENERGY || type2 == TYPE_FULL_ENERGY)
            return TYPE_FULL_ENERGY;
        if (type1 == TYPE_HIGH_ENERGY || type2 == TYPE_HIGH_ENERGY)
            return TYPE_HIGH_ENERGY;
        return TYPE_ENERGY;
    }
    
    /* Integer promotion */
    if (is_integer_type(type1) && is_integer_type(type2)) {
        if (type1 == TYPE_LARGE_MATTER || type2 == TYPE_LARGE_MATTER)
            return TYPE_LARGE_MATTER;
        return TYPE_MATTER;
    }
    
    return TYPE_ERROR;
}

/* ============================================================
   SEMANTIC CHECKING FUNCTIONS
   ============================================================ */

void check_variable_declaration(SymbolTable* table, const char* name,
                                DataType type, int line, int is_array) {
    if (!table || !name) return;
    
    /* Insert will check for duplicates */
    insert_symbol(table, name, type, line, 0, is_array);
}

void check_variable_usage(SymbolTable* table, const char* name, int line) {
    if (!table || !name) return;
    
    SymbolEntry* entry = lookup_symbol(table, name);
    if (!entry) {
        char error_msg[256];
        sprintf(error_msg, "Undeclared variable '%s'", name);
        semantic_error(error_msg, line);
    }
}

void check_function_declaration(SymbolTable* table, const char* name,
                               DataType return_type, int param_count,
                               DataType* param_types, int line) {
    if (!table || !name) return;
    
    SymbolEntry* entry = insert_symbol(table, name, return_type, line, 1, 0);
    if (entry) {
        entry->param_count = param_count;
        if (param_count > 0 && param_types) {
            entry->param_types = (DataType*)malloc(param_count * sizeof(DataType));
            memcpy(entry->param_types, param_types, param_count * sizeof(DataType));
        }
    }
}

void check_function_call(SymbolTable* table, const char* name, int arg_count,
                        DataType* arg_types, int line) {
    if (!table || !name) return;
    
    SymbolEntry* entry = lookup_symbol(table, name);
    if (!entry) {
        char error_msg[256];
        sprintf(error_msg, "Undeclared function '%s'", name);
        semantic_error(error_msg, line);
        return;
    }
    
    if (!entry->is_function) {
        char error_msg[256];
        sprintf(error_msg, "'%s' is not a function", name);
        semantic_error(error_msg, line);
        return;
    }
    
    if (entry->param_count != arg_count) {
        char error_msg[256];
        sprintf(error_msg, "Function '%s' expects %d arguments, but %d provided",
                name, entry->param_count, arg_count);
        semantic_error(error_msg, line);
        return;
    }
    
    /* Check parameter types */
    for (int i = 0; i < arg_count && i < entry->param_count; i++) {
        if (!are_types_compatible(arg_types[i], entry->param_types[i])) {
            char error_msg[256];
            sprintf(error_msg, "Argument %d of function '%s': incompatible type (expected %s, got %s)",
                    i + 1, name, get_type_name(entry->param_types[i]),
                    get_type_name(arg_types[i]));
            semantic_warning(error_msg, line);
        }
    }
}

void check_assignment(SymbolTable* table, const char* var_name,
                     DataType expr_type, int line) {
    if (!table || !var_name) return;
    
    SymbolEntry* entry = lookup_symbol(table, var_name);
    if (!entry) {
        char error_msg[256];
        sprintf(error_msg, "Undeclared variable '%s'", var_name);
        semantic_error(error_msg, line);
        return;
    }
    
    if (!are_types_compatible(entry->type, expr_type)) {
        char error_msg[256];
        sprintf(error_msg, "Type mismatch in assignment to '%s' (expected %s, got %s)",
                var_name, get_type_name(entry->type), get_type_name(expr_type));
        semantic_error(error_msg, line);
    }
}

void check_binary_operation(DataType left_type, DataType right_type,
                           const char* operator, int line) {
    if (!operator) return;
    
    /* Arithmetic operators require numeric types */
    if (strcmp(operator, "+") == 0 || strcmp(operator, "-") == 0 ||
        strcmp(operator, "*") == 0 || strcmp(operator, "/") == 0 ||
        strcmp(operator, "%") == 0) {
        if (!is_numeric_type(left_type) || !is_numeric_type(right_type)) {
            char error_msg[256];
            sprintf(error_msg, "Arithmetic operation '%s' requires numeric operands", operator);
            semantic_error(error_msg, line);
        }
    }
    
    /* Modulo requires integer types */
    if (strcmp(operator, "%") == 0) {
        if (!is_integer_type(left_type) || !is_integer_type(right_type)) {
            char error_msg[256];
            sprintf(error_msg, "Modulo operation requires integer operands");
            semantic_error(error_msg, line);
        }
    }
    
    /* Bitwise operators require integer types */
    if (strcmp(operator, "&") == 0 || strcmp(operator, "|") == 0 ||
        strcmp(operator, "^") == 0 || strcmp(operator, "<<") == 0 ||
        strcmp(operator, ">>") == 0) {
        if (!is_integer_type(left_type) || !is_integer_type(right_type)) {
            char error_msg[256];
            sprintf(error_msg, "Bitwise operation '%s' requires integer operands", operator);
            semantic_error(error_msg, line);
        }
    }
    
    /* Comparison operators require compatible types */
    if (strcmp(operator, "==") == 0 || strcmp(operator, "!=") == 0 ||
        strcmp(operator, "<") == 0 || strcmp(operator, ">") == 0 ||
        strcmp(operator, "<=") == 0 || strcmp(operator, ">=") == 0) {
        if (!are_types_compatible(left_type, right_type)) {
            char error_msg[256];
            sprintf(error_msg, "Comparison operation '%s' with incompatible types (%s and %s)",
                    operator, get_type_name(left_type), get_type_name(right_type));
            semantic_warning(error_msg, line);
        }
    }
}

void check_unary_operation(DataType operand_type, const char* operator, int line) {
    if (!operator) return;
    
    /* Logical NOT requires Truth or integer type */
    if (strcmp(operator, "!") == 0) {
        if (operand_type != TYPE_TRUTH && !is_integer_type(operand_type)) {
            semantic_warning("Logical NOT operation on non-boolean type", line);
        }
    }
    
    /* Unary minus/plus requires numeric type */
    if (strcmp(operator, "-") == 0 || strcmp(operator, "+") == 0) {
        if (!is_numeric_type(operand_type)) {
            char error_msg[256];
            sprintf(error_msg, "Unary '%s' operation requires numeric operand", operator);
            semantic_error(error_msg, line);
        }
    }
}

void check_array_access(SymbolTable* table, const char* array_name,
                       DataType index_type, int line) {
    if (!table || !array_name) return;
    
    SymbolEntry* entry = lookup_symbol(table, array_name);
    if (!entry) {
        char error_msg[256];
        sprintf(error_msg, "Undeclared array '%s'", array_name);
        semantic_error(error_msg, line);
        return;
    }
    
    if (!entry->is_array) {
        char error_msg[256];
        sprintf(error_msg, "'%s' is not an array", array_name);
        semantic_error(error_msg, line);
    }
    
    if (!is_integer_type(index_type)) {
        semantic_error("Array index must be an integer type", line);
    }
}

void check_return_statement(SymbolTable* table, DataType return_type,
                           const char* func_name, int line) {
    if (!table || !func_name) return;
    
    SymbolEntry* entry = lookup_symbol(table, func_name);
    if (!entry || !entry->is_function) {
        semantic_error("Return statement outside of function", line);
        return;
    }
    
    if (!are_types_compatible(entry->type, return_type)) {
        char error_msg[256];
        sprintf(error_msg, "Return type mismatch in function '%s' (expected %s, got %s)",
                func_name, get_type_name(entry->type), get_type_name(return_type));
        semantic_error(error_msg, line);
    }
}

/* ============================================================
   ERROR REPORTING
   ============================================================ */

void semantic_error(const char* message, int line) {
    fprintf(stderr, "Semantic Error [Line %d]: %s\n", line, message);
    if (global_symbol_table) {
        global_symbol_table->error_count++;
    }
}

void semantic_warning(const char* message, int line) {
    fprintf(stderr, "Semantic Warning [Line %d]: %s\n", line, message);
    if (global_symbol_table) {
        global_symbol_table->warning_count++;
    }
}

void print_semantic_summary(SymbolTable* table) {
    if (!table) return;
    
    printf("\n========================================\n");
    printf("     SEMANTIC ANALYSIS SUMMARY\n");
    printf("========================================\n");
    printf("Errors:   %d\n", table->error_count);
    printf("Warnings: %d\n", table->warning_count);
    
    if (table->error_count == 0) {
        printf("\n✓ Semantic analysis completed successfully!\n");
    } else {
        printf("\n✗ Semantic analysis failed with %d error(s)\n", table->error_count);
    }
    printf("========================================\n\n");
}

void print_symbol_table(SymbolTable* table) {
    if (!table) return;
    
    printf("\n========================================\n");
    printf("          SYMBOL TABLE\n");
    printf("========================================\n");
    printf("%-20s %-15s %-8s %-8s %-10s\n", 
           "Name", "Type", "Scope", "Line", "Kind");
    printf("------------------------------------------------------------------------\n");
    
    SymbolEntry* entry = table->head;
    while (entry) {
        printf("%-20s %-15s %-8d %-8d %-10s\n",
               entry->name,
               get_type_name(entry->type),
               entry->scope_level,
               entry->line_number,
               entry->is_function ? "Function" : (entry->is_array ? "Array" : "Variable"));
        entry = entry->next;
    }
    
    printf("========================================\n\n");
}
