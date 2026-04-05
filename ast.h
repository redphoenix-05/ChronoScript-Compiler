/*
 * ast.h - Shared AST type definitions for the ChronoScript Compiler
 *
 * Included by: parser/chronoscript.y (via generated chronoscript.tab.c)
 *              intermediate/icg.c
 *              intermediate/icg.h
 *
 * This header must be found in the project root directory when compiling
 * from the root (use -I. flag or rely on default directory search).
 */

#ifndef AST_H
#define AST_H

/* -----------------------------------------------------------------------
   Node type enumeration
   ----------------------------------------------------------------------- */
typedef enum {
    NODE_PROGRAM,
    NODE_DECL_LIST,
    NODE_VAR_DECL,
    NODE_FUNC_DECL,
    NODE_PARAM_LIST,
    NODE_PARAM,
    NODE_STMT_LIST,
    NODE_COMPOUND_STMT,
    NODE_IF_STMT,
    NODE_WHILE_STMT,
    NODE_FOR_STMT,
    NODE_RETURN_STMT,
    NODE_BREAK_STMT,
    NODE_CONTINUE_STMT,
    NODE_PRINT_STMT,
    NODE_INPUT_STMT,
    NODE_EXPR_STMT,
    NODE_ASSIGN_STMT,       /* kept for backward compat but unused by grammar */
    NODE_BINARY_EXPR,
    NODE_UNARY_EXPR,
    NODE_CALL_EXPR,
    NODE_ARRAY_ACCESS,
    NODE_IDENTIFIER,
    NODE_INTEGER_LITERAL,
    NODE_FLOAT_LITERAL,
    NODE_CHAR_LITERAL,
    NODE_STRING_LITERAL,
    NODE_ARRAY_DECL,
    NODE_STRUCT_DECL,
    NODE_MEMBER_LIST,
    NODE_SWITCH_STMT        /* reforge(expr){ standard v: ...; perspective: ...; } */
} NodeType;

/* -----------------------------------------------------------------------
   AST node structure
   ----------------------------------------------------------------------- */
typedef struct ASTNode {
    NodeType  type;
    int       line;
    char     *value;          /* identifier/string names */
    char      charval;        /* char literal value */
    int       intval;         /* integer literal / array size */
    double    floatval;       /* float literal */
    struct ASTNode *child[4]; /* up to 4 children */
    struct ASTNode *sibling;  /* linked list of siblings */
    char     *data_type;      /* variable / function return type */
    char     *op;             /* operator string for expression nodes */
} ASTNode;

#endif /* AST_H */
