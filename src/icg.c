/*
 * ChronoScript Compiler - Intermediate Code Generator Implementation
 * Phase 4: Intermediate Code Generation (3-Address Code)
 */

#include "../include/icg.h"

/* ============================================================
   TAC CODE MANAGEMENT
   ============================================================ */

TacCode* create_tac_code() {
    TacCode* code = (TacCode*)malloc(sizeof(TacCode));
    if (!code) {
        fprintf(stderr, "Error: Memory allocation failed for TAC code\n");
        exit(1);
    }
    code->head = NULL;
    code->tail = NULL;
    code->temp_count = 0;
    code->label_count = 0;
    return code;
}

void destroy_tac_code(TacCode* code) {
    if (!code) return;
    
    TacInstruction* current = code->head;
    while (current) {
        TacInstruction* next = current->next;
        if (current->result) free(current->result);
        if (current->arg1) free(current->arg1);
        if (current->arg2) free(current->arg2);
        free(current);
        current = next;
    }
    free(code);
}

TacInstruction* create_tac_instruction(TacOpcode opcode, const char* result,
                                       const char* arg1, const char* arg2) {
    TacInstruction* instr = (TacInstruction*)malloc(sizeof(TacInstruction));
    if (!instr) {
        fprintf(stderr, "Error: Memory allocation failed for TAC instruction\n");
        exit(1);
    }
    
    instr->opcode = opcode;
    instr->result = result ? strdup(result) : NULL;
    instr->arg1 = arg1 ? strdup(arg1) : NULL;
    instr->arg2 = arg2 ? strdup(arg2) : NULL;
    instr->next = NULL;
    
    return instr;
}

void append_tac_instruction(TacCode* code, TacInstruction* instr) {
    if (!code || !instr) return;
    
    if (!code->head) {
        code->head = instr;
        code->tail = instr;
    } else {
        code->tail->next = instr;
        code->tail = instr;
    }
}

void append_tac_code(TacCode* dest, TacCode* src) {
    if (!dest || !src) return;
    
    if (!src->head) return;
    
    if (!dest->head) {
        dest->head = src->head;
        dest->tail = src->tail;
    } else {
        dest->tail->next = src->head;
        dest->tail = src->tail;
    }
    
    /* Don't free src, just clear it */
    src->head = NULL;
    src->tail = NULL;
}

/* ============================================================
   TEMPORARY AND LABEL GENERATION
   ============================================================ */

char* new_temp(TacCode* code) {
    if (!code) return NULL;
    
    char* temp = (char*)malloc(16);
    sprintf(temp, "t%d", code->temp_count++);
    return temp;
}

char* new_label(TacCode* code) {
    if (!code) return NULL;
    
    char* label = (char*)malloc(16);
    sprintf(label, "L%d", code->label_count++);
    return label;
}

/* ============================================================
   OPCODE UTILITIES
   ============================================================ */

const char* get_opcode_string(TacOpcode opcode) {
    switch (opcode) {
        case TAC_ADD: return "+";
        case TAC_SUB: return "-";
        case TAC_MUL: return "*";
        case TAC_DIV: return "/";
        case TAC_MOD: return "%";
        case TAC_ASSIGN: return "=";
        case TAC_COPY: return "=";
        case TAC_UMINUS: return "-";
        case TAC_UPLUS: return "+";
        case TAC_NOT: return "!";
        case TAC_LT: return "<";
        case TAC_GT: return ">";
        case TAC_LE: return "<=";
        case TAC_GE: return ">=";
        case TAC_EQ: return "==";
        case TAC_NE: return "!=";
        case TAC_AND: return "&&";
        case TAC_OR: return "||";
        case TAC_BITAND: return "&";
        case TAC_BITOR: return "|";
        case TAC_BITXOR: return "^";
        case TAC_LSHIFT: return "<<";
        case TAC_RSHIFT: return ">>";
        case TAC_LABEL: return "label";
        case TAC_GOTO: return "goto";
        case TAC_IF_GOTO: return "if_goto";
        case TAC_IF_FALSE_GOTO: return "if_false_goto";
        case TAC_PARAM: return "param";
        case TAC_CALL: return "call";
        case TAC_RETURN: return "return";
        case TAC_RETURN_VOID: return "return";
        case TAC_ARRAY_READ: return "=[]";
        case TAC_ARRAY_WRITE: return "[]=";
        case TAC_FUNCTION_START: return "function";
        case TAC_FUNCTION_END: return "end_function";
        case TAC_PRINT: return "print";
        case TAC_READ: return "read";
        default: return "unknown";
    }
}

