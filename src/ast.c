#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/ast.h"

ASTNode *ast_root = NULL;

ASTNode *create_node(NodeType type, int line) {
    ASTNode *n = (ASTNode *)calloc(1, sizeof(ASTNode));
    if (!n) { fputs("OOM\n", stderr); exit(1); }
    n->type = type;
    n->line = line;
    return n;
}

ASTNode *create_binary_expr(char *op, ASTNode *left, ASTNode *right, int line) {
    ASTNode *n = create_node(NODE_BINARY_EXPR, line);
    n->op = strdup(op);
    n->child[0] = left;
    n->child[1] = right;
    return n;
}

ASTNode *create_unary_expr(char *op, ASTNode *expr, int line) {
    ASTNode *n = create_node(NODE_UNARY_EXPR, line);
    n->op = strdup(op);
    n->child[0] = expr;
    return n;
}

ASTNode *create_identifier(char *name, int line) {
    ASTNode *n = create_node(NODE_IDENTIFIER, line);
    n->value = strdup(name);
    return n;
}

ASTNode *create_int_literal(int value, int line) {
    ASTNode *n = create_node(NODE_INTEGER_LITERAL, line);
    n->intval = value;
    return n;
}

ASTNode *create_float_literal(double value, int line) {
    ASTNode *n = create_node(NODE_FLOAT_LITERAL, line);
    n->floatval = value;
    return n;
}

ASTNode *create_string_literal(char *value, int line) {
    ASTNode *n = create_node(NODE_STRING_LITERAL, line);
    n->value = strdup(value);
    return n;
}

static const char *node_type_name(NodeType t) {
    switch (t) {
        case NODE_PROGRAM:         return "PROGRAM";
        case NODE_DECL_LIST:       return "DECL_LIST";
        case NODE_VAR_DECL:        return "VAR_DECL";
        case NODE_FUNC_DECL:       return "FUNC_DECL";
        case NODE_PARAM_LIST:      return "PARAM_LIST";
        case NODE_PARAM:           return "PARAM";
        case NODE_STMT_LIST:       return "STMT_LIST";
        case NODE_COMPOUND_STMT:   return "COMPOUND_STMT";
        case NODE_IF_STMT:         return "IF_STMT";
        case NODE_WHILE_STMT:      return "WHILE_STMT";
        case NODE_FOR_STMT:        return "FOR_STMT";
        case NODE_RETURN_STMT:     return "RETURN_STMT";
        case NODE_BREAK_STMT:      return "BREAK_STMT";
        case NODE_CONTINUE_STMT:   return "CONTINUE_STMT";
        case NODE_PRINT_STMT:      return "PRINT_STMT";
        case NODE_INPUT_STMT:      return "INPUT_STMT";
        case NODE_EXPR_STMT:       return "EXPR_STMT";
        case NODE_BINARY_EXPR:     return "BINARY_EXPR";
        case NODE_UNARY_EXPR:      return "UNARY_EXPR";
        case NODE_CALL_EXPR:       return "CALL_EXPR";
        case NODE_ARRAY_ACCESS:    return "ARRAY_ACCESS";
        case NODE_IDENTIFIER:      return "IDENTIFIER";
        case NODE_INTEGER_LITERAL: return "INTEGER";
        case NODE_FLOAT_LITERAL:   return "FLOAT";
        case NODE_CHAR_LITERAL:    return "CHAR";
        case NODE_STRING_LITERAL:  return "STRING";
        case NODE_ARRAY_DECL:      return "ARRAY_DECL";
        case NODE_STRUCT_DECL:     return "STRUCT_DECL";
        case NODE_MEMBER_LIST:     return "MEMBER_LIST";
        case NODE_SWITCH_STMT:     return "SWITCH_STMT";
        default:                   return "UNKNOWN";
    }
}

void print_ast(ASTNode *n, int depth) {
    if (!n) return;
    for (int i = 0; i < depth; i++) printf("  ");
    printf("%s", node_type_name(n->type));
    if (n->value)    printf(" (%s)", n->value);
    if (n->op)       printf(" [%s]", n->op);
    if (n->data_type) printf(" <%s>", n->data_type);
    if (n->type == NODE_INTEGER_LITERAL) printf(" = %d", n->intval);
    if (n->type == NODE_FLOAT_LITERAL)   printf(" = %f", n->floatval);
    if (n->type == NODE_CHAR_LITERAL)    printf(" = '%c'", n->charval);
    printf("\n");
    for (int i = 0; i < 4; i++) print_ast(n->child[i], depth + 1);
    print_ast(n->sibling, depth);
}

void free_ast(ASTNode *n) {
    if (!n) return;
    for (int i = 0; i < 4; i++) free_ast(n->child[i]);
    free_ast(n->sibling);
    free(n->value); free(n->op); free(n->data_type);
    free(n);
}
