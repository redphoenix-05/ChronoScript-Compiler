#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../include/ast.h"
#include "../include/symtab.h"
#include "../include/interpreter.h"
#include "../include/icg.h"
#include "../include/optimizer.h"
#include "../include/target_codegen.h"

#ifdef _WIN32
#  include <direct.h>
#  define CS_MKDIR(p) _mkdir(p)
#else
#  include <sys/stat.h>
#  define CS_MKDIR(p) mkdir((p), 0755)
#endif

extern int   yyparse(void);
extern FILE *yyin;

/* Derive a base name from the input file path.
   e.g.  "tests/test8_nested_loops.cscr"  ->  "test8_nested_loops.cscr"
   Result is written into buf (at most buf_size bytes, always NUL-terminated). */
static void derive_basename(const char *input_file, char *buf, size_t buf_size) {
    if (!input_file) {
        strncpy(buf, "stdin", buf_size - 1);
        buf[buf_size - 1] = '\0';
        return;
    }
    /* Find last path separator (/ or \ on Windows) */
    const char *slash = strrchr(input_file, '/');
    const char *bslash = strrchr(input_file, '\\');
    const char *base = input_file;
    if (slash  && slash  > base) base = slash  + 1;
    if (bslash && bslash > base) base = bslash + 1;
    strncpy(buf, base, buf_size - 1);
    buf[buf_size - 1] = '\0';
}

static void run_compiler_pipeline(ASTNode *root, const char *input_file) {
    CS_MKDIR("outputs");

    /* Derive per-file output names */
    char base[512];
    derive_basename(input_file, base, sizeof(base));

    char path_symtab[600], path_ic[600], path_opt[600],
         path_tgt[600],    path_obj[600];

    snprintf(path_symtab, sizeof(path_symtab), "outputs/%s.symtab.txt",  base);
    snprintf(path_ic,     sizeof(path_ic),     "outputs/%s.ic.txt",      base);
    snprintf(path_opt,    sizeof(path_opt),     "outputs/%s.opt.txt",     base);
    snprintf(path_tgt,    sizeof(path_tgt),     "outputs/%s.asm.txt",     base);
    snprintf(path_obj,    sizeof(path_obj),     "outputs/%s.o",           base);

    /* Save symbol table */
    save_symbol_table_to_file(path_symtab);
    printf("Symbol table  -> %s\n", path_symtab);

    /* Phase 3: ICG */
    printf("\n--- Intermediate Code Generation ---\n");
    TacCode *tac = generate_intermediate_code(root);
    if (!tac) return;
    print_tac_code(tac, stdout);
    save_tac_to_file(tac, path_ic);

    /* Phase 4: Optimization */
    printf("\n--- Code Optimization ---\n");
    OptimizationStats stats;
    memset(&stats, 0, sizeof(stats));
    TacCode *opt = optimize_code(tac, &stats);
    print_optimization_stats(&stats, stdout);
    if (!opt) { destroy_tac_code(tac); return; }
    save_tac_to_file(opt, path_opt);

    /* Phase 5: Target code */
    printf("\n--- Target Code Generation ---\n");
    TargetCode *tgt = generate_target_code(opt);
    if (tgt) {
        print_target_code(tgt, stdout);
        save_target_code(tgt, path_tgt);

        /* Phase 6: Write binary-style object file (.o)
           Format: magic header + raw pseudo-assembly text.
           The 4-byte magic "CSO\x01" identifies it as a ChronoScript object. */
        FILE *obj = fopen(path_obj, "wb");
        if (obj) {
            /* 8-byte header: magic (4) + instruction count (4) */
            unsigned char magic[4] = { 'C', 'S', 'O', 0x01 };
            unsigned int  ic = (unsigned int)tgt->instruction_count;
            fwrite(magic, 1, 4, obj);
            fwrite(&ic,   4, 1, obj);
            /* Payload: each instruction as a NUL-terminated text record */
            TargetInstruction *instr = tgt->head;
            while (instr) {
                /* opcode byte */
                unsigned char op = (unsigned char)instr->opcode;
                fwrite(&op, 1, 1, obj);
                /* operands as NUL-terminated strings */
                const char *o1 = instr->operand1 ? instr->operand1 : "";
                const char *o2 = instr->operand2 ? instr->operand2 : "";
                const char *o3 = instr->operand3 ? instr->operand3 : "";
                fwrite(o1, 1, strlen(o1) + 1, obj);
                fwrite(o2, 1, strlen(o2) + 1, obj);
                fwrite(o3, 1, strlen(o3) + 1, obj);
                instr = instr->next;
            }
            fclose(obj);
            printf("Object file   -> %s\n", path_obj);
        } else {
            fprintf(stderr, "Warning: could not write object file %s\n", path_obj);
        }

        destroy_target_code(tgt);
    }
    destroy_tac_code(opt);
}

int main(int argc, char **argv) {
    printf("ChronoScript Compiler\n");
    printf("=====================\n\n");

    int         show_ast      = 0;
    int         skip_pipeline = 0;
    const char *input_file    = NULL;

    for (int i = 1; i < argc; i++) {
        if      (strcmp(argv[i], "--ast") == 0)         show_ast      = 1;
        else if (strcmp(argv[i], "--no-pipeline") == 0) skip_pipeline = 1;
        else                                            input_file    = argv[i];
    }

    if (input_file) {
        FILE *f = fopen(input_file, "r");
        if (!f) { fprintf(stderr, "Error: Cannot open '%s'\n", input_file); return 1; }
        yyin = f;
        printf("Compiling: %s\n\n", input_file);
    } else {
        printf("Reading from stdin...\n\n");
        yyin = stdin;
    }

    int parse_result = yyparse();

    if (parse_result == 0 && error_count == 0) {
        printf("\n===========================================\n");
        printf("Compilation succeeded!\n");
        printf("===========================================\n\n");

        if (show_ast && ast_root) {
            printf("=== Abstract Syntax Tree ===\n");
            print_ast(ast_root, 0);
            printf("\n");
            print_symbol_table();
        }

        if (!skip_pipeline) run_compiler_pipeline(ast_root, input_file);
        if (ast_root) execute_program(ast_root);
        free_ast(ast_root);
    } else {
        printf("\n===========================================\n");
        printf("Compilation failed with %d error(s)\n", error_count);
        printf("===========================================\n");
    }

    if (input_file) fclose(yyin);
    return (error_count == 0) ? 0 : 1;
}