int is_binary_opcode(TacOpcode opcode) {
    return (opcode >= TAC_ADD && opcode <= TAC_RSHIFT);
}

int is_unary_opcode(TacOpcode opcode) {
    return (opcode >= TAC_UMINUS && opcode <= TAC_NOT);
}

int is_comparison_opcode(TacOpcode opcode) {
    return (opcode >= TAC_LT && opcode <= TAC_NE);
}

/* ============================================================
   TAC OUTPUT
   ============================================================ */

void print_tac_instruction(TacInstruction* instr, FILE* output) {
    if (!instr || !output) return;
    
    switch (instr->opcode) {
        case TAC_LABEL:
            fprintf(output, "%s:\n", instr->result);
            break;
            
        case TAC_GOTO:
            fprintf(output, "\tgoto %s\n", instr->result);
            break;
            
        case TAC_IF_GOTO:
            fprintf(output, "\tif %s goto %s\n", instr->arg1, instr->result);
            break;
            
        case TAC_IF_FALSE_GOTO:
            fprintf(output, "\tif !%s goto %s\n", instr->arg1, instr->result);
            break;
            
        case TAC_ASSIGN:
        case TAC_COPY:
            fprintf(output, "\t%s = %s\n", instr->result, instr->arg1);
            break;
            
        case TAC_UMINUS:
        case TAC_UPLUS:
        case TAC_NOT:
            fprintf(output, "\t%s = %s%s\n", instr->result, 
                    get_opcode_string(instr->opcode), instr->arg1);
            break;
            
        case TAC_ADD:
        case TAC_SUB:
        case TAC_MUL:
        case TAC_DIV:
        case TAC_MOD:
        case TAC_LT:
        case TAC_GT:
        case TAC_LE:
        case TAC_GE:
        case TAC_EQ:
        case TAC_NE:
        case TAC_AND:
        case TAC_OR:
        case TAC_BITAND:
        case TAC_BITOR:
        case TAC_BITXOR:
        case TAC_LSHIFT:
        case TAC_RSHIFT:
            fprintf(output, "\t%s = %s %s %s\n", instr->result, instr->arg1,
                    get_opcode_string(instr->opcode), instr->arg2);
            break;
            
        case TAC_PARAM:
            fprintf(output, "\tparam %s\n", instr->arg1);
            break;
            
        case TAC_CALL:
            if (instr->result) {
                fprintf(output, "\t%s = call %s, %s\n", instr->result, 
                        instr->arg1, instr->arg2);
            } else {
                fprintf(output, "\tcall %s, %s\n", instr->arg1, instr->arg2);
            }
            break;
            
        case TAC_RETURN:
            fprintf(output, "\treturn %s\n", instr->arg1);
            break;
            
        case TAC_RETURN_VOID:
            fprintf(output, "\treturn\n");
            break;
            
        case TAC_ARRAY_READ:
            fprintf(output, "\t%s = %s[%s]\n", instr->result, instr->arg1, instr->arg2);
            break;
            
        case TAC_ARRAY_WRITE:
            fprintf(output, "\t%s[%s] = %s\n", instr->result, instr->arg1, instr->arg2);
            break;
            
        case TAC_FUNCTION_START:
            fprintf(output, "\nfunction %s:\n", instr->result);
            break;
            
        case TAC_FUNCTION_END:
            fprintf(output, "end_function %s\n\n", instr->result);
            break;
            
        case TAC_PRINT:
            fprintf(output, "\tprint %s\n", instr->arg1);
            break;
            
        case TAC_READ:
            fprintf(output, "\tread %s\n", instr->arg1);
            break;
            
        default:
            fprintf(output, "\tunknown instruction\n");
            break;
    }
}

void print_tac_code(TacCode* code, FILE* output) {
    if (!code || !output) return;
    
    fprintf(output, "========================================\n");
    fprintf(output, "    INTERMEDIATE CODE (3-Address Code)\n");
    fprintf(output, "========================================\n\n");
    
    TacInstruction* instr = code->head;
    while (instr) {
        print_tac_instruction(instr, output);
        instr = instr->next;
    }
    
    fprintf(output, "\n========================================\n");
    fprintf(output, "Total temporaries: %d\n", code->temp_count);
    fprintf(output, "Total labels: %d\n", code->label_count);
    fprintf(output, "========================================\n");
}

