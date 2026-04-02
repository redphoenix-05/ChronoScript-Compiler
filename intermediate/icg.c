/*
 * ChronoScript Compiler - Intermediate Code Generator Implementation
 * Phase 4: Intermediate Code Generation (3-Address Code)
 */

#include "icg.h"

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
   MAIN TAC GENERATION STUB
   Note: These functions are stubs that would integrate with
   the actual AST structure from the parser
   ============================================================ */

TacCode* generate_intermediate_code(void* ast_root) {
    TacCode* code = create_tac_code();
    
    printf("\n========================================\n");
    printf("   INTERMEDIATE CODE GENERATION\n");
    printf("========================================\n");
    printf("Generating 3-address code...\n");
    
    /* This is a simplified stub. In a full implementation,
       this would traverse the actual AST structure */
    
    /* Example: Generate sample TAC for demonstration */
    TacInstruction* instr;
    
    /* Function start */
    instr = create_tac_instruction(TAC_FUNCTION_START, "main", NULL, NULL);
    append_tac_instruction(code, instr);
    
    /* Example arithmetic: t0 = a + b */
    char* t0 = new_temp(code);
    instr = create_tac_instruction(TAC_ADD, t0, "a", "b");
    append_tac_instruction(code, instr);
    
    /* Example assignment: x = t0 */
    instr = create_tac_instruction(TAC_ASSIGN, "x", t0, NULL);
    append_tac_instruction(code, instr);
    
    /* Example comparison: t1 = x < 10 */
    char* t1 = new_temp(code);
    instr = create_tac_instruction(TAC_LT, t1, "x", "10");
    append_tac_instruction(code, instr);
    
    /* Example conditional jump */
    char* label1 = new_label(code);
    instr = create_tac_instruction(TAC_IF_FALSE_GOTO, label1, t1, NULL);
    append_tac_instruction(code, instr);
    
    /* Print statement */
    instr = create_tac_instruction(TAC_PRINT, NULL, "x", NULL);
    append_tac_instruction(code, instr);
    
    /* Label */
    instr = create_tac_instruction(TAC_LABEL, label1, NULL, NULL);
    append_tac_instruction(code, instr);
    
    /* Function end */
    instr = create_tac_instruction(TAC_FUNCTION_END, "main", NULL, NULL);
    append_tac_instruction(code, instr);
    
    free(t0);
    free(t1);
    free(label1);
    
    printf("Intermediate code generation complete!\n");
    printf("========================================\n\n");
    
    return code;
}

/* Additional generation functions would be implemented here
   to handle the full AST traversal */
