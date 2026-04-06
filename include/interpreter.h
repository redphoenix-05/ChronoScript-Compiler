#ifndef INTERPRETER_H
#define INTERPRETER_H

#include "ast.h"

typedef enum {
    RUNTIME_VOID,
    RUNTIME_INT,
    RUNTIME_FLOAT,
    RUNTIME_CHAR,
    RUNTIME_STRING
} RuntimeValueType;

typedef struct RuntimeValue {
    RuntimeValueType type;
    int    intval;
    double floatval;
    char   charval;
    char  *strval;
} RuntimeValue;

typedef struct RuntimeVariable {
    char                   *name;
    char                   *declared_type;
    RuntimeValue            value;
    struct RuntimeVariable *next;
} RuntimeVariable;

typedef struct RuntimeContext {
    RuntimeVariable *variables;
    int              has_return;
    int              has_break;
    int              has_continue;
    RuntimeValue     return_value;
} RuntimeContext;

int execute_program(ASTNode *root);

#endif /* INTERPRETER_H */