void save_tac_to_file(TacCode* code, const char* filename) {
    if (!code || !filename) return;
    
    FILE* file = fopen(filename, "w");
    if (!file) {
        fprintf(stderr, "Error: Cannot open file '%s' for writing\n", filename);
        return;
    }
    
    print_tac_code(code, file);
    fclose(file);
    
    printf("Intermediate code saved to: %s\n", filename);
}

/* ============================================================
   TAC GENERATION HELPER FUNCTIONS
   ============================================================ */

TacOpcode get_tac_opcode_from_operator(const char* operator) {
    if (!operator) return TAC_ASSIGN;
    
    if (strcmp(operator, "+") == 0) return TAC_ADD;
    if (strcmp(operator, "-") == 0) return TAC_SUB;
    if (strcmp(operator, "*") == 0) return TAC_MUL;
    if (strcmp(operator, "/") == 0) return TAC_DIV;
    if (strcmp(operator, "%") == 0) return TAC_MOD;
    if (strcmp(operator, "<") == 0) return TAC_LT;
    if (strcmp(operator, ">") == 0) return TAC_GT;
    if (strcmp(operator, "<=") == 0) return TAC_LE;
    if (strcmp(operator, ">=") == 0) return TAC_GE;
    if (strcmp(operator, "==") == 0) return TAC_EQ;
    if (strcmp(operator, "!=") == 0) return TAC_NE;
    if (strcmp(operator, "&&") == 0) return TAC_AND;
    if (strcmp(operator, "||") == 0) return TAC_OR;
    if (strcmp(operator, "&") == 0) return TAC_BITAND;
    if (strcmp(operator, "|") == 0) return TAC_BITOR;
    if (strcmp(operator, "^") == 0) return TAC_BITXOR;
    if (strcmp(operator, "<<") == 0) return TAC_LSHIFT;
    if (strcmp(operator, ">>") == 0) return TAC_RSHIFT;
    if (strcmp(operator, "!") == 0) return TAC_NOT;
    
    return TAC_ASSIGN;
}

/* ============================================================
   REAL AST TRAVERSAL - ICG
   Walks the ASTNode tree produced by the parser and emits TAC.
   ============================================================ */

/* Labels used by the current loop for break/continue */
static char *icg_break_label    = NULL;
static char *icg_continue_label = NULL;

/* Forward declarations of static helpers */
static char *icg_gen_expr(ASTNode *node, TacCode *code);
static void  icg_gen_stmt(ASTNode *node, TacCode *code);
static void  icg_gen_compound(ASTNode *node, TacCode *code);
static void  icg_gen_stmt_list(ASTNode *node, TacCode *code);
static void  icg_gen_decl_list(ASTNode *node, TacCode *code);

/* ------------------------------------------------------------------
   Expression code generation
   Returns a heap-allocated string naming the result operand.
   Caller must free it.
   ------------------------------------------------------------------ */
static char *icg_gen_expr(ASTNode *node, TacCode *code) {
    if (!node) return strdup("_void");

    char buf[128];

    switch (node->type) {

    case NODE_INTEGER_LITERAL:
        snprintf(buf, sizeof(buf), "%d", node->intval);
        return strdup(buf);

    case NODE_FLOAT_LITERAL:
        snprintf(buf, sizeof(buf), "%g", node->floatval);
        return strdup(buf);

    case NODE_CHAR_LITERAL:
        snprintf(buf, sizeof(buf), "'%c'", node->charval);
        return strdup(buf);

    case NODE_STRING_LITERAL: {
        char *res = (char *)malloc(strlen(node->value) + 3);
        sprintf(res, "\"%s\"", node->value);
        return res;
    }

    case NODE_IDENTIFIER:
        return strdup(node->value ? node->value : "_anon");

    case NODE_ARRAY_ACCESS: {
        char *arr = icg_gen_expr(node->child[0], code);
        char *idx = icg_gen_expr(node->child[1], code);
        char *tmp = new_temp(code);
        append_tac_instruction(code,
            create_tac_instruction(TAC_ARRAY_READ, tmp, arr, idx));
        free(arr); free(idx);
        return tmp;
    }

    case NODE_UNARY_EXPR: {
        char *operand = icg_gen_expr(node->child[0], code);
        char *tmp = new_temp(code);
        TacOpcode op = TAC_UMINUS;
        if (node->op) {
            if (strcmp(node->op, "!") == 0) op = TAC_NOT;
            else if (strcmp(node->op, "+") == 0) op = TAC_UPLUS;
        }
        append_tac_instruction(code,
            create_tac_instruction(op, tmp, operand, NULL));
        free(operand);
        return tmp;
    }

    case NODE_BINARY_EXPR: {
        if (!node->op) return strdup("_void");

        /* Simple assignment: lhs = rhs */
        if (strcmp(node->op, "=") == 0) {
            char *rhs = icg_gen_expr(node->child[1], code);
            if (node->child[0] && node->child[0]->type == NODE_IDENTIFIER) {
                append_tac_instruction(code,
                    create_tac_instruction(TAC_ASSIGN,
                        node->child[0]->value, rhs, NULL));
                char *ret = strdup(node->child[0]->value);
                free(rhs);
                return ret;
            }
            if (node->child[0] &&
                node->child[0]->type == NODE_ARRAY_ACCESS) {
                char *arr = icg_gen_expr(node->child[0]->child[0], code);
                char *idx = icg_gen_expr(node->child[0]->child[1], code);
                append_tac_instruction(code,
                    create_tac_instruction(TAC_ARRAY_WRITE, arr, idx, rhs));
                char *ret = strdup(rhs);
                free(arr); free(idx); free(rhs);
                return ret;
            }
            return rhs;
        }

        /* Compound assignment: lhs op= rhs */
        if (node->op[1] == '=' && node->op[2] == '\0' &&
            node->child[0] &&
            node->child[0]->type == NODE_IDENTIFIER) {
            const char *lhs_name = node->child[0]->value;
            char *rhs = icg_gen_expr(node->child[1], code);
            char *tmp = new_temp(code);
            char op_char[2] = { node->op[0], '\0' };
            TacOpcode tac_op = get_tac_opcode_from_operator(op_char);
            append_tac_instruction(code,
                create_tac_instruction(tac_op, tmp, lhs_name, rhs));
            append_tac_instruction(code,
                create_tac_instruction(TAC_ASSIGN, lhs_name, tmp, NULL));
            free(rhs); free(tmp);
            return strdup(lhs_name);
        }

        /* Arithmetic / relational / logical / bitwise */
        char *left  = icg_gen_expr(node->child[0], code);
        char *right = icg_gen_expr(node->child[1], code);
        char *tmp   = new_temp(code);
        TacOpcode tac_op = get_tac_opcode_from_operator(node->op);
        append_tac_instruction(code,
            create_tac_instruction(tac_op, tmp, left, right));
        free(left); free(right);
        return tmp;
    }

    case NODE_CALL_EXPR: {
        if (!node->child[0]) return strdup("_void");
        const char *fname = node->child[0]->value;
        if (!fname) return strdup("_void");

        /* Evaluate arguments and collect names */
#define MAX_ARGS 32
        char *arg_names[MAX_ARGS];
        int argc = 0;
        ASTNode *arg = node->child[1];
        while (arg && argc < MAX_ARGS) {
            arg_names[argc++] = icg_gen_expr(arg, code);
            arg = arg->sibling;
        }
        /* Emit PARAMs */
        for (int i = 0; i < argc; i++) {
            append_tac_instruction(code,
                create_tac_instruction(TAC_PARAM, NULL, arg_names[i], NULL));
            free(arg_names[i]);
        }
#undef MAX_ARGS
        char argc_buf[16];
        snprintf(argc_buf, sizeof(argc_buf), "%d", argc);
        char *tmp = new_temp(code);
        append_tac_instruction(code,
            create_tac_instruction(TAC_CALL, tmp, fname, argc_buf));
        return tmp;
    }

    default:
        return strdup("_unk");
    }
}

/* ------------------------------------------------------------------
   Statement code generation
   ------------------------------------------------------------------ */
static void icg_gen_stmt(ASTNode *node, TacCode *code) {
    if (!node) return;

    switch (node->type) {

    case NODE_EXPR_STMT:
        if (node->child[0]) {
            char *v = icg_gen_expr(node->child[0], code);
            free(v);
        }
        break;

    case NODE_PRINT_STMT: {
        char *val = icg_gen_expr(node->child[0], code);
        append_tac_instruction(code,
            create_tac_instruction(TAC_PRINT, NULL, val, NULL));
        free(val);
        break;
    }

    case NODE_INPUT_STMT: {
        const char *name =
            (node->child[0] && node->child[0]->value)
            ? node->child[0]->value : "_anon";
        append_tac_instruction(code,
            create_tac_instruction(TAC_READ, NULL, name, NULL));
        break;
    }

    case NODE_IF_STMT: {
        char *cond      = icg_gen_expr(node->child[0], code);
        char *false_lbl = new_label(code);
        char *end_lbl   = node->child[2] ? new_label(code) : NULL;

        append_tac_instruction(code,
            create_tac_instruction(TAC_IF_FALSE_GOTO, false_lbl, cond, NULL));
        free(cond);

        icg_gen_stmt(node->child[1], code);  /* then */

        if (node->child[2]) {
            append_tac_instruction(code,
                create_tac_instruction(TAC_GOTO, end_lbl, NULL, NULL));
        }
        append_tac_instruction(code,
            create_tac_instruction(TAC_LABEL, false_lbl, NULL, NULL));

        if (node->child[2]) {
            icg_gen_stmt(node->child[2], code);  /* else */
            append_tac_instruction(code,
                create_tac_instruction(TAC_LABEL, end_lbl, NULL, NULL));
            free(end_lbl);
        }
        free(false_lbl);
        break;
    }

    case NODE_WHILE_STMT: {
        char *start_lbl = new_label(code);
        char *exit_lbl  = new_label(code);
        char *saved_break    = icg_break_label;
        char *saved_continue = icg_continue_label;
        icg_break_label      = exit_lbl;
        icg_continue_label   = start_lbl;

        append_tac_instruction(code,
            create_tac_instruction(TAC_LABEL, start_lbl, NULL, NULL));

        char *cond = icg_gen_expr(node->child[0], code);
        append_tac_instruction(code,
            create_tac_instruction(TAC_IF_FALSE_GOTO, exit_lbl, cond, NULL));
        free(cond);

        icg_gen_stmt(node->child[1], code);

        append_tac_instruction(code,
            create_tac_instruction(TAC_GOTO, start_lbl, NULL, NULL));
        append_tac_instruction(code,
            create_tac_instruction(TAC_LABEL, exit_lbl, NULL, NULL));

        icg_break_label    = saved_break;
        icg_continue_label = saved_continue;
        free(start_lbl);
        free(exit_lbl);
        break;
    }

    case NODE_FOR_STMT: {
        char *cond_lbl = new_label(code);
        char *incr_lbl = new_label(code);
        char *exit_lbl = new_label(code);
        char *saved_break    = icg_break_label;
        char *saved_continue = icg_continue_label;
        icg_break_label      = exit_lbl;
        icg_continue_label   = incr_lbl;

        /* init */
        if (node->child[0]) {
            if (node->child[0]->type == NODE_VAR_DECL ||
                node->child[0]->type == NODE_ARRAY_DECL)
                icg_gen_decl_list(node->child[0], code);
            else
                icg_gen_stmt(node->child[0], code);
        }

        append_tac_instruction(code,
            create_tac_instruction(TAC_LABEL, cond_lbl, NULL, NULL));

        /* condition */
        if (node->child[1] && node->child[1]->child[0]) {
            char *cond = icg_gen_expr(node->child[1]->child[0], code);
            append_tac_instruction(code,
                create_tac_instruction(TAC_IF_FALSE_GOTO, exit_lbl, cond, NULL));
            free(cond);
        }

        /* body */
        icg_gen_stmt(node->child[3], code);

        /* increment label + expression */
        append_tac_instruction(code,
            create_tac_instruction(TAC_LABEL, incr_lbl, NULL, NULL));
        if (node->child[2]) {
            char *inc = icg_gen_expr(node->child[2], code);
            free(inc);
        }

        append_tac_instruction(code,
            create_tac_instruction(TAC_GOTO, cond_lbl, NULL, NULL));
        append_tac_instruction(code,
            create_tac_instruction(TAC_LABEL, exit_lbl, NULL, NULL));

        icg_break_label    = saved_break;
        icg_continue_label = saved_continue;
        free(cond_lbl); free(incr_lbl); free(exit_lbl);
        break;
    }

    case NODE_RETURN_STMT: {
        if (node->child[0]) {
            char *val = icg_gen_expr(node->child[0], code);
            append_tac_instruction(code,
                create_tac_instruction(TAC_RETURN, NULL, val, NULL));
            free(val);
        } else {
            append_tac_instruction(code,
                create_tac_instruction(TAC_RETURN_VOID, NULL, NULL, NULL));
        }
        break;
    }

    case NODE_BREAK_STMT:
        if (icg_break_label)
            append_tac_instruction(code,
                create_tac_instruction(TAC_GOTO, icg_break_label, NULL, NULL));
        break;

    case NODE_CONTINUE_STMT:
        if (icg_continue_label)
            append_tac_instruction(code,
                create_tac_instruction(TAC_GOTO, icg_continue_label, NULL, NULL));
        break;

    case NODE_COMPOUND_STMT:
        icg_gen_compound(node, code);
        break;

    default:
        break;
    }
}

static void icg_gen_stmt_list(ASTNode *node, TacCode *code) {
    while (node) {
        ASTNode *cur = (node->type == NODE_STMT_LIST) ? node->child[0] : node;
        icg_gen_stmt(cur, code);
        node = node->sibling;
    }
}

static void icg_gen_decl_list(ASTNode *node, TacCode *code) {
    while (node) {
        ASTNode *cur = (node->type == NODE_DECL_LIST) ? node->child[0] : node;
        if (cur && cur->type == NODE_VAR_DECL && cur->value && cur->child[1]) {
            char *init = icg_gen_expr(cur->child[1], code);
            append_tac_instruction(code,
                create_tac_instruction(TAC_ASSIGN, cur->value, init, NULL));
            free(init);
        }
        node = node->sibling;
    }
}

static void icg_gen_compound(ASTNode *node, TacCode *code) {
    if (!node) return;
    if (node->child[0] && node->child[0]->type == NODE_DECL_LIST) {
        icg_gen_decl_list(node->child[0], code);
        if (node->child[1] && node->child[1]->type == NODE_STMT_LIST)
            icg_gen_stmt_list(node->child[1], code);
    } else if (node->child[0] && node->child[0]->type == NODE_STMT_LIST) {
        icg_gen_stmt_list(node->child[0], code);
    }
}

/* ------------------------------------------------------------------
   Main entry point: walk the whole AST
   ------------------------------------------------------------------ */
TacCode* generate_intermediate_code(ASTNode* ast_root) {
    TacCode *code = create_tac_code();

    printf("Generating intermediate (3-address) code...\n");

    if (!ast_root || !ast_root->child[0]) {
        printf("(empty program)\n");
        return code;
    }

    icg_break_label    = NULL;
    icg_continue_label = NULL;

    ASTNode *decl = ast_root->child[0];
    while (decl) {
        ASTNode *cur = (decl->type == NODE_DECL_LIST) ? decl->child[0] : decl;

        if (cur && cur->type == NODE_FUNC_DECL && cur->value) {
            /* Function prolog */
            append_tac_instruction(code,
                create_tac_instruction(TAC_FUNCTION_START,
                                       cur->value, NULL, NULL));

            /* Declare parameters */
            ASTNode *pn = cur->child[1];
            while (pn) {
                ASTNode *param =
                    (pn->type == NODE_PARAM_LIST) ? pn->child[0] : pn;
                if (param && param->value)
                    append_tac_instruction(code,
                        create_tac_instruction(TAC_PARAM,
                                               param->value, NULL, NULL));
                pn = pn->sibling;
            }

            /* Function body */
            icg_gen_compound(cur->child[2], code);

            /* Function epilog */
            append_tac_instruction(code,
                create_tac_instruction(TAC_FUNCTION_END,
                                       cur->value, NULL, NULL));

        } else if (cur && cur->type == NODE_VAR_DECL &&
                   cur->value && cur->child[1]) {
            /* Top-level initialized global variable */
            char *init = icg_gen_expr(cur->child[1], code);
            append_tac_instruction(code,
                create_tac_instruction(TAC_ASSIGN, cur->value, init, NULL));
            free(init);
        }
        decl = decl->sibling;
    }

    printf("Intermediate code generation complete!\n");
    return code;
}
